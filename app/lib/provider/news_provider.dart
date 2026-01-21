import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app/models/news_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewsProvider with ChangeNotifier {
  List<News> _newsList = [];

  List<News> get newsList => _newsList;

  Future<void> fetchNews({bool forceRefresh = false}) async {
    if (!forceRefresh && _newsList.isNotEmpty) return;
    try {
      final response = await http.get(
        Uri.parse('${dotenv.env["BACKEND_URL"]!}/news'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _newsList = (data['news'] as List)
            .map((item) => News.fromJson(item))
            .toList();
        // Sort by newest first
        _newsList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        notifyListeners();
      } else {
        debugPrint('Error fetching news: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching news: $e');
    }
  }

  Future<bool> createNews({
    required String title,
    required String content,
    required String authorName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");

    if (userId == null) return false;

    try {
      final response = await http.post(
        Uri.parse('${dotenv.env["BACKEND_URL"]!}/news/$userId'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "title": title,
          "content": content,
          "authorName": authorName,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final newNews = News.fromJson(data['news']);
        _newsList.insert(0, newNews);
        notifyListeners();
        return true;
      } else {
        debugPrint('Error creating news: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error creating news: $e');
      return false;
    }
  }
}
