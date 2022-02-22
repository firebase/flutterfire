// ignore_for_file: require_trailing_commas
export 'package:firebase_core/src/internals.dart' hide guardWebExceptions;

import 'package:firebase_core/firebase_core.dart';
// ignore: implementation_imports
import 'package:firebase_core/src/internals.dart' as internals;

/// Will return a [FirebaseException] from a thrown web error.
/// Any other errors will be propagated as normal.
R convertWebExceptions<R>(R Function() cb) {
  return internals.guardWebExceptions(
    cb,
    plugin: 'cloud_firestore',
    codeParser: (code) => code.replaceFirst('firestore/', ''),
  );
}
