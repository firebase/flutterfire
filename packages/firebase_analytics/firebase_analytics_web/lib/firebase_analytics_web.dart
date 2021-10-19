// ignore_for_file: require_trailing_commas
// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart'
as core_interop;
import 'interop/analytics.dart' as analytics_interop;

/// Web implementation of [FirebaseAnalyticsPlatform]
class FirebaseAnalyticsWeb extends FirebaseAnalyticsPlatform {
  /// instance of Analytics from the web plugin
  final analytics_interop.Analytics _webAnalytics;

  /// Builds an instance of [FirebaseAnalyticsWeb] with an optional [FirebaseApp] instance
  /// If [app] is null then the created instance will use the default [FirebaseApp]
  FirebaseAnalyticsWeb({FirebaseApp? app})
      : _webAnalytics =
  analytics_interop.getAnalyticsInstance(core_interop.app(app?.name)),
        super(appInstance: app);

  /// Called by PluginRegistry to register this plugin for Flutter Web
  static void registerWith(Registrar registrar) {
    FirebaseAnalyticsPlatform.instance = FirebaseAnalyticsWeb();
  }

  @override
  FirebaseAnalyticsPlatform delegateFor({FirebaseApp? app}) {
    return FirebaseAnalyticsWeb(app: app);
  }

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
    CallOptions? callOptions,
  }) async {
    _webAnalytics.logEvent(
      name: name,
      parameters: parameters ?? {},
      callOptions: callOptions,
    );
  }

  @override
  Future<void> setConsent(
      {ConsentStatus? adStorage, ConsentStatus? analyticsStorage}) async {
    // no setConsent() API for web
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    _webAnalytics.setAnalyticsCollectionEnabled(enabled: enabled);
  }

  @override
  Future<void> setUserId({
    String? id,
    CallOptions? callOptions,
  }) async {
    _webAnalytics.setUserId(
      id: id,
      callOptions: callOptions,
    );
  }

  @override
  Future<void> setCurrentScreen({
    String? screenName,
    String? screenClassOverride,
    CallOptions? callOptions,
  }) async {
    _webAnalytics.setCurrentScreen(
      screenName: screenName,
      callOptions: callOptions,
    );
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required Object value,
    CallOptions? callOptions,
  }) async {
    _webAnalytics.setUserProperty(
      name: name,
      value: value,
      callOptions: callOptions,
    );
  }

  @override
  Future<void> setSessionTimeoutDuration(Duration timeout) async {
    // no setSessionTimeoutDuration() API for web
  }
}
