import 'package:app/constants/color.dart';
import 'package:app/models/business_model.dart';
import 'package:app/screens/user_contact_screen.dart';
import 'package:app/widgets/business_logo.dart';
import 'package:app/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

class BusinessDetailScreen extends StatelessWidget {
  final BusinessUser businessUser;

  const BusinessDetailScreen({super.key, required this.businessUser});

  Future<void> _launchDialer(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _launchUrl(String url) async {
    if (!url.startsWith('http')) {
      url = 'https://$url';
    }
    final Uri launchUri = Uri.parse(url);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final business = businessUser.business;
    if (business == null) return const Scaffold();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          "Business Details",
          style: GoogleFonts.mulish(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: BusinessLogo(
                businessName: business.name ?? '',
                logoUrl: business.logo,
                readOnly: true,
              ),
            ),
            const SizedBox(height: 16),

            _Section(
              title: "Business Details",
              children: [
                _DetailTile(
                  icon: HugeIcons.strokeRoundedStore01,
                  title: "Business Name",
                  value: business.name ?? 'Not specified',
                ),
                _DetailTile(
                  icon: HugeIcons.strokeRoundedTag01,
                  title: "Category",
                  value: business.category ?? 'Not specified',
                ),
                if (business.contact != null)
                  _DetailTile(
                    icon: HugeIcons.strokeRoundedCall,
                    title: "Contact",
                    value: business.contact.toString(),
                    onTap: () => _launchDialer(business.contact.toString()),
                  ),
                if (business.website != null && business.website!.isNotEmpty)
                  _DetailTile(
                    icon: HugeIcons.strokeRoundedLink01,
                    title: "Website",
                    value: business.website!,
                    onTap: () => _launchUrl(business.website!),
                  ),
                if (business.address != null)
                  _DetailTile(
                    icon: HugeIcons.strokeRoundedLocation01,
                    title: "Address",
                    value: [
                      business.address!.lineOne,
                      business.address!.lineTwo,
                      business.address!.city,
                      business.address!.state,
                      business.address!.zipCode?.toString() ?? '',
                    ].where((s) => s.isNotEmpty).join(', '),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              "Business Owner",
              style: GoogleFonts.mulish(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              color: AppColors.primaryLight.withAlpha(30),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.primaryLight.withAlpha(40)),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          UserContactScreen(uuid: businessUser.uuid),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ProfileAvatar(
                        firstName: businessUser.firstName ?? '?',
                        profilePicture: businessUser.profilePicture,
                        readOnly: true,
                        radius: 28,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${businessUser.firstName ?? ''} ${businessUser.lastName ?? ''}"
                                  .trim(),
                              style: GoogleFonts.mulish(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Tap to view full profile",
                              style: GoogleFonts.mulish(
                                fontSize: 13,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowRight01,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.mulish(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: AppColors.primaryLight.withAlpha(30),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.primaryLight.withAlpha(40)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _DetailTile extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _DetailTile({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: HugeIcon(icon: icon, size: 20, color: AppColors.primary),
      title: Text(
        title,
        style: GoogleFonts.mulish(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        value,
        style: GoogleFonts.mulish(
          color: onTap != null ? AppColors.primary : Colors.grey.shade700,
          decoration: onTap != null ? TextDecoration.underline : null,
          decorationColor: AppColors.primary,
        ),
      ),
      trailing: onTap != null
          ? HugeIcon(
              icon: HugeIcons.strokeRoundedArrowUpRight01,
              size: 16,
              color: AppColors.primary,
            )
          : null,
    );
  }
}
