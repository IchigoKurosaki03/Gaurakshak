# Real OTP rollout

The presentation build intentionally uses the fixed demo OTP `123456`.
Production startup refuses to run with demo authentication enabled or without
SMS provider configuration.

Before enabling real OTP:

1. Choose an SMS provider that supports Indian transactional templates (for
   example MSG91, 2Factor, or Exotel).
2. Add `SMS_PROVIDER`, `SMS_API_KEY`, `SMS_SENDER_ID`, and `SMS_TEMPLATE_ID`
   to `backend/.env` only.
3. Implement the provider adapter in the backend. It must generate a
   cryptographically random six-digit code, store only a hash with a short
   expiry, enforce resend/attempt limits, and send through HTTPS.
4. Set `DEMO_AUTH_ENABLED=false` and `APP_ENV=production`.

Do not put provider credentials in Flutter, the APK, GitHub, or the `.env`
example file. The existing login UI already accepts the resulting six-digit
OTP; only the backend delivery/verification provider is pending.
