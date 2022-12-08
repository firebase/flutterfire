// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'named_query.g.dart';

@NamedQuery<Conflict>('named-bundle-test-4')
@Collection<Conflict>('firestore-example-app/42/named-query-conflict')
@JsonSerializable()
class Conflict {
  Conflict(this.number);

  final num number;
}
