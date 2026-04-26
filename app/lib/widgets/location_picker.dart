import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/indian_locations.dart';

class IndiaLocationPicker extends StatefulWidget {
  final String? selectedState;
  final String? selectedCity;
  final ValueChanged<String?> onStateChanged;
  final ValueChanged<String?> onCityChanged;
  final String stateDropdownLabel;
  final String cityDropdownLabel;

  const IndiaLocationPicker({
    super.key,
    this.selectedState,
    this.selectedCity,
    required this.onStateChanged,
    required this.onCityChanged,
    this.stateDropdownLabel = "State",
    this.cityDropdownLabel = "City",
  });

  @override
  State<IndiaLocationPicker> createState() => _IndiaLocationPickerState();
}

class _IndiaLocationPickerState extends State<IndiaLocationPicker> {
  String? _currentState;
  String? _currentCity;

  @override
  void initState() {
    super.initState();
    _currentState = widget.selectedState?.isEmpty == true ? null : widget.selectedState;
    _currentCity = widget.selectedCity?.isEmpty == true ? null : widget.selectedCity;
  }

  @override
  void didUpdateWidget(IndiaLocationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedState != oldWidget.selectedState) {
      _currentState = widget.selectedState?.isEmpty == true ? null : widget.selectedState;
    }
    if (widget.selectedCity != oldWidget.selectedCity) {
      _currentCity = widget.selectedCity?.isEmpty == true ? null : widget.selectedCity;
    }
  }

  @override
  Widget build(BuildContext context) {
    final states = IndianLocations.states;
    final cities = _currentState != null ? IndianLocations.getCities(_currentState!) : <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(
          hint: widget.stateDropdownLabel,
          value: _currentState,
          items: states,
          onChanged: (val) {
            setState(() {
              _currentState = val;
              _currentCity = null; // Reset city when state changes
            });
            widget.onStateChanged(val);
            widget.onCityChanged(null);
          },
        ),
        const SizedBox(height: 8),
        _buildDropdown(
          hint: widget.cityDropdownLabel,
          value: _currentCity,
          items: cities,
          onChanged: (val) {
            setState(() {
              _currentCity = val;
            });
            widget.onCityChanged(val);
          },
          isEnabled: _currentState != null && cities.isNotEmpty,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isEnabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isEnabled ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(
            hint,
            style: GoogleFonts.mulish(color: Colors.grey.shade600),
          ),
          value: items.contains(value) ? value : null,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
          style: GoogleFonts.mulish(color: Colors.black87, fontSize: 16),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          items: isEnabled
              ? items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList()
              : null,
          onChanged: isEnabled ? onChanged : null,
        ),
      ),
    );
  }
}
