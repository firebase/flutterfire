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

/// The audio transcription configuration.
class AudioTranscriptionConfig {
  // ignore: public_member_api_docs
  Map<String, Object?> toJson() => {};
}

/// Configures the sliding window context compression mechanism.
///
/// The SlidingWindow method operates by discarding content at the beginning of
/// the context window. The resulting context will always begin at the start of
/// a USER role turn. System instructions will always remain at the start of the
/// result.
class SlidingWindow {
  /// Creates a [SlidingWindow] instance.
  ///
  /// [targetTokens] (optional): The target number of tokens to keep in the
  /// context window.
  SlidingWindow({this.targetTokens});

  /// The session reduction target, i.e., how many tokens we should keep.
  final int? targetTokens;
  // ignore: public_member_api_docs
  Map<String, Object?> toJson() =>
      {if (targetTokens case final targetTokens?) 'targetTokens': targetTokens};
}

/// Enables context window compression to manage the model's context window.
///
/// This mechanism prevents the context from exceeding a given length.
class ContextWindowCompressionConfig {
  /// Creates a [ContextWindowCompressionConfig] instance.
  ///
  /// [triggerTokens] (optional): The number of tokens that triggers the
  /// compression mechanism.
  /// [slidingWindow] (optional): The sliding window compression mechanism to
  /// use.
  ContextWindowCompressionConfig({this.triggerTokens, this.slidingWindow});

  /// The number of tokens (before running a turn) that triggers the context
  /// window compression.
  final int? triggerTokens;

  /// The sliding window compression mechanism.
  final SlidingWindow? slidingWindow;
  // ignore: public_member_api_docs
  Map<String, Object?> toJson() => {
        if (triggerTokens case final triggerTokens?)
          'triggerTokens': triggerTokens,
        if (slidingWindow case final slidingWindow?)
          'slidingWindow': slidingWindow.toJson()
      };
}

/// Configuration for the session resumption mechanism.
///
/// When included in the session setup, the server will send
/// [SessionResumptionUpdate] messages.
class SessionResumptionConfig {
  /// Creates a [SessionResumptionConfig] to start a new resumable session.
  ///
  /// When this is included in the session setup, the server will send
  /// [SessionResumptionUpdate] messages with handles that can be used to
  /// resume the session later.
  SessionResumptionConfig() : handle = null;

  /// Creates a [SessionResumptionConfig] to resume a previous session.
  ///
  /// [handle] is the session resumption handle received in a previous session's
  /// [SessionResumptionUpdate].
  SessionResumptionConfig.resume(String this.handle);

  /// The session resumption handle of the previous session to restore.
  ///
  /// If null, a new session will be started (and will be resumable if this
  /// config was included).
  final String? handle;

  // ignore: public_member_api_docs
  Map<String, Object?> toJson() => {
        if (handle case final handle?) 'handle': handle,
      };
}

/// Configures model input behavior when generating content in the Live API via the realtime supported methods.
final class RealtimeInputConfig {
  /// Creates a [RealtimeInputConfig] instance.
  RealtimeInputConfig({
    this.automaticActivityDetection,
    this.activityHandling,
    this.turnCoverage,
  });

  /// Configures automatic activity detection on the model.
  final ActivityDetectionConfig? automaticActivityDetection;

  /// Defines how the model treats user input activity.
  final ActivityHandling? activityHandling;

  /// Defines which input is included in the user's turn, relative to the starting and ending of the activity.
  final TurnCoverage? turnCoverage;

  // ignore: public_member_api_docs
  Map<String, Object?> toJson() => {
        if (automaticActivityDetection case final automaticActivityDetection?)
          'automatic_activity_detection': automaticActivityDetection.toJson(),
        if (activityHandling case final activityHandling?)
          'activity_handling': activityHandling.value,
        if (turnCoverage case final turnCoverage?)
          'turn_coverage': turnCoverage.value,
      };
}

/// Configures the model's automatic detection of user activity.
final class ActivityDetectionConfig {
  /// Creates an [ActivityDetectionConfig] instance.
  ActivityDetectionConfig({
    Sensitivity? startSensitivity,
    Sensitivity? endSensitivity,
    int? prefixPaddingMS,
    int? silenceDurationMS,
  }) : this._(
          startSensitivity: startSensitivity,
          endSensitivity: endSensitivity,
          prefixPaddingMS: prefixPaddingMS,
          silenceDurationMS: silenceDurationMS,
        );

  ActivityDetectionConfig._({
    this.startSensitivity,
    this.endSensitivity,
    this.prefixPaddingMS,
    this.silenceDurationMS,
    this.disabled,
  });

  /// Disables automatic activity detection.
  factory ActivityDetectionConfig.disabled() {
    return ActivityDetectionConfig._(
      disabled: true,
    );
  }

  /// Determines how likely the start of speech is detected.
  final Sensitivity? startSensitivity;

  /// Determines how likely the end of speech is detected.
  final Sensitivity? endSensitivity;

  /// How long detected speech should be present before start-of-speech is committed.
  final int? prefixPaddingMS;

  /// How long silence (or non-speech) should be present before end-of-speech is committed.
  final int? silenceDurationMS;

  /// Whether automatic activity detection is disabled.
  final bool? disabled;

  // ignore: public_member_api_docs
  Map<String, Object?> toJson() => {
        if (startSensitivity case final startSensitivity?)
          'start_of_speech_sensitivity':
              'START_${startSensitivity.value}',
        if (endSensitivity case final endSensitivity?)
          'end_of_speech_sensitivity':
              'END_${endSensitivity.value}',
        if (prefixPaddingMS case final prefixPaddingMS?)
          'prefix_padding_ms': prefixPaddingMS,
        if (silenceDurationMS case final silenceDurationMS?)
          'silence_duration_ms': silenceDurationMS,
        if (disabled case final disabled?) 'disabled': disabled,
      };
}

/// How a model handles user input activity.
enum ActivityHandling {
  /// When the user sends input marking the start of activity, the model's current response will be cut-off immediately.
  interrupt('START_OF_ACTIVITY_INTERRUPTS'),

  /// When the user sends input marking the start of activity, the model will process it, but won't cut-off its current response.
  noInterrupt('NO_INTERRUPTION');

  const ActivityHandling(this.value);

  /// The JSON wire string value.
  final String value;
}

/// How the model considers which input is included in the user's turn.
enum TurnCoverage {
  /// The model will exclude inactivity (e.g, silence on the audio stream) from the user's input.
  onlyActivity('TURN_INCLUDES_ONLY_ACTIVITY'),

  /// The model will include all input (including inactivity) since the last turn as the user's input.
  allInput('TURN_INCLUDES_ALL_INPUT'),

  /// Includes audio activity and all video since the last turn.
  audioActivityAndAllVideo('TURN_INCLUDES_AUDIO_ACTIVITY_AND_ALL_VIDEO');

  const TurnCoverage(this.value);

  /// The JSON wire string value.
  final String value;
}

/// How sensitive the model interprets speech activity.
enum Sensitivity {
  /// The model will detect speech less often.
  low('SENSITIVITY_LOW'),

  /// The model will detect speech more often.
  high('SENSITIVITY_HIGH');

  const Sensitivity(this.value);

  /// The JSON wire string value.
  final String value;
}

/// Configures live generation settings.
final class LiveGenerationConfig extends BaseGenerationConfig {
  // ignore: public_member_api_docs
  LiveGenerationConfig(
      {super.speechConfig,
      this.inputAudioTranscription,
      this.outputAudioTranscription,
      this.contextWindowCompression,
      this.realtimeInputConfig,
      super.responseModalities,
      super.maxOutputTokens,
      super.temperature,
      super.topP,
      super.topK,
      super.presencePenalty,
      super.frequencyPenalty,
      super.mediaResolution});

  /// The transcription of the input aligns with the input audio language.
  final AudioTranscriptionConfig? inputAudioTranscription;

  /// The transcription of the output aligns with the language code specified for
  /// the output audio.
  final AudioTranscriptionConfig? outputAudioTranscription;

  /// The context window compression configuration.
  final ContextWindowCompressionConfig? contextWindowCompression;

  /// The realtime input configuration for voice activity detection and handling.
  final RealtimeInputConfig? realtimeInputConfig;

  @override
  Map<String, Object?> toJson() => {
        ...super.toJson(),
      };
}

/// An abstract class representing a message received from a live server.
///
/// This class serves as a base for different types of server messages,
/// such as content updates, tool calls, and tool call cancellations.
/// Subclasses should implement specific message types.
sealed class LiveServerMessage {}

/// A message indicating that the live server setup is complete.
///
/// This message signals that the initial connection and setup process
/// with the live server has finished successfully.
class LiveServerSetupComplete implements LiveServerMessage {}

/// Audio transcription message.
class Transcription {
  // ignore: public_member_api_docs
  const Transcription({this.text, this.finished});

  /// Transcription text.
  final String? text;

  /// Whether this is the end of the transcription.
  final bool? finished;
}

/// Content generated by the model in a live stream.
class LiveServerContent implements LiveServerMessage {
  /// Creates a [LiveServerContent] instance.
  ///
  /// [modelTurn] (optional): The content generated by the model.
  /// [turnComplete] (optional): Indicates if the turn is complete.
  /// [interrupted] (optional): Indicates if the generation was interrupted.
  /// [inputTranscription] (optional): The input transcription.
  /// [outputTranscription] (optional): The output transcription.
  LiveServerContent(
      {this.modelTurn,
      this.turnComplete,
      this.interrupted,
      this.inputTranscription,
      this.outputTranscription});

  // TODO(cynthia): Add accessor for media content
  /// The content generated by the model.
  final Content? modelTurn;

  /// Whether the turn is complete. If true, indicates that the model is done
  /// generating.
  final bool? turnComplete;

  /// Whether generation was interrupted. If true, indicates that a
  /// client message has interrupted current model
  final bool? interrupted;

  /// The input transcription.
  ///
  /// The transcription is independent to the model turn which means it doesn't
  /// imply any ordering between transcription and model turn.
  final Transcription? inputTranscription;

  /// The output transcription.
  ///
  /// The transcription is independent to the model turn which means it doesn't
  /// imply any ordering between transcription and model turn.
  final Transcription? outputTranscription;
}

/// A tool call in a live stream.
///
/// A `Tool` is a piece of code that enables the system to interact with
/// external systems to perform an action, or set of actions, outside of
/// knowledge and scope of the model.
class LiveServerToolCall implements LiveServerMessage {
  /// Creates a [LiveServerToolCall] instance.
  ///
  /// [functionCalls] (optional): The list of function calls.
  LiveServerToolCall({this.functionCalls});

  /// The list of function calls to be executed.
  final List<FunctionCall>? functionCalls;
}

/// A tool call cancellation in a live stream.
///
/// Notification for the client that a previously issued `ToolCallMessage`
/// with the specified `id`s should have been not executed and should be
/// cancelled. If there were side-effects to those tool calls, clients may
/// attempt to undo the tool calls. This message occurs only in cases where the
/// clients interrupt server turns.
class LiveServerToolCallCancellation implements LiveServerMessage {
  /// Creates a [LiveServerToolCallCancellation] instance.
  ///
  /// [functionIds] (optional): The list of function IDs to cancel.
  LiveServerToolCallCancellation({this.functionIds});

  /// The list of [FunctionCall.id] to cancel.
  final List<String>? functionIds;
}

/// A server message indicating that the server will not be able to service the
/// client soon.
class GoingAwayNotice implements LiveServerMessage {
  /// Creates a [GoingAwayNotice] instance.
  ///
  /// [timeLeft] (optional): The remaining time before the connection will be
  /// terminated.
  const GoingAwayNotice({this.timeLeft});

  /// The remaining time before the connection will be terminated as ABORTED.
  final String? timeLeft;
}

/// An update of the session resumption state.
///
/// This message is only sent if [SessionResumptionConfig] was set in the
/// session setup.
class SessionResumptionUpdate implements LiveServerMessage {
  /// Creates a [SessionResumptionUpdate] instance.
  ///
  /// [newHandle] (optional): The new handle that represents the state that can
  /// be resumed.
  /// [resumable] (optional): Indicates if the session can be resumed at this
  /// point.
  /// [lastConsumedClientMessageIndex] (optional): The index of the last client
  /// message that is included in the state represented by this update.
  SessionResumptionUpdate(
      {this.newHandle, this.resumable, this.lastConsumedClientMessageIndex});

  /// The new handle that represents the state that can be resumed. Empty if
  /// `resumable` is false.
  final String? newHandle;

  /// Indicates if the session can be resumed at this point.
  final bool? resumable;

  /// The index of the last client message that is included in the state
  /// represented by this update.
  final int? lastConsumedClientMessageIndex;
}

/// A single response chunk received during a live content generation.
///
/// It can contain generated content, function calls to be executed, or
/// instructions to cancel previous function calls, along with the status of the
/// ongoing generation.
class LiveServerResponse {
  // ignore: public_member_api_docs
  LiveServerResponse({required this.message});

  /// The server message generated by the live model.
  final LiveServerMessage message;
}

/// Represents realtime input from the client in a live stream.
class LiveClientRealtimeInput {
  /// Creates a [LiveClientRealtimeInput] instance.
  LiveClientRealtimeInput({
    @Deprecated('Use audio, video, or text instead') this.mediaChunks,
    this.audio,
    this.video,
    this.text,
    this.activityStart,
    this.activityEnd,
  });

  /// Creates a [LiveClientRealtimeInput] with audio data.
  LiveClientRealtimeInput.audio(this.audio)
      // ignore: deprecated_member_use_from_same_package
      : mediaChunks = null,
        video = null,
        text = null,
        activityStart = null,
        activityEnd = null;

  /// Creates a [LiveClientRealtimeInput] with video data.
  LiveClientRealtimeInput.video(this.video)
      // ignore: deprecated_member_use_from_same_package
      : mediaChunks = null,
        audio = null,
        text = null,
        activityStart = null,
        activityEnd = null;

  /// Creates a [LiveClientRealtimeInput] with text data.
  LiveClientRealtimeInput.text(this.text)
      // ignore: deprecated_member_use_from_same_package
      : mediaChunks = null,
        audio = null,
        video = null,
        activityStart = null,
        activityEnd = null;

  /// Creates a [LiveClientRealtimeInput] with activity start signal.
  LiveClientRealtimeInput.activityStart()
      // ignore: deprecated_member_use_from_same_package
      : mediaChunks = null,
        audio = null,
        video = null,
        text = null,
        activityStart = const {},
        activityEnd = null;

  /// Creates a [LiveClientRealtimeInput] with activity end signal.
  LiveClientRealtimeInput.activityEnd()
      // ignore: deprecated_member_use_from_same_package
      : mediaChunks = null,
        audio = null,
        video = null,
        text = null,
        activityStart = null,
        activityEnd = const {};

  /// The list of media chunks.
  @Deprecated('Use audio, video, or text instead')
  final List<InlineDataPart>? mediaChunks;

  /// Audio data.
  final InlineDataPart? audio;

  /// Video data.
  final InlineDataPart? video;

  /// Text data.
  final String? text;

  /// Activity start signal.
  final Map<String, dynamic>? activityStart;

  /// Activity end signal.
  final Map<String, dynamic>? activityEnd;

  // ignore: public_member_api_docs
  Map<String, dynamic> toJson() => {
        'realtime_input': {
          if (mediaChunks != null)
            'media_chunks':
                // ignore: deprecated_member_use_from_same_package
                mediaChunks?.map((e) => e.toMediaChunkJson()).toList(),
          if (audio != null) 'audio': audio!.toMediaChunkJson(),
          if (video != null) 'video': video!.toMediaChunkJson(),
          if (text != null) 'text': text,
          if (activityStart != null) 'activity_start': activityStart,
          if (activityEnd != null) 'activity_end': activityEnd,
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

  /// Whether the turn is complete.
  ///
  /// If true, indicates that the server content generation should start with
  /// the currently accumulated prompt. Otherwise, the server will await
  /// additional messages before starting generation.
  final bool? turnComplete;

  // ignore: public_member_api_docs
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
  // ignore: public_member_api_docs
  Map<String, dynamic> toJson() => {
        'toolResponse': {
          'functionResponses': functionResponses
              ?.map((e) => {
                    'name': e.name,
                    'response': e.response,
                    if (e.id != null) 'id': e.id,
                  })
              .toList(),
        },
      };
}

/// Parses a JSON object received from the live server into a [LiveServerResponse].
///
/// This function handles different types of server messages, including:
/// - Error messages, which result in a [FirebaseAIException] being thrown.
/// - `serverContent` messages containing model-generated content.
/// - `toolCall` messages indicating function calls requested by the model.
/// - `toolCallCancellation` messages to cancel pending function calls.
/// - `setupComplete` messages signaling the completion of the server setup.
///
/// If the JSON object does not match any of the expected formats, an
/// [FirebaseAISdkException] is thrown.
///
/// Example:
/// ```dart
/// final jsonObject = {
///   'serverContent': {
///     'modelTurn': {
///       'parts': [
///         {'text': 'Hello, world!'}
///       ]
///     },
///     'turnComplete': true,
///   }
/// };
/// final message = parseServerMessage(jsonObject);
/// if (message is LiveServerContent) {
///   print('Received server content: ${message.modelTurn}');
/// }
/// ```
///
/// Throws:
/// - [FirebaseAIException]: If the JSON object contains an error message.
/// - [FirebaseAISdkException]: If the JSON object does not match any expected format.
///
/// Parameters:
/// - [jsonObject]: The JSON object received from the live server.
///
/// Returns:
/// - A [LiveServerResponse] object representing the parsed message.
LiveServerResponse parseServerResponse(Object jsonObject) {
  LiveServerMessage message = _parseServerMessage(jsonObject);
  return LiveServerResponse(message: message);
}

LiveServerMessage _parseServerMessage(Object jsonObject) {
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
    final interrupted = serverContentJson['interrupted'] as bool?;
    Transcription? _parseTranscription(String key) {
      if (serverContentJson.containsKey(key)) {
        final transcriptionJson =
            serverContentJson[key] as Map<String, dynamic>;
        return Transcription(
          text: transcriptionJson['text'] as String?,
          finished: transcriptionJson['finished'] as bool?,
        );
      }
      return null;
    }

    return LiveServerContent(
      modelTurn: modelTurn,
      turnComplete: turnComplete,
      interrupted: interrupted,
      inputTranscription: _parseTranscription('inputTranscription'),
      outputTranscription: _parseTranscription('outputTranscription'),
    );
  } else if (json.containsKey('toolCall')) {
    final toolContentJson = json['toolCall'] as Map<String, dynamic>;
    List<FunctionCall> functionCalls = [];
    if (toolContentJson.containsKey('functionCalls')) {
      final functionCallJsons =
          toolContentJson['functionCalls']! as List<dynamic>;
      for (final functionCallJson in functionCallJsons) {
        var functionCall =
            parsePart({'functionCall': functionCallJson}) as FunctionCall;
        functionCalls.add(functionCall);
      }
    }

    return LiveServerToolCall(functionCalls: functionCalls);
  } else if (json.containsKey('toolCallCancellation')) {
    final toolCancelData = json['toolCallCancellation'] as Map;
    final Map<String, List<String>> toolCancelJson = toolCancelData.map(
      (key, value) => MapEntry(
        key as String,
        (value as List).cast<String>(),
      ),
    );
    return LiveServerToolCallCancellation(functionIds: toolCancelJson['ids']);
  } else if (json.containsKey('setupComplete')) {
    return LiveServerSetupComplete();
  } else if (json.containsKey('goAway')) {
    final goAwayJson = json['goAway'] as Map<String, dynamic>;
    return GoingAwayNotice(timeLeft: goAwayJson['timeLeft'] as String?);
  } else if (json.containsKey('sessionResumptionUpdate')) {
    final sessionResumptionUpdateJson =
        json['sessionResumptionUpdate'] as Map<String, dynamic>;
    return SessionResumptionUpdate(
      newHandle: sessionResumptionUpdateJson['newHandle'] as String?,
      resumable: sessionResumptionUpdateJson['resumable'] as bool?,
      lastConsumedClientMessageIndex:
          sessionResumptionUpdateJson['lastConsumedClientMessageIndex'] as int?,
    );
  } else {
    throw unhandledFormat('LiveServerMessage', json);
  }
}
