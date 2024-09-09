// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_data_connect;

/// Timestamp class is a custom class that allows for storing of nanoseconds.
class Timestamp {
  // ignore: use_raw_strings
  final regex = RegExp(
      r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{0,9})?(Z|[+-]\d{2}:\d{2})$');

  /// Constructor
  Timestamp(this.nanoseconds, this.seconds);

  // TODO(mtewani): Fix this so that it keeps track of positional arguments so you don't have to repeatedly search the string multiple times.
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
    return DateTime.parse(toJson());
  }

  /// Current nanoseconds
  int nanoseconds = 0;

  /// Current seconds
  int seconds = 0;
}
