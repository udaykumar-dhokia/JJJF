import 'package:app/app_drawer.dart';
import 'package:app/constants/color.dart';
import 'package:app/models/business_model.dart';
import 'package:app/provider/business_provider.dart';
import 'package:app/screens/user_contact_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key});

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearch = false;

  String? _selectedCategory;
  final List<String> _categories = [
    'Retail',
    'Wholesale',
    'Manufacturing',
    'Service',
    'Technology',
    'Healthcare',
    'Education',
    'Real Estate',
    'Finance',
    'Construction',
    'Food & Beverage',
    'Consulting',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessProvider>().fetchBusinesses(forceRefresh: false);
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
          "Businesses",
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
                _isSearch = !_isSearch;
                if (!_isSearch) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
            icon: HugeIcon(
              icon: _isSearch
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
          PopupMenuButton<String>(
            color: Colors.white,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withAlpha(18),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryLight.withAlpha(78)),
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedFilter,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            onSelected: (String value) {
              setState(() {
                _selectedCategory = value == 'All' ? null : value;
              });
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'All',
                  child: Text('All Categories', style: GoogleFonts.mulish()),
                ),
                ..._categories.map((String category) {
                  return PopupMenuItem<String>(
                    value: category,
                    child: Text(category, style: GoogleFonts.mulish()),
                  );
                }).toList(),
              ];
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<BusinessProvider>().fetchBusinesses(
            forceRefresh: true,
          );
        },
        color: AppColors.primary,
        backgroundColor: Colors.white,
        child: Consumer<BusinessProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CupertinoActivityIndicator());
            }

            final filteredBusinesses = provider.businesses.where((
              businessUser,
            ) {
              final business = businessUser.business;
              if (business == null) return false;

              final matchesCategory =
                  _selectedCategory == null ||
                  business.category == _selectedCategory;

              final matchesSearch =
                  _searchQuery.isEmpty ||
                  (business.name?.toLowerCase().contains(_searchQuery) ??
                      false) ||
                  (business.category?.toLowerCase().contains(_searchQuery) ??
                      false) ||
                  (business.contact.toString().contains(_searchQuery)) ||
                  (business.address?.city?.toLowerCase().contains(
                        _searchQuery,
                      ) ??
                      false) ||
                  (business.address?.state?.toLowerCase().contains(
                        _searchQuery,
                      ) ??
                      false) ||
                  (business.address?.lineOne?.toLowerCase().contains(
                        _searchQuery,
                      ) ??
                      false);
              return matchesCategory && matchesSearch;
            }).toList();

            return Column(
              children: [
                if (_isSearch)
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
                        hintText: 'Search businesses here...',
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
                  child: filteredBusinesses.isEmpty
                      ? Center(
                          child: Text(
                            'No businesses found',
                            style: GoogleFonts.mulish(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: filteredBusinesses.length,
                          itemBuilder: (context, index) {
                            final businessUser = filteredBusinesses[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildBusinessCard(businessUser),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBusinessCard(BusinessUser user) {
    final business = user.business;
    if (business == null) return const SizedBox.shrink();

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserContactScreen(uuid: user.uuid),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedStore01,
                    size: 24,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        business.name ?? 'Unknown Business',
                        style: GoogleFonts.mulish(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          business.category ?? 'Uncategorized',
                          style: GoogleFonts.mulish(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 12),
            if (business.address?.city != null)
              _buildInfoRow(
                HugeIcons.strokeRoundedLocation01,
                '${business.address!.city}, ${business.address!.state}',
              ),
            if (business.contact != null)
              _buildInfoRow(
                HugeIcons.strokeRoundedCall02,
                business.contact.toString(),
                onTap: () => _launchDialer(business.contact.toString()),
              ),
            if (business.website != null && business.website!.isNotEmpty)
              _buildInfoRow(
                HugeIcons.strokeRoundedLink01,
                business.website!,
                onTap: () => _launchUrl(business.website!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    List<List<dynamic>> icon,
    String text, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            HugeIcon(icon: icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.mulish(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
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

  Future<void> _launchUrl(String url) async {
    if (!url.startsWith('http')) {
      url = 'https://$url';
    }
    final Uri launchUri = Uri.parse(url);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }
}
