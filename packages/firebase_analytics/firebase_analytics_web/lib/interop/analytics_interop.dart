// ignore_for_file: require_trailing_commas
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
    Map<String, Object?>? parameters,
    CallOptions? callOptions,
  );

  external void setAnalyticsCollectionEnabled(bool enabled);

  external void setCurrentScreen(
    String? screenName,
    CallOptions? callOptions,
  );

  external void setUserId(
    String? id,
    CallOptions? callOptions,
  );

  external void setUserProperties(
    Map<String, Object> property,
    CallOptions? callOptions,
  );
}
