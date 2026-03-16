import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyCTREryNBWncGG1J1LHsM1kuRv2kqCX7v0',
      appId: '1:687028189828:web:34e740d06a0be21a2ba0d1',
      messagingSenderId: '687028189828',
      projectId: 'tapsurvivor-88a47',
      authDomain: 'tapsurvivor-88a47.firebaseapp.com',
      storageBucket: 'tapsurvivor-88a47.firebasestorage.app',
      measurementId: 'G-4WFBQWSHKB',
    );
  }
}
