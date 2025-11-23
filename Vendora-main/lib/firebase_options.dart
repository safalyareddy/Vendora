// Placeholder Firebase configuration file.
// Replace the placeholder values below with your project's real
// Firebase configuration. Generating this file with the FlutterFire CLI
// (`flutterfire configure`) is the recommended approach.

import 'package:firebase_core/firebase_core.dart';

/// Default Firebase options used by the app when Firebase is initialized.
///
/// IMPORTANT: Replace the string values below with the values from
/// Firebase Console → Project settings → Your apps → SDK setup and config.
class DefaultFirebaseOptions {
  static const FirebaseOptions currentPlatform = FirebaseOptions(
    apiKey: 'REPLACE_WITH_API_KEY',
    authDomain: 'REPLACE_WITH_PROJECT.firebaseapp.com',
    projectId: 'REPLACE_WITH_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_PROJECT.appspot.com',
    messagingSenderId: 'REPLACE_WITH_SENDER_ID',
    appId: 'REPLACE_WITH_APP_ID',
    measurementId: 'REPLACE_WITH_MEASUREMENT_ID',
  );
}

// Usage in `main.dart` (example):
// await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
