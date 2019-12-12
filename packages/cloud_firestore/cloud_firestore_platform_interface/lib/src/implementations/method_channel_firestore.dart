// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show visibleForTesting;

import '../implementations/method_channel_document_reference.dart';
import '../implementations/method_channel_query.dart';
import '../implementations/method_channel_transaction.dart';
import '../implementations/method_channel_write_batch.dart';

import '../interfaces/firestore_platform.dart';
import '../interfaces/document_reference_platform.dart';
import '../interfaces/query_platform.dart';
import '../interfaces/transaction_platform.dart';
import '../interfaces/write_batch_platform.dart';

class MethodChannelFirestore extends FirestorePlatform {
  /// Constructor
  MethodChannelFirestore() {
    // Register all other instances...
    DocumentReferencePlatform.instance = MethodChannelDocumentReference();
    QueryPlatform.instance = MethodChannelQuery();
    TransactionPlatform.instance = MethodChannelTransaction();
    WriteBatchPlatform.instance = MethodChannelWriteBatch();
  }

  /// DocumentReference delegate
  @override
  DocumentReferencePlatform get documentReference =>
      DocumentReferencePlatform.instance;

  /// Query delegate
  @override
  QueryPlatform get query => QueryPlatform.instance;

  /// Transaction delegate
  @override
  TransactionPlatform get transaction => TransactionPlatform.instance;

  /// WriteBatch delegate
  @override
  WriteBatchPlatform get writeBatch => WriteBatchPlatform.instance;

  /// The MethodChannel used to pass messages to the native side.
  @visibleForTesting
  static const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/cloud_firestore',
  );

  @override
  Future<void> enablePersistence(String app, {bool enable = true}) {
    return channel
        .invokeMethod<void>('Firestore#enablePersistence', <String, dynamic>{
      'app': app,
      'enable': enable,
    });
  }

  @override
  Future<void> settings(
    String app, {
    bool persistenceEnabled,
    String host,
    bool sslEnabled,
    int cacheSizeBytes,
  }) {
    return channel.invokeMethod<void>('Firestore#settings', <String, dynamic>{
      'app': app,
      'persistenceEnabled': persistenceEnabled,
      'host': host,
      'sslEnabled': sslEnabled,
      'cacheSizeBytes': cacheSizeBytes,
    });
  }

  // runTransaction as a facade to TransactionPlatform::run?

}
