import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Android Emulator: http://10.0.2.2:5000/api
  // iOS Simulator / Desktop / Web: http://localhost:5000/api
  // Physical Mobile Device: http://<YOUR_COMPUTER_LOCAL_IP>:5000/api
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    } else {
      return 'http://10.0.2.2:5000/api';
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

  // Send 6-digit verification code to email before registration
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

  // Verify 6-digit registration code and complete account creation
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

  // Register a new user
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

  // Forgot Password
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

  // Fetch all songs from MongoDB
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

  // Fetch all learning path levels from MongoDB
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

  // Fetch logged-in user profile & progress data from MongoDB
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

  // Update user's tuner completion status in MongoDB
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
}
