// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
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
    final auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Reset password (enter OTP)')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text('Enter the OTP you received and choose a new password.'),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) => v != null && v.contains('@') ? null : 'Enter valid email',
                      onSaved: (v) => email = v?.trim() ?? '',
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      decoration: const InputDecoration(labelText: 'OTP'),
                      onSaved: (v) => otp = v?.trim() ?? '',
                      validator: (v) => (v?.isNotEmpty ?? false) ? null : 'Enter OTP',
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      decoration: const InputDecoration(labelText: 'New password'),
                      obscureText: true,
                      onSaved: (v) => newPassword = v ?? '',
                      validator: (v) => (v?.length ?? 0) >= 6 ? null : 'Min 6 chars',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        _formKey.currentState!.save();

                        setState(() => _loading = true);

                        try {
                          await auth.verifyOtpAndResetPassword(email: email, otp: otp, newPassword: newPassword);

                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password reset successful. Please login.')),
                          );

                          Navigator.pushReplacementNamed(context, AppRoutes.login);
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to reset password: $e')),
                          );
                        } finally {
                          if (mounted) setState(() => _loading = false);
                        }
                      },
                      child: const Text('Reset password'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
