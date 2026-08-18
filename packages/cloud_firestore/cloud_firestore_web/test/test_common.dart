// ignore_for_file: require_trailing_commas
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_web/cloud_firestore_web.dart';
import 'package:cloud_firestore_web/src/document_reference_web.dart';
import 'package:cloud_firestore_web/src/interop/firestore.dart' as web;
import 'package:cloud_firestore_web/src/query_web.dart';
import 'package:mockito/mockito.dart';

const kCollectionId = 'test';

class MockWebDocumentSnapshot extends Mock implements web.DocumentSnapshot {}

// Lint error here but tests pass without this.
// class MockWebSnapshotMetaData extends Mock implements web.SnapshotMetadata {}

class MockFirestoreWeb extends Mock implements web.Firestore {}

class MockWebTransaction extends Mock implements web.Transaction {}

class MockWebWriteBatch extends Mock implements web.WriteBatch {}

//ignore: avoid_implementing_value_types
class MockDocumentReference extends Mock implements DocumentReferenceWeb {}

//ignore: avoid_implementing_value_types
class MockFirestore extends Mock implements FirebaseFirestoreWeb {}

class MockWebDocumentReference extends Mock implements web.DocumentReference {}

class MockWebCollectionReference extends Mock
    implements web.CollectionReference {}

// ignore: must_be_immutable, avoid_implementing_value_types
class MockQueryWeb extends Mock implements QueryWeb {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshotPlatform {}
