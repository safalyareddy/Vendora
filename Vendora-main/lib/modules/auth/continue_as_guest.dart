import 'package:flutter/material.dart';

/// ROLES USED IN THE APP
enum AppRole { buyer, seller, guest }

/// AUTH SERVICE USING PROVIDER
class AuthService extends ChangeNotifier {
  AppRole? _role;

  AppRole? get role => _role;

  /// Set role BEFORE login (buyer / seller / guest)
  void setRole(AppRole role) {
    _role = role;
    notifyListeners();
  }

  // ---------------- LOGIN METHODS ------------------

  /// GENERIC LOGIN
  Future<void> login(String email, String password) async {
    await Future.delayed(Duration(milliseconds: 500));
  }

  /// BUYER LOGIN
  Future<void> loginAsBuyer({
    required String email,
    required String password,
  }) async {
    await Future.delayed(Duration(milliseconds: 500)); // mock
    _role = AppRole.buyer;
    notifyListeners();
  }

  /// SELLER LOGIN
  Future<void> loginAsSeller({
    required String email,
    required String password,
  }) async {
    await Future.delayed(Duration(milliseconds: 500)); // mock
    _role = AppRole.seller;
    notifyListeners();
  }

  // ---------------- REGISTER METHOD ------------------

  Future<void> register(String name, String email, String password) async {
    await Future.delayed(Duration(milliseconds: 500));
  }

  // ---------------- LOGOUT ------------------

  void logout() {
    _role = null;
    notifyListeners();
  }
}
