// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_database;

/// Instances of this class represent the outcome of a transaction.
class TransactionResult {
  TransactionResultPlatform _delegate;

  TransactionResult._(this._delegate) {
    TransactionResultPlatform.verify(_delegate);
  }

  /// The [committed] status associated to this transaction result.
  bool get committed {
    return _delegate.committed;
  }

  /// The [DataSnapshot] associated to this transaction result.
  DataSnapshot get snapshot {
    return DataSnapshot._(_delegate.snapshot);
  }
}
