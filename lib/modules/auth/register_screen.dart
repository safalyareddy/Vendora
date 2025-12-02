// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../app/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = "", email = "", password = "";
  AppRole? selectedRole;

  bool _loading = false;
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacementNamed(context, AppRoutes.roleSelect);
          return false;
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                const Text(
                  "Select Your Role",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<AppRole>(
                        title: const Text("Buyer"),
                        value: AppRole.buyer,
                        groupValue: selectedRole,
                        onChanged: (v) => setState(() => selectedRole = v),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<AppRole>(
                        title: const Text("Seller"),
                        value: AppRole.seller,
                        groupValue: selectedRole,
                        onChanged: (v) => setState(() => selectedRole = v),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Full name / Shop name",
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        onSaved: (v) => name = v?.trim() ?? "",
                        validator: (v) =>
                            (v?.isNotEmpty ?? false) ? null : "Enter name",
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        onSaved: (v) => email = v?.trim() ?? "",
                        validator: (v) => (v != null && v.contains("@"))
                            ? null
                            : "Enter valid email",
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () => setState(
                              () => _passwordVisible = !_passwordVisible,
                            ),
                          ),
                        ),
                        onSaved: (v) => password = v ?? "",
                        validator: (v) {
                          if (v == null || v.isEmpty) return "Enter password";
                          if (v.length < 6) return "Min 6 characters";
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      _loading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: () async {
                                if (selectedRole == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Please select Buyer or Seller",
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                if (!_formKey.currentState!.validate()) return;

                                _formKey.currentState!.save();
                                setState(() => _loading = true);

                                try {
                                  await auth.register(
                                    email,
                                    password,
                                    name,
                                    selectedRole!,
                                  );

                                  if (!mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Registered as ${selectedRole == AppRole.seller ? 'Seller (with Buyer access)' : 'Buyer'}",
                                      ),
                                    ),
                                  );

                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.login,
                                  );
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Register failed: $e"),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) setState(() => _loading = false);
                                }
                              },
                              child: const Text("Register"),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
