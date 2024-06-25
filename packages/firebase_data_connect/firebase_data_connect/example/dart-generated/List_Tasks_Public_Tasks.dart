import 'package:json_annotation/json_annotation.dart';

part 'ListTasksPublicTasks.g.dart';

@JsonSerializable()

class ListTasksPublicTasks {
  
    
    String description;
  
    
    String id;
  
    
    bool completed;
  
    
    String owner;
  
    
    Date date;
  
  ListTasksPublicTasks(
    this.description,
  
    this.id,
  
    this.completed,
  
    this.owner,
  
    this.date,
  );
  factory ListTasksPublicTasks.fromJson(Map<String, dynamic> json) =>
      _$ListTasksPublicTasksFromJson(json);
  Map<String, dynamic> toJson() => _$ListTasksPublicTasksToJson(this);
}