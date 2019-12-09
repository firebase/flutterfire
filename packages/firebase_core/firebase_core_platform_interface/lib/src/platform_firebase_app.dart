// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:quiver/core.dart';

import 'firebase_options.dart';

/// A data class storing the name and options of a Firebase app.
///
/// This is created as a result of calling
/// [`firebase.initializeApp`](https://firebase.google.com/docs/reference/js/firebase#initialize-app)
/// in the various platform implementations.
///
/// This class is different from `FirebaseApp` declared in
/// `package:firebase_core`: `FirebaseApp` is initialized synchronously, and
/// the options for the app are obtained via a call that returns
/// `Future<FirebaseOptions>`. This class is the platform representation of a
/// Firebase app.
class PlatformFirebaseApp {
  PlatformFirebaseApp(this.name, this.options);

  /// The name of this Firebase app.
  final String name;

  /// The options that this app was configured with.
  final FirebaseOptions options;

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other is! PlatformFirebaseApp) return false;
    return other.name == name && other.options == options;
  }

  @override
  int get hashCode => hash2(name, options);

  @override
  String toString() => '$PlatformFirebaseApp($name)';
}
