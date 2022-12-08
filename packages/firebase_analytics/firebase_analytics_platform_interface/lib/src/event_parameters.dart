// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class EventParameters {
  EventParameters();
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

  EventParameters._(this._parameters);

  Map<String, Object?> _parameters = {};

  EventParameters addString(String key, String value) {
    _parameters[key] = value;
    return this;
  }

  EventParameters addNumber(String key, num value) {
    _parameters[key] = value;
    return this;
  }

  EventParameters addNull(String key) {
    // used for removing keys when setting default event parameters
    _parameters[key] = null;
    return this;
  }

  /// Returns a map for this EventParameters instance.
  Map<String, Object?> asMap() {
    return Map<String, Object?>.from(_parameters);
  }

  @override
  String toString() {
    return '$EventParameters($asMap)';
  }
}
