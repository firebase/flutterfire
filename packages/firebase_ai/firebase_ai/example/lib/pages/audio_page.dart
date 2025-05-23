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

import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import '../widgets/message_widget.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

final record = AudioRecorder();

class AudioPage extends StatefulWidget {
  const AudioPage({super.key, required this.title, required this.model});

  final String title;
  final GenerativeModel model;

  @override
  State<AudioPage> createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
  ChatSession? chat;
  final ScrollController _scrollController = ScrollController();
  final List<MessageData> _messages = <MessageData>[];
  bool _recording = false;

  @override
  void initState() {
    super.initState();
    chat = widget.model.startChat();
  }

  Future<void> recordAudio() async {
    if (!await record.hasPermission()) {
      print('Audio recording permission denied');
      return;
    }

    final dir = Directory(
      '${(await getApplicationDocumentsDirectory()).path}/libs/recordings',
    );

    // ignore: avoid_slow_async_io
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    String filePath =
        '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';

    await record.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
      ),
      path: filePath,
    );
  }

  Future<void> stopRecord() async {
    var path = await record.stop();

    if (path == null) {
      print('Failed to stop recording');
      return;
    }

    debugPrint('Recording saved to: $path');

    try {
      File file = File(path);
      final audio = await file.readAsBytes();
      debugPrint('Audio file size: ${audio.length} bytes');

      final audioPart = InlineDataPart('audio/wav', audio);

      await _submitAudioToModel(audioPart);

      await file.delete();
      debugPrint('Recording deleted successfully.');
    } catch (e) {
      debugPrint('Error processing recording: $e');
    }
  }

  Future<void> _submitAudioToModel(audioPart) async {
    try {
      String textPrompt = 'What is in the audio recording?';
      final prompt = TextPart('What is in the audio recording?');

      setState(() {
        _messages.add(MessageData(text: textPrompt, fromUser: true));
      });

      final response = await widget.model.generateContent([
        Content.multi([prompt, audioPart]),
      ]);

      setState(() {
        _messages.add(MessageData(text: response.text, fromUser: false));
      });

      debugPrint(response.text);
    } catch (e) {
      debugPrint('Error sending audio to model: $e');
    }
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
                  IconButton(
                    onPressed: () async {
                      setState(() {
                        _recording = !_recording;
                      });
                      if (_recording) {
                        await recordAudio();
                      } else {
                        await stopRecord();
                      }
                    },
                    icon: Icon(
                      Icons.mic,
                      color: _recording
                          ? Colors.blueGrey
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox.square(
                    dimension: 15,
                  ),
                  const Text(
                    'Tap the mic to record, tap again to submit',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
