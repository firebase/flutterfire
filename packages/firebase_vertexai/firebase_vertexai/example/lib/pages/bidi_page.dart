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
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:just_audio/just_audio.dart';
// import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/material.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import '../widgets/message_widget.dart';

class AudioUtil {
  static final Uint8List wavHeaderBase = Uint8List.fromList([
    // "RIFF" (Size will be updated later)
    82, 73, 70, 70, 0, 0, 0, 0,
    // WAVE
    87, 65, 86, 69,
    // fmt
    102, 109, 116, 32,
    // fmt chunk size 16
    16, 0, 0, 0,
    // Type of format
    1, 0,
    // One channel (Adjust if needed)
    1, 0,
    // Sample rate (Will be updated)
    0, 0, 0, 0,
    // Byte rate (Will be updated)
    0, 0, 0, 0,
    // Block align
    2, 0, // For 16-bit mono
    // bitsize
    16, 0,
    // "data" (Size will be updated later)
    100, 97, 116, 97, 0, 0, 0, 0,
  ]);

  static Future<Uint8List> audioChunkWithHeader(
    List<int> data,
    int sampleRate,
  ) async {
    // var channels = 1;
    // int byteRate = ((16 * sampleRate * channels) / 8).round();
    // var size = data.length;
    // var fileSize = size + 36;

    // // 1. *Copy* the header base:
    // final header = Uint8List.fromList(
    //   wavHeaderBase,
    // ); // Create a *new* Uint8List by copying

    // // 2. Update the *copy* (using byteData view for efficient manipulation)
    // final byteData = ByteData.view(header.buffer);

    // // RIFF size
    // byteData.setUint32(4, fileSize, Endian.little);
    // // Sample rate
    // byteData.setUint32(20, sampleRate, Endian.little);
    // // Byte rate
    // byteData.setUint32(24, byteRate, Endian.little);
    // // Data size
    // byteData.setUint32(40, size, Endian.little);

    // // 3. Append the data *after* the header
    // final combined = Uint8List(36 + size);
    // combined.setAll(0, header);
    // combined.setRange(36, 36 + size, data);

    // return combined;
    var channels = 1;

    int byteRate = ((16 * sampleRate * channels) / 8).round();

    var size = data.length;
    var fileSize = size + 36;

    Uint8List header = Uint8List.fromList([
      // "RIFF"
      82, 73, 70, 70,
      fileSize & 0xff,
      (fileSize >> 8) & 0xff,
      (fileSize >> 16) & 0xff,
      (fileSize >> 24) & 0xff,
      // WAVE
      87, 65, 86, 69,
      // fmt
      102, 109, 116, 32,
      // fmt chunk size 16
      16, 0, 0, 0,
      // Type of format
      1, 0,
      // One channel
      channels, 0,
      // Sample rate
      sampleRate & 0xff,
      (sampleRate >> 8) & 0xff,
      (sampleRate >> 16) & 0xff,
      (sampleRate >> 24) & 0xff,
      // Byte rate
      byteRate & 0xff,
      (byteRate >> 8) & 0xff,
      (byteRate >> 16) & 0xff,
      (byteRate >> 24) & 0xff,
      // Uhm
      ((16 * channels) / 8).round(), 0,
      // bitsize
      16, 0,
      // "data"
      100, 97, 116, 97,
      size & 0xff,
      (size >> 8) & 0xff,
      (size >> 16) & 0xff,
      (size >> 24) & 0xff,
      // incoming data
      ...data
    ]);
    return header;
  }
}

class ByteStreamAudioSource extends StreamAudioSource {
  ByteStreamAudioSource(this.bytes) : super(tag: 'Byte Stream Audio');

  final Uint8List bytes;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/wav', // Or the appropriate content type
    );
  }
}

class AudioStreamManager {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final StreamController<Uint8List> _audioChunkController =
      StreamController<Uint8List>();
  var _chunkIndex = 0;

  AudioStreamManager() {
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    // 1. Create a ConcatenatingAudioSource to handle the stream
    await _audioPlayer.setAudioSource(
      ConcatenatingAudioSource(
        children: [],
      ),
    );

    // 2. Listen to the stream of audio chunks
    _audioChunkController.stream.listen(_addAudioChunk);

    await _audioPlayer.play(); // Start playing (even if initially empty)
  }

  Future<void> _addAudioChunk(Uint8List chunk) async {
    // 3. Convert the chunk to a buffer audio source
    var buffer = ByteStreamAudioSource(chunk);
    // final buffer = AudioSource.uri(
    //   Uri.dataFromBytes(
    //     chunk,
    //     mimeType: 'audio/wav; rate=24000; channels=1; endian=little; bits=16',
    //   ), // Adjust mime type if needed
    // );

    // 4. Add the buffer to the ConcatenatingAudioSource
    final currentSource = _audioPlayer.audioSource! as ConcatenatingAudioSource;
    print('Add new Audio Chunk to player');

    // The crucial change: use add instead of insert
    await currentSource.add(buffer);

    _chunkIndex++;
    print('play audio chunk $_chunkIndex');
  }

  void addAudio(Uint8List chunk) {
    _audioChunkController.add(chunk);
  }

  Future<void> stop() async {
    print('total audio chunks are $_chunkIndex');
    await _audioPlayer.stop();
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
    await _audioChunkController.close();
  }
}

class BidiPage extends StatefulWidget {
  const BidiPage({super.key, required this.title, required this.model});

  final String title;
  final GenerativeModel model;

  @override
  State<BidiPage> createState() => _BidiPageState();
}

class _BidiPageState extends State<BidiPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  final List<MessageData> _messages = <MessageData>[];
  bool _loading = false;
  bool _session_opening = false;
  late AsyncSession _session;
  //final AudioPlayer _player = AudioPlayer();
  final _audioManager = AudioStreamManager();

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
                      Icons.mic,
                      color: _session_opening
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Send Stream Message',
                    onPressed: !_loading
                        ? () async {
                            await _startRecordingStreaming(
                                _textController.text);
                          }
                        : null,
                    icon: Icon(
                      Icons.abc,
                      color: _loading
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (!_loading)
                    IconButton(
                      onPressed: () async {
                        await _sendChatMessage(_textController.text);
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
    // const location = 'us-central1';
    // const baseUrl = 'generativelanguage.googleapis.com/';
    // const apiVersion = 'v1alpha';
    // const apiKey = 'AIzaSyCVF_c-cFSmHdC4-xbmmCUH3u8YdIBPgjA';
    const modelName = 'gemini-2.0-flash-exp';
    // const config = {
    //   'generation_config': {
    //     'response_modalities': ['AUDIO'],
    //     'speech_config': {
    //       'voice_config': {
    //         'prebuilt_voice_config': {'voice_name': 'Aoede'}
    //       }
    //     }
    //   },
    // };
    final config = LiveGenerationConfig(
      speechConfig: SpeechConfig(voice: Voices.Charon),
      responseModalities: [ResponseModalities.Audio],
    );
    //var live = AsyncLive(baseUrl, apiKey, apiVersion, location);
    if (!_session_opening) {
      _session = await widget.model.connect(model: modelName, config: config);
      _session_opening = true;
    } else {
      await _session!.close();
      await _audioManager.stop();
      await _audioManager.dispose();
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

  // Future<void> waitForAudioToStop() async {
  //   await for (final playerState in _player.playerStateStream) {
  //     if (playerState.playing) {
  //       print('Audio is still playing');
  //     } else {
  //       print('Audio has stopped');
  //       break;
  //     }
  //   }
  // }

  Future<void> _startRecordingStreaming(String prompt) async {
    setState(() {
      _loading = true;
    });
    if (_session != null) {
      await _session!.send(input: Content.text(prompt), turnComplete: true);

      final audioChunks = <Uint8List>[];

      final responseStream = _session!.receive();
      var chunkBuilder = BytesBuilder();
      var audioIndex = 0;
      await for (var response in responseStream) {
        if (response.serverContent?.modelTurn != null) {
          final partList = response.serverContent?.modelTurn?.parts;
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

                print('played received data part');
              } else {
                print('receive part with type ${part.runtimeType}');
              }
            }
          }
        }

        // Check if the turn is complete
        if (response.serverContent?.turnComplete ?? false) {
          print('Turn complete!');
          if (chunkBuilder.isNotEmpty) {
            Uint8List chunk = await AudioUtil.audioChunkWithHeader(
              chunkBuilder.toBytes(),
              24000,
            );
            _audioManager.addAudio(chunk);
          }

          //await audioChunkController.close();
          //await _flutterSound.closePlayer();
          // String filePath = '/Users/cynthiajiang/Downloads/a_sample.wav';
          // await writeAudioFile(audioChunks, filePath, 24000);
          // String wavFilePath = '/Users/cynthiajiang/Downloads/a_sample.wav';
          // await _player.setAudioSource(AudioSource.file(filePath));
          // await _player.play();

          break; // Exit the loop if the turn is complete
        }
      }
    }

    setState(() {
      _loading = false;
    });
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
