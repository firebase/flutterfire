// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_remote_config_platform_interface/firebase_remote_config_platform_interface.dart';
import 'package:firebase_remote_config_platform_interface/src/method_channel/method_channel_firebase_remote_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses native throttled fetch status', () {
    final remoteConfig =
        MethodChannelFirebaseRemoteConfig.instance.setInitialValues(
      remoteConfigValues: <String, Object?>{
        'lastFetchStatus': 'throttled',
      },
    );

    expect(remoteConfig.lastFetchStatus, RemoteConfigFetchStatus.throttle);
  });
}
