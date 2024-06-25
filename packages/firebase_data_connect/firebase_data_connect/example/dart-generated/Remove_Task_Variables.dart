import 'package:json_annotation/json_annotation.dart';

part 'RemoveTaskVariables.g.dart';

@JsonSerializable()

class RemoveTaskVariables {
  
    
    String id;
  
  RemoveTaskVariables(
    this.id,
  );
  factory RemoveTaskVariables.fromJson(Map<String, dynamic> json) =>
      _$RemoveTaskVariablesFromJson(json);
  Map<String, dynamic> toJson() => _$RemoveTaskVariablesToJson(this);
}