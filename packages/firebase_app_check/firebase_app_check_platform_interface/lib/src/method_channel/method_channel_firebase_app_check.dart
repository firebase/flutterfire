// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import '../../firebase_app_check_platform_interface.dart';
import 'utils/exception.dart';

class MethodChannelFirebaseAppCheck extends FirebaseAppCheckPlatform {
  static Map<String, StreamController<AppCheckTokenResult>>
      _tokenChangesStreamControllers = {};

  /// Create an instance of [MethodChannelFirebaseAppCheck].
  MethodChannelFirebaseAppCheck({required FirebaseApp app})
      : super(appInstance: app) {
    // Add a new StreamController for the current app.
    _tokenChangesStreamControllers[app.name] =
        StreamController<AppCheckTokenResult>.broadcast();

    // If a method channel handler has not been created - init one.
    if (_initialized) return;
    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'FirebaseAppCheck#idTokenChanges':
          Map<dynamic, dynamic> result =
              call.arguments as Map<dynamic, dynamic>;
          String appName = result['appName'];

          _tokenChangesStreamControllers[appName]!
              .add(AppCheckTokenResult(result['token']));
          break;
        default:
          throw UnimplementedError('${call.method} has not been implemented');
      }
    });
    _initialized = true;
  }

  static Map<String, MethodChannelFirebaseAppCheck>
      _methodChannelFirebaseAppCheckInstances =
      <String, MethodChannelFirebaseAppCheck>{};

  static bool _initialized = false;

  /// The [MethodChannel] used to communicate with the native plugin
  static MethodChannel channel = const MethodChannel(
    'plugins.flutter.io/firebase_app_check',
  );

  /// Returns a stub instance to allow the platform interface to access
  /// the class instance statically.
  static MethodChannelFirebaseAppCheck get instance {
    return MethodChannelFirebaseAppCheck._();
  }

  /// Internal stub class initializer.
  ///
  /// When the user code calls an auth method, the real instance is
  /// then initialized via the [delegateFor] method.
  MethodChannelFirebaseAppCheck._() : super(appInstance: null);

  @override
  FirebaseAppCheckPlatform delegateFor({required FirebaseApp app}) {
    return _methodChannelFirebaseAppCheckInstances.putIfAbsent(app.name, () {
      return MethodChannelFirebaseAppCheck(app: app);
    });
  }

  @override
  MethodChannelFirebaseAppCheck setInitialValues() {
    return this;
  }

  @override
  Future<void> activate({String? webRecaptchaSiteKey}) async {
    try {
      await channel.invokeMethod<void>('FirebaseAppCheck#activate', {
        'appName': app.name,
      });
    } on PlatformException catch (e, s) {
      throw platformExceptionToFirebaseException(e, s);
    }
  }

  @override
  Future<AppCheckTokenResult> getToken(bool forceRefresh) async {
    try {
      final result = await channel.invokeMapMethod(
        'FirebaseAppCheck#getToken',
        {'appName': app.name, 'forceRefresh': forceRefresh},
      );

      return AppCheckTokenResult(result!['token']);
    } on PlatformException catch (e, s) {
      throw platformExceptionToFirebaseException(e, s);
    }
  }

  @override
  Future<void> setTokenAutoRefreshEnabled(
    bool isTokenAutoRefreshEnabled,
  ) async {
    try {
      await channel.invokeMapMethod(
        'FirebaseAppCheck#setTokenAutoRefreshEnabled',
        {
          'appName': app.name,
          'isTokenAutoRefreshEnabled': isTokenAutoRefreshEnabled
        },
      );
    } on PlatformException catch (e, s) {
      throw platformExceptionToFirebaseException(e, s);
    }
  }

  @override
  Stream<AppCheckTokenResult> tokenChanges() {
    return _tokenChangesStreamControllers[app.name]!.stream;
  }
}
