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

    // 1. Success case
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    // 2. Safe error handling: check if response is actually JSON before decoding
    final contentType = response.headers['content-type'] ?? '';
    if (contentType.contains('application/json')) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to log in');
    } else {
      // Server returned HTML (e.g., 404 Not Found or 500 Internal Error)
      throw Exception(
        'Server returned status ${response.statusCode}. Check if route /api/auth/login exists on your backend.',
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

    // Safe JSON check for error response
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
}
