import 'package:json_annotation/json_annotation.dart';

part 'ListTasksForTodayVariables.g.dart';

@JsonSerializable()

class ListTasksForTodayVariables {
  
    
    Date day;
  
  ListTasksForTodayVariables(
    this.day,
  );
  factory ListTasksForTodayVariables.fromJson(Map<String, dynamic> json) =>
      _$ListTasksForTodayVariablesFromJson(json);
  Map<String, dynamic> toJson() => _$ListTasksForTodayVariablesToJson(this);
}