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
    apiKey: 'AIzaSyCiNw55MzaJPqW409-iMZxUMeUTKfmGqFU',
    appId: '1:84806642758:web:7c9c56e5f196368f292e47',
    messagingSenderId: '84806642758',
    projectId: 'logix-94060',
    authDomain: 'logix-94060.firebaseapp.com',
    storageBucket: 'logix-94060.firebasestorage.app',
    measurementId: 'G-86X42LY6XG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBUahv_BCz_uhfzbb3ocATzbQcgFADp-gc',
    appId: '1:84806642758:android:3a1b6483d141d55c292e47',
    messagingSenderId: '84806642758',
    projectId: 'logix-94060',
    storageBucket: 'logix-94060.firebasestorage.app',
  );
}
