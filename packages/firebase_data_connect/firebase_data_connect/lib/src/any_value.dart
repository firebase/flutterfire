import 'dart:convert';

class AnyValue {
  AnyValue(this.value);

  /// fromJson takes the dynamic values and converts them into the any type.
  AnyValue.fromJson(Map<String, dynamic> any) {
    value = any;
  }
  dynamic value;

  /// toJson converts the array into a json-encoded string.
  String toJson() {
    switch (value.runtimeType) {
      case bool:
        return value.toString();
      case String:
        return value;
      case int:
      case double:
        return value.toString();
      default:
        if (value is List) {
          return jsonEncode(
              (value as List).map((e) => AnyValue(e).toJson()).toList());
        } else if (value is Map) {
          return jsonEncode(convertMap(value));
        }
        try {
          return jsonEncode(value.toJson());
        } catch (e) {
          // empty cache to try and encode the value
        }
        try {
          return jsonEncode(value);
        } catch (e) {
          throw Exception('Could not encode type ${value.runtimeType}');
        }
    }
  }
}

Map<String, String> convertMap(Map<String, dynamic> map) {
  return map.map((key, value) {
    if (value is String) {
      return MapEntry(key, value);
    } else {
      return MapEntry(key, AnyValue(value).toJson());
    }
  });
}
