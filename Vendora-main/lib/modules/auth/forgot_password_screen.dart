// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    // AuthService is available via Provider if needed elsewhere.
    // We use FirebaseAuth directly for the built-in password reset email.
    // final auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Forgot password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Enter the email of your account. We will send a reset link.',
              ),
              const SizedBox(height: 16),

              Form(
                key: _formKey,
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) =>
                      v != null && v.contains('@') ? null : 'Enter valid email',
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
                          // Use Firebase's built-in password reset email.
                          await FirebaseAuth.instance.sendPasswordResetEmail(
                            email: email,
                          );
                          if (!mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Password reset email sent! Check your inbox.',
                              ),
                            ),
                          );
                          // Optionally navigate back to login
                          Navigator.pop(context);
                        } on FirebaseAuthException catch (e) {
                          if (!mounted) {
                            return;
                          }
                          String msg = 'Failed to send reset email';
                          if (e.code == 'user-not-found') {
                            msg = 'No user found with this email';
                          }
                          if (e.code == 'invalid-email') {
                            msg = 'Invalid email address';
                          }
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(msg)));
                        } catch (e) {
                          if (!mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        } finally {
                          if (mounted) {
                            setState(() => _loading = false);
                          }
                        }
                      },
                      child: const Text('Send reset email'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
