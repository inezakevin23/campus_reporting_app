import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class StorageService {
  final SupabaseClient _supabase;
  final FirebaseAuth _auth;

  static const String bucketName = 'incident-photos';
  static const int maxFileSize = 5 * 1024 * 1024;

  StorageService({required this._supabase, required this._auth});

  // Verify that the Firebase account has the
  // custom claim required by Supabase.
  Future<User> _getAuthorizedUser() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('You must be logged in to upload photographs.');
    }

    final tokenResult = await user.getIdTokenResult(true);

    if (tokenResult.claims?['role'] != 'authenticated') {
      throw StateError(
        'Your account is not configured for Supabase Storage. '
        'Please contact the administrator.',
      );
    }

    return user;
  }

  // Upload an incident photograph.
  Future<String> uploadIncidentImage({
    required String incidentId,
    required Uint8List bytes,
    required String extension,
    required String contentType,
  }) async {
    final user = await _getAuthorizedUser();

    if (bytes.isEmpty) {
      throw ArgumentError('The selected image is empty.');
    }

    if (bytes.length > maxFileSize) {
      throw ArgumentError('The image must not exceed 5 MB.');
    }

    const allowedTypes = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'webp': 'image/webp',
    };

    final normalizedExtension = extension.toLowerCase();
    final normalizedContentType = contentType.toLowerCase();

    if (allowedTypes[normalizedExtension] != normalizedContentType) {
      throw ArgumentError('Unsupported image format.');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final filePath =
        '${user.uid}/$incidentId/photo_$timestamp.$normalizedExtension';

    await _supabase.storage
        .from(bucketName)
        .uploadBinary(
          filePath,
          bytes,
          fileOptions: FileOptions(
            contentType: normalizedContentType,
            upsert: false,
          ),
        );

    return filePath;
  }

  // Generate a temporary URL for displaying a private image.
  Future<String> getSignedImageUrl(String imagePath) async {
    await _getAuthorizedUser();

    return await _supabase.storage
        .from(bucketName)
        .createSignedUrl(imagePath, 3600);
  }

  // Delete an uploaded image.
  Future<void> deleteIncidentImage(String imagePath) async {
    await _getAuthorizedUser();

    await _supabase.storage.from(bucketName).remove([imagePath]);
  }
}
