// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

/// The TransactionHandler may be executed multiple times, it should be able
/// to handle multiple executions.
typedef Future<dynamic> TransactionHandler(TransactionPlatform transaction);

/// a [TransactionPlatform] is a set of read and write operations on one or more documents.
abstract class TransactionPlatform extends PlatformInterface {
  /// Constructor.
  TransactionPlatform(this.firestore) : super(token: _token);

  static final Object _token = Object();

  /// Throws an [AssertionError] if [instance] does not extend
  /// [TransactionPlatform].
  ///
  /// This is used by the app-facing [Transaction] to ensure that
  /// the object in which it's going to delegate calls has been
  /// constructed properly.
  static verifyExtends(TransactionPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
  }

  /// [FirestorePlatform] instance used for this [TransactionPlatform]
  FirestorePlatform firestore;
  List<Future<dynamic>> _pendingResults = <Future<dynamic>>[];

  /// executes all the pending operations on the transaction
  Future<void> finish() => Future.wait<void>(_pendingResults);

  /// Reads the document referenced by the provided DocumentReference.
  Future<DocumentSnapshotPlatform> get(
      DocumentReferencePlatform documentReference) {
    final Future<DocumentSnapshotPlatform> result = doGet(documentReference);
    _pendingResults.add(result);
    return result;
  }

  /// Reads the document referenced by the provided DocumentReference.
  /// This is here so it can be overridden by implementations that do NOT
  /// handle returned futures automatically, like the [MethodChannelTransaction].
  /// Does not affect the _pendingResults.
  Future<DocumentSnapshotPlatform> doGet(
    DocumentReferencePlatform documentReference,
  ) async {
    throw UnimplementedError("get() not implemented");
  }

  /// Deletes the document referred to by the provided [documentReference].
  ///
  /// Awaiting the returned [Future] is optional and will be done automatically
  /// when the transaction handler completes.
  Future<void> delete(DocumentReferencePlatform documentReference) {
    final Future<void> result = doDelete(documentReference);
    _pendingResults.add(result);
    return result;
  }

  /// Deletes the document referred to by the provided [documentReference].
  /// This is here so it can be overridden by implementations that do NOT
  /// handle returned futures automatically, like the [MethodChannelTransaction].
  /// Does not affect the _pendingResults.
  Future<void> doDelete(DocumentReferencePlatform documentReference) async {
    throw UnimplementedError("delete() not implemented");
  }

  /// Updates fields in the document referred to by [documentReference].
  /// The update will fail if applied to a document that does not exist.
  ///
  /// Awaiting the returned [Future] is optional and will be done automatically
  /// when the transaction handler completes.
  Future<void> update(
    DocumentReferencePlatform documentReference,
    Map<String, dynamic> data,
  ) async {
    final Future<void> result = doUpdate(documentReference, data);
    _pendingResults.add(result);
    return result;
  }

  /// Updates fields in the document referred to by [documentReference].
  /// The update will fail if applied to a document that does not exist.
  /// This is here so it can be overridden by implementations that do NOT
  /// handle returned futures automatically, like the [MethodChannelTransaction].
  /// Does not affect the _pendingResults.
  Future<void> doUpdate(
    DocumentReferencePlatform documentReference,
    Map<String, dynamic> data,
  ) async {
    throw UnimplementedError("updated() not implemented");
  }

  /// Writes to the document referred to by the provided [DocumentReferencePlatform].
  /// If the document does not exist yet, it will be created. If you pass
  /// SetOptions, the provided data can be merged into the existing document.
  ///
  /// Awaiting the returned [Future] is optional and will be done automatically
  /// when the transaction handler completes.
  Future<void> set(
    DocumentReferencePlatform documentReference,
    Map<String, dynamic> data,
  ) {
    final Future<void> result = doSet(documentReference, data);
    _pendingResults.add(result);
    return result;
  }

  /// Writes to the document referred to by the provided [DocumentReferencePlatform].
  /// If the document does not exist yet, it will be created. If you pass
  /// SetOptions, the provided data can be merged into the existing document.
  /// This is here so it can be overridden by implementations that do NOT
  /// handle returned futures automatically, like the [MethodChannelTransaction].
  /// Does not affect the _pendingResults.
  Future<void> doSet(
    DocumentReferencePlatform documentReference,
    Map<String, dynamic> data,
  ) async {
    throw UnimplementedError("set() not implemented");
  }
}
