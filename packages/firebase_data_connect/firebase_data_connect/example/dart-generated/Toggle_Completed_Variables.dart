import 'package:json_annotation/json_annotation.dart';

part 'ToggleCompletedVariables.g.dart';

@JsonSerializable()

class ToggleCompletedVariables {
  
    
    String id;
  
    
    bool completed;
  
  ToggleCompletedVariables(
    this.id,
  
    this.completed,
  );
  factory ToggleCompletedVariables.fromJson(Map<String, dynamic> json) =>
      _$ToggleCompletedVariablesFromJson(json);
  Map<String, dynamic> toJson() => _$ToggleCompletedVariablesToJson(this);
}