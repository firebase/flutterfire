// Copyright 2025 Google LLC
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

/// Configuration parameters for sending requests to the backend.
final class RequestOptions {
  /// Constructor
  RequestOptions({this.apiVersion});

  /// The API version to use in requests to the backend.
  final ApiVersion? apiVersion;
}

/// API versions for the Vertex AI in Firebase endpoint.
enum ApiVersion {
  /// The stable channel for version 1 of the API.
  v1('v1'),

  /// The beta channel for version 1 of the API.
  v1beta('v1beta');

  const ApiVersion(this.versionIdentifier);

  /// The identifier for the API version.
  final String versionIdentifier;

  @override
  String toString() => name;
}
