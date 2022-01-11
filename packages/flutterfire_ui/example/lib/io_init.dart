import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> initializeFirebase() {
  if (Platform.isIOS || Platform.isMacOS) {
    return Firebase.initializeApp();
  } else {
    return Firebase.initializeApp(options: firebaseOptions);
  }
}
