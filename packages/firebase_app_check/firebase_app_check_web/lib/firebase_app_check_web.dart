// ignore_for_file: require_trailing_commas
// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';
import 'dart:js_interop';

import 'package:firebase_app_check_platform_interface/firebase_app_check_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'src/internals.dart';
import 'src/interop/app_check.dart' as app_check_interop;

class FirebaseAppCheckWeb extends FirebaseAppCheckPlatform {
  static const recaptchaTypeV3 = 'recaptcha-v3';
  static const recaptchaTypeEnterprise = 'enterprise';
  static Map<String, StreamController<String?>> _tokenChangesListeners = {};

  /// Stub initializer to allow the [registerWith] to create an instance without
  /// registering the web delegates or listeners.
  FirebaseAppCheckWeb._()
      : _webAppCheck = null,
        super(appInstance: null);

  /// The entry point for the [FirebaseAuthWeb] class.
  FirebaseAppCheckWeb({required FirebaseApp app}) : super(appInstance: app);

  /// Called by PluginRegistry to register this plugin for Flutter Web
  static void registerWith(Registrar registrar) {
    FirebaseCoreWeb.registerService(
      'app-check',
      productNameOverride: 'app_check',
      ensurePluginInitialized: (firebaseApp) async {
        final instance =
            FirebaseAppCheckWeb(app: Firebase.app(firebaseApp.name));
        final recaptchaType = web
            .window.sessionStorage[_sessionKeyRecaptchaType(firebaseApp.name)];
        final recaptchaSiteKey = web.window
            .sessionStorage[_sessionKeyRecaptchaSiteKey(firebaseApp.name)];
        if (recaptchaType != null && recaptchaSiteKey != null) {
          final WebProvider provider;
          if (recaptchaType == recaptchaTypeV3) {
            provider = ReCaptchaV3Provider(recaptchaSiteKey);
          } else if (recaptchaType == recaptchaTypeEnterprise) {
            provider = ReCaptchaEnterpriseProvider(recaptchaSiteKey);
          } else {
            throw Exception('Invalid recaptcha type: $recaptchaType');
          }
          await instance.activate(webProvider: provider);
        }
      },
    );

    FirebaseAppCheckPlatform.instance = FirebaseAppCheckWeb.instance;
  }

  /// Initializes a stub instance to allow the class to be registered.
  static FirebaseAppCheckWeb get instance {
    return FirebaseAppCheckWeb._();
  }

  static String _sessionKeyRecaptchaType(String appName) {
    return 'FlutterFire-$appName-recaptchaType';
  }

  static String _sessionKeyRecaptchaSiteKey(String appName) {
    return 'FlutterFire-$appName-recaptchaSiteKey';
  }

  /// instance of AppCheck from the web plugin
  app_check_interop.AppCheck? _webAppCheck;

  /// Lazily initialize [_webAppCheck] on first method call
  app_check_interop.AppCheck? get _delegate {
    if (_webAppCheck == null) {
      throw Exception(
          "Before using other Firebase App Check APIs, FirebaseAppCheck.instance.activate() must be called first once you've initialized your Firebase app.");
    }
    return _webAppCheck;
  }

  @override
  FirebaseAppCheckPlatform delegateFor({required FirebaseApp app}) {
    return FirebaseAppCheckWeb(app: app);
  }

  @override
  FirebaseAppCheckWeb setInitialValues() {
    return this;
  }

  @override
  Future<void> activate({
    WebProvider? webProvider,
    AndroidProvider? androidProvider,
    AppleProvider? appleProvider,
  }) async {
    // save the recaptcha type and site key for future startups
    if (webProvider != null) {
      final String recaptchaType;
      if (webProvider is ReCaptchaV3Provider) {
        recaptchaType = recaptchaTypeV3;
      } else if (webProvider is ReCaptchaEnterpriseProvider) {
        recaptchaType = recaptchaTypeEnterprise;
      } else {
        throw Exception('Invalid web provider: $webProvider');
      }
      web.window.sessionStorage[_sessionKeyRecaptchaType(app.name)] =
          recaptchaType;
      web.window.sessionStorage[_sessionKeyRecaptchaSiteKey(app.name)] =
          webProvider.siteKey;
    }

    // activate API no longer exists, recaptcha key has to be passed on initialization of app-check instance.
    return convertWebExceptions<Future<void>>(() async {
      _webAppCheck ??= app_check_interop.getAppCheckInstance(
          core_interop.app(app.name), webProvider);
      _initialiseStreamController();
    });
  }

  void _initialiseStreamController() {
    if (_tokenChangesListeners[app.name] == null) {
      _tokenChangesListeners[app.name] = StreamController<String?>.broadcast(
        onCancel: () {
          _tokenChangesListeners[app.name]!.close();
          _tokenChangesListeners.remove(app.name);
          _delegate!.idTokenChangedController?.close();
        },
      );
      _delegate!.onTokenChanged(app.name).listen((event) {
        _tokenChangesListeners[app.name]!.add(event.token.toDart);
      });
    }
  }

  @override
  Future<String?> getToken(bool forceRefresh) async {
    return convertWebExceptions<Future<String?>>(() async {
      app_check_interop.AppCheckTokenResult result =
          await _delegate!.getToken(forceRefresh);
      return result.token.toDart;
    });
  }

  @override
  Future<String> getLimitedUseToken() async {
    return convertWebExceptions<Future<String>>(() async {
      app_check_interop.AppCheckTokenResult result =
          await _delegate!.getLimitedUseToken();
      return result.token.toDart;
    });
  }

  @override
  Future<void> setTokenAutoRefreshEnabled(
    bool isTokenAutoRefreshEnabled,
  ) async {
    return convertWebExceptions<Future<void>>(
      () async =>
          _delegate!.setTokenAutoRefreshEnabled(isTokenAutoRefreshEnabled),
    );
  }

  @override
  Stream<String?> get onTokenChange {
    _initialiseStreamController();
    return convertWebExceptions(
      () => _tokenChangesListeners[app.name]!.stream,
    );
  }
}
