// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const String _initializeCoreChannel =
    'dev.flutter.pigeon.firebase_core_platform_interface.FirebaseCoreHostApi.initializeCore';

Future<void> _initializeCoreAgainAsASecondEngineWould() async {
  await ServicesBinding.instance.defaultBinaryMessenger.send(
    _initializeCoreChannel,
    null,
  );
}

void runReinitializeCoreTests() {
  group('Firebase core reinitialized by another engine', () {
    late FirebaseFirestore firestore;

    setUpAll(() {
      firestore = FirebaseFirestore.instance;
    });

    test(
      'keeps the Firestore instance and its listeners alive',
      () async {
        final document = firestore.doc('flutter-tests/reinitialize-core');
        await document.set({'value': 0});

        final listenerSawInitialValue = Completer<void>();
        final listenerSawUpdate = Completer<void>();
        final subscription = document.snapshots().listen((snapshot) {
          final value = snapshot.data()?['value'];
          if (value == 0 && !listenerSawInitialValue.isCompleted) {
            listenerSawInitialValue.complete();
          }
          if (value == 1 && !listenerSawUpdate.isCompleted) {
            listenerSawUpdate.complete();
          }
        }, onError: listenerSawUpdate.completeError);
        await listenerSawInitialValue.future;

        await _initializeCoreAgainAsASecondEngineWould();

        await document.set({'value': 1});
        await listenerSawUpdate.future.timeout(const Duration(seconds: 10));
        expect((await document.get()).data(), {'value': 1});

        await subscription.cancel();
      },
      skip:
          kIsWeb ||
          (defaultTargetPlatform != TargetPlatform.iOS &&
              defaultTargetPlatform != TargetPlatform.macOS),
    );
  });
}
