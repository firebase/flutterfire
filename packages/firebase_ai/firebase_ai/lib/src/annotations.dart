// Copyright 2026 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/// Annotation for classes that can be used to generate a JSON Schema.
class Generable {
  /// A brief description of the generated object.
  final String? description;

  /// Creates a [Generable] annotation.
  const Generable({this.description});
}

/// Annotation for fields to provide constraints and documentation for the schema.
class Guide {
  /// Description of the field.
  final String? description;

  /// Minimum value for numeric fields.
  final num? minimum;

  /// Maximum value for numeric fields.
  final num? maximum;

  /// Regular expression pattern for string fields.
  final String? pattern;

  /// Creates a [Guide] annotation.
  const Guide({this.description, this.minimum, this.maximum, this.pattern});
}

/// Annotation for functions that can be used as tools by the model.
class GenerateTool {
  /// The name of the tool. If omitted, the function name is used.
  final String? name;

  /// Creates a [GenerateTool] annotation.
  const GenerateTool({this.name});
}
