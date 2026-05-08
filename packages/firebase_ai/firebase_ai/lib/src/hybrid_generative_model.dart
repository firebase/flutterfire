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
import 'api.dart';
import 'content.dart';
import 'base_model.dart';
import 'generated/local_ai.g.dart';

enum InferenceMode {
  preferCloud,
  preferLocal,
  onlyLocal,
  onlyCloud,
}

class HybridGenerativeModel {
  final GenerativeModel cloudModel;
  final LocalAIApi localApi;
  final InferenceMode mode;

  HybridGenerativeModel({
    required this.cloudModel,
    required this.localApi,
    this.mode = InferenceMode.preferCloud,
  });

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

  Future<void> warmup() async {
    await localApi.warmup();
  }
}
