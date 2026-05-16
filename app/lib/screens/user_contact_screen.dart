import 'package:app/constants/color.dart';
import 'package:app/models/user_model.dart';
import 'package:app/provider/directory_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app/widgets/profile_avatar.dart';
import 'package:app/widgets/business_logo.dart';

class UserContactScreen extends StatefulWidget {
  final String uuid;
  const UserContactScreen({super.key, required this.uuid});

  @override
  State<UserContactScreen> createState() => _UserContactScreenState();
}

class _UserContactScreenState extends State<UserContactScreen> {
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    final user = await context.read<DirectoryProvider>().fetchUserDetails(
      widget.uuid,
    );
    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CupertinoActivityIndicator(radius: 14)),
      );
    }

    if (_user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white),
        body: const Center(child: Text("User not found")),
      );
    }

    final user = _user!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        leading: Builder(
          builder: (context) => Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withAlpha(18),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryLight.withAlpha(78)),
            ),
            child: IconButton(
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedArrowLeft01,
                size: 18,
              ),
              color: AppColors.primary,
              onPressed: () {
                Navigator.pop(context);
              },
              tooltip: 'Back',
            ),
          ),
        ),
        backgroundColor: Colors.white,
        title: Text(
          "Contact Details",
          style: GoogleFonts.mulish(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: user.mobile != null
                      ? () => _launchDialer(user.mobile.toString())
                      : null,
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedCall02,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: Text("Call", style: GoogleFonts.mulish(fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _launchEmail(user.email),
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedMail01,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  label: Text("Email", style: GoogleFonts.mulish(fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: user.mobile != null
                    ? () => _launchWhatsApp(user.mobile.toString())
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(10),
                  minimumSize: const Size(44, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedWhatsapp,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ProfileAvatar(
              firstName: user.firstName,
              profilePicture: user.profilePicture,
              readOnly: true,
            ),
            const SizedBox(height: 12),

            Text(
              "${user.firstName} ${user.lastName}",
              style: GoogleFonts.mulish(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (user.fatherName != null && user.fatherName!.isNotEmpty)
              Text(
                "S/o: ${user.fatherName}",
                style: GoogleFonts.mulish(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 4),

            Text(
              user.email,
              style: GoogleFonts.mulish(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),

            if (user.mobile != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone_outlined, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    user.isMobileHidden
                        ? "+91 ••••••••${user.mobile.toString().substring(user.mobile.toString().length - 2)}"
                        : "+91 ${user.mobile}",
                    style: GoogleFonts.mulish(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            _ProfileSection(
              title: "Personal Details",
              children: [
                if (user.birthDate != null)
                  _ProfileTile(
                    icon: HugeIcons.strokeRoundedBirthdayCake,
                    title: "Birth Date",
                    value:
                        "${user.birthDate!.day}/${user.birthDate!.month}/${user.birthDate!.year}",
                  ),
                if (user.anniversaryDate != null)
                  _ProfileTile(
                    icon: HugeIcons.strokeRoundedCalendar03,
                    title: "Anniversary",
                    value:
                        "${user.anniversaryDate!.day}/${user.anniversaryDate!.month}/${user.anniversaryDate!.year}",
                  ),
                if (user.maritalStatus != null &&
                    user.maritalStatus!.isNotEmpty)
                  _ProfileTile(
                    icon: HugeIcons.strokeRoundedUserGroup,
                    title: "Marital Status",
                    value: user.maritalStatus!,
                  ),
                if (user.gaon != null && user.gaon!.isNotEmpty)
                  _ProfileTile(
                    icon: HugeIcons.strokeRoundedHome01,
                    title: "Native Village (Gaon)",
                    value: user.gaon!,
                  ),
                if (user.district != null && user.district!.isNotEmpty)
                  _ProfileTile(
                    icon: HugeIcons.strokeRoundedMapPin,
                    title: "District",
                    value: user.district!,
                  ),
                if (user.currentCity != null && user.currentCity!.isNotEmpty)
                  _ProfileTile(
                    icon: HugeIcons.strokeRoundedBuilding02,
                    title: "Current City",
                    value: user.currentCity!,
                  ),
              ],
            ),

            const SizedBox(height: 16),

            if ((user.jobRole != null && user.jobRole!.isNotEmpty) ||
                (user.companyName != null && user.companyName!.isNotEmpty)) ...[
              _ProfileSection(
                title: "Professional Details",
                children: [
                  if (user.jobRole != null && user.jobRole!.isNotEmpty)
                    _ProfileTile(
                      icon: HugeIcons.strokeRoundedWorkHistory,
                      title: "Job Role",
                      value: user.jobRole!,
                    ),
                  if (user.companyName != null && user.companyName!.isNotEmpty)
                    _ProfileTile(
                      icon: HugeIcons.strokeRoundedBuilding01,
                      title: "Company",
                      value: user.companyName!,
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            _ProfileSection(
              title: "Contact Information",
              children: [
                if (user.mobile != null)
                  _ProfileTile(
                    icon: HugeIcons.strokeRoundedCall,
                    title: "Mobile",
                    value: user.mobile.toString(),
                  ),
                _ProfileTile(
                  icon: HugeIcons.strokeRoundedMail01,
                  title: "Email",
                  value: user.email,
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (user.familyDetails != null && user.familyDetails!.isNotEmpty)
              _ProfileSection(
                title: "Family Details",
                children: user.familyDetails!
                    .map(
                      (member) => _ProfileTile(
                        icon: HugeIcons.strokeRoundedUserGroup,
                        title: member.relation,
                        value: "${member.name} (${member.occupation})",
                      ),
                    )
                    .toList(),
              ),

            const SizedBox(height: 16),

            if (user.address != null)
              _ProfileSection(
                title: "Address",
                children: [
                  _ProfileTile(
                    icon: HugeIcons.strokeRoundedLocation01,
                    title: "Address",
                    value:
                        "${user.address!.lineOne}\n"
                        "${user.address!.lineTwo.isNotEmpty == true ? "${user.address!.lineTwo}\n" : ""}"
                        "${user.address!.city}, ${user.address!.state}\n"
                        "${user.address!.zipCode}",
                  ),
                ],
              ),

            if (user.isBusinessCompleted && user.business != null) ...[
              const SizedBox(height: 16),

              _ProfileSection(
                title: "Business Details",
                children: [
                  _ProfileTile(
                    icon: HugeIcons.strokeRoundedStore01,
                    title: "Business Name",
                    value: user.business!.name ?? '',
                  ),
                  _ProfileTile(
                    icon: HugeIcons.strokeRoundedTag01,
                    title: "Category",
                    value: user.business!.category ?? '',
                  ),
                  if (user.business!.contact != null)
                    _ProfileTile(
                      icon: HugeIcons.strokeRoundedCall,
                      title: "Contact",
                      value: user.business!.contact.toString(),
                    ),
                  if (user.business!.website != null &&
                      user.business!.website!.isNotEmpty)
                    _ProfileTile(
                      icon: HugeIcons.strokeRoundedLink01,
                      title: "Website",
                      value: user.business!.website!,
                    ),
                  if (user.business!.address != null)
                    _ProfileTile(
                      icon: HugeIcons.strokeRoundedLocation01,
                      title: "Address",
                      value:
                          "${user.business!.address!.lineOne}\n"
                          "${user.business!.address!.lineTwo.isNotEmpty == true ? "${user.business!.address!.lineTwo}\n" : ""}"
                          "${user.business!.address!.city}, ${user.business!.address!.state}\n"
                          "${user.business!.address!.zipCode}",
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _launchDialer(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    final String url = "https://wa.me/91$phoneNumber";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.mulish(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
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

class _ProfileTile extends StatelessWidget {
  final dynamic icon;
  final String title;
  final String value;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: HugeIcon(icon: icon, size: 20, color: AppColors.primary),
      title: Text(
        title,
        style: GoogleFonts.mulish(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        value,
        style: GoogleFonts.mulish(color: Colors.grey.shade700),
      ),
    );
  }
}
