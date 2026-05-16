import 'package:app/app_drawer.dart';
import 'package:app/constants/color.dart';
import 'package:app/provider/user_provider.dart';
import 'package:app/screens/business_onboard_screen.dart';
import 'package:app/screens/edit_profile_screen.dart';
import 'package:app/screens/splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:app/widgets/profile_avatar.dart';
import 'package:app/widgets/business_logo.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    if (user == null) {
      return const Scaffold(body: Center(child: CupertinoActivityIndicator()));
    }

    return Scaffold(
      drawer: const AppDrawer(),
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
              icon: HugeIcon(icon: HugeIcons.strokeRoundedMenu01, size: 18),
              color: AppColors.primary,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: 'Menu',
            ),
          ),
        ),
        backgroundColor: Colors.white,
        title: Text(
          "Profile",
          style: GoogleFonts.mulish(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            color: Colors.black,
            tooltip: "Edit",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
            icon: HugeIcon(icon: HugeIcons.strokeRoundedEdit03, size: 18),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primaryLight.withAlpha(18),
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: AppColors.primaryLight.withAlpha(78)),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          IconButton(
            color: Colors.black,
            tooltip: "Logout",
            onPressed: () async {
              final _prefs = await SharedPreferences.getInstance();
              await _prefs.remove("userId");
              await ClerkAuth.of(context).signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SplashScreen()),
              );
            },
            icon: HugeIcon(icon: HugeIcons.strokeRoundedLogout01, size: 18),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primaryLight.withAlpha(18),
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: AppColors.primaryLight.withAlpha(78)),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<UserProvider>().fetchUser(forceRefresh: true);
        },
        color: AppColors.primary,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (!user.isBusinessCompleted)
                Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: AppColors.primaryLight.withAlpha(60),
                    ),
                  ),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Complete your business profile",
                                style: GoogleFonts.mulish(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primaryLight.withAlpha(
                              18,
                            ),
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: AppColors.primaryLight.withAlpha(78),
                              ),
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const BusinessOnboardScreen(),
                              ),
                            );
                          },
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowRight01,
                          ),
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),

              ProfileAvatar(
                firstName: user.firstName,
                profilePicture: user.profilePicture,
              ),
              const SizedBox(height: 12),

              Text(
                "${user.firstName} ${user.lastName}",
                style: GoogleFonts.mulish(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),

              Text(
                user.email,
                style: GoogleFonts.mulish(color: Colors.grey.shade600),
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
                ],
              ),
              const SizedBox(height: 16),

              _ProfileSection(
                title: "Professional Details",
                children: [
                  _ProfileTile(
                    icon: HugeIcons.strokeRoundedWorkHistory,
                    title: "Job Role",
                    value: user.jobRole != null && user.jobRole!.isNotEmpty
                        ? user.jobRole!
                        : "Not specified",
                  ),
                  _ProfileTile(
                    icon: HugeIcons.strokeRoundedBuilding01,
                    title: "Company",
                    value:
                        user.companyName != null && user.companyName!.isNotEmpty
                            ? user.companyName!
                            : "Not specified",
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _ProfileSection(
                title: "Contact Information",
                children: [
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

              _ProfileSection(
                title: "Address",
                children: [
                  _ProfileTile(
                    icon: HugeIcons.strokeRoundedLocation01,
                    title: "Address",
                    value: user.address == null
                        ? "Not provided"
                        : "${user.address!.lineOne}\n"
                              "${user.address!.lineTwo.isNotEmpty ? "${user.address!.lineTwo}\n" : ""}"
                              "${user.address!.city}, ${user.address!.state}\n"
                              "${user.address!.zipCode}",
                  ),
                ],
              ),

              if (user.isBusinessCompleted && user.business != null) ...[
                const SizedBox(height: 16),

                Center(
                  child: BusinessLogo(
                    businessName: user.business!.name ?? '',
                    logoUrl: user.business!.logo,
                  ),
                ),
                const SizedBox(height: 12),

                _ProfileSection(
                  title: "Business Details",
                  trailing: IconButton(
                    icon: HugeIcon(icon: HugeIcons.strokeRoundedEdit02, size: 16),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BusinessOnboardScreen(isEditing: true),
                        ),
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    style: const ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    color: AppColors.primary,
                  ),
                  children: [
                    _ProfileTile(
                      icon: HugeIcons.strokeRoundedStore01,
                      title: "Business Name",
                      value: user.business!.name!,
                    ),
                    _ProfileTile(
                      icon: HugeIcons.strokeRoundedTag01,
                      title: "Category",
                      value: user.business!.category!,
                    ),
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
                    _ProfileTile(
                      icon: HugeIcons.strokeRoundedLocation01,
                      title: "Address",
                      value:
                          "${user.business!.address!.lineOne}\n"
                          "${user.business!.address!.lineTwo.isNotEmpty ? "${user.business!.address!.lineTwo}\n" : ""}"
                          "${user.business!.address!.city}, ${user.business!.address!.state}\n"
                          "${user.business!.address!.zipCode}",
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? trailing;

  const _ProfileSection({required this.title, required this.children, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.mulish(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            if (trailing != null) trailing!,
          ],
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
  final List<List<dynamic>> icon;
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
