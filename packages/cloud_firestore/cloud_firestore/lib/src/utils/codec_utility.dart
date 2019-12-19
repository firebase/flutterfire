part of cloud_firestore;

class _CodecUtility {
  static Map<String, dynamic> _replaceValueWithDelegatesInMap(
      Map<String, dynamic> data) {
    Map<String, dynamic> output = Map.from(data);
    output.updateAll((_, value) => _valueEncode(value));
    return output;
  }

  static List<dynamic> _replaceValueWithDelegatesInArray(List<dynamic> data) {
    return List.from(data).map((value) => _valueEncode(value));
  }

  static Map<String, dynamic> _replaceDelegatesWithValueInMap(
      Map<String, dynamic> data) {
    Map<String, dynamic> output = Map.from(data);
    output.updateAll((_, value) => _valueDecode(value));
    return output;
  }

  static List<dynamic> _replaceDelegatesWithValueInArray(List<dynamic> data) {
    return List.from(data).map((value) => _valueDecode(value));
  }

  static dynamic _valueEncode(dynamic value) {
    if (value is DocumentReference) {
      return value._delegate;
    } else if (value is List) {
      _replaceValueWithDelegatesInArray(value);
    } else if (value is Map<String, dynamic>) {
      _replaceValueWithDelegatesInMap(value);
    }
    return value;
  }

  static dynamic _valueDecode(dynamic value) {
    if (value is platform.DocumentReference) {
      return DocumentReference._(value);
    } else if (value is List) {
      _replaceDelegatesWithValueInArray(value);
    } else if (value is Map<String, dynamic>) {
      _replaceDelegatesWithValueInMap(value);
    }
    return value;
  }
}
