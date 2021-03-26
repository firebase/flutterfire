extension Convert<T> on T? {
  R? safeCast<R>() {
    if (this is R) return this as R;
    return null;
  }

  R? guard<R>(R Function(T v) cb) {
    if (this == null) return null;
    return cb(this as T);
  }

  Map<Key, Value>? castMap<Key, Value>() {
    return safeCast<Map<Object?, Object?>>()?.cast<Key, Value>();
  }

  List<Value>? castList<Value>() {
    final value = this;

    return value is Iterable ? value.cast<Value>().toList() : null;
  }
}
