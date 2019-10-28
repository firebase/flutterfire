// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:quiver_hashcode/hashcode.dart';

import 'firebase_options.dart';

/// A data class storing the name and options of a Firebase app.
class FirebaseAppData {
  FirebaseAppData(this.name, this.options);

  /// The name of this Firebase app.
  final String name;

  /// The options that this app was configured with.
  final FirebaseOptions options;

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other is! FirebaseAppData) return false;
    return other.name == name && other.options == options;
  }

  @override
  int get hashCode => hash2(name, options);

  @override
  String toString() => '$FirebaseAppData($name)';
}
