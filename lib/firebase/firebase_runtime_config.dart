import 'package:firebase_core/firebase_core.dart';

class FirebaseRuntimeConfig {
  static const String apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const String messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const String projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const String authDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
  );
  static const String storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
  );
  static const String measurementId = String.fromEnvironment(
    'FIREBASE_MEASUREMENT_ID',
  );

  static bool get isConfigured {
    return apiKey.isNotEmpty &&
        appId.isNotEmpty &&
        messagingSenderId.isNotEmpty &&
        projectId.isNotEmpty;
  }

  static FirebaseOptions get webOptions {
    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      authDomain: _nullIfEmpty(authDomain),
      storageBucket: _nullIfEmpty(storageBucket),
      measurementId: _nullIfEmpty(measurementId),
    );
  }

  static String? _nullIfEmpty(String value) {
    return value.isEmpty ? null : value;
  }
}
