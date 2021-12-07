// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_performance;

/// The Firebase Performance API.
///
/// You can get an instance by calling [FirebasePerformance.instance].
class FirebasePerformance extends FirebasePluginPlatform {
  FirebasePerformance._({required this.app})
      : super(app.name, 'plugins.flutter.io/firebase_performance');

  // Cached and lazily loaded instance of [FirebasePerformancePlatform] to avoid
  // creating a [MethodChannelFirebasePerformance] when not needed or creating an
  // instance with the default app before a user specifies an app.
  FirebasePerformancePlatform? _delegatePackingProperty;

  /// Returns an instance using the default [FirebaseApp].
  static FirebasePerformance get instance {
    FirebaseApp defaultAppInstance = Firebase.app();
    return FirebasePerformance.instanceFor(app: defaultAppInstance);
  }

  static Map<String, FirebasePerformance> _firebasePerformanceInstances = {};

  /// The [FirebaseApp] for this current [FirebaseMessaging] instance.
  FirebaseApp app;

  /// Returns the underlying delegate implementation.
  ///
  /// If called and no [_delegatePackingProperty] exists, it will first be
  /// created and assigned before returning the delegate.
  FirebasePerformancePlatform get _delegate {
    return _delegatePackingProperty ??= FirebasePerformancePlatform.instanceFor(
      app: app,
    );
  }

  /// Returns an instance using a specified [FirebaseApp].
  factory FirebasePerformance.instanceFor({required FirebaseApp app}) {
    return _firebasePerformanceInstances.putIfAbsent(app.name, () {
      return FirebasePerformance._(app: app);
    });
  }

  /// Determines whether custom performance monitoring is enabled or disabled.
  ///
  /// True if custom performance monitoring is enabled and false if performance
  /// monitoring is disabled. This is for dynamic enable/disable state. This
  /// does not reflect whether instrumentation is enabled/disabled.
  Future<bool> isPerformanceCollectionEnabled() {
    // TODO: update API to match web & iOS for 'dataCollectionEnabled' & 'instrumentationEnabled'
    return _delegate.isPerformanceCollectionEnabled();
  }

  /// Enables or disables custom performance monitoring setup.
  ///
  /// This setting is persisted and applied on future invocations of your
  /// application. By default, custom performance monitoring is enabled.
  Future<void> setPerformanceCollectionEnabled(bool enabled) {
    return _delegate.setPerformanceCollectionEnabled(enabled);
  }

  /// Creates a [Trace] object with given [name]. Traces can be used to measure
  /// the time taken for a sequence of steps. Traces also include “Counters”.
  /// Counters are used to track information which is cumulative in nature
  /// (e.g., Bytes downloaded).
  ///
  /// The [name] requires no leading or trailing whitespace, no leading
  /// underscore _ character, and max length of [Trace.maxTraceNameLength]
  /// characters.
  Trace newTrace(String name) {
    return Trace._(_delegate.newTrace(name));
  }

  /// Creates a HttpMetric object for collecting network performance data for one
  /// request/response. Only works for native apps. A stub class is created for web
  /// which does nothing
  HttpMetric newHttpMetric(String url, HttpMethod httpMethod) {
    return HttpMetric._(_delegate.newHttpMetric(url, httpMethod));
  }
}
