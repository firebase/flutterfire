// DO NOT MOVE THIS FILE
//
// Other firebase packages may import `package:firebase_core/src/internals.dart`.
// Moving it would break the imports
//
// This file exports utilities shared between firebase packages, without making
// them public.

extension ObjectX<T> on T? {
  R? guard<R>(R Function(T value) cb) {
    if (this is T) return cb(this as T);
    return null;
  }

  R? safeCast<R>() {
    if (this is R) return this as R;
    return null;
  }
}
