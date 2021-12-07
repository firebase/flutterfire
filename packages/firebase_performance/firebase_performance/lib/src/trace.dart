// Copyright 2021 The Chromium Authors. All rights reserved.
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
class Trace {
  Trace._(this._delegate);

  final TracePlatform _delegate;

  /// Starts this [Trace].
  ///
  /// Can only be called once.
  ///
  /// Using `await` with this method is only necessary when accurate timing
  /// is relevant.
  Future<void> start() {
    return _delegate.start();
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
    return _delegate.stop();
  }

  /// Increments the metric with the given [name].
  ///
  /// If the metric does not exist, a new one will be created. If the [Trace] has
  /// not been started or has already been stopped, returns immediately without
  /// taking action.
  void incrementMetric(String name, int value) {
    return _delegate.incrementMetric(name, value);
  }

  /// Sets the [value] of the metric with the given [name].
  ///
  /// If a metric with the given name doesn't exist, a new one will be created.
  /// If the [Trace] has not been started or has already been stopped, returns
  /// immediately without taking action.
  void setMetric(String name, int value) {
    return _delegate.setMetric(name, value);
  }

  /// Gets the value of the metric with the given [name].
  ///
  /// If a metric with the given name doesn't exist, it is NOT created and a 0
  /// is returned.
  int getMetric(String name) {
    return _delegate.getMetric(name);
  }

  /// Sets a String [value] for the specified attribute with [name].
  ///
  /// Updates the value of the attribute if the attribute already exists.
  /// The maximum number of attributes that can be added are
  /// [maxCustomAttributes]. An attempt to add more than [maxCustomAttributes]
  /// to this object will return without adding the attribute.
  ///
  /// Name of the attribute has max length of [maxAttributeKeyLength]
  /// characters. Value of the attribute has max length of
  /// [maxAttributeValueLength] characters. If the name has a length greater
  /// than [maxAttributeKeyLength] or the value has a length greater than
  /// [maxAttributeValueLength], this method will return without adding
  /// anything.
  ///
  /// If this object has been stopped, this method returns without adding the
  /// attribute.
  void putAttribute(String name, String value) {
    return _delegate.putAttribute(name, value);
  }

  /// Removes an already added attribute.
  ///
  /// If this object has been stopped, this method returns without removing the
  /// attribute.
  void removeAttribute(String name) {
    return _delegate.removeAttribute(name);
  }

  /// Returns the value of an attribute.
  ///
  /// Returns `null` if an attribute with this [name] has not been added.
  String? getAttribute(String name) => _delegate.getAttribute(name);

  /// All attributes added.
  Map<String, String> getAttributes() {
    return _delegate.getAttributes();
  }
}
