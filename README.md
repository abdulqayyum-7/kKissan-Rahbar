# Kissan Rahbar (Flutter)

Flutter app for Pakistani farmers, with a Gemini-powered agriculture assistant that replies in Urdu by default.

## Run it (phone connected, USB debugging on)

```bash
dart tool/setup.dart --key=YOUR_GEMINI_KEY
```

That one command: creates the Android project, adds the INTERNET permission and
minSdk 23, installs packages, builds the icon + splash, connects your Firebase
project (`flutterfire configure`), and runs the app on the connected phone.

Before the first run, once:
- `npm install -g firebase-tools` then `firebase login` (use YOUR Google account)
- Firebase console: enable Authentication > Email/Password, and create a Realtime Database.

Run again later (setup is skipped where already done):

```bash
flutter run --dart-define=GEMINI_API_KEY=YOUR_GEMINI_KEY
```

## Gemini
The app asks Google which `gemini-X-flash` models your key can use, picks the newest,
retries 503/429 errors, and falls back to another model if one is overloaded or retired.
Force a model with `--dart-define=GEMINI_MODEL=<name>`.

## App features
Welcome, Login, Register, Home (Pakistan-focused example questions), Chat (Gemini, Urdu replies,
Pakistani Urdu voice transcription on Android, retryable errors and saved conversations), Saved
chats (synced to Realtime Database), and Profile.
Signed-in users skip the Welcome screen. The app uses a fixed light appearance.

## Design
The welcome screen uses Pakistan-inspired forest green, warm paper and harvest gold, with an Urdu
tagline and no terms notice. Android voice input opens the device speech recognizer in Pakistani
Urdu and returns the transcript to the chat composer for review. Logo and app icon are in assets/icon.
After changing the icon or splash run:
  dart run flutter_launcher_icons && dart run flutter_native_splash:create
