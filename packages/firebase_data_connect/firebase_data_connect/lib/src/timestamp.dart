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

/// Timestamp class is a custom class that allows for storing of nanoseconds.
class Timestamp {
  // ignore: use_raw_strings
  final regex = RegExp(
    r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{0,9})?(Z|[+-]\d{2}:\d{2})$',
  );

  /// Constructor
  Timestamp(this.nanoseconds, this.seconds);

  Timestamp.fromJson(String date) {
    if (!regex.hasMatch(date)) {
      throw Exception('Invalid Date provided!');
    }
    DateTime dateTime = DateTime.parse(date);
    seconds = dateTime.millisecondsSinceEpoch ~/ 1000;
    String nanoStr = '';
    int dotIdx = date.indexOf('.');
    if (dotIdx > -1) {
      for (int i = dotIdx + 1; i < date.length; i++) {
        if (int.tryParse(date[i]) != null) {
          nanoStr += date[i];
        } else {
          break;
        }
      }
    }
    if (nanoStr.isNotEmpty) {
      nanoseconds = int.parse(nanoStr.padRight(9, '0'));
    }
  }

  String toJson() {
    String secondsStr =
        DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true)
            .toIso8601String();
    if (nanoseconds == 0) {
      return secondsStr;
    }
    String nanoStr = nanoseconds.toString().padRight(9, '0');
    return '${secondsStr.substring(0, 19)}.${nanoStr}Z';
  }

  DateTime toDateTime() {
    final string = toJson();
    final date = DateTime.parse(string);
    return date;
  }

  /// Current nanoseconds
  int nanoseconds = 0;

  /// Current seconds
  int seconds = 0;
}
