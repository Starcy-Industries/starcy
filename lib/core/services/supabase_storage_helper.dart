import 'dart:typed_data';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

class SupabaseStorageHelper {
  static final _storage = Supabase.instance.client.storage;
  static const String _bucketName = 'avatars';

  static Future<String?> uploadImage({
    required Uint8List bytes,
    required String fileName,
    required String folder,
  }) async {
    try {
      debugPrint('Starting image upload process...');
      debugPrint('File name: $fileName');
      debugPrint('Folder: $folder');
      debugPrint('File size: ${(bytes.length / 1024).toStringAsFixed(2)} KB');

      final String filePath = '$folder/$fileName';
      debugPrint('Full file path: $filePath');

      // Upload the file
      debugPrint('Attempting to upload to Supabase storage...');
      await _storage.from(_bucketName).uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );
      debugPrint('Upload successful!');

      // Return just the file path
      debugPrint('Returning file path: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('❌ Error uploading image to Supabase:');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Error message: $e');

      if (e.toString().contains('Bucket not found')) {
        debugPrint(
            '⚠️ Please create the "$_bucketName" bucket in your Supabase storage');
      } else if (e.toString().contains('Permission denied')) {
        debugPrint('⚠️ Permission denied. Please check your storage policies');
      } else if (e.toString().contains('File size limit')) {
        debugPrint('⚠️ File size exceeds the limit');
      }
      return null;
    }
  }

  static Future<String?> uploadWebImage({
    required String base64String,
    required String fileName,
    required String folder,
  }) async {
    try {
      debugPrint('Starting web image upload process...');
      debugPrint('File name: $fileName');
      debugPrint('Folder: $folder');
      debugPrint('Base64 string length: ${base64String.length}');

      final String filePath = '$folder/$fileName';
      debugPrint('Full file path: $filePath');

      // Convert base64 to bytes
      debugPrint('Converting base64 to bytes...');
      final bytes = base64Decode(base64String);
      debugPrint(
          'Converted file size: ${(bytes.length / 1024).toStringAsFixed(2)} KB');

      // Upload the file
      debugPrint('Attempting to upload to Supabase storage...');
      await _storage.from(_bucketName).uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );
      debugPrint('Upload successful!');

      // Return just the file path
      debugPrint('Returning file path: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('❌ Error uploading web image to Supabase:');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Error message: $e');

      if (e.toString().contains('Bucket not found')) {
        debugPrint(
            '⚠️ Please create the "$_bucketName" bucket in your Supabase storage');
      } else if (e.toString().contains('Permission denied')) {
        debugPrint('⚠️ Permission denied. Please check your storage policies');
      } else if (e.toString().contains('File size limit')) {
        debugPrint('⚠️ File size exceeds the limit');
      } else if (e.toString().contains('Invalid base64')) {
        debugPrint('⚠️ Invalid base64 string provided');
      }
      return null;
    }
  }

  static Future<String?> getAvatarUrl(String filePath) async {
    try {
      debugPrint('Getting signed URL for avatar: $filePath');
      final String signedUrl =
          await _storage.from(_bucketName).createSignedUrl(filePath, 60 * 60);
      debugPrint('Generated signed URL: $signedUrl');
      return signedUrl;
    } catch (e) {
      debugPrint('❌ Error getting signed URL:');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Error message: $e');
      return null;
    }
  }
}
