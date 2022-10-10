import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

Future<void> initializeFirebase() {
  return Firebase.initializeApp(options: firebaseOptions);
}
