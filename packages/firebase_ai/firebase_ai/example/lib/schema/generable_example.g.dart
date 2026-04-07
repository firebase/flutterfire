

// **************************************************************************
// SchemaGenerator
// **************************************************************************

/// Auto-generated schema for MockUser.
const MockUserSchema = AutoSchema<MockUser>(
  schemaMap: const <String, dynamic>{'type': 'OBJECT', 'properties': {'name': {'description': 'The user name', 'type': 'STRING', 'pattern': '^[a-zA-Z]+$'}, 'age': {'description': 'The user age', 'type': 'INTEGER', 'minimum': 0, 'maximum': 120}}},
  fromJson: (json) => MockUser(
  name: json['name'] as String,
  age: json['age'] as int,
),
);

// **************************************************************************
// ToolGenerator
// **************************************************************************

/// Auto-generated tool wrapper for getMockUser.
final getMockUserTool = AutoFunctionDeclaration(
  name: 'get_mock_user',
  description: 'Auto-generated tool for getMockUser',
  parameters: const {'type': 'OBJECT', 'properties': {'name': {'type': 'STRING'}}},
  callable: (args) async {
  // Extract arguments
  final _name = args['name'] as String;
  final result = await getMockUser(_name, );
  return result.toJson(); // Assumes result has toJson
}
,
);
