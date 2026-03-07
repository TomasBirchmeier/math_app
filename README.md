# math_app

A new Flutter project.

## Private ensayos

The original PDF and intermediate extraction files now live outside of the
published bundle under `private_assets/ensayos/`. This folder is ignored via
`.gitignore`, so you can keep sensitive material there without pushing it to a
public repository or build. Only the generated PNG questions in
`assets/ensayos/questions/` are included in the app.

If you need to regenerate the assets, place the source PDF inside
`private_assets/ensayos/`, run the conversion script locally, and copy the
resulting images back into `assets/ensayos/questions/`.

## Remote monitoring with Firebase

This app can sync student progress in real time to Firestore and expose the web
app to students outside your local network through Firebase Hosting.

1. Create a Firebase project and enable Firestore (start in Test mode for initial setup).
2. Install Firebase CLI and login:
   - `npm install -g firebase-tools`
   - `firebase login`
3. Build web with your Firebase web config:
   - `flutter build web --release --dart-define=FIREBASE_API_KEY=... --dart-define=FIREBASE_APP_ID=... --dart-define=FIREBASE_MESSAGING_SENDER_ID=... --dart-define=FIREBASE_PROJECT_ID=... --dart-define=FIREBASE_AUTH_DOMAIN=... --dart-define=FIREBASE_STORAGE_BUCKET=... --dart-define=FIREBASE_MEASUREMENT_ID=...`
4. Deploy:
   - `firebase deploy --only hosting`

Once deployed, students can connect from anywhere and the admin account can use
`Ver seguimiento remoto` to watch submissions live.

You can also export your Firebase variables and run:

- `./deploy_firebase_web.sh`

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
