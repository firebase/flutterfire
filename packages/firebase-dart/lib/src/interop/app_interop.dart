@JS('firebase.app')
library firebase.app_interop;

import 'package:js/js.dart';

import 'auth_interop.dart';
import 'database_interop.dart';
import 'es6_interop.dart';
import 'firebase_interop.dart';
import 'firestore_interop.dart';
import 'functions_interop.dart';
import 'storage_interop.dart';

@JS('App')
abstract class AppJsImpl {
  external String get name;
  external FirebaseOptions get options;
  external AuthJsImpl auth();
  external DatabaseJsImpl database();
  external PromiseJsImpl<void> delete();
  external StorageJsImpl storage([String url]);
  external FirestoreJsImpl firestore();
  external FunctionsJsImpl functions([String region]);
}
