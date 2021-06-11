import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../method_channel/method_channel_firebase_performance.dart';
import 'platform_interface_http_metric.dart';
import 'platform_interface_trace.dart';

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
  /// Create an instance using [app].
  FirebasePerformancePlatform()
      : appInstance = Firebase.app(),
        super(token: Object());

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
    PlatformInterface.verifyToken(instance, Object());
    _instance = instance;
  }

  /// The [FirebaseApp] this instance was initialized with.
  @protected
  final FirebaseApp appInstance;

  /// Returns the [FirebaseApp] for the current instance.
  FirebaseApp get app => appInstance;

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
  static Future<TracePlatform> startTrace(String name) async {
    final trace = FirebasePerformancePlatform.instance.newTrace(name);
    await trace.start();
    return trace;
  }
}
