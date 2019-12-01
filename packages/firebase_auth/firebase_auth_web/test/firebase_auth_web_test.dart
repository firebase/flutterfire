// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js' as js;

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_web/firebase_core_web.dart';

void main() {
  group('$FirebaseAuthWeb', () {
    setUp(() {
      final js.JsObject firebaseMock = js.JsObject.jsify(<String, dynamic>{});
      js.context['firebase'] = firebaseMock;
      FirebaseCorePlatform.instance = FirebaseCoreWeb();
      FirebaseAuthPlatform.instance = FirebaseAuthWeb();
    });
  });
}
