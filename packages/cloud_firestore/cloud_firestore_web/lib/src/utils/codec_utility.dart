import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:firebase/firestore.dart' as web;
import 'package:meta/meta.dart';

import 'package:cloud_firestore_web/firestore_web.dart';
import 'package:cloud_firestore_web/src/document_reference_web.dart';
import 'package:cloud_firestore_web/src/field_value_web.dart';

// ignore: public_member_api_docs
class CodecUtility {
  // ignore: public_member_api_docs
  static Map<String, dynamic> encodeMapData(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    Map<String, dynamic> output = Map.from(data);
    output.updateAll((key, value) => valueEncode(value));
    return output;
  }

  // disabling lint as it's only visible for testing
  @visibleForTesting
  // ignore: public_member_api_docs
  static List<dynamic> encodeArrayData(List<dynamic> data) {
    if (data == null) {
      return null;
    }
    return List.from(data).map(valueEncode).toList();
  }

  // disabling lint as it's only visible for testing
  @visibleForTesting
  // ignore: public_member_api_docs
  static dynamic valueEncode(dynamic value) {
    if (value is FieldValuePlatform && value.instance is FieldValueWeb) {
      return (value.instance as FieldValueWeb).delegate;
    } else if (value is Timestamp) {
      return value.toDate();
    } else if (value is GeoPoint) {
      return web.GeoPoint(value.latitude, value.longitude);
    } else if (value is Blob) {
      return web.Blob.fromUint8Array(value.bytes);
    } else if (value is DocumentReferenceWeb) {
      return value.delegate;
    } else if (value is Map<String, dynamic>) {
      return encodeMapData(value);
    } else if (value is List<dynamic>) {
      return encodeArrayData(value);
    }
    return value;
  }

  // disabling lint as it's only visible for testing
  @visibleForTesting
  // ignore: public_member_api_docs
  static Map<String, dynamic> decodeMapData(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    Map<String, dynamic> output = Map.from(data);
    output.updateAll((key, value) => valueDecode(value));
    return output;
  }

  // disabling lint as it's only visible for testing
  @visibleForTesting
  // ignore: public_member_api_docs
  static List<dynamic> decodeArrayData(List<dynamic> data) {
    if (data == null) {
      return null;
    }
    return List.from(data).map(valueDecode).toList();
  }

  // disabling lint as it's only visible for testing
  @visibleForTesting
  // ignore: public_member_api_docs
  static dynamic valueDecode(dynamic value) {
    if (value is web.GeoPoint) {
      return GeoPoint(value.latitude, value.longitude);
    } else if (value is DateTime) {
      return Timestamp.fromDate(value);
    } else if (value is web.Blob) {
      return Blob(value.toUint8Array());
    } else if (value is web.DocumentReference) {
      return DocumentReferenceWeb(
          (FirestorePlatform.instance as FirestoreWeb).webFirestore,
          FirestorePlatform.instance,
          value.path.split("/"));
    } else if (value is Map<String, dynamic>) {
      return decodeMapData(value);
    } else if (value is List<dynamic>) {
      return decodeArrayData(value);
    }
    return value;
  }
}
