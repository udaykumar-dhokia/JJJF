import 'package:app/constants/color.dart';
import 'package:app/constants/menu_items.dart';
import 'package:app/provider/navigation_provider.dart';
import 'package:app/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return Drawer(
      shape: BeveledRectangleBorder(),
      backgroundColor: Colors.white,
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: AppColors.primary.withAlpha(230)),
            accountName: Text(
              user != null ? "${user.firstName} ${user.lastName}" : "Guest",
              style: GoogleFonts.mulish(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            accountEmail: Text(
              user?.email ?? "Not signed in",
              style: GoogleFonts.mulish(color: Colors.white70),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user != null ? user.firstName[0].toUpperCase() : "G",
                style: GoogleFonts.mulish(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: menuItems.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return ListTile(
                  leading: HugeIcon(
                    icon: item['icon'],
                    size: 24,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    item['label'] ?? '',
                    style: GoogleFonts.mulish(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    final route = item['route'];
                    if (route != null) {
                      if (route == '/profile') {
                        context.read<NavigationProvider>().setIndex(4);
                      } else if (route == '/directory' ||
                          route == '/contacts') {
                        context.read<NavigationProvider>().setIndex(2);
                      } else if (route == '/news') {
                        context.read<NavigationProvider>().setIndex(3);
                      } else if (route == '/business') {
                        context.read<NavigationProvider>().setIndex(1);
                      } else {
                        Navigator.pushNamed(context, route);
                      }
                    }
                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "Version 0.0.1",
              style: GoogleFonts.mulish(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
