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
      // 1. Upload the optional image to Supabase.
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

      // 2. Prepare one atomic Firestore batch.
      final batch = _firestore.batch();

      // 3. Create the incident document.
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
      });

      // 4. Create the initial status-history document.
      final historyRef = incidentRef.collection('statusHistory').doc();

      batch.set(historyRef, {
        'status': 'submitted',
        'note': 'Incident submitted.',
        'changedByUid': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 5. Save both documents together.
      await batch.commit();

      return incidentRef.id;
    } catch (error) {
      // Remove an uploaded image if the Firestore write fails.
      if (uploadedImagePath != null) {
        try {
          await _storage.deleteIncidentImage(uploadedImagePath);
        } catch (_) {
          // Preserve the original submission error.
        }
      }

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
}
