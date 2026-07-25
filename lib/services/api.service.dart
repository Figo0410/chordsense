import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Android Emulator: http://10.0.2.2:5000/api
  // iOS Simulator / Desktop / Web: http://localhost:5000/api
  // Physical Mobile Device: http://<YOUR_COMPUTER_LOCAL_IP>:5000/api
  static const String baseUrl = 'http://10.0.2.2:5000/api';

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
}
