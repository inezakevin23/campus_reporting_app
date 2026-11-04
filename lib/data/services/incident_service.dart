import 'dart:typed_data';

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
}
