// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:_flutterfire_internals/_flutterfire_internals.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../firebase_app_check_platform_interface.dart';
import '../pigeon/messages.pigeon.dart' as pigeon;
import 'utils/exception.dart';
import 'utils/provider_to_string.dart';

class _WindowsCustomProviderFlutterApi
    extends pigeon.FirebaseAppCheckFlutterApi {
  @override
  Future<pigeon.CustomAppCheckToken> getCustomToken() async {
    final provider = MethodChannelFirebaseAppCheck._windowsCustomProvider;
    if (provider == null) {
      throw StateError('No WindowsCustomProvider has been activated.');
    }

    final token = await provider.fetchToken();
    return pigeon.CustomAppCheckToken(
      token: token.token,
      expireTimeMillis: token.expireTimeMillis,
    );
  }
}

class MethodChannelFirebaseAppCheck extends FirebaseAppCheckPlatform {
  /// Create an instance of [MethodChannelFirebaseAppCheck].
  MethodChannelFirebaseAppCheck({required FirebaseApp app})
      : super(appInstance: app) {
    pigeon.FirebaseAppCheckFlutterApi.setUp(_windowsCustomProviderFlutterApi);
    _tokenChangesListeners[app.name] = StreamController<String?>.broadcast();
    _listenerRegistration = _registerTokenListener(app);
  }

  Future<void> _registerTokenListener(FirebaseApp app) async {
    try {
      final channelName = await _pigeonApi.registerTokenListener(app.name);
      if (_isDisposed) {
        return;
      }

      final events = EventChannel(channelName);
      _subscription = events
          .receiveGuardedBroadcastStream(onError: convertPlatformException)
          .listen((arguments) {
        // ignore: close_sinks
        final controller = _tokenChangesListeners[app.name];
        if (!_isDisposed && controller != null) {
          Map<dynamic, dynamic> result = arguments;
          controller.add(result['token'] as String?);
        }
      });
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      // Silently ignore errors during token listener registration.
      // This can happen in test environments where the host API is not set up.
    }
  }

  static final Map<String, StreamController<String?>> _tokenChangesListeners =
      {};

  static Map<String, MethodChannelFirebaseAppCheck>
      _methodChannelFirebaseAppCheckInstances =
      <String, MethodChannelFirebaseAppCheck>{};

  /// The Pigeon API used for platform communication.
  final pigeon.FirebaseAppCheckHostApi _pigeonApi =
      pigeon.FirebaseAppCheckHostApi();
  static final _windowsCustomProviderFlutterApi =
      _WindowsCustomProviderFlutterApi();
  static WindowsCustomProvider? _windowsCustomProvider;
  late final Future<void> _listenerRegistration;
  StreamSubscription<dynamic>? _subscription;
  bool _isDisposed = false;

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
  Future<void> dispose() async {
    _isDisposed = true;
    await _listenerRegistration;
    await _subscription?.cancel();
    _subscription = null;
    await _tokenChangesListeners.remove(app.name)?.close();
    _methodChannelFirebaseAppCheckInstances.remove(app.name);
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
    WindowsAppCheckProvider? providerWindows,
  }) async {
    try {
      _setWindowsCustomProvider(providerWindows);
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
        _getDebugToken(
          providerAndroid: providerAndroid,
          providerApple: providerApple,
          providerWindows: providerWindows,
        ),
        _getWindowsProvider(providerWindows),
      );
    } on PlatformException catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  static void _setWindowsCustomProvider(
    WindowsAppCheckProvider? providerWindows,
  ) {
    _windowsCustomProvider =
        providerWindows is WindowsCustomProvider ? providerWindows : null;
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

String? _getDebugToken({
  AndroidAppCheckProvider? providerAndroid,
  AppleAppCheckProvider? providerApple,
  WindowsAppCheckProvider? providerWindows,
}) {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return providerAndroid is AndroidDebugProvider
          ? providerAndroid.debugToken
          : null;
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return providerApple is AppleDebugProvider
          ? providerApple.debugToken
          : null;
    case TargetPlatform.windows:
      return providerWindows is WindowsDebugProvider
          ? providerWindows.debugToken
          : null;
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
      return null;
  }
}

String? _getWindowsProvider(WindowsAppCheckProvider? providerWindows) {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    return providerWindows?.type;
  }

  return null;
}
