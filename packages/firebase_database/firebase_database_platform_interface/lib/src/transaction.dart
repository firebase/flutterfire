// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The pending result of a [TransactionHandler].
class Transaction {
  Transaction._(this.aborted, this.value);

  /// The transaction was successful and should update the reference to the new
  /// [value] provided.
  Transaction.success(Object? value) : this._(false, value);

  /// The transaction should be aborted.
  Transaction.abort() : this._(true, null);

  /// Whether the transaction was aborted.
  final bool aborted;

  /// The new value that will be set if the transaction was not [aborted].
  final Object? value;
}
