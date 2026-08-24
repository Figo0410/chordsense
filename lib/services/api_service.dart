import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class ApiService {
  static String? _cachedBaseUrl;

  /// Candidate list of host IPs to scan dynamically (Add any common static IP here)
  static const List<String> _candidateHosts = [
    '192.168.254.112', // Physical phone Wi-Fi
    '192.168.43.208',  // Physical phone Hotspot
    '10.0.2.2',        // Android Emulator Loopback
    'localhost',       // iOS Simulator / Web
  ];

  static String get baseUrl {
    if (_cachedBaseUrl != null) return _cachedBaseUrl!;

    if (kIsWeb) {
      _cachedBaseUrl = 'http://localhost:5000/api';
      return _cachedBaseUrl!;
    }

    return 'http://192.168.254.112:5000/api';
  }

  static void resetCachedUrl() {
    _cachedBaseUrl = null;
  }

  static Future<String> initBaseUrl() async {
    if (kIsWeb) {
      _cachedBaseUrl = 'http://localhost:5000/api';
      return _cachedBaseUrl!;
    }

    if (_cachedBaseUrl != null) {
      final Uri uri = Uri.parse(_cachedBaseUrl!);
      if (await _isHostReachable(uri.host, uri.port)) {
        return _cachedBaseUrl!;
      }
    }

    for (String host in _candidateHosts) {
      if (await _isHostReachable(host, 5000)) {
        _cachedBaseUrl = 'http://$host:5000/api';
        return _cachedBaseUrl!;
      }
    }

    _cachedBaseUrl = 'http://192.168.254.112:5000/api';
    return _cachedBaseUrl!;
  }

  static Future<bool> _isHostReachable(String host, int port) async {
    try {
      final socket = await Socket.connect(host, port, timeout: const Duration(milliseconds: 800));
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<http.Response> _safeApiCall(Future<http.Response> Function() requestFn) async {
    try {
      return await requestFn();
    } catch (e) {
      resetCachedUrl();
      await initBaseUrl();
      return await requestFn();
    }
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await _safeApiCall(() => http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    ));

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

  static Future<Map<String, dynamic>> syncWithCloud() async {
    final response = await _safeApiCall(() => http.post(
      Uri.parse('$baseUrl/sync/push'),
      headers: {'Content-Type': 'application/json'},
    ));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Database sync failed or no internet connection.');
    }
  }

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final response = await _safeApiCall(() => http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    ));

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
    final response = await _safeApiCall(() => http.post(
      Uri.parse('$baseUrl/auth/send-register-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    ));

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
    final response = await _safeApiCall(() => http.post(
      Uri.parse('$baseUrl/auth/verify-register-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    ));

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
    final response = await _safeApiCall(() => http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    ));

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
    final response = await _safeApiCall(() => http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    ));

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
    final response = await _safeApiCall(() => http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'resetToken': resetToken,
        'newPassword': newPassword,
      }),
    ));

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
    final response = await _safeApiCall(() => http.get(
      Uri.parse('$baseUrl/songs'),
      headers: {'Content-Type': 'application/json'},
    ));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch songs from server.');
    }
  }

  static Future<List<dynamic>> searchSongs(String query) async {
    final response = await _safeApiCall(() => http.get(
      Uri.parse('$baseUrl/songs/search?q=${Uri.encodeComponent(query)}'),
      headers: {'Content-Type': 'application/json'},
    ));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to search songs.');
    }
  }

  static Future<Map<String, dynamic>> getSongById(String id) async {
    final response = await _safeApiCall(() => http.get(
      Uri.parse('$baseUrl/songs/$id'),
      headers: {'Content-Type': 'application/json'},
    ));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch song details.');
    }
  }

  static Future<List<dynamic>> getLearningPaths() async {
    final response = await _safeApiCall(() => http.get(
      Uri.parse('$baseUrl/learning-path'),
      headers: {'Content-Type': 'application/json'},
    ));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch learning path from server.');
    }
  }

  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final response = await _safeApiCall(() => http.get(
      Uri.parse('$baseUrl/auth/user/$userId'),
      headers: {'Content-Type': 'application/json'},
    ));

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
    final response = await _safeApiCall(() => http.patch(
      Uri.parse('$baseUrl/auth/user/$userId/progress'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    ));

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
    final response = await _safeApiCall(() => http.patch(
      Uri.parse('$baseUrl/auth/user/$userId/tuner-status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'hasCompletedTuner': hasCompletedTuner}),
    ));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update tuner status.');
    }
  }

  static Future<List<dynamic>> getLeaderboard([String sortBy = 'accuracy']) async {
    final response = await _safeApiCall(() => http.get(
      Uri.parse('$baseUrl/auth/leaderboard?sortBy=$sortBy'),
      headers: {'Content-Type': 'application/json'},
    ));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
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
        "totalPoints": pointsEarned,
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

      final progressResponse = await _safeApiCall(() => http.patch(
        Uri.parse('$baseUrl/auth/user/$userId/progress'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'levelId': levelId,
          'levelNumber': levelId,
          'pointsEarned': pointsEarned,
          'totalPoints': pointsEarned,
          'accuracy': accuracy,
          'completed': true,
          'completedLevel': {
            'levelNumber': levelId,
            'accuracy': accuracy,
            'progress': 1.0,
          },
          'chordsCompleted': chordsList,
        }),
      ));
      if (progressResponse.statusCode == 200) {
        result = jsonDecode(progressResponse.body);
      }
    } catch (_) {}

    return result;
  }
}