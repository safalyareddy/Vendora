import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Wait 2 seconds then navigate to role select screen
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushReplacementNamed(context, AppRoutes.roleSelect);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo (change to your PNG if needed)
            Icon(
              Icons.store_mall_directory_outlined,
              size: 90,
              color: Colors.blueAccent,
            ),

            const SizedBox(height: 20),

            const Text(
              "Vendora",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 45),

            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
