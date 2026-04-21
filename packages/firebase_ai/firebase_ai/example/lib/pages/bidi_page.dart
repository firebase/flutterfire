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
import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:waveform_flutter/waveform_flutter.dart';

import '../utils/audio_input.dart';
import '../utils/audio_output.dart';
import '../utils/video_input.dart';
import '../widgets/message_widget.dart';
import '../widgets/audio_visualizer.dart';
import '../widgets/camera_previews.dart';

// ============================================================================
// MEDIA MANAGER
// Isolates Audio and Video hardware stream setup, start, stop, and cleanup.
// ============================================================================
class BidiMediaManager {
  final AudioOutput _audioOutput = AudioOutput();
  final AudioInput _audioInput = AudioInput();
  final VideoInput _videoInput = VideoInput();

  StreamSubscription? _audioSubscription;
  StreamSubscription? _videoSubscription;

  bool videoIsInitialized = false;

  // Expose hardware state/streams to the Controller and UI
  Stream<Amplitude>? get amplitudeStream => _audioInput.amplitudeStream;
  dynamic get cameraController => _videoInput.cameraController;
  String? get selectedCameraId => _videoInput.selectedCameraId;
  bool get controllerInitialized => _videoInput.controllerInitialized;

  void setMacOSController(dynamic controller) {
    _videoInput.setMacOSController(controller);
  }

  Future<void> init() async {
    try {
      await _audioOutput.init();
    } catch (e) {
      developer.log('Audio Output init error: $e');
    }

    try {
      await _audioInput.init();
    } catch (e) {
      developer.log('Audio Input init error: $e');
    }

    try {
      await _videoInput.init();
      videoIsInitialized = true;
    } catch (e) {
      developer.log('Error during video initialization: $e');
    }
  }

  Future<void> startAudio(void Function(Uint8List) onData) async {
    await stopAudio();
    try {
      var inputStream = await _audioInput.startRecordingStream();
      await _audioOutput.playStream();
      if (inputStream != null) {
        _audioSubscription = inputStream.listen(
          onData,
          onError: (e) {
            developer.log('Audio Stream Error: $e');
            stopAudio();
          },
          cancelOnError: true,
        );
      }
    } catch (e) {
      developer.log('BidiMediaManager.startAudio(): $e');
      rethrow;
    }
  }

  Future<void> stopAudio() async {
    await _audioSubscription?.cancel();
    _audioSubscription = null;
    await _audioInput.stopRecording();
  }

  Future<void> startVideo(void Function(Uint8List, String) onData) async {
    if (!videoIsInitialized) return;

    if (!_videoInput.controllerInitialized ||
        _videoInput.cameraController == null) {
      await _videoInput.initializeCameraController();
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.macOS) {
      int attempts = 0;
      while (_videoInput.cameraController == null) {
        if (attempts > 50) break; // 5 second timeout safety
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }
    }

    // Wait for Mac Camera to Settle (Prevent audio hijack)
    await Future.delayed(const Duration(milliseconds: 1000));

    _videoSubscription = _videoInput.startStreamingImages().listen(
      (data) {
        String mimeType = 'image/jpeg';
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.macOS) {
          if (data.length > 3 && data[0] == 0x89 && data[1] == 0x50) {
            mimeType = 'image/png';
          }
        }
        onData(data, mimeType);
      },
      onError: (e) => developer.log('Video Stream Error: $e'),
    );
  }

  Future<void> stopVideo() async {
    await _videoSubscription?.cancel();
    _videoSubscription = null;
    await _videoInput.stopStreamingImages();
  }

  void playAudioChunk(Uint8List bytes) {
    _audioOutput.addDataToAudioStream(bytes);
  }
}

// ============================================================================
// BIDI SESSION CONTROLLER
// Isolates business logic, session start/stop, reconnection, and tool execution.
// ============================================================================
class BidiSessionController extends ChangeNotifier {
  BidiSessionController({
    required this.model,
    required this.useVertexBackend,
    this.onShowError,
    this.onScrollDown,
  }) {
    _initLiveModel();
  }

  final GenerativeModel model;
  final bool useVertexBackend;
  final void Function(String)? onShowError;
  final VoidCallback? onScrollDown;

  late LiveGenerativeModel _liveModel;
  LiveSession? _session;
  final BidiMediaManager mediaManager = BidiMediaManager();

  bool isLoading = false;
  bool isSessionActive = false;
  bool isMicOn = false;
  bool isCameraOn = false;

  // Intention state for robust stream reconnection
  bool _intendedMicOn = false;
  bool _intendedCameraOn = false;

  final List<MessageData> messages = [];
  String? _activeSessionHandle;
  int? _inputTranscriptionMessageIndex;
  int? _outputTranscriptionMessageIndex;

  void _initLiveModel() {
    final config = LiveGenerationConfig(
      speechConfig: SpeechConfig(voiceName: 'Fenrir'),
      responseModalities: [ResponseModalities.audio],
      inputAudioTranscription: AudioTranscriptionConfig(),
      outputAudioTranscription: AudioTranscriptionConfig(),
    );

    final tools = [
      Tool.functionDeclarations([_lightControlTool]),
      Tool.googleSearch(),
    ];

    _liveModel = useVertexBackend
        ? FirebaseAI.vertexAI().liveGenerativeModel(
            model: 'gemini-live-2.5-flash-preview-native-audio-09-2025',
            liveGenerationConfig: config,
            tools: tools,
          )
        : FirebaseAI.googleAI().liveGenerativeModel(
            model: 'gemini-2.5-flash-native-audio-preview-09-2025',
            liveGenerationConfig: config,
            tools: tools,
          );
  }

  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();
    await mediaManager.init();
    isLoading = false;
    notifyListeners();
  }

  Future<void> toggleSession() async {
    if (isSessionActive) {
      await _stopSession(explicit: true);
    } else {
      await _startSession(explicit: true);
    }
  }

  Future<void> _startSession({required bool explicit}) async {
    isLoading = true;
    notifyListeners();

    try {
      _session = await _liveModel.connect(
        sessionResumption:
            SessionResumptionConfig(handle: _activeSessionHandle),
      );
    } on Exception catch (e) {
      developer.log(
        'Error setting up session with handle $_activeSessionHandle, error: $e, starting a new one.',
      );
      _session = await _liveModel.connect();
    }

    isSessionActive = true;
    unawaited(_processMessagesContinuously());

    if (explicit) {
      // Reconnect previously active hardware seamlessly into the new session
      if (_intendedMicOn) await _startMicStream();
      if (_intendedCameraOn) await _startCameraStream();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _stopSession({required bool explicit}) async {
    isLoading = true;
    notifyListeners();

    if (explicit) {
      await mediaManager.stopAudio();
      await mediaManager.stopVideo();
      isMicOn = false;
      isCameraOn = false;
      // We purposefully DO NOT reset _intendedMicOn/CameraOn so we know what
      // the user had active when they reconnect!
    }

    await _session?.close();
    _session = null;
    isSessionActive = false;

    isLoading = false;
    notifyListeners();
  }

  Future<void> _sessionResume() async {
    if (isSessionActive) {
      await _stopSession(explicit: false);
      await _startSession(explicit: false);
    }
  }

  Future<void> _onAudioData(Uint8List data) async {
    if (isSessionActive && _session != null) {
      try {
        await _session!.sendAudioRealtime(InlineDataPart('audio/pcm', data));
      } catch (e) {
        developer.log('Error sending audio realtime: $e');
        // If we hit a closed socket, stop trying to send until reconnected
        isMicOn = false;
        notifyListeners();
      }
    }
  }

  Future<void> _onVideoData(Uint8List data, String mimeType) async {
    if (isSessionActive && _session != null) {
      try {
        await _session!.sendVideoRealtime(InlineDataPart(mimeType, data));
      } catch (e) {
        developer.log('Error sending video realtime: $e');
      }
    }
  }

  Future<void> toggleMic() async {
    _intendedMicOn = !_intendedMicOn;
    if (_intendedMicOn) {
      await _startMicStream();
    } else {
      await mediaManager.stopAudio();
      isMicOn = false;
      notifyListeners();
    }
  }

  Future<void> _startMicStream() async {
    if (!isSessionActive) {
      isMicOn = true;
      notifyListeners();
      return;
    }
    try {
      await mediaManager.startAudio(_onAudioData);
      isMicOn = true;
      notifyListeners();
    } catch (e) {
      onShowError?.call(e.toString());
      isMicOn = false;
      notifyListeners();
    }
  }

  Future<void> _startCameraStream() async {
    if (!isSessionActive) {
      isCameraOn = true;
      notifyListeners();
      return;
    }
    try {
      await mediaManager.startVideo(_onVideoData);
      isCameraOn = true;
      notifyListeners();
    } catch (e) {
      developer.log('Error starting video stream: $e');
      onShowError?.call(e.toString());
      isCameraOn = false;
      notifyListeners();
    }
  }

  Future<void> toggleCamera() async {
    if (isLoading) return; // Prevent multiple clicks
    _intendedCameraOn = !_intendedCameraOn;

    isLoading = true;
    notifyListeners();

    try {
      if (!_intendedCameraOn) {
        await mediaManager.stopVideo();
        isCameraOn = false;
      } else {
        // Stop audio momentarily to prevent hijacking (Mac quirk workaround)
        bool wasMicOn = isMicOn;
        if (wasMicOn) await mediaManager.stopAudio();

        await Future.delayed(const Duration(milliseconds: 250));

        await _startCameraStream();

        // Restart Audio
        if (wasMicOn) await _startMicStream();
      }
    } catch (e) {
      developer.log('Error switching to video: $e');
      onShowError?.call(e.toString());
      isCameraOn = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendTextPrompt(String textPrompt) async {
    if (!isSessionActive || _session == null) return;
    isLoading = true;
    notifyListeners();

    try {
      await _session!.sendTextRealtime(textPrompt);
    } catch (e) {
      onShowError?.call(e.toString());
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _processMessagesContinuously() async {
    if (_session == null) return;
    try {
      await for (final message in _session!.receive()) {
        await _handleLiveServerMessage(message);
      }
    } catch (e) {
      onShowError?.call(e.toString());
    }
  }

  Future<void> _handleLiveServerMessage(LiveServerResponse response) async {
    final message = response.message;

    if (message is LiveServerContent) {
      if (message.modelTurn != null) {
        await _handleLiveServerContent(message);
      }

      _inputTranscriptionMessageIndex = _handleTranscription(
        message.inputTranscription,
        _inputTranscriptionMessageIndex,
        'Input transcription: ',
        true,
      );
      _outputTranscriptionMessageIndex = _handleTranscription(
        message.outputTranscription,
        _outputTranscriptionMessageIndex,
        'Output transcription: ',
        false,
      );

      if (message.interrupted != null && message.interrupted!) {
        developer.log('Interrupted: $response');
      }
    } else if (message is LiveServerToolCall && message.functionCalls != null) {
      await _handleLiveServerToolCall(message);
    } else if (message is GoingAwayNotice) {
      if (_activeSessionHandle != null) {
        unawaited(_sessionResume());
      }
    } else if (message is SessionResumptionUpdate &&
        message.resumable != null &&
        message.resumable!) {
      _activeSessionHandle = message.newHandle;
    }
  }

  int? _handleTranscription(
    Transcription? transcription,
    int? messageIndex,
    String prefix,
    bool fromUser,
  ) {
    int? currentIndex = messageIndex;
    if (transcription?.text != null) {
      if (currentIndex != null) {
        messages[currentIndex] = messages[currentIndex].copyWith(
          text: '${messages[currentIndex].text}${transcription!.text!}',
        );
      } else {
        messages.add(
          MessageData(
            text: '$prefix${transcription!.text!}',
            fromUser: fromUser,
          ),
        );
        currentIndex = messages.length - 1;
      }

      if (transcription.finished ?? false) {
        currentIndex = null;
        onScrollDown?.call();
      } else {
        notifyListeners(); // Trigger UI rebuild for streaming text
      }
    }
    return currentIndex;
  }

  Future<void> _handleLiveServerContent(LiveServerContent response) async {
    final partList = response.modelTurn?.parts;
    if (partList != null) {
      for (final part in partList) {
        if (part is TextPart) {
          messages.add(
            MessageData(
              text: part.text,
              fromUser: false,
              isThought: part.isThought ?? false,
            ),
          );
          onScrollDown?.call();
          notifyListeners();
        } else if (part is InlineDataPart) {
          if (part.mimeType.startsWith('audio')) {
            mediaManager.playAudioChunk(part.bytes);
          }
        } else {
          developer.log('receive part with type ${part.runtimeType}');
        }
      }
    }
  }

  Future<void> _handleLiveServerToolCall(LiveServerToolCall response) async {
    final functionCalls = response.functionCalls!.toList();
    if (functionCalls.isNotEmpty) {
      final functionCall = functionCalls.first;
      if (functionCall.name == 'setLightValues') {
        var color = functionCall.args['colorTemperature']! as String;
        var brightness = functionCall.args['brightness']! as int;

        // Mock Tool Execution
        final functionResult = {
          'colorTemprature':
              color, // original had a typo, keeping to preserve functionality intent
          'brightness': brightness,
        };

        await _session?.sendToolResponse([
          FunctionResponse(
            functionCall.name,
            functionResult,
            id: functionCall.id,
          ),
        ]);
      } else {
        throw UnimplementedError('Function not declared: ${functionCall.name}');
      }
    }
  }

  void simulateGoingAway() {
    if (isSessionActive && _session != null) {
      developer.log('Simulating GoingAwayNotice locally');
      _handleLiveServerMessage(
        LiveServerResponse(message: const GoingAwayNotice(timeLeft: '10')),
      );
    }
  }

  @override
  void dispose() {
    _stopSession(explicit: true);
    super.dispose();
  }

  static final _lightControlTool = FunctionDeclaration(
    'setLightValues',
    'Set the brightness and color temperature of a room light.',
    parameters: {
      'brightness': Schema.integer(
        description:
            'Light level from 0 to 100. Zero is off and 100 is full brightness.',
      ),
      'colorTemperature': Schema.string(
        description:
            'Color temperature of the light fixture, which can be `daylight`, `cool` or `warm`.',
      ),
    },
  );
}

// ============================================================================
// UI WIDGET
// Isolates presentation, keeping state out of the visual hierarchy.
// ============================================================================
class BidiPage extends StatefulWidget {
  const BidiPage({
    super.key,
    required this.title,
    required this.model,
    required this.useVertexBackend,
  });

  final String title;
  final GenerativeModel model;
  final bool useVertexBackend;

  @override
  State<BidiPage> createState() => _BidiPageState();
}

class _BidiPageState extends State<BidiPage> {
  late final BidiSessionController _controller;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = BidiSessionController(
      model: widget.model,
      useVertexBackend: widget.useVertexBackend,
      onShowError: _showError,
      onScrollDown: _scrollDown,
    );
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _textController.dispose();
    _textFieldFocus.dispose();
    super.dispose();
  }

  void _scrollDown() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Something went wrong'),
          content: SingleChildScrollView(child: SelectableText(message)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Live Stream Session',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.speed, size: 16),
                    label: const Text('Simulate GoAway'),
                    style: ElevatedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: _controller.isSessionActive
                        ? () => _controller.simulateGoingAway()
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_controller.isCameraOn)
                Container(
                  height: 200,
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: (!kIsWeb &&
                          defaultTargetPlatform == TargetPlatform.macOS)
                      ? FullCameraPreview(
                          controller: _controller.mediaManager.cameraController,
                          deviceId: _controller.mediaManager.selectedCameraId,
                          onInitialized: (controller) {
                            _controller.mediaManager
                                .setMacOSController(controller);
                          },
                        )
                      : (_controller.mediaManager.cameraController != null &&
                              _controller.mediaManager.controllerInitialized)
                          ? FullCameraPreview(
                              controller:
                                  _controller.mediaManager.cameraController,
                              deviceId:
                                  _controller.mediaManager.selectedCameraId,
                              onInitialized: (controller) {},
                            )
                          : const Center(child: CircularProgressIndicator()),
                ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _controller.messages.length,
                  itemBuilder: (context, idx) {
                    final message = _controller.messages[idx];
                    return MessageWidget(
                      text: message.text,
                      image: message.imageBytes != null
                          ? Image.memory(
                              message.imageBytes!,
                              cacheWidth: 400,
                              cacheHeight: 400,
                            )
                          : null,
                      isFromUser: message.fromUser ?? false,
                      isThought: message.isThought,
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        focusNode: _textFieldFocus,
                        controller: _textController,
                        onSubmitted: (text) {
                          _controller.sendTextPrompt(text);
                          _textController.clear();
                        },
                      ),
                    ),
                    const SizedBox.square(dimension: 15),
                    AudioVisualizer(
                      audioStreamIsActive: _controller.isMicOn,
                      amplitudeStream: _controller.mediaManager.amplitudeStream,
                    ),
                    const SizedBox.square(dimension: 15),
                    IconButton(
                      tooltip: 'Start Streaming',
                      onPressed: !_controller.isLoading
                          ? () => _controller.toggleSession()
                          : null,
                      icon: Icon(
                        Icons.network_wifi,
                        color: _controller.isSessionActive
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Send Stream Message',
                      onPressed: !_controller.isLoading
                          ? () => _controller.toggleMic()
                          : null,
                      icon: Icon(
                        _controller.isMicOn ? Icons.stop : Icons.mic,
                        color: _controller.isLoading
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Toggle Camera',
                      onPressed: !_controller.isLoading
                          ? () => _controller.toggleCamera()
                          : null,
                      icon: Icon(
                        _controller.isCameraOn
                            ? Icons.videocam_off
                            : Icons.videocam,
                        color: _controller.isLoading
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (!_controller.isLoading)
                      IconButton(
                        tooltip: 'Send Text',
                        onPressed: () {
                          _controller.sendTextPrompt(_textController.text);
                          _textController.clear();
                        },
                        icon: Icon(
                          Icons.send,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    else
                      const CircularProgressIndicator(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
