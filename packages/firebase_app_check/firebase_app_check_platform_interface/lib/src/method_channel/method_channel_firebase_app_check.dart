// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:_flutterfire_internals/_flutterfire_internals.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../firebase_app_check_platform_interface.dart';
import '../pigeon/messages.pigeon.dart';
import 'utils/exception.dart';
import 'utils/provider_to_string.dart';

class MethodChannelFirebaseAppCheck extends FirebaseAppCheckPlatform {
  /// Create an instance of [MethodChannelFirebaseAppCheck].
  MethodChannelFirebaseAppCheck({required FirebaseApp app})
      : super(appInstance: app) {
    _tokenChangesListeners[app.name] = StreamController<String?>.broadcast();

    _pigeonApi.registerTokenListener(app.name).then((channelName) {
      final events = EventChannel(channelName);
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

  /// The Pigeon API used for platform communication.
  final FirebaseAppCheckHostApi _pigeonApi = FirebaseAppCheckHostApi();

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
    WebProvider? webProvider,
    @Deprecated(
      'Use providerAndroid instead. '
      'This parameter will be removed in a future major release.',
    )
    AndroidProvider? androidProvider,
    @Deprecated(
      'Use providerApple instead. '
      'This parameter will be removed in a future major release.',
    )
    AppleProvider? appleProvider,
    AndroidAppCheckProvider? providerAndroid,
    AppleAppCheckProvider? providerApple,
  }) async {
    try {
      String? debugToken;
      if (providerAndroid is AndroidDebugProvider &&
          providerAndroid.debugToken != null) {
        debugToken = providerAndroid.debugToken;
      } else if (providerApple is AppleDebugProvider &&
          providerApple.debugToken != null) {
        debugToken = providerApple.debugToken;
      }

      await _pigeonApi.activate(
        app.name,
        defaultTargetPlatform == TargetPlatform.android || kDebugMode
            ? getAndroidProviderString(
                legacyProvider: androidProvider,
                newProvider: providerAndroid,
              )
            : null,
        defaultTargetPlatform == TargetPlatform.iOS ||
                defaultTargetPlatform == TargetPlatform.macOS ||
                kDebugMode
            ? getAppleProviderString(
                legacyProvider: appleProvider,
                newProvider: providerApple,
              )
            : null,
        debugToken,
      );
    } on PlatformException catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<String?> getToken(bool forceRefresh) async {
    try {
      return await _pigeonApi.getToken(app.name, forceRefresh);
    } on PlatformException catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setTokenAutoRefreshEnabled(
    bool isTokenAutoRefreshEnabled,
  ) async {
    try {
      await _pigeonApi.setTokenAutoRefreshEnabled(
        app.name,
        isTokenAutoRefreshEnabled,
      );
    } on PlatformException catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Stream<String?> get onTokenChange {
    return _tokenChangesListeners[app.name]!.stream;
  }

  @override
  Future<String> getLimitedUseToken() async {
    try {
      return await _pigeonApi.getLimitedUseAppCheckToken(app.name);
    } on PlatformException catch (e, s) {
      convertPlatformException(e, s);
    }
  }
}
