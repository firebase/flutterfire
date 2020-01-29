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
    return List.from(data).map((value) => valueEncode(value)).toList();
  }

  static Map<String, dynamic> replaceDelegatesWithValueInMap(
      Map<String, dynamic> data, Firestore firestore) {
    if (data == null) {
      return null;
    }
    Map<String, dynamic> output = Map.from(data);
    output.updateAll((_, value) => valueDecode(value, firestore));
    return output;
  }

  static List<dynamic> replaceDelegatesWithValueInArray(
      List<dynamic> data, Firestore firestore) {
    if (data == null) {
      return null;
    }
    return List.from(data)
        .map((value) => valueDecode(value, firestore))
        .toList();
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

  static dynamic valueDecode(dynamic value, Firestore firestore) {
    if (value is platform.DocumentReferencePlatform) {
      return DocumentReference._(value, firestore);
    } else if (value is List) {
      return replaceDelegatesWithValueInArray(value, firestore);
    } else if (value is Map<String, dynamic>) {
      return replaceDelegatesWithValueInMap(value, firestore);
    }
    return value;
  }
}
