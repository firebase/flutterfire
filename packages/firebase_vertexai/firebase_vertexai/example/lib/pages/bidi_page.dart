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
import 'dart:typed_data';
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import '../widgets/message_widget.dart';
import '../utils/audio_player.dart';
import '../utils/audio_recorder.dart';

class BidiPage extends StatefulWidget {
  const BidiPage({super.key, required this.title, required this.model});

  final String title;
  final GenerativeModel model;

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
  final _audioManager = AudioStreamManager();
  final _audioRecorder = InMemoryAudioRecorder();
  var _chunkBuilder = BytesBuilder();
  var _audioIndex = 0;
  StreamController<bool> _stopController = StreamController<bool>();

  @override
  void initState() {
    super.initState();

    final config = LiveGenerationConfig(
      speechConfig: SpeechConfig(voice: Voice.fenrir),
      responseModalities: [
        ResponseModalities.audio,
      ],
    );

    _liveModel = FirebaseVertexAI.instance.liveGenerativeModel(
      model: 'gemini-2.0-flash-exp',
      liveGenerationConfig: config,
      tools: [
        Tool.functionDeclarations([lightControlTool]),
      ],
    );
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
      _audioManager.stopAudioPlayer();
      _audioManager.disposeAudioPlayer();

      _audioRecorder.stopRecording();

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
                    image: _messages[idx].image,
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
        processMessagesContinuously(
          stopSignal: _stopController,
        ),
      );
    } else {
      _stopController.add(true);
      await _stopController.close();

      await _session.close();
      await _audioManager.stopAudioPlayer();
      await _audioManager.disposeAudioPlayer();
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
      await _audioRecorder.checkPermission();
      final audioRecordStream = _audioRecorder.startRecordingStream();
      // Map the Uint8List stream to InlineDataPart stream
      final mediaChunkStream = audioRecordStream.map((data) {
        return InlineDataPart('audio/pcm', data);
      });
      await _session.sendMediaStream(mediaChunkStream);
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stopRecording();
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

  Future<void> processMessagesContinuously({
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

  Future<void> _handleLiveServerMessage(LiveServerMessage response) async {
    if (response is LiveServerContent && response.modelTurn != null) {
      await _handleLiveServerContent(response);
    }

    if (response is LiveServerContent &&
        response.turnComplete != null &&
        response.turnComplete!) {
      await _handleTurnComplete();
    }

    if (response is LiveServerContent &&
        response.interrupted != null &&
        response.interrupted!) {
      log('Interrupted: $response');
    }

    if (response is LiveServerToolCall && response.functionCalls != null) {
      await _handleLiveServerToolCall(response);
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
          log('receive part with type ${part.runtimeType}');
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
      _chunkBuilder.add(part.bytes);
      _audioIndex++;
      if (_audioIndex == 15) {
        Uint8List chunk = await audioChunkWithHeader(
          _chunkBuilder.toBytes(),
          24000,
        );
        _audioManager.addAudio(chunk);
        _chunkBuilder.clear();
        _audioIndex = 0;
      }
    }
  }

  Future<void> _handleTurnComplete() async {
    if (_chunkBuilder.isNotEmpty) {
      Uint8List chunk = await audioChunkWithHeader(
        _chunkBuilder.toBytes(),
        24000,
      );
      _audioManager.addAudio(chunk);
      _audioIndex = 0;
      _chunkBuilder.clear();
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
        await _session.send(
          input: Content.functionResponse(functionCall.name, functionResult),
        );
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
