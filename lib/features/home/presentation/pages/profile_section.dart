import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:starcy/utils/sp.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/image_picker_helper/image_picker_helper.dart';
import '../../../../core/services/image_picker_helper/upload_image_sheet.dart';
import '../../../../core/services/supabase_storage_helper.dart';

class ProfileSection extends StatefulWidget {
  const ProfileSection({super.key});

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentSession?.user;
    return Column(
      spacing: 8,
      children: [
        Center(
          child: SizedBox(
            width: 64.appSp,
            height: 64.appSp,
            child: FutureBuilder(
              future: user != null
                  ? Supabase.instance.client
                      .from('profiles')
                      .select('data')
                      .eq('id', user.id)
                      .single()
                  : null,
              builder: (context, snapshot) {
                final avatarUrl = snapshot.data?['data']?['avatar_url'];
                return ProfileAvatar(
                  avatarUrl: avatarUrl,
                  onTap: () => _handleImagePick(context),
                );
              },
            ),
          ),
        ),
        ProfileName(userId: user?.id),
      ],
    );
  }

  void _handleImagePick(BuildContext context) async {
    try {
      final String? imagePath = await UploadImageSheet.showUploadImageSheet(
        context: context,
        isCropper: true,
      );

      if (imagePath != null &&
          Supabase.instance.client.auth.currentSession?.user != null) {
        final user = Supabase.instance.client.auth.currentSession!.user;

        // Get the image bytes
        final bytes = await ImagePickerHelper.getImageBytes(XFile(imagePath));
        if (bytes == null) {
          throw Exception('Failed to get image bytes');
        }

        // Generate a unique filename
        final fileName =
            '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

        // Upload to Supabase storage
        final filePath = await SupabaseStorageHelper.uploadImage(
          bytes: bytes,
          fileName: fileName,
          folder: user.id,
        );

        if (filePath == null) {
          throw Exception('Failed to upload image');
        }

        // Get existing profile data
        final existingProfile = await Supabase.instance.client
            .from('profiles')
            .select('data')
            .eq('id', user.id)
            .single();

        final existingData =
            existingProfile['data'] as Map<String, dynamic>? ?? {};

        // Update profile with new avatar URL
        await Supabase.instance.client.from('profiles').upsert({
          'id': user.id,
          'email': user.email,
          'data': {
            ...existingData,
            'avatar_url': filePath,
          },
        });
        setState(() {});
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile picture: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final VoidCallback onTap;

  const ProfileAvatar({
    super.key,
    required this.avatarUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64.appSp,
        height: 64.appSp,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: ClipOval(
          child: avatarUrl != null
              ? FutureBuilder<String?>(
                  future: SupabaseStorageHelper.getAvatarUrl(avatarUrl!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError || snapshot.data == null) {
                      return const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey,
                      );
                    }

                    return Image.network(
                      snapshot.data!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey,
                        );
                      },
                    );
                  },
                )
              : const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey,
                ),
        ),
      ),
    );
  }
}

class ProfileName extends StatelessWidget {
  const ProfileName({super.key, required this.userId});

  final String? userId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder(
        future: Supabase.instance.client
            .from('profiles')
            .select('data')
            .eq('id', userId ?? '')
            .single(),
        builder: (context, response) {
          final name = response.data?['data']?['name'];
          return Text(
            name ?? "",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.appSp,
            ),
          );
        },
      ),
    );
  }
}
