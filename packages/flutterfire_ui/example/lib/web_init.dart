// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

Future<void> initializeFirebase() {
  return Firebase.initializeApp(options: firebaseOptions);
}
