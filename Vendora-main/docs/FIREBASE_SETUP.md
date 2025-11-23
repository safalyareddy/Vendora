# Firebase setup and Cloud Functions deploy

This project requires Firebase configuration to run. Follow the steps below.

## 1) Enable Email/Password sign-in
- Open Firebase Console -> Authentication -> Sign-in method -> Enable Email/Password.

## 2) Configure app (recommended)
Recommended: use FlutterFire CLI to generate `lib/firebase_options.dart` and wire native files.

Commands (PowerShell):

```powershell
# Install FlutterFire CLI (one-time)
dart pub global activate flutterfire_cli

# Ensure the dart pub global bin is in PATH. You may need to restart the terminal.

# Run interactive configuration
flutterfire configure
```

Follow prompts and choose your Firebase project and target platforms. This generates `lib/firebase_options.dart`.

## 3) Deploy Cloud Functions (OTP/email and password reset)

The functions are in `functions/index.js`. They send OTP emails (via SendGrid) and expose an HTTP endpoint to reset a user's password using the Admin SDK.

Commands (PowerShell):

```powershell
# Install Firebase CLI (if needed)
npm install -g firebase-tools
firebase login

# Set SendGrid API key (optional; without it OTPs are logged instead of emailed)
firebase functions:config:set sendgrid.key="YOUR_SENDGRID_API_KEY"

# Install function deps and deploy
cd .\functions
npm install
cd ..
firebase deploy --only functions
```

After deploy, copy the HTTPS URL for `resetPasswordWithOtp` (looks like `https://<region>-<project>.cloudfunctions.net/resetPasswordWithOtp`) and set it in the app by calling `AuthService.setFunctionsBaseUrl('<URL>')` in `lib/main.dart` provider creation.

## 4) Test
- Register a user via the app and verify it appears in Firebase Authentication and Firestore `users/{uid}`.
- Use Forgot password -> request OTP -> reset with OTP flow.

## Notes
- If you don't set a SendGrid key, the function will log the OTP to Functions logs which can be used for testing.
- Secure your SendGrid key and consider rate-limiting OTP requests.
