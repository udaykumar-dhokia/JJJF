import 'package:app/app_drawer.dart';
import 'package:app/constants/color.dart';
import 'package:app/models/directory_model.dart';
import 'package:app/provider/directory_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:app/screens/user_contact_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool isSeach = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DirectoryProvider>().fetchDirectoryUsers(
        forceRefresh: false,
      );
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
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedMenu01,
                size: 18,
              ),
              color: AppColors.primary,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: 'Menu',
            ),
          ),
        ),
        title: Text(
          "Directory",
          style: GoogleFonts.mulish(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            color: Colors.black,
            tooltip: "Search",
            onPressed: () {
              setState(() {
                isSeach = !isSeach;
              });
            },
            icon: HugeIcon(
              icon: isSeach
                  ? HugeIcons.strokeRoundedCancel01
                  : HugeIcons.strokeRoundedSearch01,
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
          IconButton(
            color: Colors.black,
            tooltip: "Filter",
            onPressed: () {},
            icon: HugeIcon(icon: HugeIcons.strokeRoundedFilter, size: 18),
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
      body: Column(
        children: [
          if (isSeach)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search people here...',
                  hintStyle: GoogleFonts.mulish(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await context.read<DirectoryProvider>().fetchDirectoryUsers(
                  forceRefresh: true,
                );
              },
              color: AppColors.primary,
              backgroundColor: Colors.white,
              child: Consumer<DirectoryProvider>(
                builder: (context, provider, child) {
                  final sortedUsers = [...provider.users]
                    ..sort((a, b) {
                      final nameA = '${a.firstName} ${a.lastName}'
                          .toLowerCase();
                      final nameB = '${b.firstName} ${b.lastName}'
                          .toLowerCase();
                      return nameA.compareTo(nameB);
                    });

                  final filteredUsers = sortedUsers.where((user) {
                    final fullName = '${user.firstName} ${user.lastName}'
                        .toLowerCase();
                    return fullName.contains(_searchQuery);
                  }).toList();

                  final Map<String, List<DirectoryUser>> groupedUsers = {};

                  for (var user in filteredUsers) {
                    final letter = user.firstName[0].toUpperCase();
                    groupedUsers.putIfAbsent(letter, () => []);
                    groupedUsers[letter]!.add(user);
                  }

                  final sectionKeys = groupedUsers.keys.toList()..sort();

                  if (provider.isLoading) {
                    return const Center(child: CupertinoActivityIndicator());
                  }

                  if (filteredUsers.isEmpty) {
                    return Center(
                      child: Text(
                        'No members found',
                        style: GoogleFonts.mulish(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ),
                    itemCount: sectionKeys.length,
                    itemBuilder: (context, index) {
                      final letter = sectionKeys[index];
                      final users = groupedUsers[letter]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(letter),
                          const SizedBox(height: 8),
                          ...users.map(
                            (user) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _buildUserCard(user),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String letter) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Text(
        letter,
        style: GoogleFonts.mulish(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildUserCard(DirectoryUser user) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserContactScreen(uuid: user.uuid),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withOpacity(0.15),
              child: Text(
                '${user.firstName[0]}${user.lastName[0]}',
                style: GoogleFonts.mulish(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: GoogleFonts.mulish(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (user.fatherName != null && user.fatherName!.isNotEmpty)
                    Text(
                      'S/o: ${user.fatherName}',
                      style: GoogleFonts.mulish(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  if (user.address?.city != null)
                    Text(
                      user.address!.city,
                      style: GoogleFonts.mulish(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            if (user.mobile != null) ...[
              IconButton(
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedWhatsapp,
                  size: 18,
                  color: Colors.green,
                ),
                onPressed: () => _launchWhatsApp(user.mobile!),
              ),
              IconButton(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedCall02,
                  size: 18,
                  color: AppColors.primary,
                ),
                onPressed: () => _launchDialer(user.mobile!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    final String url = "https://wa.me/91$phoneNumber";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchDialer(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }
}
