// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_routes.dart';
import '../../services/auth_service.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          final exit = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Exit app?"),
              content: const Text("Do you want to close the app?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Yes"),
                ),
              ],
            ),
          );
          return exit ?? false;
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 20),

                  const Text(
                    "Continue as",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),

                  const SizedBox(height: 30),

                  // MAIN ROLE CARDS
                  RoleCard(
                    title: "Buyer (MSRB / SME)",
                    subtitle:
                        "Browse wholesalers · Negotiate · Place bulk orders",
                    icon: Icons.shopping_bag_outlined,
                    onTap: () {
                      Provider.of<AuthService>(
                        context,
                        listen: false,
                      ).setRole(AppRole.buyer);

                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    },
                  ),

                  const SizedBox(height: 12),

                  RoleCard(
                    title: "Seller (Wholesaler)",
                    subtitle: "List products · Manage MOQ · Handle orders",
                    icon: Icons.storefront_outlined,
                    onTap: () {
                      Provider.of<AuthService>(
                        context,
                        listen: false,
                      ).setRole(AppRole.seller);

                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    },
                  ),

                  const SizedBox(height: 12),

                  // ⭐⭐⭐ ALWAYS VISIBLE – CONTINUE AS GUEST ⭐⭐⭐
                  const SizedBox(height: 6),
                  RoleCard(
                    title: "Continue as Guest",
                    subtitle: "Browse products as a guest",
                    icon: Icons.person_outline,
                    onTap: () {
                      Provider.of<AuthService>(
                        context,
                        listen: false,
                      ).setRole(AppRole.guest);

                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.guestHome,
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.register),
                    child: const Text(
                      "New? Register here",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Icon(icon, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
