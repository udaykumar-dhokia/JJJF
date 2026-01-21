import 'package:app/provider/navigation_provider.dart';
import 'package:app/provider/user_provider.dart';
import 'package:app/screens/directory_screen.dart';
import 'package:app/screens/home_screen.dart';
import 'package:app/screens/news_screen.dart';
import 'package:app/screens/business_screen.dart';
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

        if (userProvider.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      userProvider.errorMessage ?? "Something went wrong",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.mulish(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<UserProvider>().fetchUser(
                          forceRefresh: true,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      child: Text(
                        "Retry",
                        style: GoogleFonts.mulish(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (user == null) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CupertinoActivityIndicator()),
          );
        }

        if (!user.isProfileCompleted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OnboardScreen()),
              );
            }
          });
        }

        return Scaffold(
          bottomNavigationBar: FlashyTabBar(
            selectedIndex: context.watch<NavigationProvider>().currentIndex,
            showElevation: true,
            onItemSelected: (index) {
              context.read<NavigationProvider>().setIndex(index);
            },
            items: [
              FlashyTabBarItem(
                icon: Image(
                  image: AssetImage("lib/assets/logo.jpeg"),
                  width: 22,
                  height: 22,
                ),
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
          body: context.watch<NavigationProvider>().currentIndex == 0
              ? HomeScreen()
              : context.watch<NavigationProvider>().currentIndex == 2
              ? DirectoryScreen()
              : context.watch<NavigationProvider>().currentIndex == 4
              ? ProfileScreen()
              : context.watch<NavigationProvider>().currentIndex == 3
              ? NewsScreen()
              : context.watch<NavigationProvider>().currentIndex == 1
              ? BusinessScreen()
              : const SizedBox(),
        );
      },
    );
  }
}
