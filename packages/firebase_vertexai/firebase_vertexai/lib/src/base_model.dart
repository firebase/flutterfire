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
import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'client.dart';
import 'vertex_version.dart';

/// [Task] enum class for [GenerativeModel] to make request.
enum Task {
  /// Request type to generate content.
  generateContent,

  /// Request type to stream content.
  streamGenerateContent,

  /// Request type to count token.
  countTokens,

  /// Imagen 3 task
  predict,
}

abstract class BaseModel {
  BaseModel({
    required String model,
    required String location,
    required FirebaseApp app,
    required ApiClient client,
  })  : _model = normalizeModelName(model),
        _projectUri = _vertexUri(app, location),
        _client = client;

  static const _baseUrl = 'firebasevertexai.googleapis.com';
  static const _apiVersion = 'v1beta';

  final ({String prefix, String name}) _model;

  final Uri _projectUri;
  final ApiClient _client;

  ({String prefix, String name}) get model => _model;
  ApiClient get client => _client;

  /// Returns the model code for a user friendly model name.
  ///
  /// If the model name is already a model code (contains a `/`), use the parts
  /// directly. Otherwise, return a `models/` model code.
  static ({String prefix, String name}) normalizeModelName(String modelName) {
    if (!modelName.contains('/')) return (prefix: 'models', name: modelName);
    final parts = modelName.split('/');
    return (prefix: parts.first, name: parts.skip(1).join('/'));
  }

  static Uri _vertexUri(FirebaseApp app, String location) {
    var projectId = app.options.projectId;
    return Uri.https(
      _baseUrl,
      '/$_apiVersion/projects/$projectId/locations/$location/publishers/google',
    );
  }

  static FutureOr<Map<String, String>> Function() firebaseTokens(
      FirebaseAppCheck? appCheck, FirebaseAuth? auth) {
    return () async {
      Map<String, String> headers = {};
      // Override the client name in Google AI SDK
      headers['x-goog-api-client'] =
          'gl-dart/$packageVersion fire/$packageVersion';
      if (appCheck != null) {
        final appCheckToken = await appCheck.getToken();
        if (appCheckToken != null) {
          headers['X-Firebase-AppCheck'] = appCheckToken;
        }
      }
      if (auth != null) {
        final idToken = await auth.currentUser?.getIdToken();
        if (idToken != null) {
          headers['Authorization'] = 'Firebase $idToken';
        }
      }
      return headers;
    };
  }

  Uri taskUri(Task task) => _projectUri.replace(
      pathSegments: _projectUri.pathSegments
          .followedBy([_model.prefix, '${_model.name}:${task.name}']));

  /// Make a unary request for [task] with JSON encodable [params].
  Future<T> makeRequest<T>(Task task, Map<String, Object?> params,
          T Function(Map<String, Object?>) parse) =>
      _client.makeRequest(taskUri(task), params).then(parse);
}
