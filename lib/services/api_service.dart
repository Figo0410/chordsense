import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    } else {
      return 'http://10.0.2.2:5000/api';
    }
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    final contentType = response.headers['content-type'] ?? '';
    if (contentType.contains('application/json')) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to complete request');
    } else {
      throw Exception('Server returned status ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    final contentType = response.headers['content-type'] ?? '';
    if (contentType.contains('application/json')) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to log in');
    } else {
      throw Exception(
        'Server returned status ${response.statusCode}. Check if route /api/auth/login exists on your backend.',
      );
    }
  }

  static Future<Map<String, dynamic>> sendRegisterOtp(
    String username,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/send-register-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    final contentType = response.headers['content-type'] ?? '';
    if (contentType.contains('application/json')) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to send verification code');
    } else {
      throw Exception(
        'Server returned status ${response.statusCode}. Check backend routes.',
      );
    }
  }

  static Future<Map<String, dynamic>> verifyRegisterOtp(
    String email,
    String code,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-register-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    final contentType = response.headers['content-type'] ?? '';
    if (contentType.contains('application/json')) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to verify code');
    } else {
      throw Exception(
        'Server returned status ${response.statusCode}. Check backend routes.',
      );
    }
  }

  static Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    final contentType = response.headers['content-type'] ?? '';
    if (contentType.contains('application/json')) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Registration failed');
    } else {
      throw Exception(
        'Server returned status ${response.statusCode}. Check if route /api/auth/register exists on your backend.',
      );
    }
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    final contentType = response.headers['content-type'] ?? '';
    if (contentType.contains('application/json')) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to send reset link');
    } else {
      throw Exception(
        'Server error (${response.statusCode}). Check backend routes.',
      );
    }
  }

  static Future<Map<String, dynamic>> resetPassword(
    String email,
    String resetToken,
    String newPassword,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'resetToken': resetToken,
        'newPassword': newPassword,
      }),
    );

    final contentType = response.headers['content-type'] ?? '';
    if (contentType.contains('application/json')) {
      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return body;
      }
      throw Exception(body['message'] ?? 'Failed to reset password');
    } else {
      throw Exception('Server error (${response.statusCode}).');
    }
  }

  static Future<List<dynamic>> getSongs() async {
    final response = await http.get(
      Uri.parse('$baseUrl/songs'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch songs from server.');
    }
  }

  static Future<List<dynamic>> getLearningPaths() async {
    final response = await http.get(
      Uri.parse('$baseUrl/learning-path'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch learning path from server.');
    }
  }

  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/user/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch user progress.');
    }
  }

  static Future<Map<String, dynamic>> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/auth/user/$userId/progress'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update user profile.');
    }
  }

  static Future<Map<String, dynamic>> updateTunerStatus(
    String userId,
    bool hasCompletedTuner,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/auth/user/$userId/tuner-status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'hasCompletedTuner': hasCompletedTuner}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update tuner status.');
    }
  }

  static Future<Map<String, dynamic>> savePracticeSession({
    required String userId,
    required int levelId,
    required String chordPracticed,
    required int totalAttempts,
    required int correctAttempts,
    required int incorrectAttempts,
    required int accuracy,
    required int pointsEarned,
    required int duration,
  }) async {
    Map<String, dynamic> result = {};

    try {
      result = await post('/auth/save-session', {
        "userId": userId,
        "levelId": levelId,
        "chordPracticed": chordPracticed,
        "totalAttempts": totalAttempts,
        "correctAttempts": correctAttempts,
        "incorrectAttempts": incorrectAttempts,
        "accuracy": accuracy,
        "pointsEarned": pointsEarned,
        "duration": duration,
        "isPerfect100": accuracy >= 100,
      });
    } catch (_) {}

    try {
      final List<String> chordsList = chordPracticed
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final progressResponse = await http.patch(
        Uri.parse('$baseUrl/auth/user/$userId/progress'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'levelId': levelId,
          'levelNumber': levelId,
          'pointsEarned': pointsEarned,
          'accuracy': accuracy,
          'completed': true,
          'completedLevel': {
            'levelNumber': levelId,
            'accuracy': accuracy,
            'progress': 1.0,
          },
          'chordsCompleted': chordsList,
          'currentLevel': levelId + 1,
          'progressPercent': 100,
        }),
      );
      if (progressResponse.statusCode == 200) {
        result = jsonDecode(progressResponse.body);
      }
    } catch (_) {}

    return result;
  }
}
