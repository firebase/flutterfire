// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class EventParameters extends _BaseParameters {
  EventParameters() : super(null);
  // Constructs an [EventParameters] from a raw Map.
  factory EventParameters.fromMap(Map<String, Object> map) {
    Map<String, Object> parameters = {};
    map.forEach((key, value) {
      assert(
        value is String || value is num,
        "'string' OR 'number' must be set as the value of the parameter",
      );
      parameters[key] = value;
    });
    return EventParameters._(parameters);
  }

  EventParameters._(parameters) : super(parameters);

  @override
  String toString() {
    return '$EventParameters($asMap)';
  }
}

class _BaseParameters {
  _BaseParameters(Map<String, Object?>? parameters)
      : _parameters = parameters ?? {};
  Map<String, Object?> _parameters = {};

  _BaseParameters addString(String key, String value) {
    _parameters[key] = value;
    return this;
  }

  _BaseParameters addNumber(String key, num value) {
    _parameters[key] = value;
    return this;
  }

  /// Returns a map for this instance.
  Map<String, Object?> asMap() {
    return Map<String, Object?>.from(_parameters);
  }
}

class DefaultEventParameters extends _BaseParameters {
  DefaultEventParameters() : super(null);
  // Constructs an [EventParameters] from a raw Map.
  factory DefaultEventParameters.fromMap(Map<String, Object?> map) {
    Map<String, Object?> parameters = {};
    map.forEach((key, value) {
      assert(
        value is String || value is num || value == null,
        "'string', 'null' or 'number' must be set as the value of the parameter",
      );
      parameters[key] = value;
    });
    return DefaultEventParameters._(parameters);
  }

  DefaultEventParameters._(parameters) : super(parameters);

  DefaultEventParameters addNull(String key) {
    // used for removing keys when setting default event parameters
    _parameters[key] = null;
    return this;
  }

  @override
  String toString() {
    return '$DefaultEventParameters($asMap)';
  }
}
