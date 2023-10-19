// ignore_for_file: require_trailing_commas
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import 'method_channel_firestore.dart';

/// An implementation of [TransactionPlatform] that uses [MethodChannel] to
/// communicate with Firebase plugins.
class MethodChannelTransaction extends TransactionPlatform {
  /// [FirebaseApp] name used for this [MethodChannelTransaction]
  final String appName;
  final String databaseURL;
  late String _transactionId;
  late FirebaseFirestorePlatform _firestore;
  FirestorePigeonFirebaseApp pigeonApp;

  /// Constructor.
  MethodChannelTransaction(
      String transactionId, this.appName, this.pigeonApp, this.databaseURL)
      : _transactionId = transactionId,
        super() {
    _firestore = FirebaseFirestorePlatform.instanceFor(
        app: Firebase.app(appName), databaseURL: databaseURL);
  }

  List<PigeonTransactionCommand> _commands = [];

  /// Returns all transaction commands for the current instance.
  @override
  List<PigeonTransactionCommand> get commands {
    return _commands;
  }

  /// Reads the document referenced by the provided [documentPath].
  ///
  /// Requires all reads to be executed before all writes, otherwise an [AssertionError] will be thrown
  @override
  Future<DocumentSnapshotPlatform> get(String documentPath) async {
    assert(_commands.isEmpty,
        'Transactions require all reads to be executed before all writes.');

    final result = await MethodChannelFirebaseFirestore.pigeonChannel
        .transactionGet(pigeonApp, _transactionId, documentPath);

    return DocumentSnapshotPlatform(
      _firestore,
      documentPath,
      result.data,
      result.metadata,
    );
  }

  @override
  MethodChannelTransaction delete(String documentPath) {
    _commands.add(PigeonTransactionCommand(
      type: PigeonTransactionType.deleteType,
      path: documentPath,
    ));

    return this;
  }

  @override
  MethodChannelTransaction update(
    String documentPath,
    Map<String, dynamic> data,
  ) {
    _commands.add(PigeonTransactionCommand(
      type: PigeonTransactionType.update,
      path: documentPath,
      data: data,
    ));

    return this;
  }

  @override
  MethodChannelTransaction set(String documentPath, Map<String, dynamic> data,
      [SetOptions? options]) {
    _commands.add(PigeonTransactionCommand(
        type: PigeonTransactionType.set,
        path: documentPath,
        data: data,
        option: PigeonDocumentOption(
          merge: options?.merge,
          mergeFields: options?.mergeFields?.map((e) => e.components).toList(),
        )));

    return this;
  }
}
