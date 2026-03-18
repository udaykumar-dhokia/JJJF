import 'package:app/app_drawer.dart';
import 'package:app/constants/color.dart';
import 'package:app/models/business_model.dart';
import 'package:app/provider/business_provider.dart';
import 'package:app/provider/user_provider.dart';
import 'package:app/screens/user_contact_screen.dart';
import 'package:csc_picker/csc_picker.dart';
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

  // Filter States
  String _selectedCity = "";
  String _selectedState = "";
  String _selectedCountry = "India";

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

      // Initialize filters with user's location
      final user = context.read<UserProvider>().user;
      if (user?.address != null) {
        setState(() {
          _selectedCity = user!.address!.city;
          _selectedState = user.address!.state;
          // Assuming user is in India as per app context, or we could add country to address model later
          _selectedCountry = "India";
        });
      }
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
        title: InkWell(
          onTap: _showFilterModal,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withAlpha(18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    _selectedCity.isNotEmpty ? _selectedCity : "All Locations",
                    style: GoogleFonts.mulish(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ],
            ),
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
          IconButton(
            onPressed: _showFilterModal,
            icon: Container(
              padding: const EdgeInsets.all(10),
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

            // Optimization: Pre-calculate normalized values
            final normalizedSearch = _searchQuery.toLowerCase();
            final normalizedSelectCity = _selectedCity.trim().toLowerCase();
            final normalizedSelectState = _selectedState.trim().toLowerCase();
            final hasCityFilter =
                _selectedCity.isNotEmpty && _selectedCity != "City";
            final hasStateFilter =
                _selectedState.isNotEmpty && _selectedState != "State";

            final filteredBusinesses = provider.businesses.where((
              businessUser,
            ) {
              final business = businessUser.business;
              if (business == null) return false;

              final matchesCategory =
                  _selectedCategory == null ||
                  business.category == _selectedCategory;

              bool matchesLocation = true;

              if (hasCityFilter) {
                final businessCity = business.address?.city
                    ?.trim()
                    .toLowerCase();
                matchesLocation =
                    matchesLocation && (businessCity == normalizedSelectCity);
              }

              if (hasStateFilter) {
                final businessState = business.address?.state
                    ?.trim()
                    .toLowerCase();
                matchesLocation =
                    matchesLocation && (businessState == normalizedSelectState);
              }

              final matchesSearch =
                  _searchQuery.isEmpty ||
                  (business.name?.toLowerCase().contains(normalizedSearch) ??
                      false) ||
                  (business.category?.toLowerCase().contains(
                        normalizedSearch,
                      ) ??
                      false) ||
                  (business.contact.toString().contains(normalizedSearch)) ||
                  (business.address?.city?.toLowerCase().contains(
                        normalizedSearch,
                      ) ??
                      false) ||
                  (business.address?.state?.toLowerCase().contains(
                        normalizedSearch,
                      ) ??
                      false) ||
                  (business.address?.lineOne?.toLowerCase().contains(
                        normalizedSearch,
                      ) ??
                      false);
              return matchesCategory && matchesLocation && matchesSearch;
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserContactScreen(uuid: user.uuid),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            business.name ?? 'Unknown',
                            style: GoogleFonts.mulish(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1D1E),
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              business.category ?? 'General',
                              style: GoogleFonts.mulish(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (business.contact != null)
                      InkWell(
                        onTap: () => _launchDialer(business.contact.toString()),
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F7),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.phone_outlined,
                            size: 20,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (business.address != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          [
                            business.address!.lineOne,
                            business.address!.lineTwo,
                            business.address!.city,
                            business.address!.state,
                          ].where((s) => s.isNotEmpty).join(', '),
                          style: GoogleFonts.mulish(
                            fontSize: 13,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                if (business.website != null && business.website!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.link, size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Flexible(
                          child: InkWell(
                            onTap: () => _launchUrl(business.website!),
                            child: Text(
                              business.website!,
                              style: GoogleFonts.mulish(
                                fontSize: 13,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
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

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Businesses',
                        style: GoogleFonts.mulish(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Category',
                    style: GoogleFonts.mulish(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChip('All', _selectedCategory == null, () {
                        setModalState(() {
                          _selectedCategory = null;
                        });
                      }),
                      ..._categories.map((category) {
                        return _buildFilterChip(
                          category,
                          _selectedCategory == category,
                          () {
                            setModalState(() {
                              if (_selectedCategory == category) {
                                _selectedCategory = null;
                              } else {
                                _selectedCategory = category;
                              }
                            });
                          },
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Location',
                    style: GoogleFonts.mulish(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CSCPicker(
                    showStates: true,
                    showCities: true,
                    flagState: CountryFlag.DISABLE,

                    dropdownDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),

                    disabledDropdownDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),

                    countrySearchPlaceholder: "Country",
                    stateSearchPlaceholder: "State",
                    citySearchPlaceholder: "City",

                    countryDropdownLabel: "Country",
                    stateDropdownLabel: "State",
                    cityDropdownLabel: "City",

                    currentCountry: _selectedCountry.isNotEmpty
                        ? _selectedCountry
                        : "India",
                    currentState: _selectedState,
                    currentCity: _selectedCity,

                    onCountryChanged: (value) {
                      setModalState(() {
                        _selectedCountry = value;
                      });
                    },
                    onStateChanged: (value) {
                      setModalState(() {
                        _selectedState = value ?? "";
                      });
                    },
                    onCityChanged: (value) {
                      setModalState(() {
                        _selectedCity = value ?? "";
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedCategory = null;
                              _selectedCountry = "India";
                              _selectedState = "";
                              _selectedCity = "";
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Clear All',
                            style: GoogleFonts.mulish(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Update parent state
                            setState(() {});
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Apply',
                            style: GoogleFonts.mulish(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.mulish(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
