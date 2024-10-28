// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

/// [VectorQuerySnapshotPlatform] represents a response to an [VectorQueryPlatform] request.
class VectorQuerySnapshotPlatform extends QuerySnapshotPlatform {
  VectorQuerySnapshotPlatform(
    super.docs,
    super.docChanges,
    super.metadata,
  ) : super();
}
