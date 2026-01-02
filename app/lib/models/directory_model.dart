import 'package:app/models/address_model.dart';

class DirectoryUser {
  final String uuid;
  final String firstName;
  final String lastName;
  final String email;
  final String? mobile;
  final Address? address;

  DirectoryUser({
    required this.uuid,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.mobile,
    this.address,
  });

  factory DirectoryUser.fromJson(Map<String, dynamic> json) {
    return DirectoryUser(
      uuid: json['uuid'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile']?.toString(),
      address: json['address'] != null
          ? Address.fromJson(json['address'])
          : null,
    );
  }
}
