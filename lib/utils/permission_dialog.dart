import 'package:flutter/material.dart';

class PermissionDialog {
  static Future<bool> showPermissionRationaleDialog(
      BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'Permission Required',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hey there! 👋',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Starcy needs certain permissions to help you better:',
                      style: TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 16),
                    _buildPermissionItem(
                      'Microphone',
                      'To hear you when you say "Hey Starcy" and respond to your voice commands',
                    ),
                    const SizedBox(height: 12),
                    _buildPermissionItem(
                      'Background Processing',
                      'To wake up and respond even when your phone is locked or the app is closed',
                    ),
                    const SizedBox(height: 12),
                    _buildPermissionItem(
                      'Notifications',
                      'To let you know when Starcy is actively listening for your commands',
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'These permissions help Starcy be there for you whenever you need assistance.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Not Now',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text(
                    'Allow Permissions',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  static Widget _buildPermissionItem(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Icon(
            Icons.check_circle,
            size: 16,
            color: Colors.green.shade400,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
