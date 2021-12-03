// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';

import 'method_channel_data_snapshot.dart';

class MethodChannelTransactionResult extends TransactionResultPlatform {
  MethodChannelTransactionResult(bool committed, this._ref, this._snapshot)
      : super(committed);

  DatabaseReferencePlatform _ref;

  Map<String, dynamic> _snapshot;

  @override
  DataSnapshotPlatform get snapshot {
    return MethodChannelDataSnapshot(_ref, _snapshot);
  }
}
