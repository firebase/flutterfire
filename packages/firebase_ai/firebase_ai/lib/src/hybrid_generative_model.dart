// Copyright 2026 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'api.dart';
import 'base_model.dart';
import 'content.dart';
import 'generated/local_ai.g.dart';

/// Modes for hybrid inference.
enum InferenceMode {
  /// Prefer cloud, fallback to local on failure.
  preferCloud,
  /// Prefer local, fallback to cloud on failure.
  preferLocal,
  /// Only use local model.
  onlyLocal,
  /// Only use cloud model.
  onlyCloud,
}

/// A generative model that supports hybrid inference (local and cloud).
class HybridGenerativeModel {
  /// Creates a [HybridGenerativeModel].
  HybridGenerativeModel({
    required this.cloudModel,
    LocalAIApi? localApi,
    this.mode = InferenceMode.preferCloud,
  }) : localApi = localApi ?? LocalAIApi();

  /// The cloud model to use.
  final GenerativeModel cloudModel;
  
  /// The local AI API bridge.
  final LocalAIApi localApi;
  
  /// The inference mode.
  final InferenceMode mode;

  /// Generates content responding to [prompt].
  Future<GenerateContentResponse> generateContent(Iterable<Content> prompt) async {
    switch (mode) {
      case InferenceMode.onlyCloud:
        return cloudModel.generateContent(prompt);
      case InferenceMode.onlyLocal:
        return _generateLocal(prompt);
      case InferenceMode.preferCloud:
        try {
          return await cloudModel.generateContent(prompt);
        } catch (e) {
          if (await localApi.isAvailable()) {
            return _generateLocal(prompt);
          }
          rethrow;
        }
      case InferenceMode.preferLocal:
        if (await localApi.isAvailable()) {
          try {
            return await _generateLocal(prompt);
          } catch (e) {
            return cloudModel.generateContent(prompt);
          }
        }
        return cloudModel.generateContent(prompt);
    }
  }

  Future<GenerateContentResponse> _generateLocal(Iterable<Content> prompt) async {
    final promptString = prompt.map((c) => c.parts.whereType<TextPart>().map((p) => p.text).join()).join();
    final responseText = await localApi.generateContent(promptString);
    
    return GenerateContentResponse([
      Candidate(
        Content('model', [TextPart(responseText)]),
        null, // safetyRatings
        null, // citationMetadata
        null, // finishReason
        null, // finishMessage
      )
    ], null); // promptFeedback
  }

  /// Warms up the local model (e.g., triggers download on Web).
  Future<void> warmup() async {
    await localApi.warmup();
  }

  /// Generates a stream of content responding to [prompt].
  Stream<GenerateContentResponse> generateContentStream(Iterable<Content> prompt) {
    switch (mode) {
      case InferenceMode.onlyCloud:
        return cloudModel.generateContentStream(prompt);
      case InferenceMode.onlyLocal:
        return generateLocalStream(prompt);
      case InferenceMode.preferCloud:
        final controller = StreamController<GenerateContentResponse>();
        var yieldedData = false;
        
        try {
          cloudModel.generateContentStream(prompt).listen(
            (response) {
              yieldedData = true;
              controller.add(response);
            },
            onError: (e) async {
              if (!yieldedData && await localApi.isAvailable()) {
                generateLocalStream(prompt).listen(
                  controller.add,
                  onError: controller.addError,
                  onDone: controller.close,
                );
              } else {
                controller.addError(e);
                unawaited(controller.close());
              }
            },
            onDone: controller.close,
          );
        } catch (e) {
          localApi.isAvailable().then((available) {
            if (available) {
              generateLocalStream(prompt).listen(
                controller.add,
                onError: controller.addError,
                onDone: controller.close,
              );
            } else {
              controller.addError(e);
              unawaited(controller.close());
            }
          });
        }
        
        return controller.stream;
        
      case InferenceMode.preferLocal:
        final controller = StreamController<GenerateContentResponse>();
        
        localApi.isAvailable().then((available) {
          if (available) {
            var yieldedData = false;
            generateLocalStream(prompt).listen(
              (response) {
                yieldedData = true;
                controller.add(response);
              },
              onError: (e) {
                if (!yieldedData) {
                  cloudModel.generateContentStream(prompt).listen(
                    controller.add,
                    onError: controller.addError,
                    onDone: controller.close,
                  );
                } else {
                  controller.addError(e);
                  unawaited(controller.close());
                }
              },
              onDone: controller.close,
            );
          } else {
            cloudModel.generateContentStream(prompt).listen(
              controller.add,
              onError: controller.addError,
              onDone: controller.close,
            );
          }
        });
        
        return controller.stream;
    }
  }

  /// Generates a stream of content from the local model.
  @visibleForTesting
  Stream<GenerateContentResponse> generateLocalStream(Iterable<Content> prompt) {
    final promptString = prompt.map((c) => c.parts.whereType<TextPart>().map((p) => p.text).join()).join();
    
    final controller = StreamController<GenerateContentResponse>();
    
    localApi.startStreaming(promptString).then((_) {
      const channel = EventChannel('dev.flutter.pigeon.firebase_ai.LocalAIApi.stream');
      channel.receiveBroadcastStream().map((event) {
        final responseText = event as String;
        // ignore: prefer_const_constructors
        return GenerateContentResponse([
          Candidate(
            Content('model', [TextPart(responseText)]),
            null,
            null,
            null,
            null,
          )
        ], null);
      }).listen(controller.add, onError: controller.addError, onDone: controller.close);
    }).catchError((e) {
      controller.addError(e);
      unawaited(controller.close());
    });
    
    return controller.stream;
  }
}
