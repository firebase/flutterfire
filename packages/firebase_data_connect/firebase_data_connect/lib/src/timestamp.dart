// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_data_connect;

/// Timestamp class is a custom class that allows for storing of nanoseconds.
class Timestamp {
  /// Constructor
  Timestamp(this.nanoseconds, this.seconds);
  // TODO(mtewani): Fix this so that it keeps track of positional arguments so you don't have to repeatedly search the string multiple times.
  Timestamp.fromJson(String date) {
    // ignore: use_raw_strings
    var regex = RegExp(
        r'^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d{0,9})?(Z|[+-]\\d{2}:\\d{2})\$');
    if (!regex.hasMatch(date)) {
      throw Exception('Invalid Date provided!');
    }
    DateTime dateTime = DateTime.parse(date);
    seconds = dateTime.second;
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
    // TODO(mtewani): Add offset values.
    if (date.contains('Z')) {
      return;
    }
    int addIdx = date.indexOf('+');
    bool isAdd = addIdx > -1;
    int signIdx = isAdd ? addIdx : date.indexOf('-');
    int timeHour = int.parse(date.substring(signIdx + 1, signIdx + 3));
    int timeMin = int.parse(date.substring(signIdx + 4, signIdx + 6));
    int timeZoneDiffer = timeHour * 3600 + timeMin * 60;
    seconds = seconds + (isAdd ? -timeZoneDiffer : timeZoneDiffer);
  }
  String toJson() {
    String secondsStr =
        DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true)
            .toIso8601String();
    String nanoStr = nanoseconds.toString().padRight(9, '0');
    return '${secondsStr.substring(0, nanoStr.length - 1)}.${nanoStr}Z';
  }

  DateTime toDateTime() {
    return DateTime.utc((seconds * 1000 + (nanoseconds / 1000000)).floor());
  }

  /// Current nanoseconds
  int nanoseconds = 0;

  /// Current seconds
  int seconds = 0;
}
