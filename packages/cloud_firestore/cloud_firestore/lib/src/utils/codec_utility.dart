part of cloud_firestore;

class _CodecUtility {
  static Map<String, dynamic> replaceValueWithDelegatesInMap(
      Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    Map<String, dynamic> output = Map.from(data);
    output.updateAll((_, value) => valueEncode(value));
    return output;
  }

  static List<dynamic> replaceValueWithDelegatesInArray(List<dynamic> data) {
    if (data == null) {
      return null;
    }
    return List.from(data).map((value) => valueEncode(value));
  }

  static Map<String, dynamic> replaceDelegatesWithValueInMap(
      Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    Map<String, dynamic> output = Map.from(data);
    output.updateAll((_, value) => valueDecode(value));
    return output;
  }

  static List<dynamic> replaceDelegatesWithValueInArray(List<dynamic> data) {
    if (data == null) {
      return null;
    }
    return List.from(data).map((value) => valueDecode(value));
  }

  static dynamic valueEncode(dynamic value) {
    if (value is DocumentReference) {
      return value._delegate;
    } else if (value is List) {
      return replaceValueWithDelegatesInArray(value);
    } else if (value is Map<String, dynamic>) {
      return replaceValueWithDelegatesInMap(value);
    }
    return value;
  }

  static dynamic valueDecode(dynamic value) {
    if (value is platform.DocumentReference) {
      return DocumentReference._(value);
    } else if (value is List) {
      return replaceDelegatesWithValueInArray(value);
    } else if (value is Map<String, dynamic>) {
      return replaceDelegatesWithValueInMap(value);
    }
    return value;
  }
}
