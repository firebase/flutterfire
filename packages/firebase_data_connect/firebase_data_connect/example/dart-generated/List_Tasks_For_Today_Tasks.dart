import 'package:json_annotation/json_annotation.dart';

part 'ListTasksForTodayTasks.g.dart';

@JsonSerializable()

class ListTasksForTodayTasks {
  
    
    String id;
  
    
    String description;
  
    
    bool completed;
  
    
    Date date;
  
    
    String owner;
  
  ListTasksForTodayTasks(
    this.id,
  
    this.description,
  
    this.completed,
  
    this.date,
  
    this.owner,
  );
  factory ListTasksForTodayTasks.fromJson(Map<String, dynamic> json) =>
      _$ListTasksForTodayTasksFromJson(json);
  Map<String, dynamic> toJson() => _$ListTasksForTodayTasksToJson(this);
}