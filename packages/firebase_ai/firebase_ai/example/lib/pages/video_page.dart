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

import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/services.dart';
import '../widgets/message_widget.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key, required this.title, required this.model});

  final String title;
  final GenerativeModel model;

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  ChatSession? chat;
  late final GenerativeModel model;
  final List<MessageData> _messages = <MessageData>[];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    chat = widget.model.startChat();
  }

  Future<void> _testVideo(model) async {
    try {
      ByteData videoBytes =
          await rootBundle.load('assets/videos/landscape.mp4');

      const _prompt = 'Can you tell me what is in the video?';

      final prompt = TextPart(_prompt);

      setState(() {
        _messages.add(MessageData(text: _prompt, fromUser: true));
      });

      final videoPart =
          InlineDataPart('video/mp4', videoBytes.buffer.asUint8List());

      final response = await widget.model.generateContent([
        Content.multi([prompt, videoPart]),
      ]);

      setState(() {
        _messages.add(MessageData(text: response.text, fromUser: false));
      });
    } catch (e) {
      print('Error sending video to model: $e');
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
                itemBuilder: (context, idx) {
                  return MessageWidget(
                    text: _messages[idx].text,
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
              child: Center(
                child: SizedBox(
                  child: ElevatedButton(
                    onPressed: !_loading
                        ? () async {
                            await _testVideo(widget.model);
                          }
                        : null,
                    child: const Text('Test Video Prompt'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
