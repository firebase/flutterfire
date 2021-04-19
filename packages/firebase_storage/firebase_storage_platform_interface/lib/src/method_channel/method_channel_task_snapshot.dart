// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../firebase_storage_platform_interface.dart';
import 'method_channel_reference.dart';

/// Implementation for a [TaskSnapshotPlatform].
class MethodChannelTaskSnapshot extends TaskSnapshotPlatform {
  // ignore: public_member_api_docs
  MethodChannelTaskSnapshot(this.storage, TaskState state, this._data)
      : super(state, _data);

  /// The [FirebaseStoragePlatform] used to create the task.
  final FirebaseStoragePlatform storage;

  final Map<String, dynamic> _data;

  @override
  ReferencePlatform get ref {
    return MethodChannelReference(storage, _data['path']);
  }
}
