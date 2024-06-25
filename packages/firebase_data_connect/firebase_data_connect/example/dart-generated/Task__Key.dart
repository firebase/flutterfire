import 'package:json_annotation/json_annotation.dart';

part 'Task_Key.g.dart';

@JsonSerializable()

class Task_Key {
  
    
    String id;
  
  Task_Key(
    this.id,
  );
  factory Task_Key.fromJson(Map<String, dynamic> json) =>
      _$Task_KeyFromJson(json);
  Map<String, dynamic> toJson() => _$Task_KeyToJson(this);
}