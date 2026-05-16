import 'package:app/models/address_model.dart';

class BusinessData {
  final String? name;
  final String? category;
  final int? contact;
  final String? website;
  final Address? address;
  final String? logo;

  BusinessData({
    this.name,
    this.category,
    this.contact,
    this.website,
    this.address,
    this.logo,
  });

  factory BusinessData.fromJson(Map<String, dynamic> json) {
    return BusinessData(
      name: json['name'] as String?,
      category: json['category'] as String?,
      contact: json['contact'] as int?,
      website: json['website'] as String?,
      logo: json['logo'] as String?,
      address: json['address'] != null
          ? Address.fromJson(json['address'] as Map<String, dynamic>)
          : null,
    );
  }
}

class BusinessUser {
  final BusinessData? business;
  final String uuid;
  final String? firstName;
  final String? lastName;
  final String? profilePicture;

  BusinessUser({
    this.business,
    required this.uuid,
    this.firstName,
    this.lastName,
    this.profilePicture,
  });

  factory BusinessUser.fromJson(Map<String, dynamic> json) {
    return BusinessUser(
      business: json['business'] != null
          ? BusinessData.fromJson(json['business'] as Map<String, dynamic>)
          : null,
      uuid: json['uuid'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      profilePicture: json['profilePicture'] as String?,
    );
  }
}
