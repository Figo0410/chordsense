import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'services/api_service.dart';

import 'new_password_screen.dart'; // Import the NewPasswordScreen

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSendResetLink() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar("Please enter your email address");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await ApiService.forgotPassword(email);
      _showSnackBar(res['message'] ?? "Reset code sent!");

      // Navigate to NewPasswordScreen and pass the user's email
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewPasswordScreen(email: email),
          ),
        );
      }
    } catch (e) {
      _showSnackBar(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF9333EA),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- BACK TO LOGIN ---
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  children: [
                    Icon(
                      LucideIcons.arrow_left,
                      color: Color(0xFF94A3B8),
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Back to Login",
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),

              // --- LOGO ICON ---
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF22D3EE), Color(0xFFA855F7)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFA855F7).withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    LucideIcons.music,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // --- FORM CONTAINER ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Reset Password",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Enter your email to receive a password reset link",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    ),
                    const SizedBox(height: 24),

                    // Email Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Email Address",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "your.email@example.com",
                            hintStyle: const TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              LucideIcons.mail,
                              color: Color(0xFF64748B),
                              size: 18,
                            ),
                            filled: true,
                            fillColor: const Color(0xFF020617),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFA855F7),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Send Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSendResetLink,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF06B6D4), Color(0xFFA855F7)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Send Reset Link",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
