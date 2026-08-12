// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_installations_platform_interface/src/method_channel/method_channel_firebase_app_installations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock.dart';
import '../pigeon/test_api.dart';

void main() {
  setupFirebaseAppInstallationsMocks();

  late FirebaseApp app;
  late MethodChannelFirebaseAppInstallations installations;
  late _TestFirebaseAppInstallationsHostApi hostApi;

  setUpAll(() async {
    app = await Firebase.initializeApp();
    hostApi = _TestFirebaseAppInstallationsHostApi();
    TestFirebaseAppInstallationsHostApi.setUp(hostApi);
    installations = MethodChannelFirebaseAppInstallations(app: app);
    // Allow constructor listener registration to complete.
    await Future<void>.delayed(Duration.zero);
  });

  tearDownAll(() {
    TestFirebaseAppInstallationsHostApi.setUp(null);
  });

  setUp(() {
    hostApi.reset();
  });

  test('delete forwards the app name', () async {
    await installations.delete();

    expect(hostApi.appName, app.name);
    expect(hostApi.deleteCalled, isTrue);
  });

  test('getId forwards the app name', () async {
    final id = await installations.getId();

    expect(hostApi.appName, app.name);
    expect(id, 'test-installation-id');
  });

  test('getToken forwards the app name and forceRefresh', () async {
    final token = await installations.getToken(true);

    expect(hostApi.appName, app.name);
    expect(hostApi.forceRefresh, isTrue);
    expect(token, 'test-installation-token');
  });

  test('registerIdChangeListener is invoked for onIdChange setup', () {
    expect(hostApi.registerIdChangeListenerCalled, isTrue);
    expect(hostApi.registeredAppName, app.name);
  });
}

class _TestFirebaseAppInstallationsHostApi
    implements TestFirebaseAppInstallationsHostApi {
  String? appName;
  String? registeredAppName;
  bool? forceRefresh;
  bool deleteCalled = false;
  bool registerIdChangeListenerCalled = false;

  void reset() {
    appName = null;
    forceRefresh = null;
    deleteCalled = false;
    // Keep registerIdChangeListenerCalled / registeredAppName — set during construction.
  }

  @override
  Future<void> delete(String appName) async {
    this.appName = appName;
    deleteCalled = true;
  }

  @override
  Future<String> getId(String appName) async {
    this.appName = appName;
    return 'test-installation-id';
  }

  @override
  Future<String> getToken(String appName, bool forceRefresh) async {
    this.appName = appName;
    this.forceRefresh = forceRefresh;
    return 'test-installation-token';
  }

  @override
  Future<String> registerIdChangeListener(String appName) async {
    registeredAppName = appName;
    registerIdChangeListenerCalled = true;
    return 'plugins.flutter.io/firebase_app_installations/token/$appName';
  }
}
