import 'package:json/json.dart';

@JsonCodable()
class User {
  final int? age;
  final String name;
  final String username;
}
