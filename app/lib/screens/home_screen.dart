import 'package:app/app_drawer.dart';
import 'package:app/provider/navigation_provider.dart';
import 'package:app/provider/directory_provider.dart';
import 'package:app/constants/color.dart';
import 'package:app/screens/anniversaries_screen.dart';
import 'package:app/screens/birthdays_screen.dart';
import 'package:app/screens/job_board_screen.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
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

  final List<String> _carouselImages = [
    "https://images.unsplash.com/photo-1511632765486-a01980e01a18?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    'https://images.unsplash.com/photo-1540553016722-983e48a2cd10?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=800&q=80',
    "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  ];

  @override
  void initState() {
    super.initState();
    _prefs = SharedPreferences.getInstance();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DirectoryProvider>().fetchUpcomingEvents();
    });
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

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            physics: const BouncingScrollPhysics(),
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: 180.0,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: 0.9,
                  autoPlayInterval: const Duration(seconds: 4),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                ),
                items: _carouselImages.map((imageUrl) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Dashboard",
                  style: GoogleFonts.mulish(
                    fontSize: 20,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: menuItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                          final route = item['route'];
                          if (route == '/profile') {
                            context.read<NavigationProvider>().setIndex(4);
                          } else if (route == '/directory' ||
                              route == '/contacts') {
                            context.read<NavigationProvider>().setIndex(2);
                          } else if (route == '/news') {
                            context.read<NavigationProvider>().setIndex(3);
                          } else if (route == '/business') {
                            context.read<NavigationProvider>().setIndex(1);
                          } else if (route == '/jobs') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const JobBoardScreen(),
                              ),
                            );
                          } else if (route == '/birthday') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const BirthdaysScreen(),
                              ),
                            );
                          } else if (route == '/anniversary') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AnniversariesScreen(),
                              ),
                            );
                          } else {
                            Navigator.pushNamed(context, route);
                          }
                        },
                        child: CircleAvatar(
                          radius: 38,
                          backgroundColor: AppColors.primaryLight.withAlpha(40),
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
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
