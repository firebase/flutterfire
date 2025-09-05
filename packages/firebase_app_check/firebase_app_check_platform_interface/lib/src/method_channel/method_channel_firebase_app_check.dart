// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:_flutterfire_internals/_flutterfire_internals.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_app_check_platform_interface/src/pigeon/messages.pigeon.dart';
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

  final _hostApi = FirebaseAppCheckHostApi();

  @override
  Future<void> activate({
    WebProvider? webProvider,
    AndroidProvider? androidProvider,
    AppleProvider? appleProvider,
  }) async {
    try {
      // Convert platform interface types to Pigeon types
      AppCheckWebProvider pigeonWebProvider = AppCheckWebProvider(
        providerName: webProvider != null ? _getWebProviderString(webProvider) : 'debug'
      );
      AppCheckAndroidProvider pigeonAndroidProvider = AppCheckAndroidProvider(
        providerName: getAndroidProviderString(androidProvider)
      );
      AppCheckAppleProvider pigeonAppleProvider = AppCheckAppleProvider(
        providerName: getAppleProviderString(appleProvider)
      );
      
      await _hostApi.activate(app.name, pigeonWebProvider, pigeonAndroidProvider, pigeonAppleProvider);
    } on PlatformException catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  /// Converts [WebProvider] to [String]
  String _getWebProviderString(WebProvider? provider) {
    if (provider is ReCaptchaV3Provider) {
      return 'reCAPTCHA';
    } else if (provider is ReCaptchaEnterpriseProvider) {
      return 'reCAPTCHA';
    } else {
      return 'debug';
    }
  }

  @override
  Future<String?> getToken(bool forceRefresh) async {
    try {
      return await _hostApi.getToken(app.name, forceRefresh);
    } on PlatformException catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setTokenAutoRefreshEnabled(
    bool isTokenAutoRefreshEnabled,
  ) async {
    try {
      await _hostApi.setTokenAutoRefreshEnabled(app.name, isTokenAutoRefreshEnabled);
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
      return await _hostApi.getLimitedUseToken(app.name);
    } on PlatformException catch (e, s) {
      convertPlatformException(e, s);
    }
  }
}
