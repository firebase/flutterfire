import 'package:json_annotation/json_annotation.dart';

part 'ListTasksPublicVariables.g.dart';

@JsonSerializable()

class ListTasksPublicVariables {
  
  ListTasksPublicVariables();
  factory ListTasksPublicVariables.fromJson(Map<String, dynamic> json) =>
      _$ListTasksPublicVariablesFromJson(json);
  Map<String, dynamic> toJson() => _$ListTasksPublicVariablesToJson(this);
}