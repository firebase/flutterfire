// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_app_installations_platform_interface/src/method_channel/method_channel_firebase_app_installations.dart';
import 'package:firebase_app_installations_platform_interface/src/pigeon/messages.pigeon.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock.dart';

const String _hostApiPrefix =
    'dev.flutter.pigeon.firebase_app_installations_platform_interface.FirebaseAppInstallationsHostApi';

void main() {
  setupFirebaseAppInstallationsMocks();

  late FirebaseApp app;
  late MethodChannelFirebaseAppInstallations installations;

  String? lastDeleteAppName;
  String? lastGetIdAppName;
  String? lastGetTokenAppName;
  bool? lastForceRefresh;
  String? lastRegisterAppName;

  ByteData? encodeSuccess([Object? value]) {
    return FirebaseAppInstallationsHostApi.pigeonChannelCodec.encodeMessage(
      <Object?>[value],
    );
  }

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('$_hostApiPrefix.registerIdChangeListener', (
          ByteData? message,
        ) async {
          final List<Object?> args =
              FirebaseAppInstallationsHostApi.pigeonChannelCodec.decodeMessage(
                    message,
                  )
                  as List<Object?>;
          lastRegisterAppName = args[0]! as String;
          return encodeSuccess(
            'plugins.flutter.io/firebase_app_installations/token/$lastRegisterAppName',
          );
        });

    app = await Firebase.initializeApp();
    installations = MethodChannelFirebaseAppInstallations(app: app);
    await Future<void>.delayed(Duration.zero);
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(
          '$_hostApiPrefix.registerIdChangeListener',
          null,
        );
  });

  setUp(() {
    lastDeleteAppName = null;
    lastGetIdAppName = null;
    lastGetTokenAppName = null;
    lastForceRefresh = null;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('$_hostApiPrefix.delete', (
          ByteData? message,
        ) async {
          final List<Object?> args =
              FirebaseAppInstallationsHostApi.pigeonChannelCodec.decodeMessage(
                    message,
                  )
                  as List<Object?>;
          lastDeleteAppName = args[0]! as String;
          return encodeSuccess();
        });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('$_hostApiPrefix.getId', (
          ByteData? message,
        ) async {
          final List<Object?> args =
              FirebaseAppInstallationsHostApi.pigeonChannelCodec.decodeMessage(
                    message,
                  )
                  as List<Object?>;
          lastGetIdAppName = args[0]! as String;
          return encodeSuccess('test-installation-id');
        });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('$_hostApiPrefix.getToken', (
          ByteData? message,
        ) async {
          final List<Object?> args =
              FirebaseAppInstallationsHostApi.pigeonChannelCodec.decodeMessage(
                    message,
                  )
                  as List<Object?>;
          lastGetTokenAppName = args[0]! as String;
          lastForceRefresh = args[1]! as bool;
          return encodeSuccess('test-installation-token');
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('$_hostApiPrefix.delete', null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('$_hostApiPrefix.getId', null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('$_hostApiPrefix.getToken', null);
  });

  test('delete forwards the app name', () async {
    await installations.delete();

    expect(lastDeleteAppName, app.name);
  });

  test('getId forwards the app name', () async {
    final id = await installations.getId();

    expect(lastGetIdAppName, app.name);
    expect(id, 'test-installation-id');
  });

  test('getToken forwards the app name and forceRefresh', () async {
    final token = await installations.getToken(true);

    expect(lastGetTokenAppName, app.name);
    expect(lastForceRefresh, isTrue);
    expect(token, 'test-installation-token');
  });

  test('registerIdChangeListener is invoked for onIdChange setup', () {
    expect(lastRegisterAppName, app.name);
  });
}
