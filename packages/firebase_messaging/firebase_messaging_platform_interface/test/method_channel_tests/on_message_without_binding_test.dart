// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

// Kept in its own file: it needs an isolate without a Flutter binding, like a
// plain unit test of code that subscribes to `FirebaseMessaging.onMessage`.
void main() {
  test('listening to the message streams does not need a binding', () async {
    final onMessage = FirebaseMessagingPlatform.onMessage.stream.listen((_) {});
    final onMessageOpenedApp =
        FirebaseMessagingPlatform.onMessageOpenedApp.stream.listen((_) {});

    await onMessage.cancel();
    await onMessageOpenedApp.cancel();
  });
}
