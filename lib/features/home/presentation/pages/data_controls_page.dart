import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:starcy/core/routes/app_router.dart';
import 'package:starcy/utils/sp.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

class DataControlsPage extends StatefulWidget {
  const DataControlsPage({
    super.key,
    required this.isDesktop,
    required this.onPressed,
  });

  final VoidCallback onPressed;
  final bool isDesktop;

  @override
  State<DataControlsPage> createState() => _DataControlsPageState();
}

class _DataControlsPageState extends State<DataControlsPage> {
  bool improveModelEnabled = false;
  bool improveVoiceEnabled = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        widget.onPressed();
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                BackButton(
                  color: Colors.white,
                  onPressed: widget.onPressed,
                ),
                Text(
                  "Data Control",
                  style: TextStyle(color: Colors.white, fontSize: 18.appSp),
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.appSp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildToggleSection(
                      title: 'Improve the model for everyone',
                      subtitle:
                          'Allow your content to be used to train our models, which makes StarCY better for you and everyone who uses it. We take steps to protect your privacy.',
                      value: improveModelEnabled,
                      onChanged: (value) {
                        setState(() {
                          improveModelEnabled = value;
                        });
                      },
                      learnMoreUrl: 'Learn more',
                    ),
                    SizedBox(height: 24.appSp),
                    _buildToggleSection(
                      title: 'Improve voice for everyone',
                      subtitle:
                          'Share audio from future voice chats to improve and train our models. This improves the quality of voice chats for everyone.',
                      value: improveVoiceEnabled,
                      onChanged: (value) {
                        setState(() {
                          improveVoiceEnabled = value;
                        });
                      },
                      learnMoreUrl: 'Learn more',
                    ),
                    SizedBox(height: 32.appSp),
                    _buildDangerSection(),
                    SizedBox(height: 32.appSp),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSection({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required String learnMoreUrl,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.black,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.appSp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              CupertinoSwitch(
                value: value,
                onChanged: onChanged,
                activeTrackColor: const Color(0xFF34C759),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.appSp),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12.appSp,
              height: 1.4,
            ),
          ),
        ),
        SizedBox(height: 4.appSp),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GestureDetector(
            onTap: () {
              // Handle learn more tap
            },
            child: Text(
              learnMoreUrl,
              style: TextStyle(
                color: Colors.blue[300],
                fontSize: 12.appSp,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDangerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            final bool? confirm = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.black,
                  title: Text(
                    'Delete Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.appSp,
                    ),
                  ),
                  content: Text(
                    'Are you sure you want to delete your account? This action cannot be undone.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.appSp,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.appSp,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          color: const Color(0xFFFF3B30),
                          fontSize: 14.appSp,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );

            if (confirm == true) {
              try {
                final supabase = Supabase.instance.client;
                final user = supabase.auth.currentSession?.user;

                if (user == null) {
                  throw Exception('User not authenticated');
                }

                // Delete user's profile data

                if (await deleteUserAccount()) {
                  await supabase.from('profiles').delete().eq('id', user.id);
                  await supabase.auth.signOut();

                  if (mounted) {
                    context.router.replace(const LoginRoute());
                  }
                }
              } catch (e) {
                if (mounted) {
                  String errorMessage = 'Error deleting account: ';
                  if (e.toString().contains('Permission denied') ||
                      e.toString().contains('not_admin')) {
                    errorMessage +=
                        'Unable to delete account. Please contact support.';
                  } else if (e.toString().contains('User not found')) {
                    errorMessage += 'User account not found.';
                  } else {
                    errorMessage += e.toString();
                  }
                  print(e.toString());
                  toastification.show(
                    context: context,
                    title: Text(
                      errorMessage,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.appSp,
                      ),
                    ),
                    type: ToastificationType.error,
                    autoCloseDuration: const Duration(seconds: 4),
                  );
                }
              }
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.black,
            ),
            child: Text(
              'Delete Account',
              style: TextStyle(
                color: const Color(0xFFFF3B30),
                fontSize: 16.appSp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<bool> deleteUserAccount() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      print("No user is logged in.");
      return false;
    }

    const url =
        "https://txuvmmvubieskhcwwmrh.supabase.co/functions/v1/delete_user_account";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization":
              "Bearer ${supabase.auth.currentSession?.accessToken}",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        print("User deleted successfully");
        return true;
      } else {
        print("Failed to delete user: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error deleting user: $e");
      return false;
    }
  }
}
