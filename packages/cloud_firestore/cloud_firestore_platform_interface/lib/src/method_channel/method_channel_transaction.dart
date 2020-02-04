// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

import 'method_channel_firestore.dart';

/// An implementation of [TransactionPlatform] which uses [MethodChannel] to
/// communication with native plugin
class MethodChannelTransaction extends TransactionPlatform {
  /// [FirebaseApp] name used for this [MethodChannelTransaction]
  final String appName;
  int _transactionId;

  /// Constructor.
  MethodChannelTransaction(int transactionId, this.appName)
      : _transactionId = transactionId,
        super(appName == FirebaseApp.defaultAppName
            ? FirestorePlatform.instance
            : FirestorePlatform.instanceFor(app: FirebaseApp(name: appName)));

  @override
  Future<DocumentSnapshotPlatform> doGet(
    DocumentReferencePlatform documentReference,
  ) async {
    final Map<String, dynamic> result = await MethodChannelFirestore.channel
        .invokeMapMethod<String, dynamic>('Transaction#get', <String, dynamic>{
      'app': firestore.app.name,
      'transactionId': _transactionId,
      'path': documentReference.path,
    });
    if (result != null) {
      return DocumentSnapshotPlatform(
          documentReference.path,
          result['data']?.cast<String, dynamic>(),
          SnapshotMetadataPlatform(result['metadata']['hasPendingWrites'],
              result['metadata']['isFromCache']),
          firestore);
    } else {
      return null;
    }
  }

  @override
  Future<void> doDelete(DocumentReferencePlatform documentReference) async {
    return MethodChannelFirestore.channel
        .invokeMethod<void>('Transaction#delete', <String, dynamic>{
      'app': firestore.app.name,
      'transactionId': _transactionId,
      'path': documentReference.path,
    });
  }

  @override
  Future<void> doUpdate(
    DocumentReferencePlatform documentReference,
    Map<String, dynamic> data,
  ) async {
    return MethodChannelFirestore.channel
        .invokeMethod<void>('Transaction#update', <String, dynamic>{
      'app': firestore.app.name,
      'transactionId': _transactionId,
      'path': documentReference.path,
      'data': data,
    });
  }

  @override
  Future<void> doSet(
    DocumentReferencePlatform documentReference,
    Map<String, dynamic> data,
  ) async {
    return MethodChannelFirestore.channel
        .invokeMethod<void>('Transaction#set', <String, dynamic>{
      'app': firestore.app.name,
      'transactionId': _transactionId,
      'path': documentReference.path,
      'data': data,
    });
  }
}
