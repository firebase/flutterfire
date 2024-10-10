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
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('emptySerializer', () {
    test('should return an empty string when null is passed', () {
      final result = emptySerializer(null);
      expect(result, '');
    });

    test('should return an empty string when any value is passed', () {
      final resultWithVoid = emptySerializer(null); // void type simulation
      final resultWithInt = emptySerializer(42);
      final resultWithString = emptySerializer('Some String');
      final resultWithList = emptySerializer([1, 2, 3]);

      expect(resultWithVoid, '');
      expect(resultWithInt, '');
      expect(resultWithString, '');
      expect(resultWithList, '');
    });
  });
}
