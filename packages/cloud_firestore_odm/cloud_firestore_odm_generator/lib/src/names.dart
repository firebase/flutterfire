// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/type.dart';

/// A mixin for obtaining the class name of collections/documents/snapshots/etc
/// based on annotation metadata.
mixin Names {
  String? get collectionPrefix;
  DartType get type;

  late final String classPrefix = collectionPrefix ??
      type.getDisplayString(withNullability: false).replaceFirstMapped(
            RegExp('[a-zA-Z]'),
            (match) => match.group(0)!.toUpperCase(),
          );

  late final String collectionReferenceInterfaceName =
      '${classPrefix}CollectionReference';
  late final String collectionReferenceImplName =
      '_\$${classPrefix}CollectionReference';
  late final String documentReferenceName = '${classPrefix}DocumentReference';
  late final String queryReferenceInterfaceName = '${classPrefix}Query';
  late final String queryReferenceImplName = '_\$${classPrefix}Query';
  late final String querySnapshotName = '${classPrefix}QuerySnapshot';
  late final String queryDocumentSnapshotName =
      '${classPrefix}QueryDocumentSnapshot';
  late final String documentSnapshotName = '${classPrefix}DocumentSnapshot';
  late final String originalDocumentSnapshotName = 'DocumentSnapshot<$type>';
}
