import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyANahVtrHkNaCTZ8FMKKKorEPezTrNMC18',
      appId: '1:238385591985:web:66473faa803becc92a5490',
      messagingSenderId: '238385591985',
      projectId: 'virtuwal-8ba9b',
      authDomain: 'virtuwal-8ba9b.firebaseapp.com',
      databaseURL: 'https://virtuwal-8ba9b-default-rtdb.asia-southeast1.firebasedatabase.app',
      storageBucket: 'virtuwal-8ba9b.firebasestorage.app',
    );
  }
}
