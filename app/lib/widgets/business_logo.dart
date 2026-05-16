import 'dart:io';
import 'package:app/constants/color.dart';
import 'package:app/provider/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class BusinessLogo extends StatefulWidget {
  final String businessName;
  final String? logoUrl;
  final bool readOnly;

  const BusinessLogo({super.key, required this.businessName, this.logoUrl, this.readOnly = false});

  @override
  State<BusinessLogo> createState() => _BusinessLogoState();
}

class _BusinessLogoState extends State<BusinessLogo> {
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _isUploading = true;
    });

    final success = await context.read<UserProvider>().updateBusinessLogo(File(image.path));
    
    if (!mounted) return;
    
    setState(() {
      _isUploading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business logo updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update business logo')),
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
            radius: 36,
            backgroundColor: AppColors.primaryLight.withAlpha(30),
            backgroundImage: widget.logoUrl != null
                ? NetworkImage(widget.logoUrl!)
                : null,
            child: _isUploading
                ? const CupertinoActivityIndicator()
                : (widget.logoUrl == null
                    ? Text(
                        widget.businessName.isNotEmpty ? widget.businessName[0].toUpperCase() : '?',
                        style: GoogleFonts.mulish(
                          fontSize: 24,
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
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
