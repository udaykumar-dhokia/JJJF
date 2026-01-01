import 'package:app/models/address_model.dart';

class Business {
  final String? name;
  final String? category;
  final int? contact;
  final String? website;
  final Address? address;

  Business({
    this.name,
    this.category,
    this.contact,
    this.website,
    this.address,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      name: json['name'] as String?,
      category: json['category'] as String?,
      contact: json['contact'] as int?,
      website: json['website'] as String?,
      address: json['address'] != null
          ? Address.fromJson(json['address'] as Map<String, dynamic>)
          : null,
    );
  }
}
