import 'package:app/bottom_bar.dart';
import 'package:app/constants/color.dart';
import 'package:app/models/user_model.dart';
import 'package:app/provider/user_provider.dart';
import 'package:app/widgets/location_picker.dart';
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
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _anniversaryDateController =
      TextEditingController();
  final TextEditingController _gaonController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _jobRoleController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();

  final List<FamilyMember> _familyMembers = [];

  void _addFamilyMember() {
    setState(() {
      _familyMembers.add(FamilyMember(name: "", relation: "", occupation: ""));
    });
  }

  void _removeFamilyMember(int index) {
    setState(() {
      _familyMembers.removeAt(index);
    });
  }

  void _updateFamilyMember(int index, {String? name, String? relation, String? occupation}) {
    setState(() {
      _familyMembers[index] = FamilyMember(
        name: name ?? _familyMembers[index].name,
        relation: relation ?? _familyMembers[index].relation,
        occupation: occupation ?? _familyMembers[index].occupation,
      );
    });
  }

  String genderValue = "";
  String maritalStatusValue = "";
  String countryValue = "India";
  String stateValue = "";
  String cityValue = "";

  DateTime? _birthDate;
  DateTime? _anniversaryDate;

  @override
  void dispose() {
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _zipCodeController.dispose();
    _birthDateController.dispose();
    _anniversaryDateController.dispose();
    _gaonController.dispose();
    _districtController.dispose();
    _jobRoleController.dispose();
    _companyNameController.dispose();
    _fatherNameController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(
    String label, {
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.mulish(color: AppColors.primary),
      hintText: hint,
      suffixIcon: suffixIcon,
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

  Future<void> _selectDate(BuildContext context, bool isBirthDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isBirthDate) {
          _birthDate = picked;
          _birthDateController.text = "${picked.toLocal()}".split(' ')[0];
        } else {
          _anniversaryDate = picked;
          _anniversaryDateController.text = "${picked.toLocal()}".split(' ')[0];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
        physics: BouncingScrollPhysics(),
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
              const SizedBox(height: 16),

              TextFormField(
                controller: _fatherNameController,
                decoration: _inputDecoration("Father's Name*"),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              Text("Family Details", style: GoogleFonts.mulish(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._familyMembers.asMap().entries.map((entry) {
                int idx = entry.key;
                FamilyMember member = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: AppColors.primaryLight.withAlpha(10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Family Member ${idx + 1}",
                                style: GoogleFonts.mulish(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                              onPressed: () => _removeFamilyMember(idx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: member.name,
                          decoration: _inputDecoration("Name"),
                          onChanged: (val) => _updateFamilyMember(idx, name: val),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: member.relation,
                                decoration: _inputDecoration("Relation"),
                                onChanged: (val) => _updateFamilyMember(idx, relation: val),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                initialValue: member.occupation,
                                decoration: _inputDecoration("Occupation"),
                                onChanged: (val) => _updateFamilyMember(idx, occupation: val),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              
              OutlinedButton.icon(
                onPressed: _addFamilyMember,
                icon: const Icon(Icons.add, size: 18),
                label: Text("Add Family Member", style: GoogleFonts.mulish()),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),

              Text("Personal Details.", style: GoogleFonts.mulish()),
              const SizedBox(height: 8),

              Text("Gender*", style: GoogleFonts.mulish()),
              const SizedBox(height: 8),

              Row(
                children: ["Male", "Female", "Other"].map((gender) {
                  final bool isSelected = genderValue == gender;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          genderValue = gender;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected ? AppColors.primary : Colors.white,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            gender,
                            style: GoogleFonts.mulish(
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _birthDateController,
                readOnly: true,
                onTap: () => _selectDate(context, true),
                decoration: _inputDecoration("Date of Birth*"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your birth date';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _anniversaryDateController,
                readOnly: true,
                onTap: () => _selectDate(context, false),
                decoration: _inputDecoration(
                  "Anniversary Date",
                  hint: "Optional",
                ),
              ),
              const SizedBox(height: 16),

              Text("Marital Status*", style: GoogleFonts.mulish()),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                value: maritalStatusValue.isEmpty ? null : maritalStatusValue,
                decoration: _inputDecoration("Marital Status*"),
                items: ["Single", "Married", "Widowed", "Divorced"]
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status, style: GoogleFonts.mulish()),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    maritalStatusValue = val ?? "";
                  });
                },
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              Text("Native Place (Gaon)", style: GoogleFonts.mulish()),
              const SizedBox(height: 8),

              TextFormField(
                controller: _gaonController,
                decoration: _inputDecoration("Gaon (Village)*"),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _districtController,
                decoration: _inputDecoration("District*"),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              Text("Current Job Role", style: GoogleFonts.mulish()),
              const SizedBox(height: 8),

              TextFormField(
                controller: _jobRoleController,
                decoration: _inputDecoration("Job Role"),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _companyNameController,
                decoration: _inputDecoration("Company Name"),
              ),
              const SizedBox(height: 16),

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

              Text("Location Details", style: GoogleFonts.mulish()),
              SizedBox(height: 8),

              IndiaLocationPicker(
                selectedState: stateValue,
                selectedCity: cityValue,
                stateDropdownLabel: "State*",
                cityDropdownLabel: "City*",
                onStateChanged: (state) {
                  setState(() {
                    stateValue = state ?? "";
                    cityValue = "";
                  });
                },
                onCityChanged: (city) {
                  setState(() {
                    cityValue = city ?? "";
                  });
                },
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
                                  city: cityValue,
                                  state: stateValue,
                                  zip: int.parse(_zipCodeController.text),
                                  birthDate: _birthDate!,
                                  gender: genderValue,
                                  anniversaryDate: _anniversaryDate,
                                  gaon: _gaonController.text.trim(),
                                  district: _districtController.text.trim(),
                                  currentCity: cityValue,
                                  maritalStatus: maritalStatusValue,
                                  jobRole: _jobRoleController.text.trim(),
                                  companyName: _companyNameController.text.trim(),
                                  fatherName: _fatherNameController.text.trim(),
                                  familyDetails: _familyMembers,
                                );

                            setState(() => _isLoading = false);

                            if (success) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BottomBar(),
                                ),
                              );
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
