// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_database;

class TransactionResult {
  TransactionResultPlatform _delegate;

  TransactionResult._(this._delegate);
}
