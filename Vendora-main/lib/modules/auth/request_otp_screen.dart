// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../app/app_routes.dart';

class RequestOtpScreen extends StatefulWidget {
  const RequestOtpScreen({super.key});

  @override
  _RequestOtpScreenState createState() => _RequestOtpScreenState();
}

class _RequestOtpScreenState extends State<RequestOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Reset password (request OTP)')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text('Enter your registered email. You will receive an OTP by email.'),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) => v != null && v.contains('@') ? null : 'Enter valid email',
                  onSaved: (v) => email = v?.trim() ?? '',
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
                          // For OTP flow we will write a request doc to Firestore and a Cloud Function will
                          // send the email. AuthService exposes a helper that uses sendPasswordResetEmail by default.
                          // We'll call a helper that creates a password-reset request record; if Cloud Functions are
                          // deployed they'll handle sending OTP. If not, fallback to Firebase reset link.
                          await auth.requestPasswordResetOtp(email);

                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('OTP requested. Check your email.')),
                          );

                          Navigator.pushReplacementNamed(context, AppRoutes.forgotEnterOtp);
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to request OTP: $e')),
                          );
                        } finally {
                          if (mounted) setState(() => _loading = false);
                        }
                      },
                      child: const Text('Request OTP'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
