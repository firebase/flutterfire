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

// ignore_for_file: use_late_for_private_fields_and_variables

import 'dart:async';
import 'dart:convert';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'api.dart';
import 'client.dart';
import 'content.dart';
import 'function_calling.dart';
import 'vertex_version.dart';
import 'live.dart';
import 'live_api.dart';

const _baseUrl = 'firebasevertexai.googleapis.com';
const _apiVersion = 'v1beta';

const _baseDailyUrl = 'daily-firebaseml.sandbox.googleapis.com';
const _apiUrl =
    'ws/google.firebase.machinelearning.v2beta.LlmBidiService/BidiGenerateContent?key=';
const _baseGAIUrl = 'generativelanguage.googleapis.com';
const _apiGAIUrl =
    'ws/google.ai.generativelanguage.v1alpha.GenerativeService.BidiGenerateContent?key=';

const _bidiGoogleAI = true;

/// [Task] enum class for [GenerativeModel] to make request.
enum Task {
  /// Request type to generate content.
  generateContent,

  /// Request type to stream content.
  streamGenerateContent,

  /// Request type to count token.
  countTokens,

  /// Request type to embed content.
  embedContent,

  /// Request type to batch embed content.
  batchEmbedContents;
}

/// A multimodel generative model (like Gemini).
///
/// Allows generating content, creating embeddings, and counting the number of
/// tokens in a piece of content.
final class GenerativeModel {
  /// Create a [GenerativeModel] backed by the generative model named [model].
  ///
  /// The [model] argument can be a model name (such as `'gemini-pro'`) or a
  /// model code (such as `'models/gemini-pro'`).
  /// There is no creation time check for whether the `model` string identifies
  /// a known and supported model. If not, attempts to generate content
  /// will fail.
  ///
  /// The optional [safetySettings] and [generationConfig] can be used to
  /// control and guide the generation. See [SafetySetting] and
  /// [GenerationConfig] for details.
  ///
  GenerativeModel._({
    required String model,
    required String location,
    required FirebaseApp app,
    FirebaseAppCheck? appCheck,
    FirebaseAuth? auth,
    List<SafetySetting>? safetySettings,
    GenerationConfig? generationConfig,
    List<Tool>? tools,
    ToolConfig? toolConfig,
    Content? systemInstruction,
    http.Client? httpClient,
  })  : _model = _normalizeModelName(model),
        _baseUri = _vertexUri(app, location),
        _app = app,
        _location = location,
        _safetySettings = safetySettings ?? [],
        _generationConfig = generationConfig,
        _tools = tools,
        _toolConfig = toolConfig,
        _systemInstruction = systemInstruction,
        _client = HttpApiClient(
            apiKey: app.options.apiKey,
            httpClient: httpClient,
            requestHeaders: _firebaseTokens(appCheck, auth));

  GenerativeModel._constructTestModel({
    required String model,
    required String location,
    required FirebaseApp app,
    FirebaseAppCheck? appCheck,
    FirebaseAuth? auth,
    List<SafetySetting>? safetySettings,
    GenerationConfig? generationConfig,
    List<Tool>? tools,
    ToolConfig? toolConfig,
    Content? systemInstruction,
    ApiClient? apiClient,
  })  : _model = _normalizeModelName(model),
        _baseUri = _vertexUri(app, location),
        _app = app,
        _location = location,
        _safetySettings = safetySettings ?? [],
        _generationConfig = generationConfig,
        _tools = tools,
        _toolConfig = toolConfig,
        _systemInstruction = systemInstruction,
        _client = apiClient ??
            HttpApiClient(
                apiKey: app.options.apiKey,
                requestHeaders: _firebaseTokens(appCheck, auth));

  final ({String prefix, String name}) _model;
  final List<SafetySetting> _safetySettings;
  final GenerationConfig? _generationConfig;
  final List<Tool>? _tools;
  final ApiClient _client;
  final Uri _baseUri;
  final ToolConfig? _toolConfig;
  final Content? _systemInstruction;
  final FirebaseApp _app;
  final String _location;

  //static const _modelsPrefix = 'models/';

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
      _baseUrl,
      '/$_apiVersion/projects/$projectId/locations/$location/publishers/google',
    );
  }

  static FutureOr<Map<String, String>> Function() _firebaseTokens(
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

  Uri _taskUri(Task task) => _baseUri.replace(
      pathSegments: _baseUri.pathSegments
          .followedBy([_model.prefix, '${_model.name}:${task.name}']));

  /// Make a unary request for [task] with JSON encodable [params].
  Future<T> makeRequest<T>(Task task, Map<String, Object?> params,
          T Function(Map<String, Object?>) parse) =>
      _client.makeRequest(_taskUri(task), params).then(parse);

  Map<String, Object?> _generateContentRequest(
    Iterable<Content> contents, {
    List<SafetySetting>? safetySettings,
    GenerationConfig? generationConfig,
    List<Tool>? tools,
    ToolConfig? toolConfig,
  }) {
    safetySettings ??= _safetySettings;
    generationConfig ??= _generationConfig;
    tools ??= _tools;
    toolConfig ??= _toolConfig;
    return {
      'model': '${_model.prefix}/${_model.name}',
      'contents': contents.map((c) => c.toJson()).toList(),
      if (safetySettings.isNotEmpty)
        'safetySettings': safetySettings.map((s) => s.toJson()).toList(),
      if (generationConfig != null)
        'generationConfig': generationConfig.toJson(),
      if (tools != null) 'tools': tools.map((t) => t.toJson()).toList(),
      if (toolConfig != null) 'toolConfig': toolConfig.toJson(),
      if (_systemInstruction case final systemInstruction?)
        'systemInstruction': systemInstruction.toJson(),
    };
  }

  /// Generates content responding to [prompt].
  ///
  /// Sends a "generateContent" API request for the configured model,
  /// and waits for the response.
  ///
  /// Example:
  /// ```dart
  /// final response = await model.generateContent([Content.text(prompt)]);
  /// print(response.text);
  /// ```
  Future<GenerateContentResponse> generateContent(Iterable<Content> prompt,
          {List<SafetySetting>? safetySettings,
          GenerationConfig? generationConfig,
          List<Tool>? tools,
          ToolConfig? toolConfig}) =>
      makeRequest(
          Task.generateContent,
          _generateContentRequest(
            prompt,
            safetySettings: safetySettings,
            generationConfig: generationConfig,
            tools: tools,
            toolConfig: toolConfig,
          ),
          parseGenerateContentResponse);

  /// Generates a stream of content responding to [prompt].
  ///
  /// Sends a "streamGenerateContent" API request for the configured model,
  /// and waits for the response.
  ///
  /// Example:
  /// ```dart
  /// final responses = await model.generateContent([Content.text(prompt)]);
  /// await for (final response in responses) {
  ///   print(response.text);
  /// }
  /// ```
  Stream<GenerateContentResponse> generateContentStream(
      Iterable<Content> prompt,
      {List<SafetySetting>? safetySettings,
      GenerationConfig? generationConfig,
      List<Tool>? tools,
      ToolConfig? toolConfig}) {
    final response = _client.streamRequest(
        _taskUri(Task.streamGenerateContent),
        _generateContentRequest(
          prompt,
          safetySettings: safetySettings,
          generationConfig: generationConfig,
          tools: tools,
          toolConfig: toolConfig,
        ));
    return response.map(parseGenerateContentResponse);
  }

  /// Counts the total number of tokens in [contents].
  ///
  /// Sends a "countTokens" API request for the configured model,
  /// and waits for the response.
  ///
  /// Example:
  /// ```dart
  /// final promptContent = [Content.text(prompt)];
  /// final totalTokens =
  ///     (await model.countTokens(promptContent)).totalTokens;
  /// if (totalTokens > maxPromptSize) {
  ///   print('Prompt is too long!');
  /// } else {
  ///   final response = await model.generateContent(promptContent);
  ///   print(response.text);
  /// }
  /// ```
  Future<CountTokensResponse> countTokens(
    Iterable<Content> contents,
  ) async {
    final parameters = <String, Object?>{
      'contents': contents.map((c) => c.toJson()).toList()
    };
    return makeRequest(Task.countTokens, parameters, parseCountTokensResponse);
  }

  Future<AsyncSession> connect({
    required String model,
    LiveGenerationConfig? config,
  }) async {
    late String uri;
    late String modelString;
    if (_bidiGoogleAI) {
      uri = 'wss://$_baseGAIUrl/$_apiGAIUrl${_app.options.apiKey}';
      modelString = 'models/$model';
    } else {
      uri = 'wss://$_baseDailyUrl/$_apiUrl${_app.options.apiKey}';
      modelString =
          'projects/${_app.options.projectId}/locations/$_location/publishers/google/models/$model';
    }

    final requestJson = {
      'setup': {
        'model': modelString,
        if (config != null) 'generation_config': config.toJson()
      }
    };

    final request = jsonEncode(requestJson);
    var ws = WebSocketChannel.connect(Uri.parse(uri));
    await ws.ready;
    print(uri);
    print(request);

    ws.sink.add(request);
    return AsyncSession(ws: ws);
  }
}

/// Returns a [GenerativeModel] using it's private constructor.
GenerativeModel createGenerativeModel({
  required FirebaseApp app,
  required String location,
  required String model,
  FirebaseAppCheck? appCheck,
  FirebaseAuth? auth,
  GenerationConfig? generationConfig,
  List<SafetySetting>? safetySettings,
  List<Tool>? tools,
  ToolConfig? toolConfig,
  Content? systemInstruction,
}) =>
    GenerativeModel._(
      model: model,
      app: app,
      appCheck: appCheck,
      auth: auth,
      location: location,
      safetySettings: safetySettings,
      generationConfig: generationConfig,
      tools: tools,
      toolConfig: toolConfig,
      systemInstruction: systemInstruction,
    );

/// Creates a model with an overridden [ApiClient] for testing.
///
/// Package private test-only method.
GenerativeModel createModelWithClient({
  required FirebaseApp app,
  required String location,
  required String model,
  required ApiClient client,
  Content? systemInstruction,
  FirebaseAppCheck? appCheck,
  FirebaseAuth? auth,
  GenerationConfig? generationConfig,
  List<SafetySetting>? safetySettings,
  List<Tool>? tools,
  ToolConfig? toolConfig,
}) =>
    GenerativeModel._constructTestModel(
        model: model,
        app: app,
        appCheck: appCheck,
        auth: auth,
        location: location,
        safetySettings: safetySettings,
        generationConfig: generationConfig,
        systemInstruction: systemInstruction,
        tools: tools,
        toolConfig: toolConfig,
        apiClient: client);
