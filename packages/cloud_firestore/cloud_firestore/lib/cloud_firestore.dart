// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library cloud_firestore;

import 'dart:async';
import 'dart:ui' show hashList;

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart'
    as platform;
import 'package:firebase_core/firebase_core.dart';

export 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart'
    show FieldPath, Blob, GeoPoint, Timestamp, Source, DocumentChangeType;

part 'src/collection_reference.dart';
part 'src/document_change.dart';
part 'src/utils/platform_utils.dart';
part 'src/document_reference.dart';
part 'src/document_snapshot.dart';
part 'src/field_value.dart';
part 'src/firestore.dart';
part 'src/query.dart';
part 'src/query_snapshot.dart';
part 'src/utils/codec_utility.dart';
part 'src/snapshot_metadata.dart';
part 'src/transaction.dart';
part 'src/write_batch.dart';
