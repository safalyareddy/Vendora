// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_routes.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  bool _loading = false;

  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        leading: BackButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.roleSelect);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Text(
                "Signed in as: ${auth.role == AppRole.buyer
                    ? 'Buyer'
                    : auth.role == AppRole.seller
                    ? 'Seller'
                    : '—'}",
              ),
              const SizedBox(height: 18),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      onSaved: (v) => email = v?.trim() ?? "",
                      validator: (v) => v != null && v.contains("@")
                          ? null
                          : "Enter valid email",
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(
                              () => _passwordVisible = !_passwordVisible,
                            );
                          },
                        ),
                      ),
                      obscureText: !_passwordVisible,
                      onSaved: (v) => password = v ?? "",
                      validator: (v) =>
                          (v?.length ?? 0) >= 6 ? null : "Min 6 chars",
                    ),

                    const SizedBox(height: 18),

                    _loading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) return;

                              _formKey.currentState!.save();
                              setState(() => _loading = true);

                              try {
                                await auth.login(email, password);

                                if (!mounted) return;

                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRoutes.guestHome,
                                  (route) => false,
                                );
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Login failed: $e")),
                                  );
                                }
                              } finally {
                                if (mounted) setState(() => _loading = false);
                              }
                            },
                            child: const Text("Login"),
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
