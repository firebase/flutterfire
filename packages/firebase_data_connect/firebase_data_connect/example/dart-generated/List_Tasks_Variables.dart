import 'package:json_annotation/json_annotation.dart';

part 'ListTasksVariables.g.dart';

@JsonSerializable()

class ListTasksVariables {
  
  ListTasksVariables();
  factory ListTasksVariables.fromJson(Map<String, dynamic> json) =>
      _$ListTasksVariablesFromJson(json);
  Map<String, dynamic> toJson() => _$ListTasksVariablesToJson(this);
}