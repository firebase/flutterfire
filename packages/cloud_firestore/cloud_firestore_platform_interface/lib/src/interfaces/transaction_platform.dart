// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';

import 'package:cloud_firestore_platform_interface/src/types/document.dart';
import 'package:cloud_firestore_platform_interface/src/types/transaction.dart';
import 'package:meta/meta.dart' show required;
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../implementations/method_channel_transaction.dart';

/// The Transaction platform interface.
abstract class TransactionPlatform extends PlatformInterface {
  /// Constructor
  TransactionPlatform() : super(token: _token);

  static final Object _token = Object();

  /// The default instance of [TransactionPlatform] to use.
  ///
  /// Platform-specific plugins should override this with their own class
  /// that extends [TransactionPlatform] when they register themselves.
  ///
  /// Defaults to [MethodChannelTransaction].
  static TransactionPlatform get instance => _instance;

  static TransactionPlatform _instance = MethodChannelTransaction();

  // TODO(amirh): Extract common platform interface logic.
  // https://github.com/flutter/flutter/issues/43368
  static set instance(TransactionPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // Actual interface

  /// Executes the given [updateFunction] and then attempts to commit the changes applied within the transaction.
  /// If any document read within the transaction has changed, Firestore retries the updateFunction.
  /// If it fails to commit after 5 attempts, the transaction fails.
  ///
  /// If the transaction completed successfully or was explicitly aborted (the updateFunction returned a failed promise),
  /// the promise returned by the updateFunction is returned here.
  /// Else, if the transaction failed, a rejected promise with the corresponding failure error will be returned.
  // TODO(ditman): What's the type of this return?
  Future<Map<String, dynamic>> run(
    String app, {
    @required PlatformTransactionHandler updateFunction,
    int transactionTimeout,
  }) async {
    throw UnimplementedError('TransactionPlatform::run() is not implemented');
  }

  /// Reads the transaction referenced by the provided [transactionId].
  Future<PlatformDocumentSnapshot> get(
    String app, {
    @required String path,
    @required int transactionId,
  }) async {
    throw UnimplementedError('TransactionPlatform::get() is not implemented');
  }

  /// Deletes the transaction referred to by the provided [transactionId].
  Future<void> delete(
    String app, {
    @required String path,
    @required int transactionId,
  }) async {
    throw UnimplementedError(
        'TransactionPlatform::delete() is not implemented');
  }

  /// Updates fields with [data] in the transaction referred to by the provided [transactionId].
  Future<void> update(
    String app, {
    @required String path,
    @required int transactionId,
    Map<String, dynamic> data,
  }) async {
    throw UnimplementedError(
        'TransactionPlatform::update() is not implemented');
  }

  /// Writes to the transaction referred to by the provided [transactionId].
  Future<void> set(
    String app, {
    @required String path,
    @required int transactionId,
    Map<String, dynamic> data,
  }) async {
    throw UnimplementedError('TransactionPlatform::set() is not implemented');
  }
}
