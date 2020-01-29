// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore_platform_interface;

/// An implementation of [TransactionPlatform] which uses [MethodChannel] to
/// communication with native plugin
class Transaction extends TransactionPlatform {
  /// [FirebaseApp] name used for this [Transaction]
  final String appName;

  // disabling lint as it's only visible for testing
  // ignore: public_member_api_docs
  @visibleForTesting
  Transaction(int transactionId, this.appName)
      : super(
            transactionId,
            appName == FirebaseApp.defaultAppName
                ? FirestorePlatform.instance
                : FirestorePlatform.instanceFor(
                    app: FirebaseApp(name: appName)));

  @override
  Future<DocumentSnapshot> _get(DocumentReferencePlatform documentReference) async {
    final Map<String, dynamic> result = await MethodChannelFirestore.channel
        .invokeMapMethod<String, dynamic>('Transaction#get', <String, dynamic>{
      'app': firestore.app.name,
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
  Future<void> _delete(DocumentReferencePlatform documentReference) async {
    return MethodChannelFirestore.channel
        .invokeMethod<void>('Transaction#delete', <String, dynamic>{
      'app': firestore.app.name,
      'transactionId': _transactionId,
      'path': documentReference.path,
    });
  }

  @override
  Future<void> _update(
      DocumentReferencePlatform documentReference, Map<String, dynamic> data) async {
    return MethodChannelFirestore.channel
        .invokeMethod<void>('Transaction#update', <String, dynamic>{
      'app': firestore.app.name,
      'transactionId': _transactionId,
      'path': documentReference.path,
      'data': FieldValuePlatform.serverDelegates(data),
    });
  }

  @override
  Future<void> _set(
      DocumentReferencePlatform documentReference, Map<String, dynamic> data) async {
    return MethodChannelFirestore.channel
        .invokeMethod<void>('Transaction#set', <String, dynamic>{
      'app': firestore.app.name,
      'transactionId': _transactionId,
      'path': documentReference.path,
      'data': FieldValuePlatform.serverDelegates(data),
    });
  }
}
