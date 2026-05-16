import 'package:app/models/address_model.dart';

class DirectoryUser {
  final String uuid;
  final String firstName;
  final String lastName;
  final String email;
  final String? mobile;
  final Address? address;
  final String? fatherName;

  DirectoryUser({
    required this.uuid,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.mobile,
    this.address,
    this.fatherName,
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
      fatherName: json['fatherName'],
    );
  }
}

class DirectoryEvent {
  final String type; // 'birthday' or 'anniversary'
  final DateTime eventDate; // The upcoming date in current/next year
  final DateTime? originalDate; // The actual birth/anniversary date
  final DirectoryUser user;

  DirectoryEvent({
    required this.type,
    required this.eventDate,
    this.originalDate,
    required this.user,
  });

  factory DirectoryEvent.fromJson(Map<String, dynamic> json) {
    return DirectoryEvent(
      type: json['type'],
      eventDate: DateTime.parse(json['eventDate']),
      originalDate: json['originalDate'] != null
          ? DateTime.parse(json['originalDate'])
          : null,
      user: DirectoryUser.fromJson(json['user']),
    );
  }
}
