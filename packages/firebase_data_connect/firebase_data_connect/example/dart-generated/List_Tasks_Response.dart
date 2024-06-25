import 'package:json_annotation/json_annotation.dart';

part 'ListTasksResponse.g.dart';

@JsonSerializable()

class ListTasksResponse {
  
    
    List<ListTasksTasks> tasks;
  
  ListTasksResponse(
    this.tasks,
  );
  factory ListTasksResponse.fromJson(Map<String, dynamic> json) =>
      _$ListTasksResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ListTasksResponseToJson(this);
}