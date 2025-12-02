import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum AppRole { buyer, seller, guest, unknown }

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isAuthenticated = false;
  AppRole _role = AppRole.unknown;
  String? _userId;

  bool get isAuthenticated => _isAuthenticated;
  AppRole get role => _role;
  String? get userId => _userId;

  // ------------------------------------------------------------------
  // 🔥 NEW — UNIVERSAL LOGIN FOR BOTH BUYER & SELLER
  // ------------------------------------------------------------------
  Future<void> login(String email, String password) async {
    // Log in with Firebase Auth
    UserCredential userCred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    _userId = userCred.user!.uid;
    _isAuthenticated = true;

    // Load role from Firestore
    DocumentSnapshot snap = await _firestore
        .collection("users")
        .doc(_userId)
        .get();

    if (snap.exists) {
      String userRole = snap["role"];
      _role = _convertRole(userRole);
    }

    notifyListeners();
  }

  // ------------------------------------------------------------------
  // 🔥 NEW — UNIVERSAL REGISTER FOR BOTH BUYER & SELLER
  // ------------------------------------------------------------------
  Future<void> register(
    String email,
    String password,
    String name,
    AppRole role,
  ) async {
    // Create user in Firebase Auth
    UserCredential userCred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    _userId = userCred.user!.uid;
    _isAuthenticated = true;

    // Save user info in Firestore
    await _firestore.collection("users").doc(_userId).set({
      "name": name,
      "email": email,
      "role": _roleToString(role),
      "createdAt": DateTime.now(),
    });

    _role = role;

    notifyListeners();
  }

  // ------------------------------------------------------------------
  // OLD FUNCTIONS (still supported)
  // ------------------------------------------------------------------

  Future<void> loginAsBuyer({
    required String email,
    required String password,
  }) async {
    await login(email, password);
    _role = AppRole.buyer;
    notifyListeners();
  }

  Future<void> loginAsSeller({
    required String email,
    required String password,
  }) async {
    await login(email, password);
    _role = AppRole.seller;
    notifyListeners();
  }

  // Logout
  void logout() {
    _auth.signOut();
    _isAuthenticated = false;
    _role = AppRole.unknown;
    _userId = null;
    notifyListeners();
  }

  // Role setter for role selection page
  void setRole(AppRole newRole) {
    _role = newRole;
    notifyListeners();
  }

  // ------------------------------------------------------------------
  // Helpers
  // ------------------------------------------------------------------
  AppRole _convertRole(String role) {
    switch (role) {
      case "buyer":
        return AppRole.buyer;
      case "seller":
        return AppRole.seller;
      case "guest":
        return AppRole.guest;
      default:
        return AppRole.unknown;
    }
  }

  String _roleToString(AppRole role) {
    switch (role) {
      case AppRole.buyer:
        return "buyer";
      case AppRole.seller:
        return "seller";
      case AppRole.guest:
        return "guest";
      default:
        return "unknown";
    }
  }
}
