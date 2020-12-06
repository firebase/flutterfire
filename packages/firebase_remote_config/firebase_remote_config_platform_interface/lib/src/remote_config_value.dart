import 'dart:convert';

/// ValueSource defines the possible sources of a config parameter value.
enum ValueSource { valueStatic, valueDefault, valueRemote }

/// RemoteConfigValue encapsulates the value and source of a Remote Config
/// parameter.
class RemoteConfigValue {
  /// Default value for String
  static const String defaultValueForString = '';
  /// Default value for Int
  static const int defaultValueForInt = 0;
  /// Default value for Double
  static const double defaultValueForDouble = 0.0;
  /// Default value for Bool
  static const bool defaultValueForBool = false;

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
      final int intValue =
          int.tryParse(strValue) ?? defaultValueForInt;
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
