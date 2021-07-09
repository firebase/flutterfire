// ignore_for_file: require_trailing_commas
// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_performance;

/// [Trace] allows you to set the beginning and end of a custom trace in your app.
///
/// A trace is a report of performance data associated with some of the
/// code in your app. You can have multiple custom traces, and it is
/// possible to have more than one custom trace running at a time. Each custom
/// trace can have multiple metrics and attributes added to help measure
/// performance related events. A trace also measures the time between calling
/// `start()` and `stop()`.
///
/// Data collected is automatically sent to the associated Firebase console
/// after stop() is called.
///
/// You can confirm that Performance Monitoring results appear in the Firebase
/// console. Results should appear within 12 hours.
///
/// It is highly recommended that one always calls `start()` and `stop()` on
/// each created [Trace] to not avoid leaking on the platform side.
class Trace extends PerformanceAttributes {
  Trace._(TracePlatform delegate) : super._(delegate);

  /// Starts this [Trace].
  ///
  /// Can only be called once.
  ///
  /// Using `await` with this method is only necessary when accurate timing
  /// is relevant.
  Future<void> start() {
    return (_delegate as TracePlatform).start();
  }

  /// Stops this [Trace].
  ///
  /// Can only be called once and only after start() Data collected is
  /// automatically sent to the associated Firebase console after stop() is
  /// called. You can confirm that Performance Monitoring results appear in the
  /// Firebase console. Results should appear within 12 hours.
  ///
  /// Not necessary to use `await` with this method.
  Future<void> stop() {
    return (_delegate as TracePlatform).stop();
  }

  /// Increments the metric with the given [name].
  ///
  /// If the metric does not exist, a new one will be created. If the [Trace] has
  /// not been started or has already been stopped, returns immediately without
  /// taking action.
  Future<void> incrementMetric(String name, int value) {
    return (_delegate as TracePlatform).incrementMetric(name, value);
  }

  /// Sets the [value] of the metric with the given [name].
  ///
  /// If a metric with the given name doesn't exist, a new one will be created.
  /// If the [Trace] has not been started or has already been stopped, returns
  /// immediately without taking action.
  Future<void> setMetric(String name, int value) {
    return (_delegate as TracePlatform).setMetric(name, value);
  }

  /// Gets the value of the metric with the given [name].
  ///
  /// If a metric with the given name doesn't exist, it is NOT created and a 0
  /// is returned.
  Future<int> getMetric(String name) async {
    return (_delegate as TracePlatform).getMetric(name);
  }
}
