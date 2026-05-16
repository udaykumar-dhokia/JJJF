import 'dart:io';
import 'package:app/constants/color.dart';
import 'package:app/provider/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileAvatar extends StatefulWidget {
  final String firstName;
  final String? profilePicture;
  final bool readOnly;
  final double radius;

  const ProfileAvatar({
    super.key,
    required this.firstName,
    this.profilePicture,
    this.readOnly = false,
    this.radius = 42,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _isUploading = true;
    });

    final success = await context.read<UserProvider>().updateProfilePicture(File(image.path));
    
    if (!mounted) return;
    
    setState(() {
      _isUploading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile picture')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: (widget.readOnly || _isUploading) ? null : _pickAndUploadImage,
          child: CircleAvatar(
            radius: widget.radius,
            backgroundColor: AppColors.primaryLight.withAlpha(30),
            backgroundImage: widget.profilePicture != null
                ? NetworkImage(widget.profilePicture!)
                : null,
            child: _isUploading
                ? const CupertinoActivityIndicator()
                : (widget.profilePicture == null
                    ? Text(
                        widget.firstName.isNotEmpty ? widget.firstName[0].toUpperCase() : '?',
                        style: GoogleFonts.mulish(
                          fontSize: widget.radius * 0.66,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      )
                    : null),
          ),
        ),
        if (!widget.readOnly)
          Positioned(
            bottom: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedCamera01,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
