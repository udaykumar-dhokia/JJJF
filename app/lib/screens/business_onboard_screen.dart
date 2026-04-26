import 'package:app/constants/color.dart';
import 'package:app/provider/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:app/widgets/location_picker.dart';

class BusinessOnboardScreen extends StatefulWidget {
  const BusinessOnboardScreen({super.key});

  @override
  State<BusinessOnboardScreen> createState() => _BusinessOnboardScreenState();
}

class _BusinessOnboardScreenState extends State<BusinessOnboardScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _selectedCategory;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  String _stateValue = '';
  String _cityValue = '';
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();

  final List<String> _businessCategories = [
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
    'Others',
  ];

  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _countryController.dispose();
    _zipCodeController.dispose();
    _contactController.dispose();
    _nameController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.mulish(color: AppColors.primary),
      hintText: hint,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Business Profile",
          style: GoogleFonts.mulish(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Complete your business profile by submitting the below details.",
                style: GoogleFonts.mulish(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 18),

              Text(
                "Tell us what is business called.",
                style: GoogleFonts.mulish(),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration("Name*"),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: _inputDecoration("Contact*"),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _websiteController,
                decoration: _inputDecoration("Wesbite"),
              ),
              const SizedBox(height: 16),

              Text(
                "Select your business category.",
                style: GoogleFonts.mulish(),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                initialValue: _selectedCategory,
                decoration: _inputDecoration("Category*"),
                items: _businessCategories
                    .map(
                      (category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category, style: GoogleFonts.mulish()),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a business category";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Text(
                "Tell us where your business live.",
                style: GoogleFonts.mulish(),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _addressLine1Controller,
                decoration: _inputDecoration("Address Line 1*"),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _addressLine2Controller,
                decoration: _inputDecoration(
                  "Address Line 2",
                  hint: "Optional",
                ),
              ),
              const SizedBox(height: 16),

              Text("Location Details", style: GoogleFonts.mulish()),
              SizedBox(height: 8),

              IndiaLocationPicker(
                selectedState: _stateValue,
                selectedCity: _cityValue,
                stateDropdownLabel: "State*",
                cityDropdownLabel: "City*",
                onStateChanged: (state) {
                  setState(() {
                    _stateValue = state ?? "";
                    _cityValue = "";
                  });
                },
                onCityChanged: (city) {
                  setState(() {
                    _cityValue = city ?? "";
                  });
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _countryController,
                decoration: _inputDecoration("Country*"),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _zipCodeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: _inputDecoration("Zip Code*"),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            if (_stateValue.isEmpty || _cityValue.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Please select State and City.")),
                              );
                              return;
                            }
                            setState(() => _isLoading = true);
                            final success = await context
                                .read<UserProvider>()
                                .onboardBusinessUser(
                                  lineOne: _addressLine1Controller.text.trim(),
                                  lineTwo: _addressLine2Controller.text.trim(),
                                  city: _cityValue,
                                  state: _stateValue,
                                  zip: int.parse(_zipCodeController.text),
                                  category: _selectedCategory!,
                                  contact: int.parse(_contactController.text),
                                  name: _nameController.text.trim(),
                                  website: _websiteController.text.trim(),
                                );

                            setState(() => _isLoading = false);

                            if (success) {
                              Navigator.of(context).pop();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Failed to complete onboarding",
                                  ),
                                ),
                              );
                            }
                          }
                        },
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CupertinoActivityIndicator(
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          "Continue",
                          style: GoogleFonts.mulish(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
