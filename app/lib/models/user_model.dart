import 'package:app/models/address_model.dart';
import 'package:app/models/business_model.dart';

class User {
  final String id;
  final String uuid;
  final String firstName;
  final String lastName;
  final String email;
  final bool isProfileCompleted;
  final bool isBusinessCompleted;
  final int? mobile;
  final DateTime? birthDate;
  final DateTime? anniversaryDate;
  final Address? address;
  final BusinessData? business;

  User({
    required this.id,
    required this.uuid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.isProfileCompleted,
    required this.isBusinessCompleted,
    this.mobile,
    this.birthDate,
    this.anniversaryDate,
    this.address,
    this.business,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      uuid: json['uuid'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      isProfileCompleted: json['isProfileCompleted'] ?? false,
      isBusinessCompleted: json['isBusinessCompleted'] ?? false,
      mobile: json['mobile'],
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'])
          : null,
      anniversaryDate: json['anniversaryDate'] != null
          ? DateTime.parse(json['anniversaryDate'])
          : null,
      business: json['business'] != null
          ? BusinessData.fromJson(json['business'])
          : null,
      address: json['address'] != null
          ? Address.fromJson(json['address'])
          : null,
    );
  }
}
