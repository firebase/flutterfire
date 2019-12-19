part of cloud_firestore_web;

class _CodecUtility {
  static Map<String, dynamic> _encodeMapData(Map<String, dynamic> data) {
    Map<String, dynamic> output = Map.from(data);
    output.updateAll((key, value) => _valueEncode(value));
    return output;
  }

  static List<dynamic> _encodeArrayData(List<dynamic> data) {
    List<dynamic> output = List.from(data);
    output.map(_valueEncode);
    return output;
  }

  static dynamic _valueEncode(dynamic value) {
    if (value is FieldValueInterface && value.instance is FieldValueWeb) {
      return (value.instance as FieldValueWeb)._delegate;
    } else if (value is GeoPoint) {
      return web.GeoPoint(value.latitude, value.longitude);
    } else if (value is Blob) {
      return web.Blob.fromUint8Array(value.bytes);
    } else if (value is DocumentReferenceWeb) {
      return value.delegate;
    } else if (value is Map<String, dynamic>) {
      return _encodeMapData(value);
    } else if (value is List<dynamic>) {
      return _encodeArrayData(value);
    }
    return value;
  }

  static Map<String, dynamic> _decodeMapData(Map<String, dynamic> data) {
    Map<String, dynamic> output = Map.from(data);
    output.updateAll((key, value) => _valueDecode(value));
    return output;
  }

  static List<dynamic> _decodeArrayData(List<dynamic> data) {
    List<dynamic> output = List.from(data);
    output.map(_valueDecode);
    return output;
  }

  static dynamic _valueDecode(dynamic value) {
    if (value is web.GeoPoint) {
      return GeoPoint(value.latitude, value.longitude);
    } else if (value is web.Blob) {
      return Blob(value.toUint8Array());
    } else if (value is web.DocumentReference) {
      return DocumentReferenceWeb(
          (FirestorePlatform.instance as FirestoreWeb).webFirestore,
          FirestorePlatform.instance,
          value.path.split("/"));
    } else if (value is Map<String, dynamic>) {
      return _decodeMapData(value);
    } else if (value is List<dynamic>) {
      return _decodeArrayData(value);
    }
    return value;
  }
}
