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
import 'package:flutter_test/flutter_test.dart';

typedef Serializer<T> = String Function(T value);
typedef Deserializer<T> = T Function(String json);

class MyObject {
  String myStr = '1';
  int myInt = 1;
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['myStr'] = myStr;
    json['myInt'] = myInt;
    return json;
  }
}

void main() {
  group('AnyValue', () {
    test('constructor initializes number type', () {
      final any = AnyValue(1);
      expect(any.value, equals(1));
    });
    test('constructor initializes string type', () {
      final any = AnyValue('abc');
      expect(any.value, equals('abc'));
    });
    test('constructor serializes string type', () {
      final any = AnyValue('abc');
      expect(any.toJson(), equals('abc'));
    });
    test('constructor serializes number type', () {
      final any = AnyValue(1);
      expect(any.toJson(), equals(1));
      expect(AnyValue.fromJson(1).value, equals(1));
    });
    test('constructor serializes custom object type', () {
      final any = AnyValue(MyObject());
      expect(any.toJson(), equals(MyObject().toJson()));
    });
    test('constructor serializes custom map type', () {
      final map = {'a': 1, 'b': 2.0};
      final any = AnyValue(map);
      expect(any.toJson(), equals(map));
    });
    test('constructor serializes List of map', () {
      final listOfMap = [
        {'a': 1, 'b': 2.0},
        {'c': 3, 'd': 4.0},
        {'e': 5, 'f': null},
      ];
      final any = AnyValue(listOfMap);
      expect(any.toJson(), equals(listOfMap));
    });
    test('constructor serializes List of primitive type', () {
      final cases = [
        [1, 2, 3, 4, 5],
        [1.0, 2.0, 3.0, 4.0, 5.0],
        ['a', 'b', 'c', 'd', 'e'],
        [true, false, true, false],
        [1, 2.0, null, 4],
      ];

      for (final list in cases) {
        final any = AnyValue(list);
        expect(any.toJson(), equals(list));
      }
    });
  });
}
