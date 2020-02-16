import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final Firestore firestore = Firestore.instance;
  const MethodChannel channel =
      MethodChannel('plugins.flutter.io/cloud_firestore');
  MethodCall methodCall;

  group('$Firestore', () {
    setUp(() async {
      channel.setMockMethodCallHandler((MethodCall m) async {
        methodCall = m;

        switch (m.method) {
          case 'DocumentReference#get':
            return <String, dynamic>{
              'path': m.arguments['path'],
              'data': <String, dynamic>{},
              'metadata': <String, dynamic>{
                'hasPendingWrites': false,
                'isFromCache': false
              }
            };

          case 'Query#getDocuments':
            return {
              'documentChanges': <Map<String, dynamic>>[],
              'metadata': <String, dynamic>{
                'hasPendingWrites': false,
                'isFromCache': true
              },
              'documents': <Map<String, dynamic>>[],
              'metadatas': <Map<String, dynamic>>[],
              'paths': <String>[]
            };

          default:
            return null;
        }
      });
    });

    tearDown(() {
      channel.setMockMethodCallHandler(null);
      methodCall = null;
    });

    group('CloudFirestore', () {
      group('document', () {
        test('get invokes method call', () async {
          await firestore.document('documentId').get();
          expect(
              methodCall,
              isMethodCall('DocumentReference#get',
                  arguments: <String, dynamic>{
                    'app': '[DEFAULT]',
                    'path': 'documentId',
                    'source': 'default'
                  }));
        });

        test('setData invokes method call', () async {
          await firestore
              .document('documentId')
              .setData(<String, dynamic>{'dataKey': 'dataValue'});
          expect(
              methodCall,
              isMethodCall(
                'DocumentReference#setData',
                arguments: <String, dynamic>{
                  'app': '[DEFAULT]',
                  'path': 'documentId',
                  'data': <String, dynamic>{'dataKey': 'dataValue'},
                  'options': <String, dynamic>{'merge': false},
                },
              ));
        });

        test('snapshots invokes method call', () async {
          await firestore
              .document('documentId')
              .snapshots()
              .listen((DocumentSnapshot snapshot) {});
          expect(
              methodCall,
              isMethodCall(
                'DocumentReference#addSnapshotListener',
                arguments: <String, dynamic>{
                  'app': '[DEFAULT]',
                  'path': 'documentId',
                  'includeMetadataChanges': false,
                },
              ));
        });

        test('updateData invokes method call', () async {
          await firestore
              .document('documentId')
              .updateData(<String, dynamic>{'dataKey': 'dataValue'});
          expect(
              methodCall,
              isMethodCall(
                'DocumentReference#updateData',
                arguments: <String, dynamic>{
                  'app': '[DEFAULT]',
                  'path': 'documentId',
                  'data': <String, dynamic>{'dataKey': 'dataValue'},
                },
              ));
        });

        test('delete invokes method call', () async {
          await firestore.document('documentId').delete();
          expect(
              methodCall,
              isMethodCall(
                'DocumentReference#delete',
                arguments: <String, dynamic>{
                  'app': '[DEFAULT]',
                  'path': 'documentId',
                },
              ));
        });
      });

      group('collection', () {
        test('getDocuments invokes method call', () async {
          await firestore.collection('collectionId').getDocuments();
          expect(
              methodCall,
              isMethodCall(
                'Query#getDocuments',
                arguments: <String, dynamic>{
                  'app': '[DEFAULT]',
                  'path': 'collectionId',
                  'isCollectionGroup': false,
                  'parameters': <String, dynamic>{
                    'where': <List<dynamic>>[],
                    'orderBy': <List<dynamic>>[]
                  },
                  'source': 'default',
                },
              ));
        });

        test('snapshots invokes method call', () async {
          await firestore
              .collection('collectionId')
              .snapshots()
              .listen((QuerySnapshot snapshot) {});
          expect(
              methodCall,
              isMethodCall(
                'Query#addSnapshotListener',
                arguments: <String, dynamic>{
                  'app': '[DEFAULT]',
                  'path': 'collectionId',
                  'isCollectionGroup': false,
                  'parameters': <String, dynamic>{
                    'where': <List<dynamic>>[],
                    'orderBy': <List<dynamic>>[]
                  },
                  'includeMetadataChanges': false
                },
              ));
        });

        test('add invokes method call', () async {
          final DocumentReference document = await firestore
              .collection('collectionId')
              .add(<String, dynamic>{'dataKey': 'dataValue'});
          expect(
              methodCall,
              isMethodCall(
                'DocumentReference#setData',
                arguments: <String, dynamic>{
                  'app': '[DEFAULT]',
                  'path': 'collectionId/${document.documentID}',
                  'data': <String, dynamic>{'dataKey': 'dataValue'},
                  'options': <String, dynamic>{'merge': false},
                },
              ));
        });
      });
    });
  });
}
