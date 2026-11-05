import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase;

  static const String bucketName = 'incident_photos';
  static const int maxFileSize = 5 * 1024 * 1024;

  StorageService({required this._supabase});

  // Upload an incident photograph.
  Future<String> uploadIncidentImage({
    required String incidentId,
    required Uint8List bytes,
    required String extension,
    required String contentType,
  }) async {
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
        'incidents/$incidentId/photo_$timestamp.$normalizedExtension';

    // await _supabase.storage
    //     .from(bucketName)
    //     .uploadBinary(
    //       filePath,
    //       bytes,
    //       fileOptions: FileOptions(
    //         contentType: normalizedContentType,
    //         upsert: false,
    //       ),
    //     );
    try {
      debugPrint('========== SUPABASE UPLOAD ==========');

      debugPrint('Bucket: $bucketName');
      debugPrint('File path: $filePath');
      debugPrint('Extension: $normalizedExtension');
      debugPrint('Content type: $normalizedContentType');
      debugPrint('File size: ${bytes.length} bytes');

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

      debugPrint('IMAGE UPLOAD SUCCESSFUL');
    } catch (error, stackTrace) {
      debugPrint('========== SUPABASE UPLOAD FAILED ==========');
      debugPrint('Error details: $error');
      debugPrint('Stack trace: $stackTrace');

      rethrow;
    }

    return filePath;
  }

  String getPublicImageUrl(String imagePath) {
    return _supabase.storage.from(bucketName).getPublicUrl(imagePath);
  }

  Future<String> getSignedImageUrl(String imagePath) async {
    return getPublicImageUrl(imagePath);
  }

  Future<void> deleteIncidentImage(String imagePath) async {
    await _supabase.storage.from(bucketName).remove([imagePath]);
  }
}
