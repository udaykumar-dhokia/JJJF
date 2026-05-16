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
  final String? gender;
  final String? gaon;
  final String? district;
  final String? currentCity;
  final String? maritalStatus;
  final String? jobRole;
  final String? companyName;
  final String? fatherName;
  final List<FamilyMember>? familyDetails;
  final String? profilePicture;
  final bool isMobileHidden;

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
    required this.gender,
    this.business,
    this.gaon,
    this.district,
    this.currentCity,
    this.maritalStatus,
    this.jobRole,
    this.companyName,
    this.fatherName,
    this.familyDetails,
    this.profilePicture,
    this.isMobileHidden = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      gender: json['gender'],
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
      gaon: json['gaon'],
      district: json['district'],
      currentCity: json['currentCity'],
      maritalStatus: json['maritalStatus'],
      jobRole: json['jobRole'],
      companyName: json['companyName'],
      fatherName: json['fatherName'],
      familyDetails: json['familyDetails'] != null
          ? (json['familyDetails'] as List)
              .map((i) => FamilyMember.fromJson(i))
              .toList()
          : null,
      profilePicture: json['profilePicture'],
      isMobileHidden: json['isMobileHidden'] ?? false,
    );
  }
}

class FamilyMember {
  final String name;
  final String relation;
  final String occupation;

  FamilyMember({
    required this.name,
    required this.relation,
    required this.occupation,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      name: json['name'] ?? '',
      relation: json['relation'] ?? '',
      occupation: json['occupation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relation': relation,
      'occupation': occupation,
    };
  }
}
