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
part of 'base_model.dart';

/// A multimodel generative model (like Gemini).
///
/// Allows generating content and counting the number of
/// tokens in a piece of content.
final class GenerativeModel extends BaseApiClientModel {
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
    required bool useVertexBackend,
    bool? useLimitedUseAppCheckTokens,
    FirebaseAppCheck? appCheck,
    FirebaseAuth? auth,
    List<SafetySetting>? safetySettings,
    GenerationConfig? generationConfig,
    this.tools,
    ToolConfig? toolConfig,
    Content? systemInstruction,
    http.Client? httpClient,
    HybridConfig? hybridConfig,
  })  : _safetySettings = safetySettings ?? [],
        _generationConfig = generationConfig,
        _toolConfig = toolConfig,
        _systemInstruction = systemInstruction,
        _hybridConfig = hybridConfig,
        _preference =
            hybridConfig?.initialPreference ?? HybridPreference.onlyCloud,
        super(
            serializationStrategy: useVertexBackend
                ? VertexSerialization()
                : DeveloperSerialization(),
            modelUri: useVertexBackend
                ? _VertexUri(app: app, model: model, location: location)
                : _GoogleAIUri(app: app, model: model),
            client: HttpApiClient(
                apiKey: app.options.apiKey,
                httpClient: httpClient,
                requestHeaders: BaseModel.firebaseTokens(
                    appCheck, auth, app, useLimitedUseAppCheckTokens))) {
    if (hybridConfig != null) {
      _localRunner = LocalModelRunner(hybridConfig.localConfig);
    }
  }

  GenerativeModel._constructTestModel({
    required String model,
    required String location,
    required FirebaseApp app,
    required useVertexBackend,
    bool? useLimitedUseAppCheckTokens,
    FirebaseAppCheck? appCheck,
    FirebaseAuth? auth,
    List<SafetySetting>? safetySettings,
    GenerationConfig? generationConfig,
    this.tools,
    ToolConfig? toolConfig,
    Content? systemInstruction,
    ApiClient? apiClient,
    HybridConfig? hybridConfig,
  })  : _safetySettings = safetySettings ?? [],
        _generationConfig = generationConfig,
        _toolConfig = toolConfig,
        _systemInstruction = systemInstruction,
        _hybridConfig = hybridConfig,
        _preference =
            hybridConfig?.initialPreference ?? HybridPreference.onlyCloud,
        super(
            serializationStrategy: useVertexBackend
                ? VertexSerialization()
                : DeveloperSerialization(),
            modelUri: useVertexBackend
                ? _VertexUri(app: app, model: model, location: location)
                : _GoogleAIUri(app: app, model: model),
            client: apiClient ??
                HttpApiClient(
                    apiKey: app.options.apiKey,
                    requestHeaders: BaseModel.firebaseTokens(
                        appCheck, auth, app, useLimitedUseAppCheckTokens))) {
    if (hybridConfig != null) {
      _localRunner = LocalModelRunner(hybridConfig.localConfig);
    }
  }

  final List<SafetySetting> _safetySettings;
  final GenerationConfig? _generationConfig;

  /// List of [Tool] registered in the model
  final List<Tool>? tools;

  final ToolConfig? _toolConfig;
  final Content? _systemInstruction;

  // Hybrid Fields
  final HybridConfig? _hybridConfig;
  HybridPreference _preference;
  LocalModelRunner? _localRunner;

  /// Test-only setter to allow mocking the local runner.
  @visibleForTesting
  // ignore: avoid_setters_without_getters
  set localRunner(LocalModelRunner? runner) {
    _localRunner = runner;
  }

  /// Get the current hybrid preference policy.
  HybridPreference get preference => _preference;

  /// Update the hybrid preference policy at runtime.
  Future<void> setPreference(HybridPreference preference) async {
    if (_hybridConfig == null && preference != HybridPreference.onlyCloud) {
      throw StateError(
        'Cannot set preference to $preference because hybridConfig was not '
        'provided during model initialization.',
      );
    }
    _preference = preference;
    if (preference == HybridPreference.onlyLocal) {
      await _localRunner!.initialize();
    } else if (preference == HybridPreference.preferLocal) {
      if (await isLocalModelInstalled()) {
        await _localRunner!.initialize();
      }
    }
  }

  /// Checks if the local on-device model is installed and ready.
  Future<bool> isLocalModelInstalled() async {
    if (_localRunner == null) return false;
    return _localRunner!.isInstalled();
  }

  /// Initiates the download of the on-device local model.
  Future<void> downloadLocalModel(
      {void Function(int progress)? onProgress}) async {
    if (_localRunner == null) {
      throw StateError(
          'Cannot download local model: hybridConfig was not provided during model initialization.');
    }
    await _localRunner!.download(onProgress: onProgress);
  }

  /// Generates content responding to [prompt], automatically routing to
  /// either Cloud or Local based on preference policies.
  Future<GenerateContentResponse> generateContent(Iterable<Content> prompt,
      {List<SafetySetting>? safetySettings,
      GenerationConfig? generationConfig,
      List<Tool>? tools,
      ToolConfig? toolConfig}) async {
    if (_hybridConfig == null) {
      return _generateContentCloud(
        prompt,
        safetySettings: safetySettings,
        generationConfig: generationConfig,
        tools: tools,
        toolConfig: toolConfig,
      );
    }
    final runLocal = await _shouldRunLocal();
    if (runLocal) {
      try {
        await _localRunner!.initialize();
        return await _localRunner!.generateContent(
          prompt,
          tools: tools ?? this.tools,
          toolConfig: toolConfig ?? _toolConfig,
          systemInstruction: _systemInstruction,
        );
      } catch (e) {
        if (_preference == HybridPreference.preferLocal) {
          debugPrint(
              'LocalModelRunner: On-device generation failed ($e). Falling back to Cloud backend...');
          return _generateContentCloud(
            prompt,
            safetySettings: safetySettings,
            generationConfig: generationConfig,
            tools: tools,
            toolConfig: toolConfig,
          );
        }
        rethrow;
      }
    } else {
      try {
        return await _generateContentCloud(
          prompt,
          safetySettings: safetySettings,
          generationConfig: generationConfig,
          tools: tools,
          toolConfig: toolConfig,
        );
      } catch (e) {
        if (_preference == HybridPreference.preferCloud &&
            await isLocalModelInstalled()) {
          debugPrint(
              'LocalModelRunner: Cloud generation failed ($e). Falling back to local on-device backend...');
          await _localRunner!.initialize();
          return _localRunner!.generateContent(
            prompt,
            tools: tools ?? this.tools,
            toolConfig: toolConfig ?? _toolConfig,
            systemInstruction: _systemInstruction,
          );
        }
        rethrow;
      }
    }
  }

  /// Generates a stream of content responding to [prompt].
  Stream<GenerateContentResponse> generateContentStream(
      Iterable<Content> prompt,
      {List<SafetySetting>? safetySettings,
      GenerationConfig? generationConfig,
      List<Tool>? tools,
      ToolConfig? toolConfig}) {
    if (_hybridConfig == null) {
      return _generateContentStreamCloud(
        prompt,
        safetySettings: safetySettings,
        generationConfig: generationConfig,
        tools: tools,
        toolConfig: toolConfig,
      );
    }
    return _generateContentStreamHybrid(
      prompt,
      safetySettings: safetySettings,
      generationConfig: generationConfig,
      tools: tools,
      toolConfig: toolConfig,
    );
  }

  Stream<GenerateContentResponse> _generateContentStreamHybrid(
      Iterable<Content> prompt,
      {List<SafetySetting>? safetySettings,
      GenerationConfig? generationConfig,
      List<Tool>? tools,
      ToolConfig? toolConfig}) async* {
    final runLocal = await _shouldRunLocal();
    if (runLocal) {
      try {
        await _localRunner!.initialize();
        await for (final response in _localRunner!.generateContentStream(
          prompt,
          tools: tools ?? this.tools,
          toolConfig: toolConfig ?? _toolConfig,
          systemInstruction: _systemInstruction,
        )) {
          yield response;
        }
      } catch (e) {
        if (_preference == HybridPreference.preferLocal) {
          debugPrint(
              'LocalModelRunner: On-device stream failed ($e). Falling back to Cloud backend...');
          yield* _generateContentStreamCloud(
            prompt,
            safetySettings: safetySettings,
            generationConfig: generationConfig,
            tools: tools,
            toolConfig: toolConfig,
          );
        } else {
          rethrow;
        }
      }
    } else {
      try {
        await for (final response in _generateContentStreamCloud(
          prompt,
          safetySettings: safetySettings,
          generationConfig: generationConfig,
          tools: tools,
          toolConfig: toolConfig,
        )) {
          yield response;
        }
      } catch (e) {
        if (_preference == HybridPreference.preferCloud &&
            await isLocalModelInstalled()) {
          debugPrint(
              'LocalModelRunner: Cloud stream failed ($e). Falling back to local on-device backend...');
          await _localRunner!.initialize();
          yield* _localRunner!.generateContentStream(
            prompt,
            tools: tools ?? this.tools,
            toolConfig: toolConfig ?? _toolConfig,
            systemInstruction: _systemInstruction,
          );
        } else {
          rethrow;
        }
      }
    }
  }

  /// Counts the total number of tokens in [contents].
  Future<CountTokensResponse> countTokens(
    Iterable<Content> contents,
  ) async {
    if (_hybridConfig == null) {
      return _countTokensCloud(contents);
    }
    final runLocal = await _shouldRunLocal();
    if (runLocal) {
      try {
        await _localRunner!.initialize();
        return await _localRunner!.countTokens(contents);
      } catch (e) {
        if (_preference == HybridPreference.preferLocal) {
          return _countTokensCloud(contents);
        }
        rethrow;
      }
    } else {
      try {
        return await _countTokensCloud(contents);
      } catch (e) {
        if (_preference == HybridPreference.preferCloud &&
            await isLocalModelInstalled()) {
          await _localRunner!.initialize();
          return _localRunner!.countTokens(contents);
        }
        rethrow;
      }
    }
  }

  // === Private Fallback Helpers ===

  Future<bool> _shouldRunLocal() async {
    if (_preference == HybridPreference.onlyLocal) return true;
    if (_preference == HybridPreference.onlyCloud) return false;
    if (_preference == HybridPreference.preferLocal) {
      return isLocalModelInstalled();
    }
    return false; // preferCloud defaults to cloud first
  }

  Future<GenerateContentResponse> _generateContentCloud(
    Iterable<Content> prompt, {
    List<SafetySetting>? safetySettings,
    GenerationConfig? generationConfig,
    List<Tool>? tools,
    ToolConfig? toolConfig,
  }) {
    return makeRequest(
        Task.generateContent,
        _serializationStrategy.generateContentRequest(
          prompt,
          model,
          safetySettings ?? _safetySettings,
          generationConfig ?? _generationConfig,
          tools ?? this.tools,
          toolConfig ?? _toolConfig,
          _systemInstruction,
        ),
        _serializationStrategy.parseGenerateContentResponse);
  }

  Stream<GenerateContentResponse> _generateContentStreamCloud(
    Iterable<Content> prompt, {
    List<SafetySetting>? safetySettings,
    GenerationConfig? generationConfig,
    List<Tool>? tools,
    ToolConfig? toolConfig,
  }) {
    final response = client.streamRequest(
        taskUri(Task.streamGenerateContent),
        _serializationStrategy.generateContentRequest(
          prompt,
          model,
          safetySettings ?? _safetySettings,
          generationConfig ?? _generationConfig,
          tools ?? this.tools,
          toolConfig ?? _toolConfig,
          _systemInstruction,
        ));
    return response.map(_serializationStrategy.parseGenerateContentResponse);
  }

  Future<CountTokensResponse> _countTokensCloud(
      Iterable<Content> contents) async {
    final parameters = _serializationStrategy.countTokensRequest(
      contents,
      model,
      _safetySettings,
      _generationConfig,
      tools,
      _toolConfig,
    );
    return makeRequest(Task.countTokens, parameters,
        _serializationStrategy.parseCountTokensResponse);
  }
}

/// Returns a [GenerativeModel] using it's private constructor.
GenerativeModel createGenerativeModel({
  required FirebaseApp app,
  required String location,
  required String model,
  required bool useVertexBackend,
  bool? useLimitedUseAppCheckTokens,
  FirebaseAppCheck? appCheck,
  FirebaseAuth? auth,
  GenerationConfig? generationConfig,
  List<SafetySetting>? safetySettings,
  List<Tool>? tools,
  ToolConfig? toolConfig,
  Content? systemInstruction,
  HybridConfig? hybridConfig,
}) =>
    GenerativeModel._(
      model: model,
      app: app,
      appCheck: appCheck,
      useVertexBackend: useVertexBackend,
      useLimitedUseAppCheckTokens: useLimitedUseAppCheckTokens,
      auth: auth,
      location: location,
      safetySettings: safetySettings,
      generationConfig: generationConfig,
      tools: tools,
      toolConfig: toolConfig,
      systemInstruction: systemInstruction,
      hybridConfig: hybridConfig,
    );

/// Creates a model with an overridden [ApiClient] for testing.
///
/// Package private test-only method.
GenerativeModel createModelWithClient({
  required FirebaseApp app,
  required String location,
  required String model,
  required ApiClient client,
  required bool useVertexBackend,
  bool? useLimitedUseAppCheckTokens,
  Content? systemInstruction,
  FirebaseAppCheck? appCheck,
  FirebaseAuth? auth,
  GenerationConfig? generationConfig,
  List<SafetySetting>? safetySettings,
  List<Tool>? tools,
  ToolConfig? toolConfig,
  HybridConfig? hybridConfig,
}) =>
    GenerativeModel._constructTestModel(
        model: model,
        app: app,
        appCheck: appCheck,
        useVertexBackend: useVertexBackend,
        useLimitedUseAppCheckTokens: useLimitedUseAppCheckTokens,
        auth: auth,
        location: location,
        safetySettings: safetySettings,
        generationConfig: generationConfig,
        systemInstruction: systemInstruction,
        tools: tools,
        toolConfig: toolConfig,
        apiClient: client,
        hybridConfig: hybridConfig);
