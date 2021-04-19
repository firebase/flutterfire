export 'package:firebase_core/src/internals.dart' hide guard;

import 'package:firebase_core/firebase_core.dart';
// ignore: implementation_imports
import 'package:firebase_core/src/internals.dart' as internals;

/// Will return a [FirebaseException] from a thrown web error.
/// Any other errors will be propagated as normal.
R guard<R>(R Function() cb) {
  return internals.guard(
    cb,
    plugin: 'cloud_firestore',
    codeParser: (code) => code.replaceFirst('firestore/', ''),
  );
}
