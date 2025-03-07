// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDgDLqxYmWyOJT2OdzJHCOta4L2mzQPYkg',
    appId: '1:1034566412125:web:56d89993890da139c0aab4',
    messagingSenderId: '1034566412125',
    projectId: 'grade-up-project1',
    authDomain: 'grade-up-project1.firebaseapp.com',
    storageBucket: 'grade-up-project1.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDvitUd6TX9YK478fXHPw336jDv9kml0K8',
    appId: '1:1034566412125:android:f42adc82f3b7db7ec0aab4',
    messagingSenderId: '1034566412125',
    projectId: 'grade-up-project1',
    storageBucket: 'grade-up-project1.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA1GhMOyWcPt10KIT_ucHNzIo_DCq7z9Sk',
    appId: '1:1034566412125:ios:d2a99fe5fee409d4c0aab4',
    messagingSenderId: '1034566412125',
    projectId: 'grade-up-project1',
    storageBucket: 'grade-up-project1.appspot.com',
    iosBundleId: 'com.example.gradeUp',
  );

}