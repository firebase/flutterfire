@TestOn("chrome")
import 'dart:typed_data';
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_web/firestore_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'dart:js' as js;
import 'package:firebase/firestore.dart' as web;

class MockFieldValue extends Mock implements FieldValuePlatform {}

class MockGeoPoint extends Mock implements GeoPoint {}

class MockBlob extends Mock implements Blob {}

class MockDocumentReferenceWeb extends Mock implements DocumentReferenceWeb {}

class MockWebGeoPoint extends Mock implements web.GeoPoint {}

class MockWebBlob extends Mock implements web.Blob {}

void main() {
  group("$CodecUtility()", () {
    setUp(() {
      js.context['firebase'] = js.JsObject.jsify(<String, dynamic>{
        'firestore': js.JsObject.jsify(<String, dynamic>{
          'GeoPoint':
              js.allowInterop((latitude, longitude) => MockWebGeoPoint()),
          'Blob': js.JsObject.jsify(<String, dynamic>{
            'fromUint8Array': js.allowInterop((_) => MockWebBlob())
          })
        })
      });
    });
    test("encodeMapData", () {
      expect(CodecUtility.encodeMapData(null), isNull);

      //FieldValuePlatform
      final mockFieldValue = MockFieldValue();
      CodecUtility.encodeMapData({'test': mockFieldValue});
      verify(mockFieldValue.instance);

      final timeStamp = Timestamp.now();
      final result = CodecUtility.encodeMapData({'test': timeStamp});
      expect(result['test'], isInstanceOf<DateTime>());

      //GeoPoint
      final mockGeoPoint = MockGeoPoint();
      CodecUtility.encodeMapData({'test': mockGeoPoint});
      verify(mockGeoPoint.latitude);
      verify(mockGeoPoint.longitude);

      //Blob
      final mockBlob = MockBlob();
      CodecUtility.encodeMapData({'test': mockBlob});
      verify(mockBlob.bytes);

      //DocumentReferenceWeb
      final mockDocumentReferenceWeb = MockDocumentReferenceWeb();
      CodecUtility.encodeMapData({'test': mockDocumentReferenceWeb});
      verify(mockDocumentReferenceWeb.delegate);

      //Map
      reset(mockDocumentReferenceWeb);
      CodecUtility.encodeMapData({
        'test': {'test2': mockDocumentReferenceWeb}
      });
      verify(mockDocumentReferenceWeb.delegate);

      //List
      reset(mockDocumentReferenceWeb);
      CodecUtility.encodeMapData({
        'test': [mockDocumentReferenceWeb]
      });
      verify(mockDocumentReferenceWeb.delegate);
    });

    test("encodeArrayData", () {
      expect(CodecUtility.encodeArrayData(null), isNull);

      //FieldValuePlatform
      final mockFieldValue = MockFieldValue();
      CodecUtility.encodeArrayData([mockFieldValue]);
      verify(mockFieldValue.instance);

      final timeStamp = Timestamp.now();
      final result = CodecUtility.encodeArrayData([timeStamp]);
      expect(result.first, isInstanceOf<DateTime>());

      //GeoPoint
      final mockGeoPoint = MockGeoPoint();
      CodecUtility.encodeArrayData([mockGeoPoint]);
      verify(mockGeoPoint.latitude);
      verify(mockGeoPoint.longitude);

      //Blob
      final mockBlob = MockBlob();
      CodecUtility.encodeArrayData([mockBlob]);
      verify(mockBlob.bytes);

      //DocumentReferenceWeb
      final mockDocumentReferenceWeb = MockDocumentReferenceWeb();
      CodecUtility.encodeArrayData([mockDocumentReferenceWeb]);
      verify(mockDocumentReferenceWeb.delegate);

      //Map
      reset(mockDocumentReferenceWeb);
      CodecUtility.encodeArrayData([
        {'test2': mockDocumentReferenceWeb}
      ]);
      verify(mockDocumentReferenceWeb.delegate);

      //List
      reset(mockDocumentReferenceWeb);
      CodecUtility.encodeArrayData([
        [mockDocumentReferenceWeb]
      ]);
      verify(mockDocumentReferenceWeb.delegate);
    });

    test("decodeMapData", () {
      expect(CodecUtility.decodeMapData(null), isNull);

      //Blob
      final mockWebBlob = MockWebBlob();
      when(mockWebBlob.toUint8Array()).thenReturn(Uint8List(0));
      expect(CodecUtility.decodeMapData({'test': mockWebBlob})['test'],
          isInstanceOf<Blob>());
      verify(mockWebBlob.toUint8Array());

      final date = DateTime.now();
      expect(CodecUtility.decodeMapData({'test': date})['test'],
          isInstanceOf<Timestamp>());

      //GeoPoint
      final mockWebGeoPoint = MockWebGeoPoint();
      expect(CodecUtility.decodeMapData({'test': mockWebGeoPoint})['test'],
          isInstanceOf<GeoPoint>());

      //Map
      expect(
          CodecUtility.decodeMapData({
            'test': {'test1': mockWebGeoPoint}
          })['test']['test1'],
          isInstanceOf<GeoPoint>());

      //List
      expect(
          CodecUtility.decodeMapData({
            'test': [mockWebGeoPoint]
          })['test']
              .first,
          isInstanceOf<GeoPoint>());
    });

    test("decodeArrayData", () {
      expect(CodecUtility.decodeArrayData(null), isNull);

      //Blob
      final mockWebBlob = MockWebBlob();
      when(mockWebBlob.toUint8Array()).thenReturn(Uint8List(0));
      expect(CodecUtility.decodeArrayData([mockWebBlob]).first,
          isInstanceOf<Blob>());
      verify(mockWebBlob.toUint8Array());

      final date = DateTime.now();
      expect(CodecUtility.decodeArrayData([date]).first,
          isInstanceOf<Timestamp>());

      //GeoPoint
      final mockWebGeoPoint = MockWebGeoPoint();
      expect(CodecUtility.decodeArrayData([mockWebGeoPoint]).first,
          isInstanceOf<GeoPoint>());

      //Map
      expect(
          CodecUtility.decodeArrayData([
            {'test1': mockWebGeoPoint}
          ]).first['test1'],
          isInstanceOf<GeoPoint>());

      //List
      expect(
          CodecUtility.decodeArrayData([
            [mockWebGeoPoint]
          ]).first.first,
          isInstanceOf<GeoPoint>());
    });
  });
}
