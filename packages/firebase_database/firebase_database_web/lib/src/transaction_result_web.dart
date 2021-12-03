// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_database_web;

class TransactionResultWeb extends TransactionResultPlatform {
  TransactionResultWeb._(this._ref, this._delegate)
      : super(_delegate.committed);

  final database_interop.Transaction _delegate;

  final DatabaseReferencePlatform _ref;

  @override
  DataSnapshotPlatform get snapshot {
    return webSnapshotToPlatformSnapshot(_ref, _delegate.snapshot);
  }
}
