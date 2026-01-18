import 'package:app/app_drawer.dart';
import 'package:app/constants/color.dart';
import 'package:app/provider/user_provider.dart';
import 'package:app/screens/business_onboard_screen.dart';
import 'package:app/screens/splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clerk_flutter/clerk_flutter.dart';

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
            onPressed: () {},
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
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (!user.isBusinessCompleted)
              Card(
                margin: const EdgeInsets.only(bottom: 20),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.primaryLight.withAlpha(60)),
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
                          backgroundColor: AppColors.primaryLight.withAlpha(18),
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

            CircleAvatar(
              radius: 42,
              backgroundColor: AppColors.primaryLight.withAlpha(30),
              child: Text(
                user.firstName[0].toUpperCase(),
                style: GoogleFonts.mulish(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
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

              _ProfileSection(
                title: "Business Details",
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
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileSection({required this.title, required this.children});

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
