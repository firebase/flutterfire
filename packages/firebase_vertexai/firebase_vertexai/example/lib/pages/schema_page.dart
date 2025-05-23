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
import 'package:firebase_vertexai/firebase_vertexai.dart';
import '../widgets/message_widget.dart';

class SchemaPromptPage extends StatefulWidget {
  const SchemaPromptPage({super.key, required this.title, required this.model});

  final String title;
  final GenerativeModel model;

  @override
  State<SchemaPromptPage> createState() => _SchemaPromptPageState();
}

class _SchemaPromptPageState extends State<SchemaPromptPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  final List<MessageData> _messages = <MessageData>[];
  bool _loading = false;

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
                              await _promptSchemaTest();
                            }
                          : null,
                      child: const Text('Schema Prompt'),
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

  Future<void> _promptSchemaTest() async {
    setState(() {
      _loading = true;
    });
    try {
      final content = [
        Content.text(
          "For use in a children's card game, generate 10 animal-based "
          'characters.',
        ),
      ];

      final jsonSchema = Schema.object(
        properties: {
          'characters': Schema.array(
            items: Schema.object(
              properties: {
                'name': Schema.string(),
                'age': Schema.integer(),
                'species': Schema.string(),
                'accessory':
                    Schema.enumString(enumValues: ['hat', 'belt', 'shoes']),
              },
            ),
          ),
        },
        optionalProperties: ['accessory'],
      );

      final response = await widget.model.generateContent(
        content,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: jsonSchema,
        ),
      );

      var text = response.text;
      _messages.add(MessageData(text: text, fromUser: false));

      if (text == null) {
        _showError('No response from API.');
        return;
      } else {
        setState(() {
          _loading = false;
          _scrollDown();
        });
      }
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      _textController.clear();
      setState(() {
        _loading = false;
      });
      _textFieldFocus.requestFocus();
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
