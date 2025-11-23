// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
// No provider/auth imports required for this simplified informational screen.
import '../../app/app_routes.dart';

class ResetWithOtpScreen extends StatefulWidget {
  const ResetWithOtpScreen({super.key});

  @override
  _ResetWithOtpScreenState createState() => _ResetWithOtpScreenState();
}

class _ResetWithOtpScreenState extends State<ResetWithOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String otp = '';
  String newPassword = '';
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    // AuthService not needed on this screen anymore.

    return Scaffold(
      appBar: AppBar(title: const Text('Reset password (enter OTP)')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Enter the OTP you received and choose a new password.',
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // OTP flow removed. Use the password-reset email sent from the "Forgot password" screen.
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'This app uses Firebase password-reset links. Please request a reset from the previous screen and follow the link in your email to change your password.',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        // OTP flow removed; instruct user to use the email link.
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Use the password-reset link sent to your email.'),
                          ),
                        );
                        Navigator.pushReplacementNamed(context, AppRoutes.login);
                      },
                      child: const Text('Back to login'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
