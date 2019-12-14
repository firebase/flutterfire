// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore_platform_interface;

class Transaction extends TransactionPlatform {
  @visibleForTesting
  Transaction(int transactionId, FirestorePlatform firestore) : super(transactionId, firestore);
  

  @override
  Future<DocumentSnapshot> _get(DocumentReference documentReference) async {
    final Map<String, dynamic> result = await MethodChannelFirestore.channel
        .invokeMapMethod<String, dynamic>('Transaction#get', <String, dynamic>{
      'app': firestore.appName(),
      'transactionId': _transactionId,
      'path': documentReference.path,
    });
    if (result != null) {
      return DocumentSnapshot(
          documentReference.path,
          result['data']?.cast<String, dynamic>(),
          SnapshotMetadata(result['metadata']['hasPendingWrites'],
              result['metadata']['isFromCache']),
          firestore);
    } else {
      return null;
    }
  }
  
  @override
  Future<void> _delete(DocumentReference documentReference) async {
    return MethodChannelFirestore.channel
        .invokeMethod<void>('Transaction#delete', <String, dynamic>{
      'app': firestore.appName(),
      'transactionId': _transactionId,
      'path': documentReference.path,
    });
  }
  
  @override
  Future<void> _update(
      DocumentReference documentReference, Map<String, dynamic> data) async {
    return MethodChannelFirestore.channel
        .invokeMethod<void>('Transaction#update', <String, dynamic>{
      'app': firestore.appName(),
      'transactionId': _transactionId,
      'path': documentReference.path,
      'data': data,
    });
  }
  
  @override
  Future<void> _set(
      DocumentReference documentReference, Map<String, dynamic> data) async {
    return MethodChannelFirestore.channel
        .invokeMethod<void>('Transaction#set', <String, dynamic>{
      'app': firestore.appName(),
      'transactionId': _transactionId,
      'path': documentReference.path,
      'data': data,
    });
  }
}
