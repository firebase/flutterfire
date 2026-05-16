// Copyright 2026 Google LLC
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

import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart' as gemma;

import 'api.dart';
import 'content.dart';
import 'hybrid_config.dart';
import 'tool.dart';

/// Package-private helper to manage all on-device local model execution details
/// using the `flutter_gemma` SDK.
class LocalModelRunner {

  /// Creates a new [LocalModelRunner] instance with [LocalModelConfig].
  LocalModelRunner(this._config);
  final LocalModelConfig _config;
  gemma.InferenceModel? _activeModel;
  bool _initialized = false;

  /// Checks if the local model file is downloaded and ready on the device.
  Future<bool> isInstalled() async {
    final modelId = _getModelId();
    return gemma.FlutterGemma.isModelInstalled(modelId);
  }

  /// Starts the model download.
  Future<void> download({void Function(int progress)? onProgress}) async {
    if (_config.modelUrl == null) {
      throw StateError('Cannot download local model: LocalModelConfig.modelUrl is null.');
    }

    final builder = gemma.FlutterGemma.installModel(
      modelType: _config.modelType,
      fileType: _config.fileType,
    ).fromNetwork(_config.modelUrl!, token: _config.hfToken);

    if (onProgress != null) {
      builder.withProgress(onProgress);
    }

    await builder.install();
  }

  /// Lazily initializes the flutter_gemma framework and loads the active model.
  Future<void> initialize() async {
    if (_initialized) return;

    // 1. Ensure flutter_gemma is initialized (safe to call multiple times)
    await gemma.FlutterGemma.initialize(
      huggingFaceToken: _config.hfToken,
    );

    // 2. Ensure model is installed
    final installed = await isInstalled();
    if (!installed) {
      if (_config.modelUrl != null) {
        debugPrint('LocalModelRunner: Local model not found. Starting auto-download...');
        await download();
      } else {
        throw StateError(
          'Local model not found at path and no download URL was provided. '
          'Please pre-download the model or specify LocalModelConfig.modelUrl.',
        );
      }
    }

    // 3. Load active model
    _activeModel = await gemma.FlutterGemma.getActiveModel(
      maxTokens: _config.maxTokens,
      preferredBackend: _config.preferredBackend,
      supportImage: _config.supportImage,
      supportAudio: _config.supportAudio,
    );

    _initialized = true;
    debugPrint('LocalModelRunner: Local model successfully initialized and loaded.');
  }

  /// Executes a single generation call.
  Future<GenerateContentResponse> generateContent(
    Iterable<Content> prompt, {
    List<Tool>? tools,
    ToolConfig? toolConfig,
    Content? systemInstruction,
  }) async {
    await initialize();

    final gemmaTools = _mapTools(tools);
    final systemInstructionStr = _mapSystemInstruction(systemInstruction);

    // Create a new chat session for this request to avoid history leaks.
    final chat = await _activeModel!.createChat(
      tools: gemmaTools,
      supportsFunctionCalls: gemmaTools.isNotEmpty,
      modelType: _config.modelType,
      systemInstruction: systemInstructionStr,
    );

    // Feed the history/prompt into the chat
    final messages = _mapPrompt(prompt);
    for (var i = 0; i < messages.length - 1; i++) {
      await chat.addQueryChunk(messages[i]);
    }

    if (messages.isNotEmpty) {
      await chat.addQueryChunk(messages.last);
    }

    final response = await chat.generateChatResponse();
    return _mapResponse(response);
  }

  /// Executes a streaming generation call.
  Stream<GenerateContentResponse> generateContentStream(
    Iterable<Content> prompt, {
    List<Tool>? tools,
    ToolConfig? toolConfig,
    Content? systemInstruction,
  }) async* {
    await initialize();

    final gemmaTools = _mapTools(tools);
    final systemInstructionStr = _mapSystemInstruction(systemInstruction);

    final chat = await _activeModel!.createChat(
      tools: gemmaTools,
      supportsFunctionCalls: gemmaTools.isNotEmpty,
      modelType: _config.modelType,
      systemInstruction: systemInstructionStr,
    );

    final messages = _mapPrompt(prompt);
    for (var i = 0; i < messages.length - 1; i++) {
      await chat.addQueryChunk(messages[i]);
    }

    if (messages.isNotEmpty) {
      await chat.addQueryChunk(messages.last);
    }

    // Generate response asynchronously (streaming)
    yield* chat.session.getResponseAsync().map((token) {
      // Stream yielding token chunks
      return _mapResponse(gemma.TextResponse(token));
    });
  }

  /// Estimates total tokens in contents.
  Future<CountTokensResponse> countTokens(Iterable<Content> contents) async {
    await initialize();
    final textToEstimate = contents
        .expand((c) => c.parts)
        .whereType<TextPart>()
        .map((p) => p.text)
        .join(' ');

    // Use session.sizeInTokens if available
    final dummySession = await _activeModel!.createSession();
    try {
      final tokens = await dummySession.sizeInTokens(textToEstimate);
      return CountTokensResponse(tokens);
    } finally {
      await dummySession.close();
    }
  }

  /// Release on-device model resources.
  Future<void> close() async {
    if (_activeModel != null) {
      await _activeModel!.close();
      _activeModel = null;
      _initialized = false;
      debugPrint('LocalModelRunner: Model resources released.');
    }
  }

  // === Mappings Helper Methods ===

  String _getModelId() {
    if (_config.modelPath != null && _config.modelPath!.isNotEmpty) {
      return _config.modelPath!.split('/').last;
    }
    if (_config.modelUrl != null && _config.modelUrl!.isNotEmpty) {
      return _config.modelUrl!.split('/').last;
    }
    throw StateError('No modelPath or modelUrl provided in LocalModelConfig to identify the model.');
  }

  String? _mapSystemInstruction(Content? systemInstruction) {
    if (systemInstruction == null) return null;
    return systemInstruction.parts.whereType<TextPart>().map((p) => p.text).join('\n');
  }

  List<gemma.Tool> _mapTools(List<Tool>? tools) {
    if (tools == null || tools.isEmpty) return const [];
    final gemmaTools = <gemma.Tool>[];

    for (final tool in tools) {
      final decls = tool.autoFunctionDeclarations.isNotEmpty
          ? tool.autoFunctionDeclarations
          : (tool.toJson()['functionDeclarations'] as List?) ?? [];

      for (final decl in decls) {
        if (decl is AutoFunctionDeclaration) {
          final json = decl.toJson();
          final parameters = (json['parameters'] ?? json['parametersJsonSchema']) as Map<String, dynamic>? ?? {};
          gemmaTools.add(gemma.Tool(
            name: decl.name,
            description: decl.description,
            parameters: parameters,
          ));
        } else if (decl is FunctionDeclaration) {
          final json = decl.toJson();
          final parameters = (json['parameters'] ?? json['parametersJsonSchema']) as Map<String, dynamic>? ?? {};
          gemmaTools.add(gemma.Tool(
            name: decl.name,
            description: decl.description,
            parameters: parameters,
          ));
        } else if (decl is Map) {
          final name = decl['name'] as String;
          final desc = decl['description'] as String? ?? '';
          final parameters = (decl['parameters'] ?? decl['parametersJsonSchema']) as Map<String, dynamic>? ?? {};
          gemmaTools.add(gemma.Tool(
            name: name,
            description: desc,
            parameters: parameters,
          ));
        }
      }
    }
    return gemmaTools;
  }

  List<gemma.Message> _mapPrompt(Iterable<Content> prompt) {
    final messages = <gemma.Message>[];

    for (final content in prompt) {
      final isUser = content.role == 'user' || content.role == 'function';
      final textParts = content.parts.whereType<TextPart>().map((p) => p.text).toList();
      final imageParts = content.parts.whereType<InlineDataPart>().toList();
      final functionCallParts = content.parts.whereType<FunctionCall>().toList();
      final functionResponseParts = content.parts.whereType<FunctionResponse>().toList();

      final combinedText = textParts.join('\n');

      if (functionResponseParts.isNotEmpty) {
        // Client reporting tool response output back to model
        for (final resp in functionResponseParts) {
          messages.add(gemma.Message.toolResponse(
            toolName: resp.name,
            response: resp.response.cast<String, dynamic>(),
          ));
        }
      } else if (functionCallParts.isNotEmpty) {
        // Model called a function previously in conversation
        for (final call in functionCallParts) {
          messages.add(gemma.Message.toolCall(
            text: 'Called function: ${call.name} with args ${call.args}',
          ));
        }
      } else if (imageParts.isNotEmpty) {
        // Multimodal input
        final List<Uint8List> imageBytesList = imageParts.map((p) => p.bytes).toList();
        messages.add(gemma.Message.withImages(
          text: combinedText,
          imageBytes: imageBytesList,
          isUser: isUser,
        ));
      } else {
        // Standard text
        messages.add(gemma.Message.text(
          text: combinedText,
          isUser: isUser,
        ));
      }
    }

    return messages;
  }

  GenerateContentResponse _mapResponse(gemma.ModelResponse response) {
    if (response is gemma.TextResponse) {
      final content = Content('model', [TextPart(response.token)]);
      return GenerateContentResponse([
        Candidate(
          content,
          [],
          null,
          FinishReason.stop,
          null,
        )
      ], null);
    } else if (response is gemma.FunctionCallResponse) {
      final content = Content('model', [
        FunctionCall(response.name, response.args.cast<String, Object?>())
      ]);
      return GenerateContentResponse([
        Candidate(
          content,
          [],
          null,
          FinishReason.stop,
          null,
        )
      ], null);
    } else if (response is gemma.ParallelFunctionCallResponse) {
      final parts = response.calls.map((call) {
        return FunctionCall(call.name, call.args.cast<String, Object?>());
      }).toList();
      final content = Content('model', parts);
      return GenerateContentResponse([
        Candidate(
          content,
          [],
          null,
          FinishReason.stop,
          null,
        )
      ], null);
    } else if (response is gemma.ThinkingResponse) {
      final content = Content('model', [TextPart(response.content, isThought: true)]);
      return GenerateContentResponse([
        Candidate(
          content,
          [],
          null,
          FinishReason.stop,
          null,
        )
      ], null);
    }

    throw UnsupportedError('Unknown local model response type: ${response.runtimeType}');
  }
}
