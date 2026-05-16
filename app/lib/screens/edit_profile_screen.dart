import 'package:app/constants/color.dart';
import 'package:app/models/user_model.dart';
import 'package:app/provider/user_provider.dart';
import 'package:app/widgets/location_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
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

  List<FamilyMember> _familyMembers = [];

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

  String stateValue = "";
  String cityValue = "";
  String maritalStatusValue = "";
  bool _isMobileHidden = false;

  DateTime? _birthDate;
  DateTime? _anniversaryDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<UserProvider>().user;
      if (user != null) {
        _phoneController.text = user.mobile.toString();
        _isMobileHidden = user.isMobileHidden;
        _birthDate = user.birthDate;
        if (_birthDate != null) {
          _birthDateController.text = "${_birthDate!.toLocal()}".split(' ')[0];
        }
        _anniversaryDate = user.anniversaryDate;
        if (_anniversaryDate != null) {
          _anniversaryDateController.text = "${_anniversaryDate!.toLocal()}"
              .split(' ')[0];
        }
        if (user.address != null) {
          _addressLine1Controller.text = user.address!.lineOne;
          _addressLine2Controller.text = user.address!.lineTwo;
          _zipCodeController.text = user.address!.zipCode.toString();
          stateValue = user.address!.state;
          cityValue = user.address!.city;
        }
        _gaonController.text = user.gaon ?? "";
        _districtController.text = user.district ?? "";
        maritalStatusValue = user.maritalStatus ?? "";
        _jobRoleController.text = user.jobRole ?? "";
        _companyNameController.text = user.companyName ?? "";
        _fatherNameController.text = user.fatherName ?? "";
        _familyMembers = user.familyDetails != null ? List.from(user.familyDetails!) : [];
        setState(() {}); // Trigger rebuild to show values in custom dropdown
      }
    });
  }

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
      initialDate: isBirthDate
          ? (_birthDate ?? DateTime.now())
          : (_anniversaryDate ?? DateTime.now()),
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
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowLeft01,
                size: 18,
              ),
              color: AppColors.primary,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          "Edit Profile",
          style: GoogleFonts.mulish(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Update your contact number.", style: GoogleFonts.mulish()),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: _inputDecoration("Mobile Number*"),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: Text("Hide Mobile Number", style: GoogleFonts.mulish()),
                subtitle: Text("Your number won't be visible to others", style: GoogleFonts.mulish(fontSize: 12, color: Colors.grey)),
                value: _isMobileHidden,
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                onChanged: (bool value) {
                  setState(() {
                    _isMobileHidden = value;
                  });
                },
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

              Text("Personal Details", style: GoogleFonts.mulish()),
              const SizedBox(height: 8),
              TextFormField(
                controller: _birthDateController,
                readOnly: true,
                onTap: () => _selectDate(context, true),
                decoration: _inputDecoration("Date of Birth*"),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
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
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(status, style: GoogleFonts.mulish()),
                      ),
                    )
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

              Text("Address Details", style: GoogleFonts.mulish()),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressLine1Controller,
                decoration: _inputDecoration("Address Line 1*"),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
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
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
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
                            if (stateValue.isEmpty || cityValue.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please select State and City.",
                                  ),
                                ),
                              );
                              return;
                            }
                            if (_birthDate == null) return;

                            setState(() => _isLoading = true);

                            final success = await context
                                .read<UserProvider>()
                                .updateUserProfile(
                                  mobile: int.parse(_phoneController.text),
                                  lineOne: _addressLine1Controller.text.trim(),
                                  lineTwo: _addressLine2Controller.text.trim(),
                                  city: cityValue,
                                  state: stateValue,
                                  zip: int.parse(_zipCodeController.text),
                                  birthDate: _birthDate!,
                                  anniversaryDate: _anniversaryDate,
                                  gaon: _gaonController.text.trim(),
                                  district: _districtController.text.trim(),
                                  currentCity: cityValue,
                                  maritalStatus: maritalStatusValue,
                                  jobRole: _jobRoleController.text.trim(),
                                  companyName: _companyNameController.text.trim(),
                                  fatherName: _fatherNameController.text.trim(),
                                  familyDetails: _familyMembers,
                                  isMobileHidden: _isMobileHidden,
                                );

                            setState(() => _isLoading = false);

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Profile updated successfully!",
                                  ),
                                ),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Failed to update profile"),
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
                          "Save Changes",
                          style: GoogleFonts.mulish(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
