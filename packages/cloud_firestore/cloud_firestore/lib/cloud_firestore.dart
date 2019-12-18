// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library cloud_firestore;

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' show hashValues, hashList;

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart' as platform;
import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

part 'src/blob.dart';
part 'src/collection_reference.dart';
part 'src/document_change.dart';
part 'src/utils/platform_utils.dart';
part 'src/document_reference.dart';
part 'src/document_snapshot.dart';
part 'src/field_path.dart';
part 'src/field_value.dart';
part 'src/firestore.dart';
part 'src/geo_point.dart';
part 'src/query.dart';
part 'src/query_snapshot.dart';
part 'src/snapshot_metadata.dart';
part 'src/timestamp.dart';
part 'src/transaction.dart';
part 'src/write_batch.dart';
part 'src/source.dart';
