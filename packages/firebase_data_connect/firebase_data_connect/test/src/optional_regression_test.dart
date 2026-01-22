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

import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:firebase_data_connect/src/common/common_library.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Optional Regression Tests', () {
    test('listDeserializer should handle List<dynamic> input', () {
      final stringDeserializer = (dynamic json) => json as String;
      final deserializer = listDeserializer(stringDeserializer);

      // Simulating JSON decode which produces List<dynamic>
      final List<dynamic> jsonList = ['a', 'b'];

      final result = deserializer(jsonList);
      expect(result, isA<List<String>>());
      expect(result, equals(['a', 'b']));
    });

    test('listSerializer should handle List<dynamic> input if elements are correct type', () {
      final stringSerializer = (String value) => value;
      final serializer = listSerializer(stringSerializer);

      // List<dynamic> but contains Strings
      final List<dynamic> list = ['a', 'b'];

      // We need to cast it to List<String> to pass type check of `DynamicSerializer<List<T>>`
      // which expects `List<T>`.
      // Wait, `DynamicSerializer` is defined as `typedef DynamicSerializer<Variables> = dynamic Function(Variables vars);`
      // So `listSerializer<String>` returns `DynamicSerializer<List<String>>` i.e. `dynamic Function(List<String> vars)`.
      // Thus we cannot pass `List<dynamic>` to it directly in a statically typed language if strict checks are on.
      // But we can cast it to dynamic first to bypass static check, or use `Function.apply`.

      // However, the internal implementation of `listSerializer` casts `data` to `List`.
      // So if we pass it as dynamic, it should work.

      final result = (serializer as Function)(list);
      expect(result, equals(['a', 'b']));
    });

    test('listSerializer should fail if elements are incorrect type', () {
       final stringSerializer = (String value) => value;
      final serializer = listSerializer(stringSerializer);

      // List<dynamic> contains int
      final List<dynamic> list = [1, 2];

      expect(() => (serializer as Function)(list), throwsA(isA<TypeError>()));
    });
  });
}
