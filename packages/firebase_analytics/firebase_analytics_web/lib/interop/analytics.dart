// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:js_util' as util;

import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart';

import 'firebase_interop.dart' as firebase_interop;
import 'analytics_interop.dart' as analytics_interop;

export 'analytics_interop.dart';

/// Given an AppJSImp, return the Analytics instance.
Analytics getAnalyticsInstance([App? app]) {
  return Analytics.getInstance(
    app != null
        ? firebase_interop.analytics(app.jsObject)
        : firebase_interop.analytics(),
  );
}

class Analytics extends JsObjectWrapper<analytics_interop.AnalyticsJsImpl> {
  Analytics._fromJsObject(analytics_interop.AnalyticsJsImpl jsObject)
      : super.fromJsObject(jsObject);
  static final _expando = Expando<Analytics>();

  /// Creates a new Analytics instance from a [jsObject].
  static Analytics getInstance(analytics_interop.AnalyticsJsImpl jsObject) {
    return _expando[jsObject] ??= Analytics._fromJsObject(jsObject);
  }

  /// Non-null App for this instance of analytics service.
  App get app => App.getInstance(jsObject.app);

  void logEvent({
    required String name,
    Map<String, Object?>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    return jsObject.logEvent(name, util.jsify(parameters ?? {}), callOptions);
  }

  void setAnalyticsCollectionEnabled({required bool enabled}) {
    return jsObject.setAnalyticsCollectionEnabled(enabled);
  }

  void setCurrentScreen({
    String? screenName,
    AnalyticsCallOptions? callOptions,
  }) {
    return jsObject.setCurrentScreen(
      screenName,
      callOptions,
    );
  }

  void setUserId({
    String? id,
    AnalyticsCallOptions? callOptions,
  }) {
    return jsObject.setUserId(
      id,
      callOptions,
    );
  }

  void setUserProperty({
    required String name,
    required String? value,
    AnalyticsCallOptions? callOptions,
  }) {
    return jsObject.setUserProperties(
      {name: value},
      callOptions,
    );
  }
}
