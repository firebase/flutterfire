// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_ml_model_downloader_platform_interface/src/method_channel/method_channel_firebase_ml_model_downloader.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

typedef MethodCallCallback = dynamic Function(MethodCall methodCall);
typedef Callback = Function(MethodCall call);

void setupFirebaseModelDownloaderMocks([Callback? customHandlers]) {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
}

void handleMethodCall(MethodCallCallback methodCallCallback) =>
    MethodChannelFirebaseModelDownloader.channel
        .setMockMethodCallHandler((call) async {
      return await methodCallCallback(call);
    });

Future<void> testExceptionHandling(String type, Function testMethod) async {
  try {
    await testMethod();
  } on FirebaseException catch (_) {
    if (type == 'PLATFORM' || type == 'EXCEPTION') {
      return;
    }
    fail(
      'testExceptionHandling: $testMethod threw unexpected FirebaseException',
    );
  } catch (e) {
    fail('testExceptionHandling: $testMethod threw invalid exception $e');
  }
}
