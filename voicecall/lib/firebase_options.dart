// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyBkTzlEX7UTv7rOsOcpVBxbUwndVUGFa94',
    appId: '1:446886650399:web:7b3a3f293f05b055942b2a',
    messagingSenderId: '446886650399',
    projectId: 'calling-app-30df7',
    authDomain: 'calling-app-30df7.firebaseapp.com',
    storageBucket: 'calling-app-30df7.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDM7rFTmNDqD6Jn_wiQT9vwtWm_aSDnrWo',
    appId: '1:446886650399:android:90c359e4e91aa19e942b2a',
    messagingSenderId: '446886650399',
    projectId: 'calling-app-30df7',
    storageBucket: 'calling-app-30df7.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBoxRkxHJj0TqafMHBd5yj_SO2cPhu109U',
    appId: '1:446886650399:ios:bc3f7ee566d810df942b2a',
    messagingSenderId: '446886650399',
    projectId: 'calling-app-30df7',
    storageBucket: 'calling-app-30df7.appspot.com',
    iosBundleId: 'com.example.voicecall',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBoxRkxHJj0TqafMHBd5yj_SO2cPhu109U',
    appId: '1:446886650399:ios:bc3f7ee566d810df942b2a',
    messagingSenderId: '446886650399',
    projectId: 'calling-app-30df7',
    storageBucket: 'calling-app-30df7.appspot.com',
    iosBundleId: 'com.example.voicecall',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBkTzlEX7UTv7rOsOcpVBxbUwndVUGFa94',
    appId: '1:446886650399:web:fa4b63d1739a8125942b2a',
    messagingSenderId: '446886650399',
    projectId: 'calling-app-30df7',
    authDomain: 'calling-app-30df7.firebaseapp.com',
    storageBucket: 'calling-app-30df7.appspot.com',
  );

}