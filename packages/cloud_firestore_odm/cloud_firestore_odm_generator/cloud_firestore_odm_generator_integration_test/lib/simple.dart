import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';
import 'package:json_annotation/json_annotation.dart';
import 'model.dart';

part 'simple.g.dart';

@Collection<SplitFileModel>('split-file')
final splitFileRef = SplitFileModelCollectionReference();

@JsonSerializable()
class EmptyModel {
  EmptyModel();

  factory EmptyModel.fromJson(Map<String, dynamic> json) =>
      _$EmptyModelFromJson(json);

  Map<String, dynamic> toJson() => _$EmptyModelToJson(this);
}

@Collection<EmptyModel>('config')
final emptyModelRef = EmptyModelCollectionReference();

@JsonSerializable()
class MinValidation {
  MinValidation(this.intNbr, this.doubleNbr, this.numNbr) {
    _$assertMinValidation(this);
  }

  @Min(0)
  @Max(42)
  final int intNbr;

  @Min(10)
  final double doubleNbr;
  @Min(-10)
  final num numNbr;
}

@JsonSerializable()
class Root {
  Root(this.nonNullable, this.nullable);

  factory Root.fromJson(Map<String, Object?> json) => _$RootFromJson(json);

  final String nonNullable;
  final int? nullable;

  Map<String, Object?> toJson() => _$RootToJson(this);
}

@JsonSerializable()
class OptionalJson {
  OptionalJson(this.value);

  final int value;
}

@Collection<OptionalJson>('root')
final optionalJsonRef = OptionalJsonCollectionReference();

@JsonSerializable()
class MixedJson {
  MixedJson(this.value);

  factory MixedJson.fromJson(Map<String, Object?> json) =>
      MixedJson(json['foo']! as int);

  final int value;

  Map<String, Object?> toJson() => {'foo': value};
}

@Collection<MixedJson>('root')
final mixedJsonRef = MixedJsonCollectionReference();

@JsonSerializable()
class Sub {
  Sub(this.nonNullable, this.nullable);

  factory Sub.fromJson(Map<String, Object?> json) => _$SubFromJson(json);

  final String nonNullable;
  final int? nullable;

  Map<String, Object?> toJson() => _$SubToJson(this);
}

@JsonSerializable()
class CustomSubName {
  CustomSubName(this.value);

  factory CustomSubName.fromJson(Map<String, Object?> json) =>
      _$CustomSubNameFromJson(json);

  final num value;

  Map<String, Object?> toJson() => _$CustomSubNameToJson(this);
}

@JsonSerializable()
class AsCamelCase {
  AsCamelCase(this.value);

  factory AsCamelCase.fromJson(Map<String, Object?> json) =>
      _$AsCamelCaseFromJson(json);

  final num value;

  Map<String, Object?> toJson() => _$AsCamelCaseToJson(this);
}

@Collection<Root>('root')
@Collection<Sub>('root/*/sub')
@Collection<AsCamelCase>('root/*/as-camel-case')
@Collection<CustomSubName>('root/*/custom-sub-name', name: 'thisIsACustomName')
final rootRef = RootCollectionReference();

@JsonSerializable()
class ExplicitPath {
  ExplicitPath(this.value);

  factory ExplicitPath.fromJson(Map<String, Object?> json) =>
      _$ExplicitPathFromJson(json);

  final num value;

  Map<String, Object?> toJson() => _$ExplicitPathToJson(this);
}

@JsonSerializable()
class ExplicitSubPath {
  ExplicitSubPath(this.value);

  factory ExplicitSubPath.fromJson(Map<String, Object?> json) =>
      _$ExplicitSubPathFromJson(json);

  final num value;

  Map<String, Object?> toJson() => _$ExplicitSubPathToJson(this);
}

@Collection<ExplicitPath>('root/doc/path')
@Collection<ExplicitSubPath>('root/doc/path/*/sub')
final explicitRef = ExplicitPathCollectionReference();
