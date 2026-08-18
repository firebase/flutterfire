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

class AnyValue {
  AnyValue(this.value);

  /// fromJson takes the dynamic values and converts them into the any type.
  AnyValue.fromJson(dynamic json) {
    value = json;
  }
  dynamic value;

  /// toJson converts the array into a json-encoded string.
  dynamic toJson() {
    if (value is bool || value is double || value is int || value is String) {
      return value;
    } else {
      if (value is List) {
        return (value as List).map((e) => AnyValue(e).toJson()).toList();
      } else if (value is Map) {
        // TODO(mtewani): Throw an error if this is the wrong type.
        return convertMap(value as Map<String, dynamic>);
      }
      try {
        return value.toJson();
      } catch (e) {
        // empty cache to try and encode the value
      }
      try {
        return value;
      } catch (e) {
        throw Exception('Could not encode type ${value.runtimeType}');
      }
    }
  }
}

Map<String, dynamic> convertMap(Map<String, dynamic> map) {
  return map.map((key, value) {
    if (value is String) {
      return MapEntry(key, value);
    } else {
      return MapEntry(key, AnyValue(value).toJson());
    }
  });
}

dynamic defaultSerializer(dynamic v) {
  return v.toJson();
}
