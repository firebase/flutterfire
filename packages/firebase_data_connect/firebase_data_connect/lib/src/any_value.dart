part of firebase_data_connect;

class AnyValue {
  AnyValue(this.value);

  /// fromJson takes the dynamic values and converts them into the any type.
  AnyValue.fromJson(dynamic json) {
    value = json;
  }
  dynamic value;

  /// toJson converts the array into a json-encoded string.
  dynamic toJson() {
    if (value is bool || value is double || value is int || value is String) {
      return value;
    } else {
      if (value is List) {
        return (value as List).map((e) => e.toJson()).toList();
      } else if (value is Map) {
        // TODO(mtewani): Throw an error if this is the wrong type.
        return convertMap(value as Map<String, dynamic>);
      }
      try {
        return value.toJson();
      } catch (e) {
        // empty cache to try and encode the value
      }
      try {
        return value;
      } catch (e) {
        throw Exception('Could not encode type ${value.runtimeType}');
      }
    }
  }
}

Map<String, dynamic> convertMap(Map<String, dynamic> map) {
  return map.map((key, value) {
    if (value is String) {
      return MapEntry(key, value);
    } else {
      return MapEntry(key, AnyValue(value).toJson());
    }
  });
}

dynamic defaultSerializer(dynamic v) {
  return v.toJson();
}
