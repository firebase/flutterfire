// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class TracePlatform extends PlatformInterface {
  TracePlatform() : super(token: _token);

  static void verify(TracePlatform instance) {
    PlatformInterface.verify(instance, _token);
  }

  static final Object _token = Object();

  /// Maximum allowed length of a key passed to [putAttribute].
  static const int maxAttributeKeyLength = 40;

  /// Maximum allowed length of a value passed to [putAttribute].
  static const int maxAttributeValueLength = 100;

  /// Maximum allowed number of attributes that can be added.
  static const int maxCustomAttributes = 5;

  /// Starts this trace.
  Future<void> start() {
    throw UnimplementedError('start() is not implemented');
  }

  /// Stops this trace.
  Future<void> stop() {
    throw UnimplementedError('stop() is not implemented');
  }

  /// increments the metric with the given name in this trace by the value.
  void incrementMetric(String name, int value) {
    throw UnimplementedError('incrementMetric() is not implemented');
  }

  /// Sets the value of the metric with the given name in this trace to the value provided
  void setMetric(String name, int value) {
    throw UnimplementedError('setMetric() is not implemented');
  }

  /// Gets the value of the metric with the given name in the current trace.
  int getMetric(String name) {
    throw UnimplementedError('getMetric() is not implemented');
  }

  /// Sets a String value for the specified attribute.
  void putAttribute(String name, String value) {
    throw UnimplementedError('putAttribute() is not implemented');
  }

  /// Removes an already added attribute from the Traces.
  void removeAttribute(String name) {
    throw UnimplementedError('removeAttribute() is not implemented');
  }

  /// Returns the value of an attribute.
  String? getAttribute(String name) {
    throw UnimplementedError('getAttribute() is not implemented');
  }

  /// Returns the map of all the attributes added to this trace.
  Map<String, String> getAttributes() {
    throw UnimplementedError('getAttributes() is not implemented');
  }
}
