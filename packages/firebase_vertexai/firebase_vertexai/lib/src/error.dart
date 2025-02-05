// Copyright 2024 Google LLC
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

/// Exception thrown when generating content fails.
///
/// The [message] may explain the cause of the failure.
final class VertexAIException implements Exception {
  /// Constructor
  VertexAIException(this.message);

  /// Message of the exception
  final String message;

  @override
  String toString() => 'VertexAIException: $message';
}

/// Exception thrown when the server rejects the API key.
final class InvalidApiKey implements VertexAIException {
  /// Constructor
  InvalidApiKey(this.message);
  @override
  final String message;

  @override
  String toString() => message;
}

/// Exception thrown when the user location is unsupported.
final class UnsupportedUserLocation implements VertexAIException {
  static const _message = 'User location is not supported for the API use.';
  @override
  String get message => _message;
}

/// Exception thrown when the service API is not enabled.
final class ServiceApiNotEnabled implements VertexAIException {
  // ignore: public_member_api_docs
  ServiceApiNotEnabled(this._projectId);

  final String _projectId;

  @override
  String get message =>
      'The Vertex AI in Firebase SDK requires the Vertex AI in Firebase API '
      '(`firebasevertexai.googleapis.com`) to be enabled in your Firebase project. Enable this API '
      'by visiting the Firebase Console at '
      'https://console.firebase.google.com/project/$_id/genai '
      'and clicking "Get started". If you enabled this API recently, wait a few minutes for the '
      'action to propagate to our systems and then retry.';

  @override
  String toString() => message;

  String get _id {
    return _projectId.replaceAll('projects/', '');
  }
}

/// Exception thrown when the quota is exceeded.
final class QuotaExceeded implements VertexAIException {
  // ignore: public_member_api_docs
  QuotaExceeded(this.message);
  @override
  final String message;

  @override
  String toString() => message;
}

/// Exception thrown when the server failed to generate content.
final class ServerException implements VertexAIException {
  /// Constructor
  ServerException(this.message);
  @override
  final String message;

  @override
  String toString() => message;
}

/// Exception indicating a stale package version or implementation bug.
///
/// This exception indicates a likely problem with the SDK implementation such
/// as an inability to parse a new response format. Resolution paths may include
/// updating to a new version of the SDK, or filing an issue.
final class VertexAISdkException implements Exception {
  /// Constructor
  VertexAISdkException(this.message);

  /// Message of the exception
  final String message;

  @override
  String toString() => '$message\n'
      'This indicates a problem with the Vertex AI in Firebase SDK. '
      'Try updating to the latest version '
      '(https://pub.dev/packages/firebase_vertexai/versions), '
      'or file an issue at '
      'https://github.com/firebase/flutterfire/issues.';
}

/// Exception indicating all images filtered out.
///
/// This exception indicates all images were filtered out because they violated
/// Vertex AI's usage guidelines.
final class ImagenImagesBlockedException implements Exception {
  /// Constructor
  ImagenImagesBlockedException(this.message);

  /// Message of the exception
  final String message;

  @override
  String toString() => message;
}

/// Parse the error json object.
VertexAIException parseError(Object jsonObject) {
  return switch (jsonObject) {
    {
      'message': final String message,
      'details': [{'reason': 'API_KEY_INVALID'}, ...]
    } =>
      InvalidApiKey(message),
    {'message': UnsupportedUserLocation._message} => UnsupportedUserLocation(),
    {'message': final String message} when message.contains('quota') =>
      QuotaExceeded(message),
    {
      'message': final String _,
      'status': 'PERMISSION_DENIED',
      'details': [
        ...,
        {
          'metadata': {
            'service': 'firebasevertexai.googleapis.com',
            'consumer': final String projectId,
          }
        },
      ]
    } =>
      ServiceApiNotEnabled(projectId),
    {'message': final String message} => ServerException(message),
    _ => throw unhandledFormat('server error', jsonObject)
  };
}

/// Throw [VertexAISdkException] for unhandled format.
Exception unhandledFormat(String name, Object? jsonObject) =>
    VertexAISdkException('Unhandled format for $name: $jsonObject');
