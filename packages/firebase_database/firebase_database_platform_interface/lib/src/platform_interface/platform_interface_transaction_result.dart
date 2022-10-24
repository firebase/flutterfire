// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Interface for [TransactionHandler]
typedef TransactionHandler = Transaction Function(Object? value);

/// Interface for [TransactionResultPlatform]
class TransactionResultPlatform extends PlatformInterface {
  /// Constructor for [TransactionResultPlatform]
  TransactionResultPlatform(
    this.committed,
  ) : super(token: _token);

  /// Throws an [AssertionError] if [instance] does not extend
  /// [TransactionResultPlatform].
  static void verify(TransactionResultPlatform instance) {
    PlatformInterface.verify(instance, _token);
  }

  static final Object _token = Object();

  /// The [committed] status associated to this transaction result.
  final bool committed;

  /// The [DataSnapshotPlatform] associated to this transaction result.
  DataSnapshotPlatform get snapshot {
    throw UnimplementedError('get snapshot is not implemented');
  }
}
