// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.9

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_ml_custom/firebase_ml_custom.dart';
import 'dart:io' show Platform;

part 'firebase_model_manager.dart';

void main() {
  var completer = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => completer.future);
  tearDownAll(() => completer.complete(null));

  firebaseModelManagerTest();
}
