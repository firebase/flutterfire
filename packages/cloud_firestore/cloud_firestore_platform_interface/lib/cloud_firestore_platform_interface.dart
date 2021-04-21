// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library cloud_firestore_platform_interface;

import 'src/internal/pointer.dart';

export 'package:collection/collection.dart' show ListEquality;
export 'src/blob.dart';
export 'src/field_path.dart';
export 'src/geo_point.dart';
export 'src/platform_interface/platform_interface_firestore.dart';
export 'src/platform_interface/platform_interface_collection_reference.dart';
export 'src/platform_interface/platform_interface_document_change.dart';
export 'src/platform_interface/platform_interface_document_reference.dart';
export 'src/platform_interface/platform_interface_document_snapshot.dart';
export 'src/platform_interface/platform_interface_field_value.dart';
export 'src/platform_interface/platform_interface_field_value_factory.dart';
export 'src/platform_interface/platform_interface_query.dart';
export 'src/platform_interface/platform_interface_query_snapshot.dart';
export 'src/platform_interface/platform_interface_transaction.dart';
export 'src/platform_interface/platform_interface_write_batch.dart';
export 'src/snapshot_metadata.dart';
export 'src/source.dart';
export 'src/timestamp.dart';
export 'src/settings.dart';
export 'src/get_options.dart';
export 'src/set_options.dart';
export 'src/persistence_settings.dart';

/// Helper method exposed to determine whether a given [collectionPath] points to
/// a valid Firestore collection.
///
/// This is exposed to keep the [Pointer] internal to this library.
bool isValidCollectionPath(String collectionPath) {
  return Pointer(collectionPath).isCollection();
}

/// Helper method exposed to determine whether a given [documentPath] points to
/// a valid Firestore document.
///
/// This is exposed to keep the [Pointer] internal to this library.
bool isValidDocumentPath(String documentPath) {
  return Pointer(documentPath).isDocument();
}
