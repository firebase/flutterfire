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
  group('Timestamp', () {
    test('constructor initializes with correct nanoseconds and seconds', () {
      final timestamp = Timestamp(500, 864000); // Example timestamp values
      expect(timestamp.nanoseconds, 500);
      expect(timestamp.seconds, 864000);
    });

    test('fromJson throws exception for invalid date format', () {
      expect(() => Timestamp.fromJson('invalid-date'), throwsException);
    });

    test('fromJson correctly parses date with nanoseconds and UTC (Z) format',
        () {
      final timestamp = Timestamp.fromJson('1970-01-11T00:00:00.123456789Z');
      expect(timestamp.seconds, 864000);
      expect(timestamp.nanoseconds, 123456789);
    });

    test('fromJson correctly parses date without nanoseconds', () {
      final timestamp = Timestamp.fromJson('1970-01-11T00:00:00Z');
      expect(timestamp.seconds, 864000);
      expect(timestamp.nanoseconds, 0);
    });

    test('fromJson correctly handles timezones with positive offset', () {
      final timestamp = Timestamp.fromJson('1970-01-11T00:00:00+02:00');
      expect(
        timestamp.seconds,
        864000 - (2 * 3600),
      ); // Adjusts by the positive timezone offset
    });

    test('fromJson correctly handles timezones with negative offset', () {
      final timestamp = Timestamp.fromJson('1970-01-11T00:00:00-05:00');
      expect(
        timestamp.seconds,
        864000 + (5 * 3600),
      ); // Adjusts by the negative timezone offset
    });

    test('toJson correctly serializes to ISO8601 string with nanoseconds', () {
      final timestamp = Timestamp(123456789, 864000); // Example timestamp
      final json = timestamp.toJson();
      expect(json, '1970-01-11T00:00:00.123456789Z');
    });

    test('toJson correctly serializes to ISO8601 string without nanoseconds',
        () {
      final timestamp = Timestamp(0, 864000); // No nanoseconds
      final json = timestamp.toJson();
      expect(json, '1970-01-11T00:00:00.000Z');
    });

    test('toDateTime correctly converts to DateTime object', () {
      final timestamp = Timestamp(0, 864000); // Example timestamp
      final dateTime = timestamp.toDateTime();
      expect(dateTime, DateTime.utc(1970, 1, 11));
    });
  });
}
