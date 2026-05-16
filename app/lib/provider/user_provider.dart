import 'package:app/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _hasError = false;
  String? _errorMessage;

  User? get user => _user;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;

  Future<User?> fetchUser({bool forceRefresh = false}) async {
    if (!forceRefresh && _user != null) return _user;
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.get(
        Uri.parse(
          '${dotenv.env["BACKEND_URL"]!}/user/${prefs.getString("userId")}',
        ),
      );
      if (response.statusCode == 200) {
        _user = User.fromJson(json.decode(response.body));
        _hasError = false;
        _errorMessage = null;
        notifyListeners();
        return _user;
      } else {
        print('Error: ${response.statusCode}');
        _hasError = true;
        _errorMessage =
            'Failed to load user data (Status: ${response.statusCode})';
        notifyListeners();
        return null;
      }
    } catch (e) {
      print('Error: $e');
      _hasError = true;
      _errorMessage = 'Failed to connect to server';
      notifyListeners();
      return null;
    }
  }

  Future<bool> onboardUser({
    required int mobile,
    required String lineOne,
    String? lineTwo,
    required String city,
    required String state,
    required int zip,
    required DateTime birthDate,
    required String gender,
    DateTime? anniversaryDate,
    String? gaon,
    String? district,
    String? currentCity,
    String? maritalStatus,
    String? jobRole,
    String? companyName,
    String? fatherName,
    List<FamilyMember>? familyDetails,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final uuid = prefs.getString("userId");

    if (uuid == null) return false;

    try {
      final response = await http.post(
        Uri.parse('${dotenv.env["BACKEND_URL"]!}/auth/onboard'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "mobile": mobile,
          "lineOne": lineOne,
          "lineTwo": lineTwo,
          "city": city,
          "state": state,
          "zip": zip,
          "uuid": uuid,
          "birthDate": birthDate.toIso8601String(),
          "anniversaryDate": anniversaryDate?.toIso8601String(),
          "gender": gender,
          "gaon": gaon,
          "district": district,
          "currentCity": currentCity,
          "maritalStatus": maritalStatus,
          "jobRole": jobRole,
          "companyName": companyName,
          "fatherName": fatherName,
          "familyDetails": familyDetails?.map((e) => e.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        _user = User.fromJson(data["user"]);
        _hasError = false;
        _errorMessage = null;
        notifyListeners();

        return true;
      } else {
        debugPrint('Onboard error: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Onboard exception: $e');
      return false;
    }
  }

  Future<bool> onboardBusinessUser({
    required String lineOne,
    String? lineTwo,
    required String city,
    required String state,
    required int zip,
    required int contact,
    required String name,
    required String category,
    String? website,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final uuid = prefs.getString("userId");

    if (uuid == null) return false;

    try {
      final response = await http.post(
        Uri.parse('${dotenv.env["BACKEND_URL"]!}/auth/onboard-business/$uuid'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "lineOne": lineOne,
          "lineTwo": lineTwo,
          "city": city,
          "state": state,
          "zip": zip,
          "name": name,
          "category": category,
          "website": website,
          "contact": contact,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        _user = User.fromJson(data["user"]);
        // Ensure error state is cleared if successful
        _hasError = false;
        _errorMessage = null;
        notifyListeners();

        return true;
      } else {
        debugPrint('Onboard error: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Onboard exception: $e');
      return false;
    }
  }
  Future<bool> updateUserProfile({
    required int mobile,
    required String lineOne,
    String? lineTwo,
    required String city,
    required String state,
    required int zip,
    required DateTime birthDate,
    DateTime? anniversaryDate,
    String? gaon,
    String? district,
    String? currentCity,
    String? maritalStatus,
    String? jobRole,
    String? companyName,
    String? fatherName,
    List<FamilyMember>? familyDetails,
    bool? isMobileHidden,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final uuid = prefs.getString("userId");

    if (uuid == null) return false;

    try {
      final response = await http.put(
        Uri.parse('${dotenv.env["BACKEND_URL"]!}/user/$uuid'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "mobile": mobile,
          "address": {
            "lineOne": lineOne,
            "lineTwo": lineTwo ?? "",
            "city": city,
            "state": state,
            "zipCode": zip,
          },
          "birthDate": birthDate.toIso8601String(),
          "anniversaryDate": anniversaryDate?.toIso8601String(),
          "gaon": gaon,
          "district": district,
          "currentCity": currentCity,
           "maritalStatus": maritalStatus,
          "jobRole": jobRole,
          "companyName": companyName,
          "fatherName": fatherName,
          "familyDetails": familyDetails?.map((e) => e.toJson()).toList(),
          if (isMobileHidden != null) "isMobileHidden": isMobileHidden,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        _user = User.fromJson(data["user"]);
        _hasError = false;
        _errorMessage = null;
        notifyListeners();

        return true;
      } else {
        debugPrint('Update error: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Update exception: $e');
      return false;
    }
  }

  Future<bool> updateBusinessProfile({
    required String name,
    required String category,
    required int contact,
    String? website,
    required String lineOne,
    String? lineTwo,
    required String city,
    required String state,
    required int zip,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final uuid = prefs.getString("userId");

    if (uuid == null) return false;

    try {
      final response = await http.put(
        Uri.parse('${dotenv.env["BACKEND_URL"]!}/user/$uuid'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "business": {
            "name": name,
            "category": category,
            "contact": contact,
            "website": website ?? "",
            "address": {
              "lineOne": lineOne,
              "lineTwo": lineTwo ?? "",
              "city": city,
              "state": state,
              "zipCode": zip,
            }
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        _user = User.fromJson(data["user"]);
        _hasError = false;
        _errorMessage = null;
        notifyListeners();

        return true;
      } else {
        debugPrint('Update business error: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Update business exception: $e');
      return false;
    }
  }

  Future<bool> updateProfilePicture(File image) async {
    final prefs = await SharedPreferences.getInstance();
    final uuid = prefs.getString("userId");

    if (uuid == null) return false;

    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${dotenv.env["BACKEND_URL"]!}/user/$uuid/profile-picture'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var data = json.decode(responseData);

        _user = User.fromJson(data["user"]);
        _hasError = false;
        _errorMessage = null;
        notifyListeners();

        return true;
      } else {
        debugPrint('Upload error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Upload exception: $e');
      return false;
    }
  }

  Future<bool> updateBusinessLogo(File image) async {
    final prefs = await SharedPreferences.getInstance();
    final uuid = prefs.getString("userId");

    if (uuid == null) return false;

    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${dotenv.env["BACKEND_URL"]!}/user/$uuid/business-logo'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var data = json.decode(responseData);

        _user = User.fromJson(data["user"]);
        _hasError = false;
        _errorMessage = null;
        notifyListeners();

        return true;
      } else {
        debugPrint('Upload error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Upload exception: $e');
      return false;
    }
  }
}
