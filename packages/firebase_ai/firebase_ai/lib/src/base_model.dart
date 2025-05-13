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
import 'dart:convert';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'api.dart';
import 'client.dart';
import 'content.dart';
import 'developer/api.dart';
import 'function_calling.dart';
import 'imagen_api.dart';
import 'imagen_content.dart';
import 'live_api.dart';
import 'live_session.dart';
import 'vertex_version.dart';

part 'generative_model.dart';
part 'imagen_model.dart';
part 'live_model.dart';

/// [Task] enum class for [GenerativeModel] to make request.
enum Task {
  /// Request type to generate content.
  generateContent,

  /// Request type to stream content.
  streamGenerateContent,

  /// Request type to count token.
  countTokens,

  /// Request type to talk to Prediction Services like Imagen.
  predict,
}

abstract interface class _ModelUri {
  String get baseAuthority;
  Uri taskUri(Task task);
  ({String prefix, String name}) get model;
}

final class _VertexUri implements _ModelUri {
  _VertexUri(
      {required String model,
      required String location,
      required FirebaseApp app})
      : model = _normalizeModelName(model),
        _projectUri = _vertexUri(app, location);

  static const _baseAuthority = 'firebasevertexai.googleapis.com';
  static const _apiVersion = 'v1beta';

  /// Returns the model code for a user friendly model name.
  ///
  /// If the model name is already a model code (contains a `/`), use the parts
  /// directly. Otherwise, return a `models/` model code.
  static ({String prefix, String name}) _normalizeModelName(String modelName) {
    if (!modelName.contains('/')) return (prefix: 'models', name: modelName);
    final parts = modelName.split('/');
    return (prefix: parts.first, name: parts.skip(1).join('/'));
  }

  static Uri _vertexUri(FirebaseApp app, String location) {
    var projectId = app.options.projectId;
    return Uri.https(
      _baseAuthority,
      '/$_apiVersion/projects/$projectId/locations/$location/publishers/google',
    );
  }

  final Uri _projectUri;
  @override
  final ({String prefix, String name}) model;

  @override
  String get baseAuthority => _baseAuthority;

  @override
  Uri taskUri(Task task) {
    return _projectUri.replace(
        pathSegments: _projectUri.pathSegments
            .followedBy([model.prefix, '${model.name}:${task.name}']));
  }
}

final class _GoogleAIUri implements _ModelUri {
  _GoogleAIUri({
    required String model,
    required FirebaseApp app,
  })  : model = _normalizeModelName(model),
        _baseUri = _googleAIBaseUri(app: app);

  /// Returns the model code for a user friendly model name.
  ///
  /// If the model name is already a model code (contains a `/`), use the parts
  /// directly. Otherwise, return a `models/` model code.
  static ({String prefix, String name}) _normalizeModelName(String modelName) {
    if (!modelName.contains('/')) return (prefix: 'models', name: modelName);
    final parts = modelName.split('/');
    return (prefix: parts.first, name: parts.skip(1).join('/'));
  }

  static const _apiVersion = 'v1beta';
  static const _baseAuthority = 'firebasevertexai.googleapis.com';
  static Uri _googleAIBaseUri(
          {String apiVersion = _apiVersion, required FirebaseApp app}) =>
      Uri.https(
          _baseAuthority, '$apiVersion/projects/${app.options.projectId}');
  final Uri _baseUri;

  @override
  final ({String prefix, String name}) model;

  @override
  String get baseAuthority => _baseAuthority;

  @override
  Uri taskUri(Task task) => _baseUri.replace(
      pathSegments: _baseUri.pathSegments
          .followedBy([model.prefix, '${model.name}:${task.name}']));
}

/// Base class for models.
///
/// Do not instantiate directly.
abstract class BaseModel {
  BaseModel._(
      {required SerializationStrategy serializationStrategy,
      required _ModelUri modelUri})
      : _serializationStrategy = serializationStrategy,
        _modelUri = modelUri;

  final SerializationStrategy _serializationStrategy;
  final _ModelUri _modelUri;

  /// The normalized model name.
  ({String prefix, String name}) get model => _modelUri.model;

  /// Returns a function that generates Firebase auth tokens.
  static FutureOr<Map<String, String>> Function() firebaseTokens(
      FirebaseAppCheck? appCheck, FirebaseAuth? auth, FirebaseApp? app) {
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
      if (app != null && app.isAutomaticDataCollectionEnabled) {
        headers['X-Firebase-AppId'] = app.options.appId;
      }
      return headers;
    };
  }

  /// Returns a URI for the given [task].
  Uri taskUri(Task task) => _modelUri.taskUri(task);
}

/// An abstract base class for models that interact with an API using an [ApiClient].
///
/// This class extends [BaseModel] and provides a convenient way to make API requests
/// using the injected [ApiClient]. It handles the common logic of making requests
/// and parsing the responses.
///
/// Subclasses should define specific API interaction logic and data parsing based on
/// their requirements.
abstract class BaseApiClientModel extends BaseModel {
  // ignore: public_member_api_docs
  BaseApiClientModel({
    required super.serializationStrategy,
    required super.modelUri,
    required ApiClient client,
  })  : _client = client,
        super._();

  final ApiClient _client;

  /// The API client.
  ApiClient get client => _client;

  /// Make a unary request for [task] with JSON encodable [params].
  Future<T> makeRequest<T>(Task task, Map<String, Object?> params,
          T Function(Map<String, Object?>) parse) =>
      _client.makeRequest(taskUri(task), params).then(parse);
}
