import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Firebase configuration for Edara Hub Admin Panel
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError('Admin panel only supports web platform');
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC-U7bLeW3bQUasoRo0bkZzixNJgDc9kxs',
    appId: '1:140881193724:web:admin_panel_app_id', // You'll need to create a web app in Firebase Console
    messagingSenderId: '140881193724',
    projectId: 'edaraapp-cb18b',
    authDomain: 'edaraapp-cb18b.firebaseapp.com',
    storageBucket: 'edaraapp-cb18b.firebasestorage.app',
  );
}
