// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show visibleForTesting, required;

import '../cloud_firestore_platform_interface.dart';

class MethodChannelCloudFirestore extends CloudFirestorePlatform {
  MethodChannelCloudFirestore() {
        channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'QuerySnapshot') {
        final QuerySnapshot snapshot = QuerySnapshot._(call.arguments, this);
        _queryObservers[call.arguments['handle']].add(snapshot);
      } else if (call.method == 'DocumentSnapshot') {
        final DocumentSnapshot snapshot = DocumentSnapshot._(
          call.arguments['path'],
          _asStringKeyedMap(call.arguments['data']),
          SnapshotMetadata._(call.arguments['metadata']['hasPendingWrites'],
              call.arguments['metadata']['isFromCache']),
          this,
        );
        _documentObservers[call.arguments['handle']].add(snapshot);
      } else if (call.method == 'DoTransaction') {
        final int transactionId = call.arguments['transactionId'];
        final Transaction transaction = Transaction(transactionId, this);
        final dynamic result =
            await _transactionHandlers[transactionId](transaction);
        await transaction._finish();
        return result;
      }
    });
  }

  @visibleForTesting
  static const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/cloud_firestore',
  );

  // Platform calls
  Future<void> _handlePlatformCall(MethodCall call) async {
    switch(call.method) {
      case 'QuerySnapshot': 
        final QuerySnapshot snapshot = QuerySnapshot._(call.arguments, this);
        _queryObservers[call.arguments['handle']].add(snapshot);
        break;
      case 'DocumentSnapshot':
        final DocumentSnapshot snapshot = DocumentSnapshot._(
          call.arguments['path'],
          _asStringKeyedMap(call.arguments['data']),
          SnapshotMetadata._(call.arguments['metadata']['hasPendingWrites'],
              call.arguments['metadata']['isFromCache']),
          this,
        );
        _documentObservers[call.arguments['handle']].add(snapshot);
        break;
      case 'DoTransaction':
        final int transactionId = call.arguments['transactionId'];
        final Transaction transaction = Transaction(transactionId, this);
        final dynamic result =
            await _transactionHandlers[transactionId](transaction);
        await transaction._finish();
        return result;
        break;
    }
  }

  @override
  Future<void> onQuerySnapshot(PlatformQuerySnapshot snapshot) {

  }

  @override
  Future<void> onDocumentSnapshot(PlatformDocumentSnapshot snapshot) {

  }

  @override
  Future<void> onDoTransaction(PlatformTransaction transaction) {
    
  }

  // Global
  @override
  Future<void> removeListener(int handle) =>
     channel.invokeMethod<void>(
      'removeListener',
      <String, dynamic>{'handle': handle},
    );


  // Firestore
  @override
  Future<void> enablePersistence(String app, {bool enable = true}) => 
    channel
        .invokeMethod<void>('Firestore#enablePersistence', <String, dynamic>{
      'app': app,
      'enable': enable,
    });
  

  @override
  Future<void> settings(String app, {
      bool persistenceEnabled,
      String host,
      bool sslEnabled,
      int cacheSizeBytes,
    }) =>
     channel.invokeMethod<void>('Firestore#settings', <String, dynamic>{
      'app': app,
      'persistenceEnabled': persistenceEnabled,
      'host': host,
      'sslEnabled': sslEnabled,
      'cacheSizeBytes': cacheSizeBytes,
    });


  @override
  Future<Map<String, dynamic>> runTransaction(String app, {
    @required int transactionId,
    int transactionTimeout,
  }) => channel
        .invokeMapMethod<String, dynamic>(
            'Firestore#runTransaction', <String, dynamic>{
      'app': app,
      'transactionId': transactionId,
      'transactionTimeout': transactionTimeout
    });

  // Document Reference
  @override
  Future<void> setDocumentReferenceData(String app, {
    @required String path,
    // TODO: Type SetOptions: https://firebase.google.com/docs/reference/js/firebase.firestore.SetOptions.html
    Map<String, dynamic> options,
    Map<String, dynamic> data = const <String, dynamic>{},
  }) => channel.invokeMethod<void>(
      'DocumentReference#setData',
      <String, dynamic>{
        'app': app,
        'path': path,
        'data': data,
        'options': options,
      },
    );

  @override
  Future<void> updateDocumentReferenceData(String app, {
    @required String path,
    Map<String, dynamic> data = const <String, dynamic>{},
  }) => channel.invokeMethod<void>(
      'DocumentReference#updateData',
      <String, dynamic>{
        'app': app,
        'path': path,
        'data': data,
      },
    );

  // TODO: Type this return
  @override
  Future<Map<String, dynamic>> getDocumentReference(String app, {
    @required String path,
    @required String source,
  }) => channel.invokeMapMethod<String, dynamic>(
      'DocumentReference#get',
      <String, dynamic>{
        'app': app,
        'path': path,
        'source': source,
      },
    );

  @override
  Future<void> deleteDocumentReference(String app, {
    @required String path,
  }) => channel.invokeMethod<void>(
      'DocumentReference#delete',
      <String, dynamic>{'app': app, 'path': path},
    );

  // TODO: Port to stream
  @override
  Future<int> addDocumentReferenceSnapshotListener(String app, {
    @required String path,
    bool includeMetadataChanges,
  }) => channel.invokeMethod<int>(
          'DocumentReference#addSnapshotListener',
          <String, dynamic>{
            'app': app,
            'path': path,
            'includeMetadataChanges': includeMetadataChanges,
          },
        );

  // Query
  // TODO: Port to stream
  @override
  Future<int> addQuerySnapshotListener(String app, {
    @required String path,
    bool isCollectionGroup,
    Map<String, dynamic> parameters,
    bool includeMetadataChanges,
  }) => channel.invokeMethod<int>(
          'Query#addSnapshotListener',
          <String, dynamic>{
            'app': app,
            'path': path,
            'isCollectionGroup': isCollectionGroup,
            'parameters': parameters,
            'includeMetadataChanges': includeMetadataChanges,
          },
        );

  //TODO: Type this return
  @override
  Future<Map<dynamic, dynamic>> getQueryDocuments(String app, {
    @required String path,
    bool isCollectionGroup,
    Map<String, dynamic> parameters,
    String source,
  }) => channel.invokeMapMethod<String, dynamic>(
      'Query#getDocuments',
      <String, dynamic>{
        'app': app,
        'path': path,
        'isCollectionGroup': isCollectionGroup,
        'parameters': parameters,
        'source': source,
      },
    );

  // Transaction
  // TODO: Type this return
  @override
  Future<Map<String, dynamic>> getTransaction(String app, {
    @required String path,
    @required int transactionId,
  }) => channel
        .invokeMapMethod<String, dynamic>('Transaction#get', <String, dynamic>{
      'app': app,
      'transactionId': transactionId,
      'path': path,
    });

  @override
  Future<void> deleteTransaction(String app, {
    @required String path,
    @required int transactionId,
  }) => channel
        .invokeMethod<void>('Transaction#delete', <String, dynamic>{
      'app': app,
      'transactionId': transactionId,
      'path': path,
    });

  @override
  Future<void> updateTransaction(String app, {
    @required String path,
    @required int transactionId,
    Map<String, dynamic> data,
  }) => channel
        .invokeMethod<void>('Transaction#update', <String, dynamic>{
      'app': app,
      'transactionId': transactionId,
      'path': path,
      'data': data,
    });

  @override
  Future<void> setTransaction(String app, {
    @required String path,
    @required int transactionId,
    Map<String, dynamic> data,
  }) => channel
        .invokeMethod<void>('Transaction#set', <String, dynamic>{
      'app': app,
      'transactionId': transactionId,
      'path': path,
      'data': data,
    });

  // Write Batch
  @override
  Future<dynamic> createWriteBatch(String app) => channel.invokeMethod<dynamic>(
            'WriteBatch#create', <String, dynamic>{'app': app});

  @override
  Future<void> commitWriteBatch({
    @required dynamic handle,
  }) => channel.invokeMethod<void>(
          'WriteBatch#commit', <String, dynamic>{'handle': handle});

  @override
  Future<void> deleteWriteBatch(String app, {
    @required dynamic handle,
    @required String path,
  }) => channel.invokeMethod<void>(
            'WriteBatch#delete',
            <String, dynamic>{
              'app': app,
              'handle': handle,
              'path': path,
            },
          );

  @override
  Future<void> setWriteBatchData(String app, {
    @required dynamic handle,
    @required String path,
    Map<String, dynamic> data,
    Map<String, dynamic> options,
  }) => channel.invokeMethod<void>(
            'WriteBatch#setData',
            <String, dynamic>{
              'app': app,
              'handle': handle,
              'path': path,
              'data': data,
              'options': options,
            },
          );

  @override
  Future<void> updateWriteBatchData(String app, {
    @required dynamic handle,
    @required String path,
    Map<String, dynamic> data,
  }) => channel.invokeMethod<void>(
            'WriteBatch#updateData',
            <String, dynamic>{
              'app': app,
              'handle': handle,
              'path': path,
              'data': data,
            },
          );
}
