// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class ServerValue {
  static const Map<String, String> timestamp = <String, String>{
    '.sv': 'timestamp'
  };

  /// Returns a placeholder value that can be used to atomically increment the
  /// current database value by the provided delta.
  static Map<dynamic, dynamic> increment(num delta) {
    return <dynamic, dynamic>{
      '.sv': {'increment': delta}
    };
  }
}
