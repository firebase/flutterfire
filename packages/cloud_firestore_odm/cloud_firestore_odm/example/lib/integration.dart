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

@Collection<EmptyModel>('config')
final emptyModelRef = EmptyModelCollectionReference();
