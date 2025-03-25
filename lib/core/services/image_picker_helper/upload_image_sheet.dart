import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'image_picker_helper.dart';

class UploadImageSheet {
  static showUploadImageSheet(
      {required BuildContext context, required bool isCropper}) async {
    if (kIsWeb) {
      return await _showWebImagePicker(context: context, isCropper: isCropper);
    } else if (Platform.isAndroid) {
      return await _showBottomSheet(context: context, isCropper: isCropper);
    } else if (Platform.isIOS) {
      return await _showCupertinoActionSheet(
          context: context, isCropper: isCropper);
    } else {
      return null;
    }
  }

  static Future<String?> _showWebImagePicker({
    required BuildContext context,
    required bool isCropper,
  }) async {
    try {
      final XFile? pickedFile = await ImagePickerHelper.pickImageFromGallery(
        isCropper: isCropper,
      );
      if (pickedFile != null) {
        return pickedFile.path;
      }
    } catch (e) {
      debugPrint('Error picking image on web: $e');
    }
    return null;
  }

  static Future<String?> _showCupertinoActionSheet({
    required BuildContext context,
    required bool isCropper,
  }) async {
    return await showCupertinoModalPopup(
      context: context,
      //barrierColor: KBlack.withOpacity(0.72),
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Upload image via'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              String? path = await pickFromGallery(isCropper: isCropper);
              if (path != null) {
                if (context.mounted) {
                  Navigator.pop(context, path);
                }
              }
            },
            child: const Text('Photos'),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              String? path = await pickFromCamera(isCropper: isCropper);
              if (path != null) {
                if (context.mounted) {
                  Navigator.pop(context, path);
                }
              }
            },
            child: const Text('Camera'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }

  static _showBottomSheet(
      {required BuildContext context, required bool isCropper}) async {
    return await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          topLeft: Radius.circular(16),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(16),
              topLeft: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Center(child: Text('Upload image via')),
              ),
              ListTile(
                title: const Center(child: Text('Photos')),
                onTap: () async {
                  String? path = await pickFromGallery(isCropper: isCropper);
                  if (path != null) {
                    if (context.mounted) {
                      Navigator.pop(context, path);
                    }
                  }
                },
              ),
              Container(
                height: 1,
                color: Colors.grey,
                width: double.infinity,
              ),
              ListTile(
                title: const Center(child: Text('Camera')),
                onTap: () async {
                  String? path = await pickFromCamera(isCropper: isCropper);
                  if (path != null) {
                    if (context.mounted) {
                      Navigator.pop(context, path);
                    }
                  }
                },
              ),
              Container(
                height: 1,
                color: Colors.grey,
                width: double.infinity,
              ),
              ListTile(
                title: const Center(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              Container(
                height: MediaQuery.of(context).padding.bottom,
              ),
            ],
          ),
        );
      },
    );
  }

  static pickFromCamera({required bool isCropper}) async {
    XFile? xFile =
        await ImagePickerHelper.captureImageFromCamera(isCropper: isCropper);
    if (xFile != null) {
      return xFile.path;
    } else {
      return null;
    }
  }

  static pickFromGallery({required bool isCropper}) async {
    XFile? xFile =
        await ImagePickerHelper.pickImageFromGallery(isCropper: isCropper);
    if (xFile != null) {
      return xFile.path;
    } else {
      return null;
    }
  }
}
