import 'package:json_annotation/json_annotation.dart';

part 'RemoveTaskResponse.g.dart';

@JsonSerializable()

class RemoveTaskResponse {
  
    
    Task_Key task_delete;
  
  RemoveTaskResponse(
    this.task_delete,
  );
  factory RemoveTaskResponse.fromJson(Map<String, dynamic> json) =>
      _$RemoveTaskResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RemoveTaskResponseToJson(this);
}