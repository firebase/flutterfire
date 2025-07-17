// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:intl/intl.dart';

import 'common/common_library.dart';

/// Keeps track of whether the value has been set or not
enum OptionalState { unset, set }

/// Optional Class that allows users to pass in null or undefined for properties on a class.
/// If the state value is set, then we make sure to include it in the request over the wire.
/// If it's unset, then the value is ignored when sending over the wire.
class Optional<T> {
  /// Instantiates deserializer.
  Optional(this.deserializer, this.serializer);

  /// Instantiates deserializer and serializer.
  Optional.optional(this.deserializer, this.serializer);

  /// State of the value. Is unset by default.
  OptionalState state = OptionalState.unset;

  /// Serializer for value.
  DynamicSerializer<T> serializer;

  /// Deserializer for value.
  DynamicDeserializer<T> deserializer;

  /// Current value.
  T? _value;

  /// Sets the value for the variable, and the state to `Set`.
  set value(T? val) {
    _value = val;
    state = OptionalState.set;
  }

  /// Gets the current value of the object.
  T? get value {
    return _value;
  }

  /// Converts json to the value.
  void fromJson(dynamic json) {
    if (json is List) {
      value = json.map((e) => deserializer(e)) as T;
    } else {
      value = deserializer(json as String);
    }
  }

  /// Converts the value to String.
  dynamic toJson() {
    if (_value != null) {
      return serializer(_value as T);
    } else if (state == OptionalState.set) {
      return null;
    }
    return '';
  }
}

dynamic nativeToJson<T>(T type) {
  if (type is bool ||
      type is int ||
      type is double ||
      type is num ||
      type is String) {
    return type;
  } else if (type is DateTime) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(type);
  }
  throw UnimplementedError('This type is unimplemented: ${type.runtimeType}');
}

T nativeFromJson<T>(dynamic input) {
  if ((input is bool && T == bool) ||
      (input is int && T == int) ||
      (input is double && T == double) ||
      (input is num && T == num)) {
    return input;
  } else if (input is String) {
    if (T == DateTime) {
      return DateTime.parse(input) as T;
    } else if (T == String) {
      return input as T;
    }
  } else if (input is num) {
    if (input is double && T == int) {
      return input.toInt() as T;
    } else if (input is int && T == double) {
      return input.toDouble() as T;
    }
  }
  throw UnimplementedError('This type is unimplemented: ${T.runtimeType}');
}

DynamicDeserializer<List<T>> listDeserializer<T>(
  DynamicDeserializer<T> deserializer,
) {
  return (dynamic data) =>
      (data as List<T>).map((e) => deserializer(e)).toList();
}

DynamicSerializer<List<T>> listSerializer<T>(DynamicSerializer<T> serializer) {
  return (dynamic data) => (data as List<T>).map((e) => serializer(e)).toList();
}
