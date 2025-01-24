// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
// TODO(Lyokone): remove once we bump Flutter SDK min version to 3.3
// ignore: unnecessary_import
import 'dart:typed_data';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show FirebasePluginPlatform;
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

export 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart'
    show
        AggregateField,
        AggregateSource,
        ListEquality,
        FieldPath,
        Blob,
        GeoPoint,
        VectorValue,
        Timestamp,
        Source,
        GetOptions,
        ServerTimestampBehavior,
        SetOptions,
        ListenSource,
        DocumentChangeType,
        PersistenceSettings,
        Settings,
        WebExperimentalLongPollingOptions,
        IndexField,
        Index,
        FieldOverrides,
        FieldOverrideIndex,
        Order,
        ArrayConfig,
        QueryScope,
        LoadBundleTaskState,
        average,
        count,
        sum;
export 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show FirebaseException;

part 'src/aggregate_query.dart';
part 'src/aggregate_query_snapshot.dart';
part 'src/collection_reference.dart';
part 'src/document_change.dart';
part 'src/document_reference.dart';
part 'src/document_snapshot.dart';
part 'src/field_value.dart';
part 'src/filters.dart';
part 'src/firestore.dart';
part 'src/load_bundle_task.dart';
part 'src/load_bundle_task_snapshot.dart';
part 'src/persistent_cache_index_manager.dart';
part 'src/query.dart';
part 'src/query_document_snapshot.dart';
part 'src/query_snapshot.dart';
part 'src/snapshot_metadata.dart';
part 'src/transaction.dart';
part 'src/utils/codec_utility.dart';
part 'src/write_batch.dart';
