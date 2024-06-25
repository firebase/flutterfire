import 'package:json_annotation/json_annotation.dart';

part 'ListTasksTasks.g.dart';

@JsonSerializable()

class ListTasksTasks {
  
    
    String description;
  
    
    String id;
  
    
    bool completed;
  
    
    String owner;
  
    
    Date date;
  
  ListTasksTasks(
    this.description,
  
    this.id,
  
    this.completed,
  
    this.owner,
  
    this.date,
  );
  factory ListTasksTasks.fromJson(Map<String, dynamic> json) =>
      _$ListTasksTasksFromJson(json);
  Map<String, dynamic> toJson() => _$ListTasksTasksToJson(this);
}