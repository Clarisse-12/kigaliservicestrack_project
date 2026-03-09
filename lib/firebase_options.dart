
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;



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
    apiKey: 'AIzaSyDVC0bUOqPq34sYb6zOU652G3j29re3iNw',
    appId: '1:905195597044:web:98b13e7053313a77ecc2a1',
    messagingSenderId: '905195597044',
    projectId: 'kigaliservicestrack',
    authDomain: 'kigaliservicestrack.firebaseapp.com',
    storageBucket: 'kigaliservicestrack.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCU0mnLBFmBmXkecxu2mAvKoiGanUP80V8',
    appId: '1:905195597044:android:b00c0b3b9d35740decc2a1',
    messagingSenderId: '905195597044',
    projectId: 'kigaliservicestrack',
    storageBucket: 'kigaliservicestrack.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyADIS0mdpfx94W8t275zF1nr9Y-DjOI9c8',
    appId: '1:905195597044:ios:243220052a8ba21decc2a1',
    messagingSenderId: '905195597044',
    projectId: 'kigaliservicestrack',
    storageBucket: 'kigaliservicestrack.firebasestorage.app',
    iosBundleId: 'com.example.kigaliServicesTrack',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyADIS0mdpfx94W8t275zF1nr9Y-DjOI9c8',
    appId: '1:905195597044:ios:243220052a8ba21decc2a1',
    messagingSenderId: '905195597044',
    projectId: 'kigaliservicestrack',
    storageBucket: 'kigaliservicestrack.firebasestorage.app',
    iosBundleId: 'com.example.kigaliServicesTrack',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDVC0bUOqPq34sYb6zOU652G3j29re3iNw',
    appId: '1:905195597044:web:652fc85d01c3d1ececc2a1',
    messagingSenderId: '905195597044',
    projectId: 'kigaliservicestrack',
    authDomain: 'kigaliservicestrack.firebaseapp.com',
    storageBucket: 'kigaliservicestrack.firebasestorage.app',
  );
}
