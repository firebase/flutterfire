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
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
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
  bool _session_opening = false;
  bool _recording = false;
  late LiveGenerativeModel _liveModel;
  late LiveSession _session;
  final _audioManager = AudioStreamManager();
  final _audioRecorder = InMemoryAudioRecorder();

  @override
  void initState() {
    super.initState();

    final config = LiveGenerationConfig(
      speechConfig: SpeechConfig(voice: Voices.Charon),
      responseModalities: [ResponseModalities.Audio],
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
    if (_session_opening) {
      _audioManager.stopAudioPlayer();
      _audioManager.disposeAudioPlayer();

      _audioRecorder.stopRecording();

      _session_opening = false;
      print('close the websocket session.');
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
                      onSubmitted: _sendChatMessage,
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
                      color: _session_opening
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
                              _recording = false;
                            } else {
                              await _startRecording();
                              _recording = true;
                            }
                          }
                        : null,
                    icon: Icon(
                      Icons.mic,
                      color: _loading
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (!_loading)
                    IconButton(
                      onPressed: () async {
                        await _sendTextPrompt(textPrompt: _textController.text);
                      },
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  else
                    const CircularProgressIndicator(),
                  IconButton(
                    onPressed: () async {
                      await _checkWsStatus();
                    },
                    icon: Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
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

  Future<Map<String, Object?>> _setLightValues(
      {int? brightness, String? colorTemprature}) async {
    print('Set brightness: $brightness, colorTemprature: $colorTemprature');
    final apiResponse = {
      'colorTemprature': 'warm',
      'brightness': brightness,
    };
    return apiResponse;
  }

  Future<void> _sendChatMessage(String message) async {
    setState(() {
      _loading = true;
    });

    setState(() {
      _loading = false;
    });
  }

  Future<void> _setupSession() async {
    setState(() {
      _loading = true;
    });

    if (!_session_opening) {
      _session = await _liveModel.connect();
      _session_opening = true;
      unawaited(_handle_response());
    } else {
      await _session!.close();
      await _audioManager.stopAudioPlayer();
      await _audioManager.disposeAudioPlayer();
      _session_opening = false;
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> writeAudioFile(
    List<Uint8List> audioChunks,
    String filePath,
    int sampleRate,
  ) async {
    final file = File(filePath);
    final sink = file.openWrite();

    final builder = BytesBuilder();
    for (final chunk in audioChunks) {
      builder.add(chunk);
    }

    Uint8List mergedChunk = builder.toBytes();

    var processedChunk =
        await AudioUtil.audioChunkWithHeader(mergedChunk, 24000);
    sink.add(processedChunk);

    await sink.close();
  }

  Future<void> _startRecording() async {
    await _audioRecorder.checkPermission();
    // await _audioRecorder.startRecordingFile();
    await _audioRecorder.startRecordingStream(_sendAudioRealtimeWithNoSplit);
  }

  Future<void> _stopRecording() async {
    await _audioRecorder.stopRecording();
    // var audioPrompt = await _audioRecorder.getAudioBytes(fromFile: true);
    // await _sendAudioRealtimeWithNoSplit(audioPrompt);
    // await _streamAudioChunks(audioPrompt, 'audio/pcm');
    // await _sendAudioPrompt(audioPrompt);
    // await _sendAudioRealtime(audioPrompt);
  }

  List<Uint8List> _splitIntoChunks(Uint8List audioData, int chunkSize) {
    final chunks = <Uint8List>[];

    for (var i = 0; i < audioData.length; i += chunkSize) {
      final end =
          (i + chunkSize < audioData.length) ? i + chunkSize : audioData.length;
      chunks.add(audioData.sublist(i, end));
    }
    return chunks;
  }

  // Future<void> _streamAudioChunks(Uint8List audioData, String mimeType) async {
  //   setState(() {
  //     _loading = true;
  //   });
  //   final chunks = _splitIntoChunks(audioData, 1024);

  //   final streamController = StreamController<InlineDataPart>();
  //   for (var chunk in chunks) {
  //     if (identical(chunk, chunks.last)) {
  //       final lastData = InlineDataPart('audio/pcm', chunk, willContinue: true);
  //       streamController.add(lastData);
  //     } else {
  //       final data = InlineDataPart('audio/pcm', chunk, willContinue: true);
  //       streamController.add(data);
  //     }
  //   }
  //   streamController.close();
  //   print('streamController has stream closed');
  //   // Use startStream with the stream of chunks
  //   await for (final message in _session!
  //       .startStream(stream: streamController.stream, mimeType: mimeType)) {
  //     // Process the message received from the server
  //     print('Received message: $message');
  //   }
  //   print('Send all audio chunk to server');
  //   _session.printWsStatus();
  //   setState(() {
  //     _loading = false;
  //   });
  // }

  // Future<void> _sendAudioRealtime(Uint8List audio) async {
  //   setState(() {
  //     _loading = true;
  //   });
  //   final chunks = _splitIntoChunks(audio, 512);

  //   final media_chunks = <InlineDataPart>[];
  //   for (var chunk in chunks) {
  //     if (identical(chunk, chunks.last)) {
  //       final lastData = InlineDataPart('audio/pcm', chunk, willContinue: true);
  //       media_chunks.add(lastData);
  //     } else {
  //       final data = InlineDataPart('audio/pcm', chunk, willContinue: true);
  //       media_chunks.add(data);
  //     }
  //   }
  //   await _session!.stream(mediaChunks: media_chunks);
  //   print('Stream realtime audio chunks to server in one request');
  //   _session.printWsStatus();
  //   setState(() {
  //     _loading = false;
  //   });
  // }

  Future<void> _sendAudioRealtimeWithNoSplit(Uint8List audio) async {
    setState(() {
      _loading = true;
    });

    final media_chunks = <InlineDataPart>[];
    final data = InlineDataPart('audio/pcm', audio, willContinue: true);
    media_chunks.add(data);

    await _session!.sendMediaChunks(mediaChunks: media_chunks);
    // print('Stream realtime audio in one chunk to server in one request');
    //_session.printWsStatus();
    setState(() {
      _loading = false;
    });
  }

  // Future<void> _sendAudioPrompt(Uint8List audio) async {
  //   setState(() {
  //     _loading = true;
  //   });
  //   final prompt = Content.inlineData('audio/pcm', audio);
  //   await _session!.send(input: prompt);

  //   print('Sent audio chunk to server');
  //   _session.printWsStatus();
  //   setState(() {
  //     _loading = false;
  //   });
  // }

  Future<void> _sendPremadeAudioPayload() async {
    setState(() {
      _loading = true;
    });
    final dir = await getDownloadsDirectory();
    final path = '${dir!.path}/audio_payload.json';

    final file = File(path!);
    final dataDump = await file.readAsString();

    _session!.dumpData(dataDump);

    setState(() {
      _loading = false;
    });
  }

  Future<void> _checkWsStatus() async {
    _session!.printWsStatus();
  }

  Future<void> _sendTextPrompt({String? textPrompt}) async {
    setState(() {
      _loading = true;
    });
    if (_session != null) {
      late Content prompt;
      if (textPrompt != null) {
        prompt = Content.text(textPrompt);
      }

      if (prompt == null) {
        print('no prompt');
        setState(() {
          _loading = false;
        });
        return;
      }

      await _session!.send(input: prompt, turnComplete: true);
      print('Prompt sent to server');
      _session.printWsStatus();
      // await _handle_response();
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _handle_response() async {
    final responseStream = _session!.receive();
    var chunkBuilder = BytesBuilder();
    var audioIndex = 0;
    await for (var response in responseStream) {
      if (response is LiveServerContent && response.modelTurn != null) {
        final partList = response.modelTurn?.parts;
        if (partList != null) {
          for (var part in partList) {
            if (part is TextPart) {
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
            } else if (part is InlineDataPart) {
              print('receive data part: mimeType: ${part.mimeType}');
              if (part.mimeType.startsWith('audio')) {
                print('Audio chunk length: ${part.bytes.length}');

                chunkBuilder.add(part.bytes);
                audioIndex++;

                if (audioIndex == 15) {
                  Uint8List chunk = await AudioUtil.audioChunkWithHeader(
                    chunkBuilder.toBytes(),
                    24000,
                  );
                  _audioManager.addAudio(chunk);
                  chunkBuilder.clear();
                  audioIndex = 0;
                }
              }
            } else {
              print('receive part with type ${part.runtimeType}');
            }
          }
        }
      }

      // Check if the turn is complete
      if (response is LiveServerContent &&
          response.turnComplete != null &&
          response.turnComplete!) {
        print('Turn complete!');
        if (chunkBuilder.isNotEmpty) {
          Uint8List chunk = await AudioUtil.audioChunkWithHeader(
            chunkBuilder.toBytes(),
            24000,
          );
          _audioManager.addAudio(chunk);
          audioIndex = 0;
          chunkBuilder.clear();
        }
      }

      if (response is LiveServerToolCall && response.functionCalls != null) {
        final functionCalls = response.functionCalls!.toList();
        // When the model response with a function call, invoke the function.
        if (functionCalls.isNotEmpty) {
          final functionCall = functionCalls.first;
          if (functionCall.name == 'setLightValues') {
            var color = functionCall.args['colorTemperature']! as String;
            var brightness = functionCall.args['brightness']! as int;
            final functionResult = await _setLightValues(
                brightness: brightness, colorTemprature: color);
            // Send the response to the model so that it can use the result to
            // generate text for the user.
            await _session!.send(
              input:
                  Content.functionResponse(functionCall.name, functionResult),
            );
          } else {
            throw UnimplementedError(
              'Function not declared to the model: ${functionCall.name}',
            );
          }
        }
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
