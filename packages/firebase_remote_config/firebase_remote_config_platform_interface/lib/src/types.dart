// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_remote_config_platform_interface;

/// RemoteConfigSettings can be used to configure how Remote Config operates.
class RemoteConfigSettings {
  /// Creates an instance of [RemoteConfigSettings]
  RemoteConfigSettings({this.debugMode = false});

  /// Enable or disable developer mode for Remote Config.
  ///
  /// When set to true developer mode is enabled, when set to false developer
  /// mode is disabled. When developer mode is enabled fetch throttling is
  /// relaxed to allow many more fetch calls per hour to the remote server than
  /// the 5 per hour that is enforced when developer mode is disabled.
  final bool debugMode;
}

/// RemoteConfigValue encapsulates the value and source of a Remote Config
/// parameter.
class RemoteConfigValue {
  RemoteConfigValue._(this._value, this.source) : assert(source != null);

  List<int> _value;

  /// Indicates at which source this value came from.
  final ValueSource source;

  /// Decode value to string.
  String asString() {
    return _value != null
        ? const Utf8Codec().decode(_value)
        : defaultValueForString;
  }

  /// Decode value to int.
  int asInt() {
    if (_value != null) {
      final String strValue = const Utf8Codec().decode(_value);
      final int intValue = int.tryParse(strValue) ?? defaultValueForInt;
      return intValue;
    } else {
      return defaultValueForInt;
    }
  }

  /// Decode value to double.
  double asDouble() {
    if (_value != null) {
      final String strValue = const Utf8Codec().decode(_value);
      final double doubleValue =
          double.tryParse(strValue) ?? defaultValueForDouble;
      return doubleValue;
    } else {
      return defaultValueForDouble;
    }
  }

  /// Decode value to bool.
  bool asBool() {
    if (_value != null) {
      final String strValue = const Utf8Codec().decode(_value);
      return strValue.toLowerCase() == 'true';
    } else {
      return defaultValueForBool;
    }
  }
}
