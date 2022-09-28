import 'package:firebase_core/firebase_core.dart';
import 'package:_flutterfire_internals/_flutterfire_internals.dart'
    as internals;

/// Will return a [FirebaseException] from a thrown web error.
/// Any other errors will be propagated as normal.
R convertWebExceptions<R>(R Function() cb) {
  return internals.guardWebExceptions(
    cb,
    plugin: 'firebase_analytics',
    codeParser: (code) => code.replaceFirst('analytics/', ''),
  );
}
