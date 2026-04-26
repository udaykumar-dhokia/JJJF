import 'package:app/models/job_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JobProvider with ChangeNotifier {
  List<JobData> _jobs = [];
  bool _isLoading = false;
  bool _isSubmitting = false;

  List<JobData> get jobs => _jobs;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;

  Future<void> fetchJobs({bool forceRefresh = false}) async {
    if (!forceRefresh && _jobs.isNotEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('${dotenv.env["BACKEND_URL"]!}/jobs');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> jobsJson = data['jobs'] ?? [];
        _jobs = jobsJson.map((json) => JobData.fromJson(json)).toList();
      } else {
        debugPrint('Failed to fetch jobs: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('Error fetching jobs: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createJob({
    required String userId,
    required String title,
    required String description,
    required String type,
    required String role,
    required String city,
    required String state,
    required String contactName,
    required String contactPhone,
    String? contactEmail,
    String? link,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      final url = Uri.parse('${dotenv.env["BACKEND_URL"]!}/jobs/$userId');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'description': description,
          'type': type,
          'role': role,
          'city': city,
          'state': state,
          'contactName': contactName,
          'contactPhone': contactPhone,
          'contactEmail': contactEmail,
          'link': link,
        }),
      );

      if (response.statusCode == 201) {
        // Refresh list to include new job (once approved it will appear)
        await fetchJobs(forceRefresh: true);
        return true;
      } else {
        debugPrint('Failed to create job: ${response.body}');
        return false;
      }
    } catch (error) {
      debugPrint('Error creating job: $error');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> applyToJob({
    required String jobId,
    required String userId,
    required String message,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      final url =
          Uri.parse('${dotenv.env["BACKEND_URL"]!}/jobs/$jobId/apply/$userId');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Failed to apply to job: ${response.body}');
        return false;
      }
    } catch (error) {
      debugPrint('Error applying to job: $error');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}

