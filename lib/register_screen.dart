import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'services/api_service.dart'; // Import your ApiService

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _handleRegister() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validations
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill in all fields");
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiService.register(username, email, password);
      _showSnackBar("Account created! Please log in.");

      // Navigate back to Login Screen after successful registration
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
      backgroundColor: const Color(0xFF030712), // Dark Slate Background
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
              const SizedBox(height: 40),

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
                      "Create Account",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Username Input
                    _buildInputField(
                      label: "Username",
                      hint: "Choose a username",
                      icon: LucideIcons.user,
                      controller: _usernameController,
                    ),
                    const SizedBox(height: 16),

                    // Email Input
                    _buildInputField(
                      label: "Email",
                      hint: "Enter your email",
                      icon: LucideIcons.mail,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 16),

                    // Password Input
                    _buildInputField(
                      label: "Password",
                      hint: "Create a password",
                      icon: LucideIcons.lock,
                      isPassword: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password Input
                    _buildInputField(
                      label: "Confirm Password",
                      hint: "Confirm your password",
                      icon: LucideIcons.lock,
                      isPassword: true,
                      controller: _confirmPasswordController,
                    ),
                    const SizedBox(height: 24),

                    // Create Account Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
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
                                    "Create Account",
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

  // --- REUSABLE INPUT FIELD WIDGET ---
  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF475569), fontSize: 13),
            prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 18),
            filled: true,
            fillColor: const Color(0xFF020617),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF1E293B)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFA855F7)),
            ),
          ),
        ),
      ],
    );
  }
}
