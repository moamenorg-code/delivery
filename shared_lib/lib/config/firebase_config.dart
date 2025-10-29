import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FirebaseConfig {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: "YOUR_WEB_API_KEY",
        authDomain: "your-app.firebaseapp.com",
        projectId: "your-app",
        storageBucket: "your-app.appspot.com",
        messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
        appId: "YOUR_APP_ID",
        measurementId: "YOUR_MEASUREMENT_ID",
      );
    }

    // لنظام Android
    return const FirebaseOptions(
      apiKey: 'YOUR_ANDROID_API_KEY',
      appId: 'YOUR_ANDROID_APP_ID',
      messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
      projectId: 'your-app',
      storageBucket: 'your-app.appspot.com',
    );

    // لنظام iOS
    return const FirebaseOptions(
      apiKey: 'YOUR_IOS_API_KEY',
      appId: 'YOUR_IOS_APP_ID',
      messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
      projectId: 'your-app',
      storageBucket: 'your-app.appspot.com',
      iosClientId: 'YOUR_IOS_CLIENT_ID',
      iosBundleId: 'YOUR_IOS_BUNDLE_ID',
    );
  }

  static Future<void> initializeApp() async {
    await Firebase.initializeApp(
      options: currentPlatform,
    );
  }
}