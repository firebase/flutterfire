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
import 'api.dart';
import 'content.dart';
import 'error.dart';

/// Represents the available voice options for speech synthesis.
enum Voices {
  Aoede('Aoede'),

  Charon('Charon'),

  Fenrir('Fenrir'),

  Kore('Kore'),

  Puck('Puck');

  const Voices(this._jsonString);
  final String _jsonString;

  // ignore: public_member_api_docs
  String toJson() => _jsonString;
}

/// Configures speech synthesis settings.
class SpeechConfig {
  /// Creates a [SpeechConfig] instance.
  ///
  /// [voice] (optional): The desired voice for speech synthesis.
  SpeechConfig({this.voice});

  /// The voice to use for speech synthesis.
  final Voices? voice;
  Map<String, Object?> toJson() => {
        if (voice != null)
          'voice_config': {
            'prebuilt_voice_config': {'voice_name': voice!.toJson()}
          }
      }; // Or null
}

/// Represents the available response modalities.
enum ResponseModalities {
  /// Unspecified response modality.
  Unspecified('MODALITY_UNSPECIFIED'),

  /// Text response modality.
  Text('TEXT'),

  /// Image response modality.
  Image('IMAGE'),

  /// Audio response modality.
  Audio('AUDIO');

  const ResponseModalities(this._jsonString);
  final String _jsonString;

  /// Convert to json format
  String toJson() => _jsonString;
}

/// Configures live generation settings.
final class LiveGenerationConfig extends BaseGenerationConfig {
  // ignore: public_member_api_docs
  LiveGenerationConfig({
    this.speechConfig,
    this.responseModalities,
    super.candidateCount,
    super.maxOutputTokens,
    super.temperature,
    super.topP,
    super.topK,
  });

  /// The speech configuration.
  final SpeechConfig? speechConfig;

  /// The list of desired response modalities.
  final List<ResponseModalities>? responseModalities;

  @override
  Map<String, Object?> toJson() => {
        ...super.toJson(),
        if (speechConfig case final speechConfig?)
          'speech_config': speechConfig.toJson(),
        if (responseModalities case final responseModalities?)
          'response_modalities':
              responseModalities.map((modality) => modality.toJson()).toList(),
      };
}

/// Configures live generation settings.
// class LiveGenerationConfig {
//   // ignore: public_member_api_docs
//   LiveGenerationConfig({
//     this.speechConfig,
//     this.responseModalities,
//     this.candidateCount,
//     this.maxOutputTokens,
//     this.temperature,
//     this.topP,
//     this.topK,
//   });

//   /// The speech configuration.
//   final SpeechConfig? speechConfig;

//   /// The list of desired response modalities.
//   final List<ResponseModalities>? responseModalities;

//   /// Number of generated responses to return.
//   ///
//   /// This value must be between [1, 8], inclusive. If unset, this will default
//   /// to 1.
//   final int? candidateCount;

//   /// The maximum number of tokens to include in a candidate.
//   ///
//   /// If unset, this will default to output_token_limit specified in the `Model`
//   /// specification.
//   final int? maxOutputTokens;

//   /// Controls the randomness of the output.
//   ///
//   /// Note: The default value varies by model.
//   ///
//   /// Values can range from `[0.0, infinity]`, inclusive. A value temperature
//   /// must be greater than 0.0.
//   final double? temperature;

//   /// The maximum cumulative probability of tokens to consider when sampling.
//   ///
//   /// The model uses combined Top-k and nucleus sampling. Tokens are sorted
//   /// based on their assigned probabilities so that only the most likely tokens
//   /// are considered. Top-k sampling directly limits the maximum number of
//   /// tokens to consider, while Nucleus sampling limits number of tokens based
//   /// on the cumulative probability.
//   ///
//   /// Note: The default value varies by model.
//   final double? topP;

//   /// The maximum number of tokens to consider when sampling.
//   ///
//   /// The model uses combined Top-k and nucleus sampling. Top-k sampling
//   /// considers the set of `top_k` most probable tokens. Defaults to 40.
//   ///
//   /// Note: The default value varies by model.
//   final int? topK;

//   /// Convert to json format
//   Map<String, Object?> toJson() => {
//         if (candidateCount case final candidateCount?)
//           'candidateCount': candidateCount,
//         if (maxOutputTokens case final maxOutputTokens?)
//           'maxOutputTokens': maxOutputTokens,
//         if (temperature case final temperature?) 'temperature': temperature,
//         if (topP case final topP?) 'topP': topP,
//         if (topK case final topK?) 'topK': topK,
//         if (speechConfig case final speechConfig?)
//           'speech_config': speechConfig.toJson(),
//         if (responseModalities case final responseModalities?)
//           'response_modalities':
//               responseModalities.map((modality) => modality.toJson()).toList(),
//       };
// }

/// An abstract class representing a message received from a live server.
///
/// This class serves as a base for different types of server messages,
/// such as content updates, tool calls, and tool call cancellations.
/// Subclasses should implement specific message types.
abstract class LiveServerMessage {}

/// A message indicating that the live server setup is complete.
///
/// This message signals that the initial connection and setup process
/// with the live server has finished successfully.
class LiveServerSetupComplete implements LiveServerMessage {}

/// Represents content generated by the model in a live stream.
class LiveServerContent implements LiveServerMessage {
  /// Creates a [LiveServerContent] instance.
  ///
  /// [modelTurn] (optional): The content generated by the model.
  /// [turnComplete] (optional): Indicates if the turn is complete.
  /// [interrupted] (optional): Indicates if the generation was interrupted.
  LiveServerContent({this.modelTurn, this.turnComplete, this.interrupted});

  /// The content generated by the model.
  final Content? modelTurn;

  /// Indicates if the turn is complete.
  final bool? turnComplete;

  /// Indicates if the generation was interrupted.
  final bool? interrupted;
}

/// Represents a tool call in a live stream.
class LiveServerToolCall implements LiveServerMessage {
  /// Creates a [LiveServerToolCall] instance.
  ///
  /// [functionCalls] (optional): The list of function calls.
  LiveServerToolCall({this.functionCalls});

  /// The list of function calls.
  final List<FunctionCall>? functionCalls;
}

/// Represents a tool call cancellation in a live stream.
class LiveServerToolCallCancellation implements LiveServerMessage {
  /// Creates a [LiveServerToolCallCancellation] instance.
  ///
  /// [functionIds] (optional): The list of function IDs to cancel.
  LiveServerToolCallCancellation({this.functionIds});

  /// The list of function IDs to cancel.
  final List<String>? functionIds;
}

/// Represents realtime input from the client in a live stream.
class LiveClientRealtimeInput {
  /// Creates a [LiveClientRealtimeInput] instance.
  ///
  /// [mediaChunks] (optional): The list of media chunks.
  LiveClientRealtimeInput({this.mediaChunks});

  /// The list of media chunks.
  final List<InlineDataPart>? mediaChunks;

  Map<String, dynamic> toJson() => {
        'realtime_input': {
          'media_chunks':
              mediaChunks?.map((e) => e.toMediaChunkJson()).toList(),
        },
      };
}

/// Represents content from the client in a live stream.
class LiveClientContent {
  /// Creates a [LiveClientContent] instance.
  ///
  /// [turns] (optional): The list of content turns from the client.
  /// [turnComplete] (optional): Indicates if the turn is complete.
  LiveClientContent({this.turns, this.turnComplete});

  /// The list of content turns from the client.
  final List<Content>? turns;

  /// Indicates if the turn is complete.
  final bool? turnComplete;

  Map<String, dynamic> toJson() => {
        'client_content': {
          'turns': turns?.map((e) => e.toJson()).toList(),
          'turn_complete': turnComplete,
        }
      };
}

/// Represents a tool response from the client in a live stream.
class LiveClientToolResponse {
  /// Creates a [LiveClientToolResponse] instance.
  ///
  /// [functionResponses] (optional): The list of function responses.
  LiveClientToolResponse({this.functionResponses});

  /// The list of function responses.
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

  if (json.containsKey('serverContent')) {
    final serverContentJson = json['serverContent'] as Map<String, dynamic>;
    Content? modelTurn;
    if (serverContentJson.containsKey('modelTurn')) {
      modelTurn = parseContent(serverContentJson['modelTurn']);
    }
    bool? turnComplete;
    if (serverContentJson.containsKey('turnComplete')) {
      turnComplete = serverContentJson['turnComplete'] as bool;
    }
    return LiveServerContent(modelTurn: modelTurn, turnComplete: turnComplete);
  } else if (json.containsKey('toolCall')) {
    final toolContentJson = json['toolCall'] as Map<String, dynamic>;
    List<FunctionCall> functionCalls = [];
    if (toolContentJson.containsKey('functionCalls')) {
      final functionCallJsons =
          toolContentJson['functionCalls']! as List<dynamic>;
      for (var functionCallJson in functionCallJsons) {
        var functionCall = parsePart(functionCallJson) as FunctionCall;
        functionCalls.add(functionCall);
      }
    }

    return LiveServerToolCall(functionCalls: functionCalls);
  } else if (json.containsKey('toolCallCancellation')) {
    final toolCancelJson =
        json['toolCallCancellation'] as Map<String, List<String>>;
    return LiveServerToolCallCancellation(functionIds: toolCancelJson['ids']);
  } else if (json.containsKey('setupComplete')) {
    return LiveServerSetupComplete();
  } else {
    throw unhandledFormat('LiveServerMessage', json);
  }
}
