// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: avoid_unused_constructor_parameters, non_constant_identifier_names, public_member_api_docs

@JS('firebase.analytics')
library firebase_interop.analytics;

import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart';

import 'package:js/js.dart';

@JS('Analytics')
abstract class AnalyticsJsImpl {
  external AppJsImpl get app;

  external void logEvent(
    String eventName,
    dynamic parameters,
    AnalyticsCallOptions? callOptions,
  );

  external void setAnalyticsCollectionEnabled(bool enabled);

  external void setCurrentScreen(
    String? screenName,
    AnalyticsCallOptions? callOptions,
  );

  external void setUserId(
    String? id,
    AnalyticsCallOptions? callOptions,
  );

  external void setUserProperties(
    Map<String, Object?> property,
    AnalyticsCallOptions? callOptions,
  );
}
