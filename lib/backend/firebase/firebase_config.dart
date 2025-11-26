import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyADMa1XZAp4oZkpll328yWewzOwLX-moCA",
            authDomain: "matkenya-a1926.firebaseapp.com",
            projectId: "matkenya-a1926",
            storageBucket: "matkenya-a1926.firebasestorage.app",
            messagingSenderId: "95387823397",
            appId: "1:95387823397:web:99f916c6b1e556e96ebecc",
            measurementId: "G-HT8KCGT0FP"));
  } else {
    await Firebase.initializeApp();
  }
}
