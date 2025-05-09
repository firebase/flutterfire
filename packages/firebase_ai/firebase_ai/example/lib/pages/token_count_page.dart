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
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: !_loading
                          ? () async {
                              await _testCountToken();
                            }
                          : null,
                      child: const Text('Count Tokens'),
                    ),
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
    final tokenResult = 'Count token: ${tokenResponse.totalTokens}, billable '
        'characters: ${tokenResponse.totalBillableCharacters}';
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
}
