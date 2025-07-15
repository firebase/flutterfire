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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_ai/firebase_ai.dart';
import '../widgets/message_widget.dart';

class TokenCountPage extends StatefulWidget {
  const TokenCountPage({super.key, required this.title, required this.model});

  final String title;
  final GenerativeModel model;

  @override
  State<TokenCountPage> createState() => _TokenCountPageState();
}

class _TokenCountPageState extends State<TokenCountPage> {
  final List<MessageData> _messages = <MessageData>[];
  bool _loading = false;

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
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: !_loading ? _testCountToken : null,
                    child: const Text('Count text tokens'),
                  ),
                  ElevatedButton(
                    onPressed: !_loading ? _testCountTokenChat : null,
                    child: const Text('Count chat tokens'),
                  ),
                  ElevatedButton(
                    onPressed: !_loading ? _testCountTokenImage : null,
                    child: const Text('Count image tokens'),
                  ),
                  ElevatedButton(
                    onPressed: !_loading ? _testCountTokenVideo : null,
                    child: const Text('Count video tokens'),
                  ),
                  ElevatedButton(
                    onPressed: !_loading ? _testCountTokenPdf : null,
                    child: const Text('Count PDF tokens'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testCountToken() async {
    setState(() {
      _loading = true;
    });

    const prompt = 'tell a short story';
    final content = Content.text(prompt);
    final tokenResponse = await widget.model.countTokens([content]);
    final tokenResult = 'Count token: ${tokenResponse.totalTokens}';
    _messages.add(MessageData(text: tokenResult, fromUser: false));

    final contentResponse = await widget.model.generateContent([content]);
    final contentMetaData = 'result metadata, promptTokenCount:'
        '${contentResponse.usageMetadata!.promptTokenCount}, '
        'candidatesTokenCount:'
        '${contentResponse.usageMetadata!.candidatesTokenCount}, '
        'totalTokenCount:'
        '${contentResponse.usageMetadata!.totalTokenCount}';
    _messages.add(MessageData(text: contentMetaData, fromUser: false));
    setState(() {
      _loading = false;
    });
  }

  Future<void> _testCountTokenPdf() async {
    setState(() {
      _loading = true;
    });

    final pdfBytes =
        (await rootBundle.load('assets/documents/gemini_summary.pdf'))
            .buffer
            .asUint8List();
    const text = 'what is in the document?';
    final content = Content.multi(
        [InlineDataPart('application/pdf', pdfBytes), TextPart(text)]);

    final tokenResponse = await widget.model.countTokens([content]);
    final tokenResult = 'Count token from video: ${tokenResponse.totalTokens}';
    _messages.add(MessageData(text: tokenResult, fromUser: false));

    final contentResponse = await widget.model.generateContent([content]);
    final contentMetaData = 'result metadata, promptTokenCount:'
        '${contentResponse.usageMetadata!.promptTokenCount}, '
        'candidatesTokenCount:'
        '${contentResponse.usageMetadata!.candidatesTokenCount}, '
        'totalTokenCount:'
        '${contentResponse.usageMetadata!.totalTokenCount}';
    _messages.add(MessageData(text: contentMetaData, fromUser: false));

    setState(() {
      _loading = false;
    });
  }

  Future<void> _testCountTokenVideo() async {
    setState(() {
      _loading = true;
    });

    final busyCatBytes = (await rootBundle.load('assets/videos/landscape.mp4'))
        .buffer
        .asUint8List();
    const text = 'what is in the video?';
    final content = Content.multi(
        [InlineDataPart('video/mp4', busyCatBytes), TextPart(text)]);

    final tokenResponse = await widget.model.countTokens([content]);
    final tokenResult = 'Count token from video: ${tokenResponse.totalTokens}';
    _messages.add(MessageData(text: tokenResult, fromUser: false));

    final contentResponse = await widget.model.generateContent([content]);
    final contentMetaData = 'result metadata, promptTokenCount:'
        '${contentResponse.usageMetadata!.promptTokenCount}, '
        'candidatesTokenCount:'
        '${contentResponse.usageMetadata!.candidatesTokenCount}, '
        'totalTokenCount:'
        '${contentResponse.usageMetadata!.totalTokenCount}';
    _messages.add(MessageData(text: contentMetaData, fromUser: false));

    setState(() {
      _loading = false;
    });
  }

  Future<void> _testCountTokenImage() async {
    setState(() {
      _loading = true;
    });

    final catBytes =
        (await rootBundle.load('assets/images/cat.jpg')).buffer.asUint8List();
    const text = 'what is in the image?';
    final content =
        Content.multi([InlineDataPart('image/jpeg', catBytes), TextPart(text)]);

    final tokenResponse = await widget.model.countTokens([content]);
    final tokenResult = 'Count token from image: ${tokenResponse.totalTokens}';
    _messages.add(MessageData(text: tokenResult, fromUser: false));

    final contentResponse = await widget.model.generateContent([content]);
    final contentMetaData = 'result metadata, promptTokenCount:'
        '${contentResponse.usageMetadata!.promptTokenCount}, '
        'candidatesTokenCount:'
        '${contentResponse.usageMetadata!.candidatesTokenCount}, '
        'totalTokenCount:'
        '${contentResponse.usageMetadata!.totalTokenCount}';
    _messages.add(MessageData(text: contentMetaData, fromUser: false));

    setState(() {
      _loading = false;
    });
  }

  Future<void> _testCountTokenChat() async {
    setState(() {
      _loading = true;
    });

    final chat = widget.model.startChat(history: [
      Content.text('hello'),
      Content.model([TextPart('great to meet you, how can I help? অন্যরা')]),
    ]);
    final tokenResponse = await widget.model.countTokens(chat.history);
    final tokenResult = 'Count token from chat history: '
        '${tokenResponse.totalTokens}';
    _messages.add(MessageData(text: tokenResult, fromUser: false));

    const prompt = 'tell a short story';
    final content = Content.text(prompt);
    final contentResponse = await chat.sendMessage(content);
    final contentMetaData = 'result metadata, promptTokenCount:'
        '${contentResponse.usageMetadata!.promptTokenCount}, '
        'candidatesTokenCount:'
        '${contentResponse.usageMetadata!.candidatesTokenCount}, '
        'totalTokenCount:'
        '${contentResponse.usageMetadata!.totalTokenCount}';
    _messages.add(MessageData(text: contentMetaData, fromUser: false));

    setState(() {
      _loading = false;
    });
  }
}
