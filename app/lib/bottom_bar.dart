import 'package:app/provider/user_provider.dart';
import 'package:app/screens/directory_screen.dart';
import 'package:app/screens/home_screen.dart';
import 'package:app/screens/onboard_screen.dart';
import 'package:app/screens/profile_screen.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  var _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;

        if (user == null) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CupertinoActivityIndicator()),
          );
        }

        if (!user.isProfileCompleted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OnboardScreen()),
          );
        }

        return Scaffold(
          bottomNavigationBar: FlashyTabBar(
            selectedIndex: _selectedIndex,
            showElevation: true,
            onItemSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            items: [
              FlashyTabBarItem(
                icon: HugeIcon(icon: HugeIcons.strokeRoundedHome03, size: 18),
                title: Text('Home', style: GoogleFonts.mulish()),
              ),
              FlashyTabBarItem(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedBuilding03,
                  size: 18,
                ),
                title: Text('Business', style: GoogleFonts.mulish()),
              ),
              FlashyTabBarItem(
                icon: HugeIcon(icon: HugeIcons.strokeRoundedContact, size: 18),
                title: Text('Contacts', style: GoogleFonts.mulish()),
              ),
              FlashyTabBarItem(
                icon: HugeIcon(icon: HugeIcons.strokeRoundedNews, size: 18),
                title: Text('News', style: GoogleFonts.mulish()),
              ),
              FlashyTabBarItem(
                icon: HugeIcon(icon: HugeIcons.strokeRoundedUser, size: 18),
                title: Text('Profile', style: GoogleFonts.mulish()),
              ),
            ],
          ),
          body: _selectedIndex == 0
              ? HomeScreen()
              : _selectedIndex == 2
              ? DirectoryScreen()
              : _selectedIndex == 4
              ? ProfileScreen()
              : const SizedBox(),
        );
      },
    );
  }
}
