// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_data_connect;

/// Keeps track of whether the value has been set or not
enum OptionalState { unset, set }

class Optional<T> {
  Optional.optional(this.deserializer, this.serializer);

  Optional(this.deserializer);
  OptionalState state = OptionalState.unset;
  Serializer<T>? serializer;
  Deserializer<T> deserializer;
  T? _value;
  set value(T? val) {
    _value = val;
    state = OptionalState.set;
  }

  T? get value {
    return _value;
  }

  void fromJson(dynamic json) {
    if (json is List) {
      value = (json as List).map((e) => deserializer(e)) as T;
    } else {
      debugPrint('$json is not a list');
      value = deserializer(json as String);
    }
  }

  String toJson() {
    if (_value != null) {
      if (serializer != null) {
        if (_value is List) {
          return (_value! as List).map((e) => serializer!(e)).toString();
        } else {
          debugPrint('$_value is not a list');
        }
        return serializer!(_value as T);
      } else {
        return _value.toString();
      }
    }
    return '';
  }
}
