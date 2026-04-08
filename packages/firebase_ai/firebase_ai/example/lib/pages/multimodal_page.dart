// Copyright 2026 Google LLC
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
import 'package:flutter/services.dart';
import '../widgets/message_widget.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

final record = AudioRecorder();

class MultimodalPage extends StatefulWidget {
  const MultimodalPage({super.key, required this.title, required this.model});

  final String title;
  final GenerativeModel model;

  @override
  State<MultimodalPage> createState() => _MultimodalPageState();
}

class _MultimodalPageState extends State<MultimodalPage> {
  final ScrollController _scrollController = ScrollController();
  final List<MessageData> _messages = <MessageData>[];
  bool _recording = false;
  bool _loading = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> recordAudio() async {
    if (!await record.hasPermission()) {
      debugPrint('Audio recording permission denied');
      return;
    }

    final dir = Directory(
      '${(await getApplicationDocumentsDirectory()).path}/libs/recordings',
    );

    await dir.create(recursive: true);

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
      debugPrint('Failed to stop recording');
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

  Future<void> _submitAudioToModel(InlineDataPart audioPart) async {
    try {
      String textPrompt = 'What is in the audio recording?';
      const prompt = TextPart('What is in the audio recording?');

      setState(() {
        _messages.add(MessageData(text: textPrompt, fromUser: true));
        _loading = true;
      });

      final response = await widget.model.generateContent([
        Content.multi([prompt, audioPart]),
      ]);

      setState(() {
        _messages.add(MessageData(text: response.text, fromUser: false));
        _loading = false;
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint('Error sending audio to model: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _testVideo() async {
    try {
      setState(() {
        _loading = true;
      });

      ByteData videoBytes =
          await rootBundle.load('assets/videos/landscape.mp4');

      const promptText = 'Can you tell me what is in the video?';

      setState(() {
        _messages.add(MessageData(text: promptText, fromUser: true));
      });

      final videoPart =
          InlineDataPart('video/mp4', videoBytes.buffer.asUint8List());

      final response = await widget.model.generateContent([
        Content.multi([const TextPart(promptText), videoPart]),
      ]);

      setState(() {
        _messages.add(MessageData(text: response.text, fromUser: false));
        _loading = false;
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint('Error sending video to model: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _testDocumentReading() async {
    try {
      setState(() {
        _loading = true;
      });

      ByteData docBytes =
          await rootBundle.load('assets/documents/gemini_summary.pdf');

      const promptText =
          'Write me a summary in one sentence what this document is about.';

      setState(() {
        _messages.add(MessageData(text: promptText, fromUser: true));
      });

      final pdfPart =
          InlineDataPart('application/pdf', docBytes.buffer.asUint8List());

      final response = await widget.model.generateContent([
        Content.multi([const TextPart(promptText), pdfPart]),
      ]);

      setState(() {
        _messages.add(MessageData(text: response.text, fromUser: false));
        _loading = false;
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint('Error sending document to model: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemBuilder: (context, idx) {
                  return MessageWidget(
                    text: _messages[idx].text,
                    isFromUser: _messages[idx].fromUser ?? false,
                  );
                },
                itemCount: _messages.length,
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: _loading
                            ? null
                            : () async {
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
                              ? Colors.red
                              : Theme.of(context).colorScheme.primary,
                        ),
                        iconSize: 32,
                      ),
                      Text(
                        _recording ? 'Stop' : 'Record',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: _loading ? null : _testVideo,
                        icon: Icon(
                          Icons.video_collection,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        iconSize: 32,
                      ),
                      const Text(
                        'Test Video',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: _loading ? null : _testDocumentReading,
                        icon: Icon(
                          Icons.edit_document,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        iconSize: 32,
                      ),
                      const Text(
                        'Test Doc',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
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
