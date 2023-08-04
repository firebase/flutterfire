import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm/annotation.dart';
import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';
import 'package:json_annotation/json_annotation.dart';

part 'enums.g.dart';

enum TestEnum {
  one,
  two,
  three;
}

@JsonSerializable(createPerFieldToJson: true)
class Enums {
  Enums({
    required this.id,
    required this.enumValue,
    required this.nullableEnumValue,
    required this.enumList,
    required this.nullableEnumList,
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
