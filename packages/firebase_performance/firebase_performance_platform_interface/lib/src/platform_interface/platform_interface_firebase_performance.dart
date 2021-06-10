import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../method_channel/method_channel_firebase_performance.dart';
import 'platform_interface_trace.dart';
import 'platform_interface_http_metric.dart';

enum HttpMethod { Connect, Delete, Get, Head, Options, Patch, Post, Put, Trace }

/// The interface that implementations of `firebase_performance` must
/// extend.
///
/// Platform implementations should extend this class rather than implement it
/// as `firebase_performance` does not consider newly added methods to be breaking
/// changes. Extending this class (using `extends`) ensures that the subclass
/// will get the default implementation, while platform implementations that
/// `implements` this interface will be broken by newly added
/// [FirebasePerformancePlatform] methods.
abstract class FirebasePerformancePlatform extends PlatformInterface {
  /// Create an instance.
  FirebasePerformancePlatform() : super(token: _token);

  static final Object _token = Object();

  static FirebasePerformancePlatform? _instance;

  /// The current default [FirebasePerformancePlatform] instance.
  ///
  /// It will always default to [MethodChannelFirebasePerformance]
  /// if no other implementation was provided.
  static FirebasePerformancePlatform get instance {
    return _instance ??= MethodChannelFirebasePerformance.instance;
  }

  /// Sets the [FirebasePerformancePlatform] instance.
  static set instance(FirebasePerformancePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Sets any initial values on the instance.
  ///
  /// Platforms with Method Channels can provide constant values to be
  /// available before the instance has initialized to prevent unnecessary
  /// async calls.
  @protected
  FirebasePerformancePlatform setInitialValues({
    required Map<dynamic, dynamic> performanceValues,
  }) {
    throw UnimplementedError('setInitialValues() is not implemented');
  }

  /// Only works for native apps. Always returns true for web apps.
  Future<bool> isPerformanceCollectionEnabled() async {
    throw UnimplementedError(
      'isPerformanceCollectionEnabled() is not implemented',
    );
  }

  /// Only works for native apps. Does nothing for web apps.
  Future<void> setPerformanceCollectionEnabled(bool enabled) async {
    throw UnimplementedError(
      'setPerformanceCollectionEnabled() is not implemented',
    );
  }

  TracePlatform newTrace(String name) {
    throw UnimplementedError('newTrace() is not implemented');
  }

  /// Only works for native apps. Does nothing for web apps.
  HttpMetricPlatform newHttpMetric(String url, HttpMethod httpMethod) {
    throw UnimplementedError('newHttpMetric() is not implemented');
  }

  /// Creates a Trace object with given name and start the trace.
  Future<TracePlatform> startTrace(String name) {
    throw UnimplementedError('startTrace() is not implemented');
  }
}
