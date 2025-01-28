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

import 'package:flutter/material.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import '../widgets/message_widget.dart';

class AudioUtil {
  static Future<Uint8List> audioChunkWithHeader(
    List<int> data,
    int sampleRate,
  ) async {
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
      stream: Stream.fromIterable([bytes.sublist(start, end)]),
      contentType: 'audio/wav', // Or the appropriate content type
    );
  }
}

class AudioStreamManager {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final StreamController<Uint8List> _audioChunkController =
      StreamController<Uint8List>();

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
  }

  void addAudio(Uint8List chunk) {
    _audioChunkController.add(chunk);
  }

  Future<void> stop() async {
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
                            await _startRecordingStreaming();
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
    const location = 'us-central1';
    const baseUrl = 'generativelanguage.googleapis.com/';
    const apiVersion = 'v1alpha';
    const apiKey = '';
    const model = 'gemini-2.0-flash-exp';
    const config = {
      'generation_config': {
        'response_modalities': ['AUDIO'],
        'speech_config': {
          'voice_config': {
            'prebuilt_voice_config': {'voice_name': 'Aoede'}
          }
        }
      },
    };
    var live = AsyncLive(baseUrl, apiKey, apiVersion, location);
    if (!_session_opening) {
      _session = await live.connect(model: model, config: config);
      _session_opening = true;
    } else {
      await _session!.close();
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

  Uint8List audioChunkWithHeader(Uint8List audioChunk, int sampleRate) {
    final channels = 1; // Mono
    final bitsPerSample = 16;
    final bytesPerSample = bitsPerSample ~/ 8;
    final blockAlign = channels * bytesPerSample;
    final byteRate = sampleRate * blockAlign;
    final subChunk2Size = audioChunk.lengthInBytes;
    final chunkSize = 36 + subChunk2Size;

    final header = Uint8List.fromList([
      ...ascii.encode('RIFF'), // ChunkID
      chunkSize, 0, 0, 0, // ChunkSize
      ...ascii.encode('WAVE'), // Format
      ...ascii.encode('fmt '), // Subchunk1ID
      16, 0, 0, 0, // Subchunk1Size
      1, 0, // AudioFormat
      channels, 0, // NumChannels
      sampleRate, 0, 0, 0, // SampleRate
      byteRate, 0, 0, 0, // ByteRate
      blockAlign, 0, // BlockAlign
      bitsPerSample, 0, // BitsPerSample
      ...ascii.encode('data'), // Subchunk2ID
      subChunk2Size, 0, 0, 0, // Subchunk2Size
    ]);

    final builder = BytesBuilder();
    builder.add(header);
    builder.add(audioChunk);

    return builder.toBytes();
  }

  Future<void> playAudioStreamJustAudio(Stream<Uint8List> audioStream) async {
    try {
      final concatenatingAudioSource = ConcatenatingAudioSource(
        children: [],
      );

      final subscription = audioStream.listen((audioChunk) {
        //var dataUri = 'data:audio/pcm;base64,${base64Decode(audioChunk)}';
        // var dataUri = 'data:audio/pcm;base64,${base64Encode(audioChunk)}';
        // print('AudioStream Add audio chunk $dataUri');
        concatenatingAudioSource.add(ByteStreamAudioSource(audioChunk));
        print('audio source children ${concatenatingAudioSource.length}');
        // concatenatingAudioSource.add(
        //   AudioSource.uri(
        //     Uri.parse(dataUri),
        //   ),
        // );
      });
      print('Player start play');
      // await _player.setAudioSource(concatenatingAudioSource);
      // await _player.setVolume(1);
      // await _player.play();
      await subscription.cancel();
    } catch (e) {
      _showError(e.toString());
      print('Error playing audio: $e');
    }
  }

  // Future<void> playAudioStreamFlutterSound(
  //     Stream<Uint8List> audioStream) async {
  //   try {
  //     // Initialize the player
  //     await _flutterSound.openPlayer();
  //     await _flutterSound.startPlayerFromStream(
  //         codec: Codec.pcm16, numChannels: 1, sampleRate: 24000);

  //     // Subscribe to the audio stream
  //     final subscription = audioStream.listen((audioChunk) async {
  //       // Feed each chunk to the player
  //       print('flutter sound feed in audio');
  //       _flutterSound.foodSink!.add(FoodData(audioChunk));
  //     });

  //     // Keep the subscription active until the stream is done
  //     await subscription.asFuture();
  //     await subscription.cancel();

  //     // Close the player when finished
  //     await _flutterSound.closePlayer();
  //   } catch (e) {
  //     print("Error playing audio: $e");
  //   }
  // }

  Future<void> _startRecordingStreaming() async {
    setState(() {
      _loading = true;
    });
    if (_session != null) {
      await _session!
          .send(input: Content.text('tell a short story'), turnComplete: true);

      final audioChunks = <Uint8List>[];

      // Start playing the audio stream
      //await playAudioStreamJustAudio(audioChunkController.stream);

      final responseStream = _session!.receive();
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
                  // var processAudio = audioChunkWithHeader(part.bytes, 24000);
                  // // print(part.bytes);
                  // var dataUri =
                  //     'data:audio/pcm;base64,${base64Encode(processAudio)}';
                  // await _player.setAudioSource(
                  //   ByteStreamAudioSource(
                  //     processAudio,
                  //   ),
                  // );
                  // await _player.setAudioSource(
                  //   AudioSource.uri(
                  //     Uri.parse(dataUri),
                  //   ),
                  // );
                  //await _player.play();
                  Uint8List chunk =
                      await AudioUtil.audioChunkWithHeader(part.bytes, 24000);
                  _audioManager.addAudio(chunk);
                  //audioChunkController.sink.add(uint8list);

                  // var audioSource = ByteStreamAudioSource(uint8list);
                  // await _player.setAudioSource(audioSource);
                  // await _player.play();
                  // await waitForAudioToStop();

                  audioChunks.add(part.bytes);
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

          //await audioChunkController.close();
          //await _flutterSound.closePlayer();
          // String filePath = '/Users/cynthiajiang/Downloads/a_sample.wav';
          // await writeAudioFile(audioChunks, filePath, 24000);
          // String wavFilePath = '/Users/cynthiajiang/Downloads/a_sample.wav';
          // await _player.setAudioSource(AudioSource.file(filePath));
          // await _player.play();

          await _audioManager.stop();
          await _audioManager.dispose();
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
