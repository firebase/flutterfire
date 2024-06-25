part of firebase_data_connect;

/// Keeps track of whether the value has been set or not
enum OptionalState { unset, set }

class Optional<T> {
  OptionalState state = OptionalState.unset;
  T? _value;
  set value(T? val) {
    _value = val;
    state = OptionalState.set;
  }

  T? get value {
    return _value;
  }
}
