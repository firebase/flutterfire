part of cloud_firestore_web;

class CodecUtility {
  static Map<String, dynamic> _encodeMapData(Map<String, dynamic> data) {
    Map<String, dynamic> output = Map.from(data);
    output.updateAll((key, value) {
      if (value is FieldValueInterface && value.instance is FieldValueWeb) {
        return (value.instance as FieldValueWeb)._delegate;
      } else if (value is GeoPoint) {
        return web.GeoPoint(value.latitude, value.longitude);
      } else if (value is Blob) {
        return web.Blob.fromUint8Array(value.bytes);
      } else if(value is DocumentReferenceWeb) {
        return value.delegate;
      } else {
        return value;
      }
    });
    return output;
  }

  static Map<String, dynamic> _decodeMapData(Map<String, dynamic> data) {
    Map<String, dynamic> output = Map.from(data);
    output.updateAll((key, value) {
      if (value is web.GeoPoint) {
        return GeoPoint(value.latitude, value.longitude);
      } else if (value is web.Blob) {
        return Blob(value.toUint8Array());
      } else if(value is web.DocumentReference) {
        return DocumentReferenceWeb(
            (FirestorePlatform.instance as FirestoreWeb).webFirestore,
            FirestorePlatform.instance,
          value.path.split("/")
        );
      } else {
        return value;
      }
    });
    return output;
  }
}
