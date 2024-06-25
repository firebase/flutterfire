import 'package:json_annotation/json_annotation.dart';

part 'CreateTaskResponse.g.dart';

@JsonSerializable()

class CreateTaskResponse {
  
    
    Task_Key task_insert;
  
  CreateTaskResponse(
    this.task_insert,
  );
  factory CreateTaskResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateTaskResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CreateTaskResponseToJson(this);
}