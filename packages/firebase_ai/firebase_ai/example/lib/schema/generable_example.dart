import 'package:firebase_ai/firebase_ai.dart';

part 'generable_example.g.dart';

@Generable(description: 'A mock user for testing')
class MockUser {
  @Guide(description: 'The user name', pattern: r'^[a-zA-Z]+$')
  final String name;

  @Guide(description: 'The user age', minimum: 0, maximum: 120)
  final int age;

  MockUser({required this.name, required this.age});

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
      };
}

@GenerateTool(name: 'get_mock_user')
Future<MockUser> getMockUser(String name) async {
  return MockUser(name: name, age: 30);
}
