// A library that mimicks package:firebase_core_web/firebase_core_web_interop.dart
// for platforms that do not target dart2js

abstract class FirebaseError {
  String get code;
  String get message;
  String get name;
  String get stack;
  Object get serverResponse;
}
