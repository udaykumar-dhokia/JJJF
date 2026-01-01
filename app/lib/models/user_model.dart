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
  final Address? address;
  final Business? business;

  User({
    required this.id,
    required this.uuid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.isProfileCompleted,
    required this.isBusinessCompleted,
    this.mobile,
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
      business: json['business'] != null
          ? Business.fromJson(json['business'])
          : null,
      address: json['address'] != null
          ? Address.fromJson(json['address'])
          : null,
    );
  }
}
