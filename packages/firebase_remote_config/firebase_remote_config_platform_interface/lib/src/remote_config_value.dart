// @dart=2.9

import 'dart:convert';

import 'package:flutter/foundation.dart';

/// ValueSource defines the possible sources of a config parameter value.
enum ValueSource {
  /// The value was defined by a static constant.
  valueStatic,

  /// The value was defined by default config.
  valueDefault,

  /// The value was defined by fetched config.
  valueRemote,
}

/// RemoteConfigValue encapsulates the value and source of a Remote Config
/// parameter.
class RemoteConfigValue {
  /// Wraps a value with metadata and type-safe getters.
  @protected
  RemoteConfigValue(this._value, this.source) : assert(source != null);

  /// Default value for String
  static const String defaultValueForString = '';

  /// Default value for Int
  static const int defaultValueForInt = 0;

  /// Default value for Double
  static const double defaultValueForDouble = 0;

  /// Default value for Bool
  static const bool defaultValueForBool = false;

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
      final lowerCase = strValue.toLowerCase();
      return lowerCase == 'true' || lowerCase == '1';
    } else {
      return defaultValueForBool;
    }
  }
}
