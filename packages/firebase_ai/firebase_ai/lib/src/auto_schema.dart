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

/// A class that holds the JSON Schema representation and a factory to
/// create a typed object from a JSON map.
///
/// This serves as a bridge between the generated schema and the SDK's
/// type-safe methods for object generation and function calling.
class AutoSchema<T> {
  /// The raw JSON Schema map for the model.
  final Map<String, dynamic> schemaMap;

  /// A function that creates an instance of [T] from a JSON map.
  final T Function(Map<String, dynamic>) fromJson;

  /// Creates an [AutoSchema].
  const AutoSchema({required this.schemaMap, required this.fromJson});
}
