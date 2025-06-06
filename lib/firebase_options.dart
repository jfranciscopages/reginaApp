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
    apiKey: 'AIzaSyCAZs-Z7GR3t51cQ2ZEClZSoHAuymqiYbY',
    appId: '1:3988655373:web:b1e11ada9b3b7f165e3444',
    messagingSenderId: '3988655373',
    projectId: 'regina-app-d47ce',
    authDomain: 'regina-app-d47ce.firebaseapp.com',
    storageBucket: 'regina-app-d47ce.firebasestorage.app',
    measurementId: 'G-TZ8BGE562K',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBPFIlPSJUtTe0ku93QJsNpF43nEyS1Pko',
    appId: '1:3988655373:android:105b44366be496fa5e3444',
    messagingSenderId: '3988655373',
    projectId: 'regina-app-d47ce',
    storageBucket: 'regina-app-d47ce.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA8zRLjDdIzcBI4x0SVXDuv8XL7OE4233A',
    appId: '1:3988655373:ios:852e30313b62e66d5e3444',
    messagingSenderId: '3988655373',
    projectId: 'regina-app-d47ce',
    storageBucket: 'regina-app-d47ce.firebasestorage.app',
    iosBundleId: 'com.example.reginaApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA8zRLjDdIzcBI4x0SVXDuv8XL7OE4233A',
    appId: '1:3988655373:ios:852e30313b62e66d5e3444',
    messagingSenderId: '3988655373',
    projectId: 'regina-app-d47ce',
    storageBucket: 'regina-app-d47ce.firebasestorage.app',
    iosBundleId: 'com.example.reginaApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCAZs-Z7GR3t51cQ2ZEClZSoHAuymqiYbY',
    appId: '1:3988655373:web:c5efa6c540b591f45e3444',
    messagingSenderId: '3988655373',
    projectId: 'regina-app-d47ce',
    authDomain: 'regina-app-d47ce.firebaseapp.com',
    storageBucket: 'regina-app-d47ce.firebasestorage.app',
    measurementId: 'G-J9TQCYMBGW',
  );

}