import 'package:app/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  Future<User?> fetchUser() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.get(
        Uri.parse(
          '${dotenv.env["BACKEND_URL"]!}/user/${prefs.getString("userId")}',
        ),
      );
      if (response.statusCode == 200) {
        _user = User.fromJson(json.decode(response.body));
        notifyListeners();
        return _user;
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
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
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        _user = User.fromJson(data["user"]);
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
}
