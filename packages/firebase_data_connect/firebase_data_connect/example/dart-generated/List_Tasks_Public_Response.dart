import 'package:json_annotation/json_annotation.dart';

import 'ListTasksPublicTasks.dart';

part 'ListTasksPublicResponse.g.dart';

@JsonSerializable()

class ListTasksPublicResponse {
  
    
    List<ListTasksPublicTasks> tasks;
  
  ListTasksPublicResponse(
    this.tasks,
  );
  factory ListTasksPublicResponse.fromJson(Map<String, dynamic> json) =>
      _$ListTasksPublicResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ListTasksPublicResponseToJson(this);
}