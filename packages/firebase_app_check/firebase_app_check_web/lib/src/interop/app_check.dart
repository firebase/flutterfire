// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:js';

import 'package:firebase_core_web/firebase_core_web_interop.dart';

import 'app_check_interop.dart' as app_check_interop;

export 'app_check_interop.dart';

/// Given an AppJSImp, return the AppCheck instance.
AppCheck? getAppCheckInstance([App? app, String? recaptchaKey]) {
  final provider = app_check_interop.ReCaptchaV3Provider(recaptchaKey);
  final options = app_check_interop.AppCheckOptions(provider: provider);

  return AppCheck.getInstance(
    app != null
        ? app_check_interop.initializeAppCheck(app.jsObject, options)
        : app_check_interop.initializeAppCheck(context['undefined'], options),
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
        isTokenAutoRefreshEnabled,
      );

  Future<app_check_interop.AppCheckTokenResult> getToken(bool? forceRefresh) =>
      handleThenable(app_check_interop.getToken(jsObject, forceRefresh));

  Func0? _idTokenChangedUnsubscribe;

  StreamController<app_check_interop.AppCheckTokenResult>?
      // ignore: close_sinks
      _idTokenChangedController;

  Stream<app_check_interop.AppCheckTokenResult> onTokenChanged() {
    if (_idTokenChangedController == null) {
      final nextWrapper =
          allowInterop((app_check_interop.AppCheckTokenResult result) {
        _idTokenChangedController!.add(result);
      });

      final errorWrapper =
          allowInterop((e) => _idTokenChangedController!.addError(e));

      void startListen() {
        assert(_idTokenChangedUnsubscribe == null);
        _idTokenChangedUnsubscribe = app_check_interop.onTokenChanged(
          jsObject,
          nextWrapper,
          errorWrapper,
        );
      }

      void stopListen() {
        _idTokenChangedUnsubscribe!();
        _idTokenChangedUnsubscribe = null;
      }

      _idTokenChangedController =
          StreamController<app_check_interop.AppCheckTokenResult>.broadcast(
        onListen: startListen,
        onCancel: stopListen,
        sync: true,
      );
    }

    return _idTokenChangedController!.stream;
  }
}
