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

// ignore_for_file: unused_local_variable

import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:firebase_data_connect/src/common/common_library.dart';
import 'package:flutter_test/flutter_test.dart';

typedef Serializer<T> = dynamic Function(T value);
typedef Deserializer<T> = T Function(String json);

void main() {
  group('Optional', () {
    late DynamicDeserializer<String> stringDeserializer;
    late Serializer<String> stringSerializer;
    late Deserializer<int> intDeserializer;
    late Serializer<int> intSerializer;

    setUp(() {
      stringDeserializer = (json) => json;
      stringSerializer = (value) => value;
      intDeserializer = int.parse;
      intSerializer = (value) => value;
    });

    test('constructor initializes with deserializer', () {
      final optional = Optional<String>(stringDeserializer, stringSerializer);
      expect(optional.deserializer, equals(stringDeserializer));
      expect(optional.state, equals(OptionalState.unset));
      expect(optional.value, isNull);
    });

    test('constructor initializes with deserializer and serializer', () {
      final optional = Optional.optional(stringDeserializer, stringSerializer);
      expect(optional.deserializer, equals(stringDeserializer));
      expect(optional.serializer, equals(stringSerializer));
    });

    test('value setter updates value and sets state', () {
      final optional = Optional<String>(stringDeserializer, stringSerializer);

      optional.value = 'Test';
      expect(optional.value, equals('Test'));
      expect(optional.state, equals(OptionalState.set));
    });

    test('fromJson correctly deserializes and sets value', () {
      final optional = Optional<String>(stringDeserializer, stringSerializer);

      optional.fromJson('Test');
      expect(optional.value, equals('Test'));
      expect(optional.state, equals(OptionalState.set));
    });

    test('toJson correctly serializes the value', () {
      final optional = Optional.optional(stringDeserializer, stringSerializer);

      optional.value = 'Test';
      expect(optional.toJson(), equals('Test'));
    });

    test('toJson returns empty string when value is null', () {
      final optional = Optional.optional(stringDeserializer, stringSerializer);

      optional.value = null;
      expect(optional.toJson(), equals(null));
    });

    test('nativeToJson correctly serializes primitive types', () {
      expect(nativeToJson(42), equals(42));
      expect(nativeToJson(true), equals(true));
      expect(nativeToJson('Test'), equals('Test'));
    });

    test('nativeFromJson correctly deserializes primitive types', () {
      expect(nativeFromJson<String>('42'), equals('42'));
      expect(nativeFromJson<int>(42), equals(42));
      expect(nativeFromJson<bool>(true), equals(true));
      expect(nativeFromJson<String>('Test'), equals('Test'));
    });

    test('nativeToJson correctly serializes null primitive types', () {
      Optional intValue = Optional(nativeFromJson, nativeToJson);
      intValue.value = null;
      expect(intValue.toJson(), equals(null));
      Optional floatValue = Optional(nativeFromJson, nativeToJson);
      floatValue.value = null;
      expect(floatValue.toJson(), equals(null));
    });

    // Since protobuf doesn't distinguish between int and double, we need to do the parsing ourselves
    test('nativeFromJson correctly matches int to int and double to double',
        () {
      double expectedDouble = 42;
      int expectedInt = 42;
      expect(nativeFromJson<double>(42), equals(expectedDouble));
      expect(nativeFromJson<int>(expectedDouble), equals(expectedInt));
    });
    test('nativeFromJson correctly deserializes DateTime strings', () {
      expect(
        nativeFromJson<DateTime>('2024-01-01'),
        equals(DateTime.parse('2024-01-01')),
      );
    });

    test('nativeToJson throws UnimplementedError for unsupported types', () {
      expect(() => nativeToJson(Object()), throwsUnimplementedError);
    });

    test('nativeFromJson throws UnimplementedError for unsupported types', () {
      expect(() => nativeFromJson<Object>('abc'), throwsUnimplementedError);
    });
  });
}
