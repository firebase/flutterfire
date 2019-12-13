// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';

import 'package:meta/meta.dart' show required;
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import './document_reference_platform.dart';
import './query_platform.dart';
import './transaction_platform.dart';
import './write_batch_platform.dart';

import '../implementations/method_channel_firestore.dart';

/// The Firestore platform interface.
abstract class FirestorePlatform extends PlatformInterface {
  /// Constructor
  FirestorePlatform() : super(token: _token);

  static final Object _token = Object();

  /// The default instance of [FirestorePlatform] to use.
  ///
  /// Platform-specific plugins should override this with their own class
  /// that extends [FirestorePlatform] when they register themselves.
  ///
  /// Defaults to [MethodChannelFirestore].
  static FirestorePlatform get instance => _instance;

  static FirestorePlatform _instance = MethodChannelFirestore();

  // TODO(amirh): Extract common platform interface logic.
  // https://github.com/flutter/flutter/issues/43368
  static set instance(FirestorePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // Delegate platforms that need to be initialized at construction time
  /// DocumentReference delegate
  DocumentReferencePlatform get documentReference {
    throw UnimplementedError(
        'Provide a DocumentReferencePlatform on your implementation.');
  }

  /// Query delegate
  QueryPlatform get query {
    throw UnimplementedError('Provide a QueryPlatform on your implementation.');
  }

  /// Transaction delegate
  TransactionPlatform get transaction {
    throw UnimplementedError(
        'Provide a TransactionPlatform on your implementation.');
  }

  /// WriteBatch delegate
  WriteBatchPlatform get writeBatch {
    throw UnimplementedError(
        'Provide a WriteBatchPlatform on your implementation.');
  }

  /// Specifies custom settings to be used to configure the Firestore instance.
  /// Must be set before invoking any other methods.
  Future<void> settings(
    String app, {
    bool persistenceEnabled,
    String host,
    bool sslEnabled,
    int cacheSizeBytes,
  }) async {
    throw UnimplementedError(
        'FirestorePlatform::settings() is not implemented');
  }

  // Actual interface
  /// Attempts to enable persistent storage, if possible.
  /// Must be called before any other methods (other than [settings]).
  Future<void> enablePersistence(String app, {@required bool enable}) async {
    throw UnimplementedError(
        'FirestorePlatform::enablePersistence() is not implemented');
  }
}
