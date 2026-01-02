import 'package:app/models/directory_model.dart';
import 'package:app/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DirectoryProvider with ChangeNotifier {
  List<DirectoryUser> _users = [];
  bool _isLoading = false;

  List<DirectoryUser> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> fetchDirectoryUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");

    if (userId == null) {
      debugPrint('No user ID found in shared preferences');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('${dotenv.env["BACKEND_URL"]!}/directory/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> usersJson = data['users'];
        _users = usersJson.map((json) => DirectoryUser.fromJson(json)).toList();
      } else {
        debugPrint('Failed to fetch directory users: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('Error fetching directory users: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<User?> fetchUserDetails(String uuid) async {
    try {
      final url = Uri.parse(
        '${dotenv.env["BACKEND_URL"]!}/directory/user/$uuid',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data['user']);
      } else {
        debugPrint('Failed to fetch user details: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      debugPrint('Error fetching user details: $error');
      return null;
    }
  }
}
