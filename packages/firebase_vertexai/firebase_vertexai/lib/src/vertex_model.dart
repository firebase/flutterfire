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

part of firebase_vertexai;

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
    List<SafetySetting>? safetySettings,
    GenerationConfig? generationConfig,
    List<Tool>? tools,
    Content? systemInstruction,
    ToolConfig? toolConfig,
  })  : _firebaseApp = app,
        _googleAIModel = createModelWithBaseUri(
          model: _normalizeModelName(model),
          apiKey: app.options.apiKey,
          baseUri: _vertexUri(app, location),
          requestHeaders: _appCheckToken(appCheck),
          safetySettings: safetySettings != null
              ? safetySettings
                  .map((setting) => setting._toGoogleAISafetySetting())
                  .toList()
              : [],
          generationConfig: generationConfig?._toGoogleAIGenerationConfig(),
          systemInstruction: systemInstruction?._toGoogleAIContent(),
          tools: tools != null
              ? tools.map((tool) => tool._toGoogleAITool()).toList()
              : [],
          toolConfig: toolConfig?._toGoogleAIToolConfig(),
        );
  final FirebaseApp _firebaseApp;
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

  static google_ai.GenerationConfig _convertGenerationConfig(
      GenerationConfig? config, FirebaseApp app) {
    if (config == null) {
      return google_ai.GenerationConfig();
    } else {
      return config._toGoogleAIGenerationConfig();
    }
  }

  static FutureOr<Map<String, String>> Function() _appCheckToken(
      FirebaseAppCheck? appCheck) {
    return () async {
      Map<String, String> headers = {};
      // Override the client name in Google AI SDK
      headers['x-goog-api-client'] = 'gl-dart/flutter fire/$packageVersion';
      if (appCheck != null) {
        final token = await appCheck.getToken();
        if (token != null) {
          headers['X-Firebase-AppCheck'] = token;
        }
      }
      return headers;
    };
  }

  static google_ai.GenerationConfig? _googleAIGenerationConfig(
      GenerationConfig? config) {
    return config?._toGoogleAIGenerationConfig();
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
      GenerationConfig? generationConfig}) async {
    Iterable<google_ai.Content> googlePrompt =
        prompt.map((content) => content._toGoogleAIContent());
    List<google_ai.SafetySetting> googleSafetySettings = safetySettings != null
        ? safetySettings
            .map((setting) => setting._toGoogleAISafetySetting())
            .toList()
        : [];
    return _googleAIModel
        .generateContent(googlePrompt,
            safetySettings: googleSafetySettings,
            generationConfig:
                _convertGenerationConfig(generationConfig, _firebaseApp))
        .then(GenerateContentResponse._fromGoogleAIGenerateContentResponse);
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
      GenerationConfig? generationConfig}) {
    return _googleAIModel
        .generateContentStream(
            prompt.map((content) => content._toGoogleAIContent()),
            safetySettings: safetySettings != null
                ? safetySettings
                    .map((setting) => setting._toGoogleAISafetySetting())
                    .toList()
                : [],
            generationConfig: generationConfig?._toGoogleAIGenerationConfig())
        .map(GenerateContentResponse._fromGoogleAIGenerateContentResponse);
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
  Future<CountTokensResponse> countTokens(Iterable<Content> contents) async {
    return _googleAIModel
        .countTokens(contents.map((e) => e._toGoogleAIContent()))
        .then(CountTokensResponse._fromGoogleAICountTokensResponse);
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
      {TaskType? taskType, String? title}) async {
    return _googleAIModel
        .embedContent(content._toGoogleAIContent(),
            taskType: taskType?._toGoogleAITaskType(), title: title)
        .then(EmbedContentResponse._fromGoogleAIEmbedContentResponse);
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
        .batchEmbedContents(
            requests.map((e) => e._toGoogleAIEmbedContentRequest()))
        .then(
            BatchEmbedContentsResponse._fromGoogleAIBatchEmbedContentsResponse);
  }
}
