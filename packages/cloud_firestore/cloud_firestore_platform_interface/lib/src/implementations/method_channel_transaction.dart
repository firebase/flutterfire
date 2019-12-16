// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show required, visibleForTesting;

import './multi_method_channel.dart';

import '../interfaces/transaction_platform.dart';
import '../types.dart';

class MethodChannelTransaction extends TransactionPlatform {
  MethodChannelTransaction(MultiMethodChannel channel) {
    MethodChannelTransaction._channel = channel;
    MethodChannelTransaction._channel.addMethodCallHandler('DoTransaction', this._handleDoTransaction);
  }

  @visibleForTesting
  static MultiMethodChannel get channel => MethodChannelTransaction._channel;
  static MultiMethodChannel _channel;

  static final Map<int, PlatformTransactionHandler> _transactionHandlers =
      <int, PlatformTransactionHandler>{};
  static int _transactionHandlerId = 0;

  Future<dynamic> _handleDoTransaction(MethodCall call) async {
    final int transactionId = call.arguments['transactionId'];
    // Do the transaction
    final PlatformTransactionHandler handler = _transactionHandlers[transactionId];
    return await handler(PlatformTransaction(transactionId: transactionId));
  }

  @override
  Future<Map<String, dynamic>> run(
    String app, {
    @required PlatformTransactionHandler updateFunction,
    int transactionTimeout,
  }) async {
    // The [updateFunction] will be used by the [_handleDoTransaction] method later
    final int transactionId = _transactionHandlerId++;
    _transactionHandlers[transactionId] = updateFunction;

    return channel.invokeMapMethod<String, dynamic>(
        'Firestore#runTransaction', <String, dynamic>{
        'app': app,
        'transactionId': transactionId,
        'transactionTimeout': transactionTimeout
      });
  }

  @override
  Future<PlatformDocumentSnapshot> get(
    String app, {
    @required String path,
    @required int transactionId,
  }) {
    return channel
        .invokeMapMethod<String, dynamic>('Transaction#get', <String, dynamic>{
          'app': app,
          'transactionId': transactionId,
          'path': path,
        }).then((data) {
          return PlatformDocumentSnapshot(
              path: data['path'],
              data: data['data']?.cast<String, dynamic>(),
              metadata: PlatformSnapshotMetadata(
                  hasPendingWrites: data['metadata']['hasPendingWrites'],
                  isFromCache: data['metadata']['isFromCache'],
                ),
          );
        });
  }

  @override
  Future<void> delete(
    String app, {
    @required String path,
    @required int transactionId,
  }) {
    return channel.invokeMethod<void>('Transaction#delete', <String, dynamic>{
        'app': app,
        'transactionId': transactionId,
        'path': path,
      });
  }

  @override
  Future<void> update(
    String app, {
    @required String path,
    @required int transactionId,
    Map<String, dynamic> data,
  }) async {
    return channel.invokeMethod<void>('Transaction#update', <String, dynamic>{
        'app': app,
        'transactionId': transactionId,
        'path': path,
        'data': data,
      });
  }

  @override
  Future<void> set(
    String app, {
    @required String path,
    @required int transactionId,
    Map<String, dynamic> data,
  }) async {
    return channel.invokeMethod<void>('Transaction#set', <String, dynamic>{
        'app': app,
        'transactionId': transactionId,
        'path': path,
        'data': data,
      });
  }
}
