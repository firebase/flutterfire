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

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';

import '../widgets/message_widget.dart';

class ImageGenerationPage extends StatefulWidget {
  const ImageGenerationPage({
    super.key,
    required this.title,
    required this.useVertexBackend,
  });

  final String title;
  final bool useVertexBackend;

  @override
  State<ImageGenerationPage> createState() => _ImageGenerationPageState();
}

class _ImageGenerationPageState extends State<ImageGenerationPage> {
  late GenerativeModel _model;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  final List<MessageData> _messages = <MessageData>[];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  void _initializeModel() {
    final aiClient =
        widget.useVertexBackend ? FirebaseAI.vertexAI() : FirebaseAI.googleAI();

    _model = aiClient.generativeModel(
      model: 'gemini-2.5-flash-image',
      generationConfig: GenerationConfig(
        responseModalities: [ResponseModalities.text, ResponseModalities.image],
      ),
    );
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  Future<void> _generateImage(String prompt) async {
    if (prompt.trim().isEmpty) return;

    setState(() {
      _loading = true;
      _messages.add(MessageData(text: prompt, fromUser: true));
    });
    _textController.clear();
    _scrollDown();

    try {
      final response = await _model.generateContent([Content.text(prompt)]);

      String? textResponse = response.text;
      Uint8List? imageBytes;

      if (response.inlineDataParts.isNotEmpty) {
        imageBytes = response.inlineDataParts.first.bytes;
      }

      setState(() {
        _messages.add(
          MessageData(
            text: (textResponse ?? '') +
                (imageBytes != null
                    ? '\nGenerated Image:'
                    : 'No picture generated'),
            imageBytes: imageBytes,
            fromUser: false,
          ),
        );
      });
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        _loading = false;
      });
      _scrollDown();
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
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
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return MessageWidget(
                    text: message.text,
                    image: message.imageBytes == null
                        ? null
                        : Image.memory(
                            message.imageBytes!,
                            fit: BoxFit.contain,
                          ),
                    isFromUser: message.fromUser ?? false,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      focusNode: _textFieldFocus,
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Enter image prompt...',
                      ),
                      onSubmitted: _generateImage,
                    ),
                  ),
                  const SizedBox(width: 15),
                  if (!_loading)
                    IconButton(
                      onPressed: () => _generateImage(_textController.text),
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
}
