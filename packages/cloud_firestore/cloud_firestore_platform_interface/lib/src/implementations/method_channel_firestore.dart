// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show visibleForTesting;

import './method_channel_document_reference.dart';
import './method_channel_query.dart';
import './method_channel_transaction.dart';
import './method_channel_write_batch.dart';

import '../interfaces.dart';

/// A method channel implementation of the Firestore platform.
class MethodChannelFirestore extends FirestorePlatform {
  /// Constructor. Requires a MethodCodec [codec] that can live in userland and have business logic there.
  MethodChannelFirestore(StandardMessageCodec codec) {
    // Register all other instances...
    MethodChannelFirestore._channel = MethodChannel(
      'plugins.flutter.io/cloud_firestore',
      StandardMethodCodec(codec),
    );
    
    DocumentReferencePlatform.instance = MethodChannelDocumentReference(codec);
    QueryPlatform.instance = MethodChannelQuery(codec);
    TransactionPlatform.instance = MethodChannelTransaction(codec);
    WriteBatchPlatform.instance = MethodChannelWriteBatch(codec);
  }

  /// The MethodChannel used to pass messages to the native side.
  @visibleForTesting
  static MethodChannel get channel => MethodChannelFirestore._channel;
  static MethodChannel _channel;

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

  // Find runTransaction in transaction.run
}
