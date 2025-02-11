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
import 'package:http/http.dart' as http;

import 'api.dart';
import 'base_model.dart';
import 'client.dart';
import 'content.dart';
import 'function_calling.dart';

/// A multimodel generative model (like Gemini).
///
/// Allows generating content, creating embeddings, and counting the number of
/// tokens in a piece of content.
final class GenerativeModel extends BaseModel {
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
  })  : _safetySettings = safetySettings ?? [],
        _generationConfig = generationConfig,
        _tools = tools,
        _toolConfig = toolConfig,
        _systemInstruction = systemInstruction,
        super(
            model: model,
            app: app,
            location: location,
            client: HttpApiClient(
                apiKey: app.options.apiKey,
                httpClient: httpClient,
                requestHeaders: BaseModel.firebaseTokens(appCheck, auth)));

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
  })  : _safetySettings = safetySettings ?? [],
        _generationConfig = generationConfig,
        _tools = tools,
        _toolConfig = toolConfig,
        _systemInstruction = systemInstruction,
        super(
            model: model,
            app: app,
            location: location,
            client: apiClient ??
                HttpApiClient(
                    apiKey: app.options.apiKey,
                    requestHeaders: BaseModel.firebaseTokens(appCheck, auth)));

  final List<SafetySetting> _safetySettings;
  final GenerationConfig? _generationConfig;
  final List<Tool>? _tools;

  //final Uri _baseUri;
  final ToolConfig? _toolConfig;
  final Content? _systemInstruction;

  //static const _modelsPrefix = 'models/';

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
      'model': '${model.prefix}/${model.name}',
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
    final response = client.streamRequest(
        taskUri(Task.streamGenerateContent),
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
