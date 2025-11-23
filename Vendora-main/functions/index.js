const functions = require('firebase-functions');
const admin = require('firebase-admin');
const sgMail = require('@sendgrid/mail');

// Set your SendGrid API key in environment config: `firebase functions:config:set sendgrid.key="YOUR_KEY"`
// Then `firebase deploy --only functions`

admin.initializeApp();

const SENDGRID_KEY = functions.config().sendgrid?.key || '';
if (SENDGRID_KEY) sgMail.setApiKey(SENDGRID_KEY);

// Listen for new password reset requests and send OTP email
exports.onPasswordResetRequest = functions.firestore
  .document('password_reset_requests/{reqId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    if (!data) return null;

    const email = data.email;
    const otp = data.otp;

    if (!SENDGRID_KEY) {
      console.warn('SendGrid key not set. Skipping email send. OTP:', otp);
      return null;
    }

    const msg = {
      to: email,
      from: 'no-reply@yourdomain.com',
      subject: 'Your OTP for password reset',
      text: `Your OTP for password reset is: ${otp}. It expires in 15 minutes.`,
      html: `<p>Your OTP for password reset is: <strong>${otp}</strong>.</p><p>It expires in 15 minutes.</p>`,
    };

    try {
      await sgMail.send(msg);
      console.log('OTP email sent to', email);
    } catch (err) {
      console.error('Failed to send OTP email', err);
    }

    return null;
  });

// Callable function to reset password using Admin SDK.
// This function verifies the OTP stored in Firestore and then updates the user's password.
// To deploy: set up Firebase Functions with the Admin SDK and SendGrid as above.

// HTTP endpoint to reset password with OTP. Accepts POST JSON { email, otp, newPassword }
exports.resetPasswordWithOtp = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Only POST allowed' });
  }

  const body = req.body || {};
  const email = body.email;
  const otp = body.otp;
  const newPassword = body.newPassword;

  if (!email || !otp || !newPassword) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  try {
    const reqs = await admin.firestore()
      .collection('password_reset_requests')
      .where('email', '==', email)
      .where('used', '==', false)
      .orderBy('createdAt', 'desc')
      .limit(1)
      .get();

    if (reqs.empty) {
      return res.status(404).json({ error: 'No OTP request found' });
    }

    const doc = reqs.docs[0];
    const dataReq = doc.data();
    const storedOtp = dataReq.otp;
    const created = dataReq.createdAt && dataReq.createdAt.toDate ? dataReq.createdAt.toDate() : null;

    if (!created) {
      return res.status(412).json({ error: 'Invalid OTP request' });
    }

    const now = new Date();
    const diff = (now - created) / 1000 / 60; // minutes
    if (diff > 15) {
      return res.status(410).json({ error: 'OTP expired' });
    }

    if (storedOtp !== otp) {
      return res.status(403).json({ error: 'Invalid OTP' });
    }

    // Find user
    let userRecord;
    try {
      userRecord = await admin.auth().getUserByEmail(email);
    } catch (err) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Update password
    try {
      await admin.auth().updateUser(userRecord.uid, { password: newPassword });
      await doc.ref.update({ used: true });
      return res.json({ success: true });
    } catch (err) {
      console.error('Failed to update password', err);
      return res.status(500).json({ error: 'Failed to update password' });
    }
  } catch (err) {
    console.error('Error in resetPasswordWithOtp', err);
    return res.status(500).json({ error: 'Internal error' });
  }
});
