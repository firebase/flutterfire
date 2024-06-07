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

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as google_ai;
// ignore: implementation_imports, tightly coupled packages
import 'package:google_generative_ai/src/vertex_hooks.dart' as google_ai_hooks;

import 'vertex_api.dart';
import 'vertex_content.dart';
import 'vertex_function_calling.dart';
import 'vertex_version.dart';

const _baseUrl = 'firebaseml.googleapis.com';
const _apiVersion = 'v2beta';

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
    Content? systemInstruction,
    ToolConfig? toolConfig,
  }) : _googleAIModel = google_ai_hooks.createModelWithBaseUri(
          model: _normalizeModelName(model),
          apiKey: app.options.apiKey,
          baseUri: _vertexUri(app, location),
          requestHeaders: _firebaseTokens(appCheck, auth),
          safetySettings: safetySettings != null
              ? safetySettings.map((setting) => setting.toGoogleAI()).toList()
              : [],
          generationConfig: generationConfig?.toGoogleAI(),
          systemInstruction: systemInstruction?.toGoogleAI(),
          tools: tools?.map((tool) => tool.toGoogleAI()).toList(),
          toolConfig: toolConfig?.toGoogleAI(),
        );
  final google_ai.GenerativeModel _googleAIModel;

  static const _modelsPrefix = 'models/';
  static String _normalizeModelName(String modelName) =>
      modelName.startsWith(_modelsPrefix)
          ? modelName.substring(_modelsPrefix.length)
          : modelName;

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
          headers['Authorization'] = idToken;
        }
      }
      return headers;
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
      ToolConfig? toolConfig}) async {
    Iterable<google_ai.Content> googlePrompt =
        prompt.map((content) => content.toGoogleAI());
    List<google_ai.SafetySetting> googleSafetySettings = safetySettings != null
        ? safetySettings.map((setting) => setting.toGoogleAI()).toList()
        : [];
    final response = await _googleAIModel.generateContent(googlePrompt,
        safetySettings: googleSafetySettings,
        generationConfig: generationConfig?.toGoogleAI(),
        tools: tools?.map((tool) => tool.toGoogleAI()).toList(),
        toolConfig: toolConfig?.toGoogleAI());
    return response.toVertex();
  }

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
    return _googleAIModel
        .generateContentStream(prompt.map((content) => content.toGoogleAI()),
            safetySettings: safetySettings != null
                ? safetySettings.map((setting) => setting.toGoogleAI()).toList()
                : [],
            generationConfig: generationConfig?.toGoogleAI(),
            tools: tools?.map((tool) => tool.toGoogleAI()).toList(),
            toolConfig: toolConfig?.toGoogleAI())
        .map((r) => r.toVertex());
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
    Iterable<Content> contents, {
    List<SafetySetting>? safetySettings,
    GenerationConfig? generationConfig,
    List<Tool>? tools,
    ToolConfig? toolConfig,
  }) async {
    final parameters = <String, Object?>{
      'contents': contents.map((c) => c.toJson()).toList()
    };
    return _googleAIModel.makeRequest(
        google_ai_hooks.Task.countTokens, parameters, parseCountTokensResponse);
  }

  /// Creates an embedding (list of float values) representing [content].
  ///
  /// Sends a "embedContent" API request for the configured model,
  /// and waits for the response.
  ///
  /// Example:
  /// ```dart
  /// final promptEmbedding =
  ///     (await model.embedContent([Content.text(prompt)])).embedding.values;
  /// ```
  Future<EmbedContentResponse> embedContent(Content content,
      {TaskType? taskType, String? title, int? outputDimensionality}) async {
    return _googleAIModel
        .embedContent(content.toGoogleAI(),
            taskType: taskType?.toGoogleAI(),
            title: title,
            outputDimensionality: outputDimensionality)
        .then((r) => r.toVertex());
  }

  /// Creates embeddings (list of float values) representing each content in
  /// [requests].
  ///
  /// Sends a "batchEmbedContents" API request for the configured model.
  ///
  /// Example:
  /// ```dart
  /// final requests = [
  ///   EmbedContentRequest(Content.text(first)),
  ///   EmbedContentRequest(Content.text(second))
  /// ];
  /// final promptEmbeddings =
  ///     (await model.embedContent(requests)).embedding.values;
  /// ```
  Future<BatchEmbedContentsResponse> batchEmbedContents(
      Iterable<EmbedContentRequest> requests) async {
    return _googleAIModel
        .batchEmbedContents(requests.map((e) => e.toGoogleAI()))
        .then((r) => r.toVertex());
  }
}

/// Conversion utilities for [GenerativeModel].
extension GoogleAIGenerativeModelConversion on GenerativeModel {
  /// Return this model as a [google_ai.GenerativeModel].
  google_ai.GenerativeModel get googleAIModel => _googleAIModel;
}

/// Returns a [GenerativeModel] using it's private constructor.
GenerativeModel createGenerativeModel({
  required FirebaseApp app,
  required String location,
  required String model,
  Content? systemInstruction,
  FirebaseAppCheck? appCheck,
  FirebaseAuth? auth,
  GenerationConfig? generationConfig,
  List<SafetySetting>? safetySettings,
  List<Tool>? tools,
  ToolConfig? toolConfig,
}) =>
    GenerativeModel._(
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
    );
