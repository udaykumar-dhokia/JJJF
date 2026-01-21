import 'package:app/models/business_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BusinessProvider with ChangeNotifier {
  List<BusinessUser> _businesses = [];
  bool _isLoading = false;

  List<BusinessUser> get businesses => _businesses;
  bool get isLoading => _isLoading;

  Future<void> fetchBusinesses({bool forceRefresh = false}) async {
    if (!forceRefresh && _businesses.isNotEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('${dotenv.env["BACKEND_URL"]!}/business');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> businessesJson = data['businesses'];
        _businesses = businessesJson
            .map((json) => BusinessUser.fromJson(json))
            .toList();
      } else {
        debugPrint('Failed to fetch businesses: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('Error fetching businesses: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
