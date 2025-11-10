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
import 'error.dart';
import 'firebaseai_version.dart';
import 'imagen/imagen_api.dart';
import 'imagen/imagen_content.dart';
import 'imagen/imagen_edit.dart';
import 'imagen/imagen_reference.dart';
import 'live_api.dart';
import 'live_session.dart';
import 'tool.dart';

part 'generative_model.dart';
part 'imagen/imagen_model.dart';
part 'live_model.dart';
part 'server_template/template_generative_model.dart';
part 'server_template/template_imagen_model.dart';

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

/// [TemplateTask] enum class for [TemplateGenerativeModel] to make request.
enum TemplateTask {
  /// Request type for server template generate content.
  templateGenerateContent,

  /// Request type for server template stream generate content
  templateStreamGenerateContent,

  /// Request type for server template for Prediction Services like Imagen.
  templatePredict,
}

abstract interface class _ModelUri {
  String get baseAuthority;
  String get apiVersion;
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
  String get apiVersion => _apiVersion;

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
  String get apiVersion => _apiVersion;

  @override
  Uri taskUri(Task task) => _baseUri.replace(
      pathSegments: _baseUri.pathSegments
          .followedBy([model.prefix, '${model.name}:${task.name}']));
}

abstract interface class _TemplateUri {
  String get baseAuthority;
  String get apiVersion;
  Uri templateTaskUri(TemplateTask task, String templateId);
  String templateName(String templateId);
}

final class _TemplateVertexUri implements _TemplateUri {
  _TemplateVertexUri({required String location, required FirebaseApp app})
      : _templateUri = _vertexTemplateUri(app, location),
        _templateName = _vertexTemplateName(app, location);

  static const _baseAuthority = 'firebasevertexai.googleapis.com';
  static const _apiVersion = 'v1beta';

  final Uri _templateUri;
  final String _templateName;

  static Uri _vertexTemplateUri(FirebaseApp app, String location) {
    var projectId = app.options.projectId;
    return Uri.https(
      _baseAuthority,
      '/$_apiVersion/projects/$projectId/locations/$location',
    );
  }

  static String _vertexTemplateName(FirebaseApp app, String location) {
    var projectId = app.options.projectId;
    return 'projects/$projectId/locations/$location';
  }

  @override
  String get baseAuthority => _baseAuthority;

  @override
  String get apiVersion => _apiVersion;

  @override
  Uri templateTaskUri(TemplateTask task, String templateId) {
    return _templateUri.replace(
        pathSegments: _templateUri.pathSegments
            .followedBy(['templates', '$templateId:${task.name}']));
  }

  @override
  String templateName(String templateId) =>
      '$_templateName/templates/$templateId';
}

final class _TemplateGoogleAIUri implements _TemplateUri {
  _TemplateGoogleAIUri({
    required FirebaseApp app,
  })  : _templateUri = _googleAITemplateUri(app: app),
        _templateName = _googleAITemplateName(app: app);

  static const _baseAuthority = 'firebasevertexai.googleapis.com';
  static const _apiVersion = 'v1beta';
  final Uri _templateUri;
  final String _templateName;

  static Uri _googleAITemplateUri(
          {String apiVersion = _apiVersion, required FirebaseApp app}) =>
      Uri.https(
          _baseAuthority, '$apiVersion/projects/${app.options.projectId}');

  static String _googleAITemplateName({required FirebaseApp app}) =>
      'projects/${app.options.projectId}';

  @override
  String get baseAuthority => _baseAuthority;

  @override
  String get apiVersion => _apiVersion;

  @override
  Uri templateTaskUri(TemplateTask task, String templateId) {
    return _templateUri.replace(
        pathSegments: _templateUri.pathSegments
            .followedBy(['templates', '$templateId:${task.name}']));
  }

  @override
  String templateName(String templateId) =>
      '$_templateName/templates/$templateId';
}

/// The base class for all Firebase AI models.
///
/// This class provides the basic functionality for interacting with the
/// Firebase AI API. It is not intended to be instantiated directly.
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
    FirebaseAppCheck? appCheck,
    FirebaseAuth? auth,
    FirebaseApp? app,
    bool? useLimitedUseAppCheckTokens,
  ) {
    return () async {
      Map<String, String> headers = {};
      // Override the client name in Google AI SDK
      headers['x-goog-api-client'] =
          'gl-dart/$packageVersion fire/$packageVersion';
      if (appCheck != null) {
        final appCheckToken = useLimitedUseAppCheckTokens == true
            ? await appCheck.getLimitedUseToken()
            : await appCheck.getToken();
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

/// An abstract base class for models that interact with an API using an
/// [ApiClient].
///
/// This class extends [BaseModel] and provides a convenient way to make API
/// requests using the injected [ApiClient]. It handles the common logic of
/// making requests and parsing the responses.
///
/// Subclasses should define specific API interaction logic and data parsing
/// based on their requirements.
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

/// An abstract base class for models that interact with a template-based API
/// using an [ApiClient].
///
/// This class extends [BaseApiClientModel] and provides functionality for
/// making requests to a template-based API. It handles the common logic of
/// making requests and parsing the responses.
abstract class BaseTemplateApiClientModel extends BaseApiClientModel {
  // ignore: public_member_api_docs
  BaseTemplateApiClientModel(
      {required super.serializationStrategy,
      required super.modelUri,
      required super.client,
      required _TemplateUri templateUri})
      : _templateUri = templateUri;

  final _TemplateUri _templateUri;

  /// Makes a unary request to a template-based API.
  ///
  /// This method sends a request to the API with the given [task], [templateId],
  /// and [inputs]. It returns a [Future] that completes with the parsed
  /// response.
  Future<T> makeTemplateRequest<T>(
      TemplateTask task,
      String templateId,
      Map<String, Object?>? inputs,
      Iterable<Content>? history,
      T Function(Map<String, Object?>) parse) {
    Map<String, Object?> body = {};
    if (inputs != null) {
      body['inputs'] = inputs;
    }
    if (history != null) {
      body['history'] = history.map((c) => c.toJson()).toList();
    }
    return _client
        .makeRequest(templateTaskUri(task, templateId), body)
        .then(parse);
  }

  /// Makes a streaming request to a template-based API.
  ///
  /// This method sends a request to the API with the given [task], [templateId],
  /// and [inputs]. It returns a [Stream] of parsed responses.
  Stream<T> streamTemplateRequest<T>(
      TemplateTask task,
      String templateId,
      Map<String, Object?>? inputs,
      Iterable<Content>? history,
      T Function(Map<String, Object?>) parse) {
    Map<String, Object?> body = {};
    if (inputs != null) {
      body['inputs'] = inputs;
    }
    if (history != null) {
      body['history'] = history.map((c) => c.toJson()).toList();
    }
    final response =
        _client.streamRequest(templateTaskUri(task, templateId), body);
    return response.map(parse);
  }

  /// Returns the URI for the given [task] and [templateId].
  Uri templateTaskUri(TemplateTask task, String templateId) =>
      _templateUri.templateTaskUri(task, templateId);

  /// Returns the template name for the given [templateId].
  String templateName(String templateId) =>
      _templateUri.templateName(templateId);
}
