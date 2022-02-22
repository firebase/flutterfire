// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

export 'package:firebase_core/src/internals.dart' hide guardWebExceptions;

import 'package:firebase_core/firebase_core.dart';
// ignore: implementation_imports
import 'package:firebase_core/src/internals.dart' as internals;

/// Will return a [FirebaseException] from a thrown web error.
/// Any other errors will be propagated as normal.
Future<R> convertWebExceptions<R>(R Function() cb) async {
  return internals.guardWebExceptions(
    cb,
    plugin: 'firebase_performance',
    codeParser: (code) => code.replaceFirst('performance/', ''),
  );
}
