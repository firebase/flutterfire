// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

typedef Callback = Function(MethodCall call);

const String kTestString = 'Hello World';
const String kBucket = 'gs://fake-storage-bucket-url.com';
const String kSecondaryBucket = 'gs://fake-storage-bucket-url-2.com';

void resetFirebaseCoreMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Rest Firebase core apps & instance.
  // TODO(Salakar): Is this an API core could provide for testing, e.g. Firebase.reset().
  MethodChannelFirebase.appInstances = {};
  MethodChannelFirebase.isCoreInitialized = false;
  FirebasePlatform.instance = MethodChannelFirebase();

  setupFirebaseCoreMocks();
}

class MockHttpsCallablePlatform extends HttpsCallablePlatform {
  MockHttpsCallablePlatform(FirebaseFunctionsPlatform functions, String? origin,
      String name, HttpsCallableOptions options)
      : super(functions, origin, name, options);

  @override
  Future<dynamic> call([dynamic parameters]) async {
    // For testing purpose we return input data as output data.
    return parameters;
  }
}

class MockFirebaseFunctionsPlatform extends FirebaseFunctionsPlatform {
  MockFirebaseFunctionsPlatform({FirebaseApp? app, required String region})
      : super(app, region);

  @override
  HttpsCallablePlatform httpsCallable(
      String? origin, String name, HttpsCallableOptions options) {
    HttpsCallablePlatform httpsCallablePlatform =
        MockHttpsCallablePlatform(this, origin, name, options);
    return httpsCallablePlatform;
  }

  @override
  FirebaseFunctionsPlatform delegateFor(
      {FirebaseApp? app, required String region}) {
    MockFirebaseFunctionsPlatform functionsPlatform =
        MockFirebaseFunctionsPlatform(app: app, region: region);
    return functionsPlatform;
  }
}
