// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show visibleForTesting;

import '../interfaces/write_batch_platform.dart';

class MethodChannelWriteBatch extends WriteBatchPlatform {
  /// Constructor
  MethodChannelWriteBatch();

  @visibleForTesting
  static const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/cloud_firestore',
  );
}
