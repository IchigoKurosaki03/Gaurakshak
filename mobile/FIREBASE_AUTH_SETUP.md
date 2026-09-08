# Optional Google login setup

The MVP keeps mobile OTP as the active sign-in method and exposes Google login
under More → Login methods. Google login is intentionally not activated until
the Firebase project is configured.

Required before enabling it:

1. Create a Firebase project and enable Authentication → Google.
2. Add the Android app using the final application ID and SHA-1/SHA-256 keys.
3. Add `android/app/google-services.json` locally (never commit secrets or
   signing material).
4. Add the Firebase web configuration through the normal FlutterFire setup.
5. Add Firebase Auth/Google Sign-In dependencies and map the Firebase user to
   a backend user through a verified identity-token endpoint.
6. Keep the existing backend JWT as the app's API token; Firebase tokens should
   be exchanged server-side, not used directly for farm API authorization.

Without these project-specific files and provider settings, a Google button
would appear to work but fail at runtime. The current UI therefore labels it
as setup-required while phone OTP remains usable for the demo.
