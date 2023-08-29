// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';
import 'package:json_annotation/json_annotation.dart';

part 'enums.g.dart';

enum TestEnum {
  one,
  two,
  three;
}

@JsonSerializable()
class Enums {
  Enums({
    required this.id,
    this.enumValue = TestEnum.one,
    this.nullableEnumValue,
    this.enumList = const [],
    this.nullableEnumList,
  });

  factory Enums.fromJson(Map<String, Object?> json) => _$EnumsFromJson(json);

  Map<String, Object?> toJson() => _$EnumsToJson(this);

  final String id;
  final TestEnum enumValue;
  final TestEnum? nullableEnumValue;
  final List<TestEnum> enumList;
  final List<TestEnum>? nullableEnumList;
}

@Collection<Enums>('firestore-example-app')
final enumsRef = EnumsCollectionReference();
