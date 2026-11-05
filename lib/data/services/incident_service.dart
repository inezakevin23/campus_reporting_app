import 'dart:typed_data';

import '../models/incident_model.dart';
import '../models/incident_status_update_model.dart';

import 'package:campus_reporting_app/data/services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IncidentService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final StorageService _storage;

  IncidentService({
    required this._firestore,
    required this._auth,
    required this._storage,
  });

  Future<String> createIncident({
    required String title,
    required String description,
    required String category,
    required String location,
    required String priority,
    Uint8List? imageBytes,
    String? imageExtension,
    String? contentType,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('You must log in before submitting an incident.');
    }

    if (title.trim().isEmpty ||
        description.trim().isEmpty ||
        location.trim().isEmpty) {
      throw ArgumentError('Title, description and location are required.');
    }

    final incidentRef = _firestore.collection('incidents').doc();

    String? uploadedImagePath;

    try {
      //  Upload the optional image to Supabase.
      if (imageBytes != null) {
        if (imageExtension == null || contentType == null) {
          throw ArgumentError('Image format information is missing.');
        }

        uploadedImagePath = await _storage.uploadIncidentImage(
          incidentId: incidentRef.id,
          bytes: imageBytes,
          extension: imageExtension,
          contentType: contentType,
        );
      }
      final historyRef = incidentRef.collection('statusHistory').doc();
      // Prepare one atomic Firestore batch.
      final batch = _firestore.batch();

      // Create the incident document.
      batch.set(incidentRef, {
        'title': title.trim(),
        'description': description.trim(),
        'category': category,
        'location': location.trim(),
        'priority': priority,
        'status': 'submitted',
        'reporterId': user.uid,
        'imagePath': uploadedImagePath,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastStatusUpdateId': historyRef.id,
      });

      batch.set(historyRef, {
        'status': 'submitted',
        'note': 'Incident submitted.',
        'changedByUid': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Save both documents together.
      await batch.commit();

      return incidentRef.id;
    } catch (error) {
      // The public upload policy does not allow anonymous users to delete
      // uploaded files. An image can remain in Storage if the subsequent
      // Firestore write fails; such orphaned images can be cleaned up
      // administratively.
      rethrow;
    }
  }
  // Listen to all campus incidents.

  Stream<List<Incident>> watchCampusIncidents() {
    return _firestore
        .collection('incidents')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Incident.fromMap(doc.id, doc.data());
          }).toList();
        });
  }
  // Listen to reports belonging to a specific student.

  Stream<List<Incident>> watchMyReports(String uid) {
    return _firestore
        .collection('incidents')
        .where('reporterId', isEqualTo: uid)
        .limit(100)
        .snapshots()
        .map((snapshot) {
          final incidents = snapshot.docs.map((doc) {
            return Incident.fromMap(doc.id, doc.data());
          }).toList();

          // Sort the reports by submission date.
          incidents.sort((a, b) {
            final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

            final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

            return dateB.compareTo(dateA);
          });

          return incidents;
        });
  }
  // Listen to one specific incident.

  Stream<Incident?> watchIncident(String incidentId) {
    return _firestore.collection('incidents').doc(incidentId).snapshots().map((
      document,
    ) {
      if (!document.exists) {
        return null;
      }

      return Incident.fromMap(document.id, document.data()!);
    });
  }
  // Listen to the status history of an incident.

  Stream<List<IncidentStatusUpdate>> watchStatusHistory(String incidentId) {
    return _firestore
        .collection('incidents')
        .doc(incidentId)
        .collection('statusHistory')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return IncidentStatusUpdate.fromMap(doc.id, doc.data());
          }).toList();
        });
  }
  // --------------------------------------------------
  // UPDATE INCIDENT STATUS
  // --------------------------------------------------

  Future<void> updateIncidentStatus({
    required String incidentId,
    required String newStatus,
    required String note,
  }) async {
    // 1. Get the authenticated user.
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('You must log in before updating an incident.');
    }

    // 2. Validate the staff role.
    final userDocument = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDocument.exists || userDocument.data()?['role'] != 'staff') {
      throw StateError('Only authorized campus staff can update incidents.');
    }

    // 3. Validate the note.
    final trimmedNote = note.trim();

    if (trimmedNote.length < 5) {
      throw ArgumentError('Please provide a meaningful update note.');
    }

    if (trimmedNote.length > 500) {
      throw ArgumentError('The update note cannot exceed 500 characters.');
    }

    // 4. Get the incident document.
    final incidentRef = _firestore.collection('incidents').doc(incidentId);

    final incidentDocument = await incidentRef.get();

    if (!incidentDocument.exists) {
      throw StateError('Incident not found.');
    }

    final currentStatus = incidentDocument.data()?['status'] as String?;

    // 5. Determine the allowed next status.
    final String? expectedNextStatus = switch (currentStatus) {
      'submitted' => 'in_progress',
      'in_progress' => 'resolved',
      _ => null,
    };

    if (expectedNextStatus == null) {
      throw StateError('This incident cannot receive further status updates.');
    }

    if (newStatus != expectedNextStatus) {
      throw StateError(
        'Invalid status transition. '
        'The next status should be $expectedNextStatus.',
      );
    }

    // 6. Create a new status-history document reference.
    final historyRef = incidentRef.collection('statusHistory').doc();

    // 7. Create an atomic Firestore batch.
    final batch = _firestore.batch();

    // Update the current incident.
    batch.update(incidentRef, {
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
      'lastStatusUpdateId': historyRef.id,
    });

    // Record the staff update.
    batch.set(historyRef, {
      'status': newStatus,
      'note': trimmedNote,
      'changedByUid': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 8. Commit both operations together.
    await batch.commit();
  }
}
