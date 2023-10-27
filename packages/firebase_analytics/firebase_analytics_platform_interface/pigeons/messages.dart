// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: one_member_abstracts

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeon/messages.pigeon.dart',
    // We export in the lib folder to expose the class to other packages.
    dartTestOut: 'test/pigeon/test_api.dart',
    objcHeaderOut:
        '../firebase_analytics/ios/Classes/firebase_analytics_messages.g.h',
    objcSourceOut:
        '../firebase_analytics/ios/Classes/firebase_analytics_messages.g.m',
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
@HostApi(dartHostTestHandler: 'TestFirebaseAnalyticsHostApi')
abstract class FirebaseAnalyticsHostApi {
  @async
  void initiateOnDeviceConversionMeasurementWithEmailAddress(
    String emailAddress,
  );
}
