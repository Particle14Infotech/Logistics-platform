// Hand-written to match what `flutterfire configure` generates (neither the
// FlutterFire nor Firebase CLI is available in this dev environment, and
// `flutterfire configure` needs an interactive Google login anyway) - the
// android block's values come straight from android/app/google-services.json,
// the web block from the Firebase Console's "Web" app registration.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform - '
          'only Android and web are set up so far.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC23BDc66pnSxx2i2uGL8HMfIz8VbHxrbQ',
    appId: '1:768140781082:web:443a5f0cc8d9973ad053a3',
    messagingSenderId: '768140781082',
    projectId: 'rahmitra-40638',
    authDomain: 'rahmitra-40638.firebaseapp.com',
    storageBucket: 'rahmitra-40638.firebasestorage.app',
    measurementId: 'G-6381FB3QS9',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDybuxdpsdu1OW-fqSnhvQ6KyBMghG38SQ',
    appId: '1:768140781082:android:f0aa7a9718b20a28d053a3',
    messagingSenderId: '768140781082',
    projectId: 'rahmitra-40638',
    storageBucket: 'rahmitra-40638.firebasestorage.app',
  );
}
