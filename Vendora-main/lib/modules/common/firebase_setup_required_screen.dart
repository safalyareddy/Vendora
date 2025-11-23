import 'package:flutter/material.dart';

class FirebaseSetupRequiredScreen extends StatelessWidget {
  final String error;
  const FirebaseSetupRequiredScreen({super.key, this.error = ''});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase not configured')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Firebase initialization failed. The app couldn\'t connect to Firebase with the current configuration.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              if (error.isNotEmpty) ...[
                const Text(
                  'Error (for debugging):',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(error),
                const SizedBox(height: 12),
              ],
              const Text(
                'Follow these steps to configure Firebase for this app:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '1) Recommended: Generate firebase_options.dart with FlutterFire CLI',
              ),
              const SizedBox(height: 6),
              const SelectableText(
                '  - Install FlutterFire CLI: dart pub global activate flutterfire_cli\n  - Run: flutterfire configure\n  - Follow prompts and select your Firebase project and platforms\n  - This will generate lib/firebase_options.dart for you',
              ),
              const SizedBox(height: 10),
              const Text('2) Alternatively add native config files (manual)'),
              const SizedBox(height: 6),
              const SelectableText(
                '  - Android: place google-services.json into android/app/\n  - iOS: place GoogleService-Info.plist into ios/Runner/\n  - Web: add Firebase config to index.html or use flutterfire configure',
              ),
              const SizedBox(height: 12),
              const Text(
                '3) Deploy Cloud Functions for OTP/email (optional but required for email OTP flow)',
              ),
              const SizedBox(height: 6),
              const SelectableText(
                '  - In project root: cd functions; npm install; cd ..; firebase deploy --only functions\n  - Set SendGrid API key before deploy: firebase functions:config:set sendgrid.key="YOUR_SENDGRID_KEY"',
              ),
              const SizedBox(height: 20),
              const Text('After performing the above, restart the app.'),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () {}, child: const Text('Close')),
            ],
          ),
        ),
      ),
    );
  }
}
