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
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../widgets/message_widget.dart';

class DocumentPage extends StatefulWidget {
  const DocumentPage({super.key, required this.title, required this.model});

  final String title;
  final GenerativeModel model;

  @override
  State<DocumentPage> createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  late final GenerativeModel model;
  final List<MessageData> _messages = <MessageData>[];
  bool _loading = false;

  void _testDocumentReading(model) async {

  ByteData docBytes = await rootBundle.load('assets/documents/gemini_summary.pdf');

  final prompt = TextPart('Write me a summary in one sentence what this document is about.');

  final content = [
    Content.multi([
      prompt,
      // The only accepted mime types are image/*.
      InlineDataPart('application/pdf', docBytes.buffer.asUint8List()),
    ]),
  ];

  final response = widget.model.generateContent(content);
  
  
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
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: !_loading
                          ? () async {
                              _testDocumentReading(model);
                            }
                          : null,
                      child: const Text('Test Document Reading'),
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
}


