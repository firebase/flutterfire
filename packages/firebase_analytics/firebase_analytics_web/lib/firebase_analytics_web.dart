// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:firebase_analytics_web/utils/exception.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'src/firebase_analytics_version.dart';

import 'interop/analytics.dart' as analytics_interop;

/// Web implementation of [FirebaseAnalyticsPlatform]
class FirebaseAnalyticsWeb extends FirebaseAnalyticsPlatform {
  static const String _libraryName = 'flutter-fire-analytics';

  /// instance of Analytics from the web plugin
  analytics_interop.Analytics? _webAnalytics;

  final Map<String, dynamic>? webOptions;

  /// Lazily initialize [_webAnalytics] on first method call
  analytics_interop.Analytics get _delegate {
    return _webAnalytics ??= analytics_interop.getAnalyticsInstance(
      core_interop.app(app.name),
      webOptions,
    );
  }

  /// Builds an instance of [FirebaseAnalyticsWeb] with an optional [FirebaseApp] instance
  /// If [app] is null then the created instance will use the default [FirebaseApp]
  FirebaseAnalyticsWeb({
    FirebaseApp? app,
    this.webOptions,
  }) : super(appInstance: app);

  /// Called by PluginRegistry to register this plugin for Flutter Web
  static void registerWith(Registrar registrar) {
    FirebaseCoreWeb.registerLibraryVersion(_libraryName, packageVersion);

    FirebaseCoreWeb.registerService('analytics');
    FirebaseAnalyticsPlatform.instance = FirebaseAnalyticsWeb();
  }

  @override
  FirebaseAnalyticsPlatform delegateFor({
    FirebaseApp? app,
    Map<String, dynamic>? webOptions,
  }) {
    return FirebaseAnalyticsWeb(app: app, webOptions: webOptions);
  }

  @override
  Future<bool> isSupported() {
    return analytics_interop.Analytics.isSupported();
  }

  @override
  Future<int?> getSessionId() async {
    throw UnimplementedError('getSessionId() is not supported on Web.');
  }

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
    AnalyticsCallOptions? callOptions,
  }) async {
    return convertWebExceptions(() {
      return _delegate.logEvent(
        name: name,
        parameters: parameters ?? {},
        callOptions: callOptions,
      );
    });
  }

  @override
  Future<void> setConsent({
    bool? adStorageConsentGranted,
    bool? analyticsStorageConsentGranted,
    bool? adPersonalizationSignalsConsentGranted,
    bool? adUserDataConsentGranted,
    bool? functionalityStorageConsentGranted,
    bool? personalizationStorageConsentGranted,
    bool? securityStorageConsentGranted,
  }) async {
    return convertWebExceptions(() {
      return _delegate.setConsent(
        adStorageConsentGranted: adStorageConsentGranted,
        analyticsStorageConsentGranted: analyticsStorageConsentGranted,
        adPersonalizationSignalsConsentGranted:
            adPersonalizationSignalsConsentGranted,
        adUserDataConsentGranted: adUserDataConsentGranted,
        functionalityStorageConsentGranted: functionalityStorageConsentGranted,
        personalizationStorageConsentGranted:
            personalizationStorageConsentGranted,
        securityStorageConsentGranted: securityStorageConsentGranted,
      );
    });
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    return convertWebExceptions(() {
      return _delegate.setAnalyticsCollectionEnabled(enabled: enabled);
    });
  }

  @override
  Future<void> setUserId({
    String? id,
    AnalyticsCallOptions? callOptions,
  }) async {
    return convertWebExceptions(() {
      return _delegate.setUserId(
        id: id,
        callOptions: callOptions,
      );
    });
  }

  @override
  Future<void> resetAnalyticsData() async {
    throw UnimplementedError('resetAnalyticsData() is not supported on Web.');
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
    AnalyticsCallOptions? callOptions,
  }) async {
    return convertWebExceptions(() {
      return _delegate.setUserProperty(
        name: name,
        value: value,
        callOptions: callOptions,
      );
    });
  }

  @override
  Future<void> setSessionTimeoutDuration(Duration timeout) async {
    throw UnimplementedError(
      'setSessionTimeoutDuration() is not supported on Web.',
    );
  }

  @override
  Future<void> setDefaultEventParameters(
    Map<String, Object?>? defaultParameters,
  ) async {
    throw UnimplementedError(
      'setDefaultEventParameters() is not supported on web',
    );
  }

  @override
  Future<String?> getAppInstanceId() async {
    throw UnimplementedError(
      'getAppInstanceId() is not supported on web',
    );
  }
}
