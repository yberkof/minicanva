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
    apiKey: 'AIzaSyDZc_0QPEE_CditlZ8HaPXtEDRcpHuYJSo',
    appId: '1:302151309609:web:74ee4aad53097a7710bf38',
    messagingSenderId: '302151309609',
    projectId: 'fire-base-test-601b7',
    authDomain: 'fire-base-test-601b7.firebaseapp.com',
    databaseURL: 'https://fire-base-test-601b7.firebaseio.com',
    storageBucket: 'fire-base-test-601b7.appspot.com',
    measurementId: 'G-WGE3KHD7V6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBqXkItgdF8xwziJdVjtMt_xhwz5zB66_M',
    appId: '1:302151309609:android:5730c9aa6321344d10bf38',
    messagingSenderId: '302151309609',
    projectId: 'fire-base-test-601b7',
    databaseURL: 'https://fire-base-test-601b7.firebaseio.com',
    storageBucket: 'fire-base-test-601b7.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDp6A0PfybtcczqzlKHhH0jeLJKHKxNEOU',
    appId: '1:302151309609:ios:79d1fe2dc1b509f610bf38',
    messagingSenderId: '302151309609',
    projectId: 'fire-base-test-601b7',
    databaseURL: 'https://fire-base-test-601b7.firebaseio.com',
    storageBucket: 'fire-base-test-601b7.appspot.com',
    androidClientId: '302151309609-9hc1vh98guet42ipftp7jbjgf8q9tbv6.apps.googleusercontent.com',
    iosBundleId: 'com.example.quotesmaker',
  );
}
