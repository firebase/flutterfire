// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';

// ignore: implementation_imports
import 'package:firebase_core/src/internals.dart' as internals;

export 'package:firebase_core/src/internals.dart' hide guard;

/// Will return a [FirebaseException] from a thrown web error.
/// Any other errors will be propagated as normal.
R guard<R>(R Function() cb) {
  return internals.guard(
    cb,
    plugin: 'firebase_app_installations',
    codeParser: (code) => code.replaceFirst('installations/', ''),
  );
}
