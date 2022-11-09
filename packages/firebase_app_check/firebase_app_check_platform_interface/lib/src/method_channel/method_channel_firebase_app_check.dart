// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:_flutterfire_internals/_flutterfire_internals.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../firebase_app_check_platform_interface.dart';
import 'utils/exception.dart';
import 'utils/provider_to_string.dart';

class MethodChannelFirebaseAppCheck extends FirebaseAppCheckPlatform {
  /// Create an instance of [MethodChannelFirebaseAppCheck].
  MethodChannelFirebaseAppCheck({required FirebaseApp app})
      : super(appInstance: app) {
    _tokenChangesListeners[app.name] = StreamController<String?>.broadcast();

    channel.invokeMethod<String>('FirebaseAppCheck#registerTokenListener', {
      'appName': app.name,
    }).then((channelName) {
      final events = EventChannel(channelName!, channel.codec);
      events
          .receiveGuardedBroadcastStream(onError: convertPlatformException)
          .listen(
        (arguments) {
          // ignore: close_sinks
          StreamController<String?> controller =
              _tokenChangesListeners[app.name]!;
          Map<dynamic, dynamic> result = arguments;
          controller.add(result['token'] as String?);
        },
      );
    });
  }

  static final Map<String, StreamController<String?>> _tokenChangesListeners =
      {};

  static Map<String, MethodChannelFirebaseAppCheck>
      _methodChannelFirebaseAppCheckInstances =
      <String, MethodChannelFirebaseAppCheck>{};

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
  Future<void> activate({
    String? webRecaptchaSiteKey,
    AndroidProvider? androidProvider,
  }) async {
    try {
      await channel.invokeMethod<void>('FirebaseAppCheck#activate', {
        'appName': app.name,
        // Allow value to pass for debug mode for unit testing
        if (Platform.isAndroid || kDebugMode)
          'androidProvider': getProviderString(androidProvider),
      });
    } on PlatformException catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<String?> getToken(bool forceRefresh) async {
    try {
      final result = await channel.invokeMapMethod(
        'FirebaseAppCheck#getToken',
        {'appName': app.name, 'forceRefresh': forceRefresh},
      );

      return result!['token'];
    } on PlatformException catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setTokenAutoRefreshEnabled(
    bool isTokenAutoRefreshEnabled,
  ) async {
    try {
      await channel.invokeMethod(
        'FirebaseAppCheck#setTokenAutoRefreshEnabled',
        {
          'appName': app.name,
          'isTokenAutoRefreshEnabled': isTokenAutoRefreshEnabled
        },
      );
    } on PlatformException catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Stream<String?> get onTokenChange {
    return _tokenChangesListeners[app.name]!.stream;
  }
}
