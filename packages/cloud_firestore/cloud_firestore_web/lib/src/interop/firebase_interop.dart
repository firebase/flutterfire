@JS('firebase')
library firebase_interop.firestore;

import 'package:firebase_core_web/firebase_core_web_interop.dart';

import 'package:js/js.dart';
import 'firestore_interop.dart';

@JS()
external FirestoreJsImpl firestore([AppJsImpl app]);
