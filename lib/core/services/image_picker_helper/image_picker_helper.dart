import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'dart:typed_data';
import 'dart:convert';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<XFile?> pickImageFromGallery({required bool isCropper}) async {
    try {
      if (kIsWeb) {
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
        if (pickedFile != null) {
          // For web, we need to handle the data differently
          final bytes = await pickedFile.readAsBytes();
          final base64String = base64Encode(bytes);
          return XFile.fromData(
            bytes,
            name: pickedFile.name,
            mimeType: pickedFile.mimeType,
            lastModified: DateTime.now(),
          );
        }
      } else {
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
        if (pickedFile != null) {
          return XFile(pickedFile.path);
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
    return null;
  }

  static Future<XFile?> captureImageFromCamera(
      {required bool isCropper}) async {
    try {
      if (kIsWeb) {
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
        if (pickedFile != null) {
          // For web, we need to handle the data differently
          final bytes = await pickedFile.readAsBytes();
          final base64String = base64Encode(bytes);
          return XFile.fromData(
            bytes,
            name: pickedFile.name,
            mimeType: pickedFile.mimeType,
            lastModified: DateTime.now(),
          );
        }
      } else {
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
        if (pickedFile != null) {
          return XFile(pickedFile.path);
        }
      }
    } catch (e) {
      debugPrint('Error capturing image: $e');
    }
    return null;
  }

  static Future<bool> checkPermission() async {
    if (kIsWeb) {
      // Web doesn't need explicit permission checks
      return true;
    }

    if (Platform.isAndroid || Platform.isIOS) {
      final status = await _picker.retrieveLostData();
      return status.isEmpty;
    }

    return true;
  }

  // Helper method to convert XFile to Uint8List for web
  static Future<Uint8List?> getImageBytes(XFile file) async {
    try {
      if (kIsWeb) {
        return await file.readAsBytes();
      } else {
        final bytes = await file.readAsBytes();
        return bytes;
      }
    } catch (e) {
      debugPrint('Error converting image to bytes: $e');
      return null;
    }
  }
}
