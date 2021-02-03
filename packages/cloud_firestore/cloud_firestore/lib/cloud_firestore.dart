// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library cloud_firestore;

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show FirebasePluginPlatform;
import 'package:flutter/widgets.dart';

export 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart'
    show
        ListEquality,
        FieldPath,
        Blob,
        GeoPoint,
        Timestamp,
        Source,
        GetOptions,
        SetOptions,
        DocumentChangeType,
        Settings;
export 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show FirebaseException;

part 'src/collection_reference.dart';
part 'src/document_change.dart';
part 'src/document_reference.dart';
part 'src/document_snapshot.dart';
part 'src/field_value.dart';
part 'src/firestore.dart';
part 'src/query.dart';
part 'src/query_document_snapshot.dart';
part 'src/query_snapshot.dart';
part 'src/snapshot_metadata.dart';
part 'src/transaction.dart';
part 'src/utils/codec_utility.dart';
part 'src/write_batch.dart';
