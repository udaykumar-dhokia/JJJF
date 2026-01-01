import 'package:app/constants/color.dart';
import 'package:app/provider/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _zipCodeController.dispose();
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
          "Profile",
          style: GoogleFonts.mulish(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Complete your profile by submitting the below details to continue using the application and stay connected with community.",
                style: GoogleFonts.mulish(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 18),
              Text("Tell us your contact number.", style: GoogleFonts.mulish()),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: _inputDecoration("Mobile Number*"),
              ),
              const SizedBox(height: 8),

              Text("Tell us where do you live.", style: GoogleFonts.mulish()),
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

              TextFormField(
                controller: _cityController,
                decoration: _inputDecoration("City*"),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _stateController,
                decoration: _inputDecoration("State*"),
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
                            setState(() => _isLoading = true);
                            final success = await context
                                .read<UserProvider>()
                                .onboardUser(
                                  mobile: int.parse(_phoneController.text),
                                  lineOne: _addressLine1Controller.text.trim(),
                                  lineTwo: _addressLine2Controller.text.trim(),
                                  city: _cityController.text.trim(),
                                  state: _stateController.text.trim(),
                                  zip: int.parse(_zipCodeController.text),
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
