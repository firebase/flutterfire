// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:firebase_app_check_platform_interface/firebase_app_check_platform_interface.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart';
import 'package:flutter/foundation.dart';

import 'app_check_interop.dart' as app_check_interop;

export 'app_check_interop.dart';

/// Given an AppJSImp, return the AppCheck instance.
AppCheck? getAppCheckInstance([App? app, WebProvider? provider]) {
  late app_check_interop.ReCaptchaProvider jsProvider;

  if (provider is ReCaptchaV3Provider) {
    jsProvider = app_check_interop.ReCaptchaV3Provider(provider.siteKey.toJS);
  } else if (provider is ReCaptchaEnterpriseProvider) {
    jsProvider =
        app_check_interop.ReCaptchaEnterpriseProvider(provider.siteKey.toJS);
  } else {
    throw ArgumentError(
      'A `WebProvider` is required for `activate()` to initialise App Check on the web platform',
    );
  }

  final options = app_check_interop.AppCheckOptions(provider: jsProvider);

  return AppCheck.getInstance(
    app != null
        ? app_check_interop.initializeAppCheck(app.jsObject, options)
        : app_check_interop.initializeAppCheck(
            globalContext.getProperty('undefined'.toJS),
            options,
          ),
  );
}

class AppCheck extends JsObjectWrapper<app_check_interop.AppCheckJsImpl> {
  static final _expando = Expando<AppCheck>();

  /// Creates a new AppCheck from a [jsObject].
  static AppCheck getInstance(app_check_interop.AppCheckJsImpl jsObject) {
    return _expando[jsObject] ??= AppCheck._fromJsObject(jsObject);
  }

  AppCheck._fromJsObject(app_check_interop.AppCheckJsImpl jsObject)
      : super.fromJsObject(jsObject);

  void setTokenAutoRefreshEnabled(bool isTokenAutoRefreshEnabled) =>
      app_check_interop.setTokenAutoRefreshEnabled(
        jsObject,
        isTokenAutoRefreshEnabled.toJS,
      );

  Future<app_check_interop.AppCheckTokenResultJsImpl> getToken(
    bool? forceRefresh,
  ) =>
      app_check_interop.getToken(jsObject, forceRefresh?.toJS).toDart;

  Future<app_check_interop.AppCheckTokenResultJsImpl> getLimitedUseToken() =>
      app_check_interop.getLimitedUseToken(jsObject).toDart;

  JSFunction? _idTokenChangedUnsubscribe;

  StreamController<app_check_interop.AppCheckTokenResultJsImpl>?
      get idTokenChangedController => _idTokenChangedController;

  StreamController<app_check_interop.AppCheckTokenResultJsImpl>?
      // ignore: close_sinks
      _idTokenChangedController;

  // purely for debug mode and tracking listeners to clean up on "hot restart"
  final Map<String, int> _tokenListeners = {};
  String _appCheckWindowsKey(String appName) {
    if (kDebugMode) {
      final key = 'flutterfire-${appName}_onTokenChanged';
      if (_tokenListeners.containsKey(key)) {
        _tokenListeners[key] = _tokenListeners[key]! + 1;
      } else {
        _tokenListeners[key] = 0;
      }
      return '$key-${_tokenListeners[key]}';
    }
    return 'no-op';
  }

  Stream<app_check_interop.AppCheckTokenResultJsImpl> onTokenChanged(
    String appName,
  ) {
    final appCheckWindowsKey = _appCheckWindowsKey(appName);
    unsubscribeWindowsListener(appCheckWindowsKey);
    if (_idTokenChangedController == null) {
      final nextWrapper =
          ((app_check_interop.AppCheckTokenResultJsImpl result) {
        _idTokenChangedController!.add(result);
      }).toJS;

      final errorWrapper =
          ((JSError e) => _idTokenChangedController!.addError(e)).toJS;

      void startListen() {
        _idTokenChangedUnsubscribe = app_check_interop.onTokenChanged(
          jsObject,
          nextWrapper,
          errorWrapper,
        );
        setWindowsListener(appCheckWindowsKey, _idTokenChangedUnsubscribe!);
      }

      void stopListen() {
        _idTokenChangedUnsubscribe?.callAsFunction();
        _idTokenChangedUnsubscribe = null;
        _idTokenChangedController = null;
        removeWindowsListener(appCheckWindowsKey);
      }

      _idTokenChangedController = StreamController<
          app_check_interop.AppCheckTokenResultJsImpl>.broadcast(
        onListen: startListen,
        onCancel: stopListen,
        sync: true,
      );
    }

    return _idTokenChangedController!.stream;
  }
}
