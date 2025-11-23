OTP-based password reset (overview and deploy steps)

What I added
- Client screens:
  - `lib/modules/auth/request_otp_screen.dart` (request OTP)
  - `lib/modules/auth/reset_with_otp_screen.dart` (enter OTP + new password)
- Auth helpers in `lib/services/auth_service.dart`:
  - `requestPasswordResetOtp(email)` — writes `password_reset_requests` docs to Firestore with otp.
  - `verifyOtpAndResetPassword(email, otp, newPassword)` — verifies OTP locally; intended to call Cloud Function to perform Admin SDK password update.
- Cloud Functions scaffold under `functions/`:
  - `functions/index.js` — sends OTP email (via SendGrid) on new request and callable function `resetPasswordWithOtp` to perform password update using Admin SDK.
  - `functions/package.json` — dependencies and Node engine.

Why a Cloud Function is needed
- Changing another user's password without them being signed in requires privileged server-side access (Firebase Admin SDK).
- The client can verify OTP exists in Firestore, but can't securely update the Auth password. The Cloud Function verifies OTP and updates the user's password via Admin SDK.

How to deploy the Cloud Function (short)
1. Install Firebase CLI and login:

   ```powershell
   npm install -g firebase-tools
   firebase login
   ```

2. Initialize functions (if not already):

   ```powershell
   cd functions
   npm install
   firebase init functions
   ```

   Replace `functions/index.js` and `functions/package.json` with the files added in this repo.

3. Configure SendGrid API key in Firebase functions config:

   ```powershell
   firebase functions:config:set sendgrid.key="YOUR_SENDGRID_API_KEY"
   ```

4. Deploy functions:

   ```powershell
   firebase deploy --only functions
   ```

How the client should use the flow
1. User opens "Forgot password" ➜ requests OTP (enters email). Client calls `auth.requestPasswordResetOtp(email)` which writes a doc to `password_reset_requests`.
2. Cloud Function `onPasswordResetRequest` triggers and sends OTP to the user's email (via SendGrid).
3. User enters OTP in the app along with new password; the client calls `auth.verifyOtpAndResetPassword(...)` which verifies locally and should call the callable function `resetPasswordWithOtp` to update the password. The current code verifies locally and instructs to deploy the function; you can wire a callable HTTPS call to the deployed function after deployment.

Notes and security
- OTPs are short-lived (code uses 15 minutes expiry) and marked `used` after verification.
- You must deploy and protect the Cloud Functions; store SendGrid key in functions config, not in source.
- Alternatively, you can use Firebase Authentication's built-in reset link via `sendPasswordResetEmail` (already present in `AuthService`) which doesn't require server-side code.

Next steps for me if you want me to continue
- Wire client to call the deployed callable function (I can add an optional HTTP call using `httpsCallable` if you deploy the function and give me its region/URL), and remove the local placeholder error.
- Clean up analyzer warnings and deprecations across the app.
- Add small widget tests for registration/login flows.
