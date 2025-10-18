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

class ImagePromptPage extends StatefulWidget {
  const ImagePromptPage({super.key, required this.title, required this.model});

  final String title;
  final GenerativeModel model;

  @override
  State<ImagePromptPage> createState() => _ImagePromptPageState();
}

class _ImagePromptPageState extends State<ImagePromptPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  final List<MessageData> _generatedContent = <MessageData>[];
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
                  var content = _generatedContent[idx];
                  return MessageWidget(
                    text: content.text,
                    image: content.imageBytes == null
                        ? null
                        : Image.memory(
                            content.imageBytes!,
                            cacheWidth: 400,
                            cacheHeight: 400,
                          ),
                    isFromUser: content.fromUser ?? false,
                  );
                },
                itemCount: _generatedContent.length,
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
                    ),
                  ),
                  const SizedBox.square(
                    dimension: 15,
                  ),
                  if (!_loading)
                    IconButton(
                      onPressed: () async {
                        await _sendImagePrompt(_textController.text);
                      },
                      icon: Icon(
                        Icons.image,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  if (!_loading)
                    IconButton(
                      onPressed: () async {
                        await _sendStorageUriPrompt(_textController.text);
                      },
                      icon: Icon(
                        Icons.storage,
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

  Future<void> _sendImagePrompt(String message) async {
    setState(() {
      _loading = true;
    });
    try {
      ByteData catBytes = await rootBundle.load('assets/images/cat.jpg');
      ByteData sconeBytes = await rootBundle.load('assets/images/scones.jpg');
      final content = [
        Content.multi([
          TextPart(message),
          // The only accepted mime types are image/*.
          InlineDataPart('image/jpeg', catBytes.buffer.asUint8List()),
          InlineDataPart('image/jpeg', sconeBytes.buffer.asUint8List()),
        ]),
      ];
      _generatedContent.add(
        MessageData(
          imageBytes: catBytes.buffer.asUint8List(),
          text: message,
          fromUser: true,
        ),
      );
      _generatedContent.add(
        MessageData(
          imageBytes: sconeBytes.buffer.asUint8List(),
          fromUser: true,
        ),
      );

      var response = await widget.model.generateContent(content);
      var text = response.text;
      _generatedContent.add(MessageData(text: text, fromUser: false));

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

  Future<void> _sendStorageUriPrompt(String message) async {
    setState(() {
      _loading = true;
    });
    try {
      final content = [
        Content.multi([
          TextPart(message),
          const FileData(
            'image/jpeg',
            'gs://vertex-ai-example-ef5a2.appspot.com/foodpic.jpg',
          ),
        ]),
      ];
      _generatedContent.add(MessageData(text: message, fromUser: true));

      var response = await widget.model.generateContent(content);
      var text = response.text;
      _generatedContent.add(MessageData(text: text, fromUser: false));

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
