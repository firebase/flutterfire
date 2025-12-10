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

import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';

import '../utils/audio_input.dart';
import '../utils/audio_output.dart';
import '../widgets/message_widget.dart';

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

class LightControl {
  final int? brightness;
  final String? colorTemperature;

  LightControl({this.brightness, this.colorTemperature});
}

class _BidiPageState extends State<BidiPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  final List<MessageData> _messages = <MessageData>[];
  bool _loading = false;
  bool _sessionOpening = false;
  bool _recording = false;
  late LiveGenerativeModel _liveModel;
  late LiveSession _session;
  StreamController<bool> _stopController = StreamController<bool>();
  final AudioOutput _audioOutput = AudioOutput();
  final AudioInput _audioInput = AudioInput();
  int? _inputTranscriptionMessageIndex;
  int? _outputTranscriptionMessageIndex;

  @override
  void initState() {
    super.initState();

    final config = LiveGenerationConfig(
      speechConfig: SpeechConfig(voiceName: 'Fenrir'),
      responseModalities: [
        ResponseModalities.audio,
      ],
      inputAudioTranscription: AudioTranscriptionConfig(),
      outputAudioTranscription: AudioTranscriptionConfig(),
    );

    // ignore: deprecated_member_use
    _liveModel = widget.useVertexBackend
        ? FirebaseAI.vertexAI().liveGenerativeModel(
            model: 'gemini-live-2.5-flash-preview-native-audio-09-2025',
            liveGenerationConfig: config,
            tools: [
              Tool.functionDeclarations([lightControlTool]),
            ],
          )
        : FirebaseAI.googleAI().liveGenerativeModel(
            model: 'gemini-2.5-flash-native-audio-preview-09-2025',
            liveGenerationConfig: config,
            tools: [
              Tool.functionDeclarations([lightControlTool]),
            ],
          );
    _initAudio();
  }

  Future<void> _initAudio() async {
    await _audioOutput.init();
    await _audioInput.init();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(
          milliseconds: 750,
        ),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  @override
  void dispose() {
    if (_sessionOpening) {
      _stopController.close();
      _sessionOpening = false;
      _session.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemBuilder: (context, idx) {
                  return MessageWidget(
                    text: _messages[idx].text,
                    image: _messages[idx].imageBytes != null
                        ? Image.memory(
                            _messages[idx].imageBytes!,
                            cacheWidth: 400,
                            cacheHeight: 400,
                          )
                        : null,
                    isFromUser: _messages[idx].fromUser ?? false,
                  );
                },
                itemCount: _messages.length,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 25,
                horizontal: 15,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      focusNode: _textFieldFocus,
                      controller: _textController,
                      onSubmitted: _sendTextPrompt,
                    ),
                  ),
                  const SizedBox.square(
                    dimension: 15,
                  ),
                  IconButton(
                    tooltip: 'Start Streaming',
                    onPressed: !_loading
                        ? () async {
                            await _setupSession();
                          }
                        : null,
                    icon: Icon(
                      Icons.network_wifi,
                      color: _sessionOpening
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Send Stream Message',
                    onPressed: !_loading
                        ? () async {
                            if (_recording) {
                              await _stopRecording();
                            } else {
                              await _startRecording();
                            }
                          }
                        : null,
                    icon: Icon(
                      _recording ? Icons.stop : Icons.mic,
                      color: _loading
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (!_loading)
                    IconButton(
                      onPressed: () async {
                        await _sendTextPrompt(_textController.text);
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
      ),
    );
  }

  final lightControlTool = FunctionDeclaration(
    'setLightValues',
    'Set the brightness and color temperature of a room light.',
    parameters: {
      'brightness': Schema.integer(
        description: 'Light level from 0 to 100. '
            'Zero is off and 100 is full brightness.',
      ),
      'colorTemperature': Schema.string(
        description: 'Color temperature of the light fixture, '
            'which can be `daylight`, `cool` or `warm`.',
      ),
    },
  );

  Future<Map<String, Object?>> _setLightValues({
    int? brightness,
    String? colorTemperature,
  }) async {
    final apiResponse = {
      'colorTemprature': 'warm',
      'brightness': brightness,
    };
    return apiResponse;
  }

  Future<void> _setupSession() async {
    setState(() {
      _loading = true;
    });

    if (!_sessionOpening) {
      _session = await _liveModel.connect();
      _sessionOpening = true;
      _stopController = StreamController<bool>();
      unawaited(
        _processMessagesContinuously(
          stopSignal: _stopController,
        ),
      );
    } else {
      _stopController.add(true);
      await _stopController.close();

      await _session.close();
      _sessionOpening = false;
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _startRecording() async {
    setState(() {
      _recording = true;
    });
    try {
      var inputStream = await _audioInput.startRecordingStream();
      await _audioOutput.playStream();
      if (inputStream != null) {
        await for (final data in inputStream) {
          await _session.sendAudioRealtime(InlineDataPart('audio/pcm', data));
        }
      }
    } catch (e) {
      developer.log(e.toString());
      _showError(e.toString());
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioInput.stopRecording();
    } catch (e) {
      _showError(e.toString());
    }

    setState(() {
      _recording = false;
    });
  }

  Future<void> _sendTextPrompt(String textPrompt) async {
    setState(() {
      _loading = true;
    });
    try {
      final prompt = Content.text(textPrompt);
      await _session.send(input: prompt, turnComplete: true);
    } catch (e) {
      _showError(e.toString());
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _processMessagesContinuously({
    required StreamController<bool> stopSignal,
  }) async {
    bool shouldContinue = true;

    //listen to the stop signal stream
    stopSignal.stream.listen((stop) {
      if (stop) {
        shouldContinue = false;
      }
    });

    while (shouldContinue) {
      try {
        await for (final message in _session.receive()) {
          // Process the received message
          await _handleLiveServerMessage(message);
        }
      } catch (e) {
        _showError(e.toString());
        break;
      }

      // Optionally add a delay before restarting, if needed
      await Future.delayed(
        const Duration(milliseconds: 100),
      ); // Small delay to prevent tight loops
    }
  }

  Future<void> _handleLiveServerMessage(LiveServerResponse response) async {
    final message = response.message;

    if (message is LiveServerContent) {
      if (message.modelTurn != null) {
        await _handleLiveServerContent(message);
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
            _messages[currentIndex] = _messages[currentIndex].copyWith(
              text: '${_messages[currentIndex].text}${transcription!.text!}',
            );
          } else {
            _messages.add(
              MessageData(
                text: '$prefix${transcription!.text!}',
                fromUser: fromUser,
              ),
            );
            currentIndex = _messages.length - 1;
          }
          if (transcription.finished ?? false) {
            currentIndex = null;
          }
          setState(_scrollDown);
        }
        return currentIndex;
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
    }
  }

  Future<void> _handleLiveServerContent(LiveServerContent response) async {
    final partList = response.modelTurn?.parts;
    if (partList != null) {
      for (final part in partList) {
        if (part is TextPart) {
          await _handleTextPart(part);
        } else if (part is InlineDataPart) {
          await _handleInlineDataPart(part);
        } else {
          developer.log('receive part with type ${part.runtimeType}');
        }
      }
    }
  }

  Future<void> _handleTextPart(TextPart part) async {
    if (!_loading) {
      setState(() {
        _loading = true;
      });
    }
    _messages.add(MessageData(text: part.text, fromUser: false));
    setState(() {
      _loading = false;
      _scrollDown();
    });
  }

  Future<void> _handleInlineDataPart(InlineDataPart part) async {
    if (part.mimeType.startsWith('audio')) {
      _audioOutput.addAudioStream(part.bytes);
    }
  }

  Future<void> _handleLiveServerToolCall(LiveServerToolCall response) async {
    final functionCalls = response.functionCalls!.toList();
    if (functionCalls.isNotEmpty) {
      final functionCall = functionCalls.first;
      if (functionCall.name == 'setLightValues') {
        var color = functionCall.args['colorTemperature']! as String;
        var brightness = functionCall.args['brightness']! as int;
        final functionResult = await _setLightValues(
          brightness: brightness,
          colorTemperature: color,
        );
        await _session.sendToolResponse([
          FunctionResponse(
            functionCall.name,
            functionResult,
            id: functionCall.id,
          ),
        ]);
      } else {
        throw UnimplementedError(
          'Function not declared to the model: ${functionCall.name}',
        );
      }
    }
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Something went wrong'),
          content: SingleChildScrollView(
            child: SelectableText(message),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
