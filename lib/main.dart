import 'package:flutter/material.dart';
import 'login_screen.dart'; // Imports your custom login design

// User after login
import 'user_dashboard.dart';

// Admin after login
import 'admin_screen.dart';

// Registration screen
import 'register_screen.dart';

// Forgot Password screen
import 'forgot_password_screen.dart';

void main() {
  runApp(const ChordSenseApp());
}

class ChordSenseApp extends StatelessWidget {
  const ChordSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChordSense',
      debugShowCheckedModeBanner: false,

      // Setting a dark theme globally to match your UI
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617), // slate-950
        primaryColor: const Color(0xFF06B6D4), // cyan-500
      ),

      // Your app starts on the LoginScreen
      initialRoute: '/',

      // Route definitions using onGenerateRoute to safely pass arguments
      onGenerateRoute: (settings) {
        if (settings.name == '/user') {
          final userData = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => UserDashboard(userData: userData),
          );
        }
        return null;
      },

      routes: {
        '/': (context) => const LoginScreen(),
        '/admin': (context) => const AdminDashboardScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
      },
    );
  }
}

// --- Placeholder Screen ---
class DummyDashboard extends StatelessWidget {
  final String title;
  final Color color;

  const DummyDashboard({super.key, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/'), // Go back to login
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.door_sliding_outlined, size: 80, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Navigation successful! Ready for your layout.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
