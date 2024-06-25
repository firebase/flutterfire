import 'package:json_annotation/json_annotation.dart';

part 'CreateTaskVariables.g.dart';

@JsonSerializable()

class CreateTaskVariables {
  
    
    String description;
  
    
    Date date;
  
  CreateTaskVariables(
    this.description,
  
    this.date,
  );
  factory CreateTaskVariables.fromJson(Map<String, dynamic> json) =>
      _$CreateTaskVariablesFromJson(json);
  Map<String, dynamic> toJson() => _$CreateTaskVariablesToJson(this);
}