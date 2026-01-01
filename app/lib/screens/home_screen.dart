import 'package:app/app_drawer.dart';
import 'package:app/constants/color.dart';
import 'package:app/constants/menu_items.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<SharedPreferences> _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
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

        title: Text(
          "JJJF Ahmedabad",
          style: GoogleFonts.mulish(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            color: Colors.black,
            tooltip: "Notifications",
            onPressed: () {},
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedNotification02,
              size: 18,
            ),
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
      body: FutureBuilder<SharedPreferences>(
        future: _prefs,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CupertinoActivityIndicator());
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(15),
                    image: const DecorationImage(
                      image: NetworkImage(
                        "https://lessonslearnedinlife.net/wp-content/uploads/2020/04/Bill-Gates-Qoutes.jpg",
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Dashboard",
                  style: GoogleFonts.mulish(
                    fontSize: 20,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: menuItems.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.9,
                        ),
                    itemBuilder: (context, index) {
                      final item = menuItems[index];
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, item['route']);
                            },
                            child: CircleAvatar(
                              radius: 38,
                              backgroundColor: AppColors.primaryLight.withAlpha(
                                40,
                              ),
                              child: HugeIcon(
                                icon: item['icon'],
                                size: 28,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['label'],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.mulish(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
