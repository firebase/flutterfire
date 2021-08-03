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
  RemoteConfigValue(List<int>? value, this.source)
      : _value = utf8.decode(value ?? const []);

  /// Default value for String
  static const String defaultValueForString = '';

  /// Default value for Int
  static const int defaultValueForInt = 0;

  /// Default value for Double
  static const double defaultValueForDouble = 0;

  /// Default value for Bool
  static const bool defaultValueForBool = false;

  static const Map<String, dynamic> defaultValueForJson = {};

  String _value;

  /// Indicates at which source this value came from.
  final ValueSource source;

  /// Decode value to string.
  String asString() {
    return _value;
  }

  /// Decode value to int.
  int asInt() {
    return int.tryParse(_value) ?? defaultValueForInt;
  }

  /// Decode value to double.
  double asDouble() {
    return double.tryParse(_value) ?? defaultValueForDouble;
  }

  /// Decode value to bool.
  bool asBool() {
    final lowerCase = _value.toLowerCase();
    return lowerCase == '1' || lowerCase == 'true';
  }

  /// Decode value as json
  Map<String, dynamic> asJson() {
    try {
      return json.decode(_value);
    } catch (_) {
      return defaultValueForJson;
    }
  }
}
