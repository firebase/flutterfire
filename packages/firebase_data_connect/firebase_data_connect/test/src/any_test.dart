// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unused_local_variable

import 'dart:convert';

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
  });
}
