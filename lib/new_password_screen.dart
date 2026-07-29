import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../services/api.service.dart';

class NewPasswordScreen extends StatefulWidget {
  final String email;

  const NewPasswordScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleResetPassword() async {
    final code = _codeController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    if (code.isEmpty || newPassword.isEmpty) {
      _showSnackBar("Please fill in all fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await ApiService.resetPassword(
        widget.email,
        code,
        newPassword,
      );
      _showSnackBar(res['message'] ?? "Password updated successfully!");

      // Return to Login Screen
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
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
      backgroundColor: const Color(0xFF030712),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      "Back",
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
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
                      "Enter Reset Code",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Enter the 6-digit code sent to ${widget.email}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Code Input
                    TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        color: Colors.white,
                        letterSpacing: 4,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: "123456",
                        hintStyle: const TextStyle(
                          color: Color(0xFF475569),
                          letterSpacing: 0,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF020617),
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
                    const SizedBox(height: 16),

                    // New Password Input
                    TextField(
                      controller: _newPasswordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Enter new password",
                        hintStyle: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          LucideIcons.lock,
                          color: Color(0xFF64748B),
                          size: 18,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF020617),
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
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleResetPassword,
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
                                    "Update Password",
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
