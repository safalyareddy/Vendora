import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  /// Create a password-reset OTP request. This writes a document in
  /// `password_reset_requests` collection. A Cloud Function should listen to
  /// new documents and send the OTP email. If no Cloud Function is deployed
  /// the client can fallback to the built-in password reset email.
  Future<void> requestPasswordResetOtp(String email) async {
    try {
      final req = _db.collection('password_reset_requests').doc();
      final otp = (_generateNumericCode(6));

      await req.set({
        'email': email,
        'otp': otp,
        'createdAt': FieldValue.serverTimestamp(),
        'used': false,
      });

      // Note: Cloud Function should pick this up and send the email containing the OTP.
      return;
    } catch (e) {
      // fallback to email link if OTP flow is not available
      return sendPasswordResetEmail(email);
    }
  }

  /// Verify OTP and reset password. This function assumes a backend Cloud
  /// Function is available to perform the actual password reset using Admin SDK.
  /// We'll call a callable function via HTTPS endpoint. For simplicity, the
  /// client can instead write a `password_reset_attempts` doc and a Cloud
  /// Function can verify and reset. Here we attempt to verify locally by
  /// checking the Firestore doc and then calling a callable HTTP endpoint.
  Future<void> verifyOtpAndResetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      // Find latest request
      final q = await _db
          .collection('password_reset_requests')
          .where('email', isEqualTo: email)
          .where('used', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (q.docs.isEmpty) throw 'No OTP request found for this email.';

      final doc = q.docs.first;
      final data = doc.data();
      final storedOtp = data['otp']?.toString() ?? '';
      final created = data['createdAt'] as Timestamp?;

      // Expiry: 15 minutes
      if (created == null) throw 'Invalid OTP request.';
      final now = DateTime.now().toUtc();
      if (now.difference(created.toDate().toUtc()).inMinutes > 15) {
        throw 'OTP expired. Please request again.';
      }

      if (storedOtp != otp) throw 'Invalid OTP.';

      // Mark as used (so it can't be reused)
      await doc.reference.update({'used': true});

      // At this point we need a secure server-side operation to change the
      // user's password without being logged in. We'll call a callable Cloud
      // Function which you must deploy (see functions/). Try to call it if
      // configured.
          // Try to call the HTTP Cloud Function endpoint if `functionsBaseUrl` is configured.
          // This endpoint should be the deployed function URL (e.g. https://<region>-<project>.cloudfunctions.net/resetPasswordWithOtp)
          if ((_functionsBaseUrl ?? '').isEmpty) {
            throw 'OTP verified locally. Deploy the provided Cloud Function (functions/) to complete the password reset automatically and set AuthService.functionsBaseUrl to the function URL.';
          }

          try {
            final uri = Uri.parse('${_functionsBaseUrl!.replaceAll(RegExp(r'/$'), '')}/resetPasswordWithOtp');
            final resp = await http.post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'email': email,
                'otp': otp,
                'newPassword': newPassword,
              }),
            );

            if (resp.statusCode >= 200 && resp.statusCode < 300) {
              final body = jsonDecode(resp.body);
              if (body is Map && body['success'] == true) return;
              throw body['error'] ?? 'Unexpected response from function';
            }

            throw 'Function call failed: ${resp.statusCode} ${resp.body}';
          } catch (e) {
            throw e.toString();
          }
    } catch (e) {
      throw e.toString();
    }
  }

  String _generateNumericCode(int length) {
    final rnd = DateTime.now().microsecondsSinceEpoch % 1000000;
    return rnd.toString().padLeft(length, '0').substring(0, length);
  }

  // Optional: set this to your deployed functions base URL, e.g.
  // https://us-central1-yourproject.cloudfunctions.net
  String? _functionsBaseUrl;

  void setFunctionsBaseUrl(String url) {
    _functionsBaseUrl = url;
  }

  Future<void> logout() async {
    await _auth.signOut();
    _isAuthenticated = false;
    _role = AppRole.unknown;
    _userId = null;
    notifyListeners();
  }
}
