import 'package:json_annotation/json_annotation.dart';

part 'ToggleCompletedResponse.g.dart';

@JsonSerializable()

class ToggleCompletedResponse {
  
    
    Task_Key task_update;
  
  ToggleCompletedResponse(
    this.task_update,
  );
  factory ToggleCompletedResponse.fromJson(Map<String, dynamic> json) =>
      _$ToggleCompletedResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ToggleCompletedResponseToJson(this);
}