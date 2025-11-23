import 'package:flutter/material.dart';

enum AppRole { buyer, seller, guest, unknown }

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  AppRole _role = AppRole.unknown;
  String? _userId;

  bool get isAuthenticated => _isAuthenticated;
  AppRole get role => _role;
  String? get userId => _userId;

  // Mock login - replace with Firebase Auth later
  Future<void> loginAsBuyer({
    required String email,
    required String password,
  }) async {
    // TODO: integrate Firebase Auth
    await Future.delayed(Duration(milliseconds: 500));
    _isAuthenticated = true;
    _role = AppRole.buyer;
    _userId = "buyer_123";
    notifyListeners();
  }

  Future<void> loginAsSeller({
    required String email,
    required String password,
  }) async {
    // TODO: integrate Firebase Auth
    await Future.delayed(Duration(milliseconds: 500));
    _isAuthenticated = true;
    _role = AppRole.seller;
    _userId = "seller_123";
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _role = AppRole.unknown;
    _userId = null;
    notifyListeners();
  }

  void setRole(AppRole newRole) {
    _role = newRole;
    notifyListeners();
  }
}
