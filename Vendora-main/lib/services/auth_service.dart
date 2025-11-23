import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Removed Cloud Functions/http usage; using Firebase built-in reset email instead.

enum AppRole { buyer, seller, guest, unknown }

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isAuthenticated = false;
  AppRole _role = AppRole.unknown;
  String? _userId;

  bool get isAuthenticated => _isAuthenticated;
  AppRole get role => _role;
  String? get userId => _userId;

  AuthService() {
    // Listen to auth state changes and keep local state in sync
    _auth.authStateChanges().listen((user) async {
      if (user == null) {
        _isAuthenticated = false;
        _userId = null;
        _role = AppRole.unknown;
        notifyListeners();
      } else {
        _userId = user.uid;
        // try to fetch user profile from firestore
        try {
          final doc = await _db.collection('users').doc(user.uid).get();
          if (doc.exists) {
            final data = doc.data()!;
            final roleStr = (data['role'] ?? '').toString();
            if (roleStr == 'buyer') {
              _role = AppRole.buyer;
            } else if (roleStr == 'seller') {
              _role = AppRole.seller;
            } else if (roleStr == 'guest') {
              _role = AppRole.guest;
            } else {
              _role = AppRole.unknown;
            }
            _isAuthenticated = true;
          } else {
            _role = AppRole.unknown;
            _isAuthenticated = false;
          }
        } catch (_) {
          _role = AppRole.unknown;
          _isAuthenticated = true; // still authenticated with Firebase
        }
        notifyListeners();
      }
    });
  }

  void setRole(AppRole newRole) {
    _role = newRole;
    notifyListeners();
  }

  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    required AppRole role,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;

      await _db.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'role': role.toString().split('.').last,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _isAuthenticated = true;
      _role = role;
      _userId = uid;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw e.message ?? e.code;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> login({
    required String email,
    required String password,
    required AppRole role,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;
      final doc = await _db.collection('users').doc(uid).get();

      if (!doc.exists) {
        await _auth.signOut();
        throw 'No registration found for this account. Please register first.';
      }

      final storedRole = (doc.data()?['role'] ?? '').toString();
      final requestedRole = role.toString().split('.').last;

      if (storedRole != requestedRole) {
        await _auth.signOut();
        throw 'Role mismatch: account registered as $storedRole.';
      }

      _isAuthenticated = true;
      _role = role;
      _userId = uid;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw e.message ?? e.code;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? e.code;
    } catch (e) {
      throw e.toString();
    }
  }
  // The OTP-based reset flow and Cloud Functions integration are intentionally
  // removed in this branch to avoid requiring server-side deployment.
  // Use `sendPasswordResetEmail(email)` to trigger Firebase's built-in reset.

  Future<void> logout() async {
    await _auth.signOut();
    _isAuthenticated = false;
    _role = AppRole.unknown;
    _userId = null;
    notifyListeners();
  }
}
