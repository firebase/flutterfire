import 'package:json_annotation/json_annotation.dart';

part 'ListTasksForTodayResponse.g.dart';

@JsonSerializable()

class ListTasksForTodayResponse {
  
    
    List<ListTasksForTodayTasks> tasks;
  
  ListTasksForTodayResponse(
    this.tasks,
  );
  factory ListTasksForTodayResponse.fromJson(Map<String, dynamic> json) =>
      _$ListTasksForTodayResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ListTasksForTodayResponseToJson(this);
}