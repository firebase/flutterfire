// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';
import 'package:json_annotation/json_annotation.dart';

part 'integration.g.dart';

@JsonSerializable()
class EmptyModel {
  EmptyModel();

  factory EmptyModel.fromJson(Map<String, dynamic> json) =>
      _$EmptyModelFromJson(json);

  Map<String, dynamic> toJson() => _$EmptyModelToJson(this);
}

@Collection<EmptyModel>('firestore-example-app/test/config')
final emptyModelRef = EmptyModelCollectionReference();

@Collection<ManualJson>('root')
class ManualJson {
  ManualJson(this.value);

  factory ManualJson.fromJson(Map<String, Object?> json) {
    return ManualJson(json['value']! as String);
  }

  final String value;

  Map<String, Object?> toJson() => {'value': value};
}

@Collection<AdvancedJson>('firestore-example-app/test/advanced')
@JsonSerializable(fieldRename: FieldRename.snake)
class AdvancedJson {
  AdvancedJson({this.firstName, this.lastName, this.ignored});

  final String? firstName;

  @JsonKey(name: 'LAST_NAME')
  final String? lastName;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? ignored;

  Map<String, Object?> toJson() => _$AdvancedJsonToJson(this);

  @override
  bool operator ==(Object other) {
    return other is AdvancedJson &&
        other.lastName == lastName &&
        other.firstName == firstName &&
        other.ignored == ignored;
  }

  @override
  int get hashCode => Object.hashAll([firstName, lastName, ignored]);
}

// This tests that the generated code compiles
@Collection<_PrivateAdvancedJson>('firestore-example-app/test/private-advanced')
@JsonSerializable(fieldRename: FieldRename.snake)
class _PrivateAdvancedJson {
  _PrivateAdvancedJson({
    this.firstName,
    this.lastName,
    // ignore: unused_element
    this.ignored,
  });

  final String? firstName;

  @JsonKey(name: 'LAST_NAME')
  final String? lastName;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? ignored;

  Map<String, Object?> toJson() => _$PrivateAdvancedJsonToJson(this);

  @override
  bool operator ==(Object other) {
    return other is AdvancedJson &&
        other.lastName == lastName &&
        other.firstName == firstName &&
        other.ignored == ignored;
  }

  @override
  int get hashCode => Object.hashAll([firstName, lastName, ignored]);
}
