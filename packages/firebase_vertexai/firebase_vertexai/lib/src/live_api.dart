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
import 'dart:convert';
import 'content.dart';
import 'error.dart';

enum Voices {
  ///
  Aoede('Aoede'),

  ///
  Charon('Charon'),

  ///
  Fenrir('Fenrir'),

  ///
  Kore('Kore'),

  ///
  Puck('Puck');

  const Voices(this._jsonString);
  final String _jsonString;

  /// Convert to json format
  String toJson() => _jsonString;
}

class SpeechConfig {
  SpeechConfig({this.voice});

  final Voices? voice;
  Map<String, Object?> toJson() => {
        if (voice != null)
          'voice_config': {
            'prebuilt_voice_config': {'voice_name': voice!.toJson()}
          }
      }; // Or null
}

enum ResponseModalities {
  ///
  Unspecified('MODALITY_UNSPECIFIED'),

  ///
  Text('TEXT'),

  ///
  Image('IMAGE'),

  ///
  Audio('AUDIO');

  const ResponseModalities(this._jsonString);
  final String _jsonString;

  /// Convert to json format
  String toJson() => _jsonString;
}

class LiveGenerationConfig {
  LiveGenerationConfig({
    this.speechConfig,
    this.responseModalities,
    this.candidateCount,
    this.stopSequences,
    this.maxOutputTokens,
    this.temperature,
    this.topP,
    this.topK,
  });
  final SpeechConfig? speechConfig;

  final List<ResponseModalities>? responseModalities;

  /// Number of generated responses to return.
  ///
  /// This value must be between [1, 8], inclusive. If unset, this will default
  /// to 1.
  final int? candidateCount;

  /// The set of character sequences (up to 5) that will stop output generation.
  ///
  /// If specified, the API will stop at the first appearance of a stop
  /// sequence. The stop sequence will not be included as part of the response.
  final List<String>? stopSequences;

  /// The maximum number of tokens to include in a candidate.
  ///
  /// If unset, this will default to output_token_limit specified in the `Model`
  /// specification.
  final int? maxOutputTokens;

  /// Controls the randomness of the output.
  ///
  /// Note: The default value varies by model.
  ///
  /// Values can range from `[0.0, infinity]`, inclusive. A value temperature
  /// must be greater than 0.0.
  final double? temperature;

  /// The maximum cumulative probability of tokens to consider when sampling.
  ///
  /// The model uses combined Top-k and nucleus sampling. Tokens are sorted
  /// based on their assigned probabilities so that only the most likely tokens
  /// are considered. Top-k sampling directly limits the maximum number of
  /// tokens to consider, while Nucleus sampling limits number of tokens based
  /// on the cumulative probability.
  ///
  /// Note: The default value varies by model.
  final double? topP;

  /// The maximum number of tokens to consider when sampling.
  ///
  /// The model uses combined Top-k and nucleus sampling. Top-k sampling
  /// considers the set of `top_k` most probable tokens. Defaults to 40.
  ///
  /// Note: The default value varies by model.
  final int? topK;

  /// Convert to json format
  Map<String, Object?> toJson() => {
        if (candidateCount case final candidateCount?)
          'candidateCount': candidateCount,
        if (stopSequences case final stopSequences?
            when stopSequences.isNotEmpty)
          'stopSequences': stopSequences,
        if (maxOutputTokens case final maxOutputTokens?)
          'maxOutputTokens': maxOutputTokens,
        if (temperature case final temperature?) 'temperature': temperature,
        if (topP case final topP?) 'topP': topP,
        if (topK case final topK?) 'topK': topK,
        if (speechConfig case final speechConfig?)
          'speech_config': speechConfig.toJson(),
        if (responseModalities case final responseModalities?)
          'response_modalities':
              responseModalities.map((modality) => modality.toJson()).toList(),
      };
}

class LiveServerContent {
  LiveServerContent({this.modelTurn, this.turnComplete, this.interrupted});

  final Content? modelTurn;
  final bool? turnComplete;
  final bool? interrupted;
}

class LiveServerMessage {
  LiveServerMessage({this.serverContent});

  final LiveServerContent? serverContent;
  // toolCall and toolCallCancellation
}

class LiveClientRealtimeInput {
  LiveClientRealtimeInput({this.mediaChunks});
  final List<InlineDataPart>? mediaChunks;

  Map<String, dynamic> toJson() => {
        'mediaChunks': mediaChunks?.map((e) => e.toJson()).toList(),
      };
}

class LiveClientContent {
  LiveClientContent({this.turns, this.turnComplete});
  final List<Content>? turns;
  final bool? turnComplete;

  Map<String, dynamic> toJson() => {
        'client_content': {
          'turns': turns?.map((e) => e.toJson()).toList(),
          'turn_complete': turnComplete,
        }
      };
}

class LiveClientToolResponse {
  LiveClientToolResponse({this.functionResponses});
  final List<FunctionResponse>? functionResponses;
  Map<String, dynamic> toJson() => {
        'functionResponses': functionResponses?.map((e) => e.toJson()).toList(),
      };
}

LiveServerMessage parseServerMessage(Object jsonObject) {
  if (jsonObject case {'error': final Object error}) {
    throw parseError(error);
  }

  Map<String, dynamic> json = jsonObject as Map<String, dynamic>;
  LiveServerContent? serverContent;
  if (json.containsKey('server_content')) {
    final serverContentJson = json['server_content'] as Map<String, dynamic>;
    Content? modelTurn;
    if (serverContentJson.containsKey('model_turn')) {
      modelTurn = serverContentJson['model_turn'];
    }
    bool? turnComplete;
    if (serverContentJson.containsKey('turn_complete')) {
      turnComplete = serverContentJson['turn_complete'] as bool;
    }
    serverContent =
        LiveServerContent(modelTurn: modelTurn, turnComplete: turnComplete);
  }
  return LiveServerMessage(serverContent: serverContent);
}
