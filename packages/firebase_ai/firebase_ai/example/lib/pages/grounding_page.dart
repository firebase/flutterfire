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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import '../widgets/message_widget.dart';

class GroundingPage extends StatefulWidget {
  const GroundingPage({
    super.key,
    required this.title,
    required this.useVertexBackend,
  });

  final String title;
  final bool useVertexBackend;

  @override
  State<GroundingPage> createState() => _GroundingPageState();
}

class _GroundingPageState extends State<GroundingPage> {
  GenerativeModel? _model;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  final List<MessageData> _messages = <MessageData>[];

  bool _loading = false;
  bool _enableSearchGrounding = false;
  bool _enableMapsGrounding = false;

  @override
  void initState() {
    super.initState();
    _latController.text = '37.422'; // Default Googleplex lat
    _lngController.text = '-122.084'; // Default Googleplex lng
  }

  void _initializeModel() {
    List<Tool> tools = [];
    ToolConfig? toolConfig;

    if (_enableSearchGrounding) {
      tools.add(Tool.googleSearch());
    }

    if (_enableMapsGrounding) {
      tools.add(Tool.googleMaps());

      final lat = double.tryParse(_latController.text);
      final lng = double.tryParse(_lngController.text);

      if (lat != null && lng != null) {
        toolConfig = ToolConfig(
          retrievalConfig: RetrievalConfig(
            latLng: LatLng(latitude: lat, longitude: lng),
          ),
        );
      }
    }

    if (widget.useVertexBackend) {
      _model = FirebaseAI.vertexAI(auth: FirebaseAuth.instance).generativeModel(
        model: 'gemini-2.5-flash',
        tools: tools.isNotEmpty ? tools : null,
        toolConfig: toolConfig,
      );
    } else {
      _model = FirebaseAI.googleAI(auth: FirebaseAuth.instance).generativeModel(
        model: 'gemini-2.5-flash',
        tools: tools.isNotEmpty ? tools : null,
        toolConfig: toolConfig,
      );
    }
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

  Future<void> _sendPrompt(String message) async {
    if (message.isEmpty) return;

    _initializeModel(); // Re-initialize before sending to capture current toggles

    setState(() {
      _loading = true;
    });

    try {
      _messages.add(MessageData(text: message, fromUser: true));

      final response = await _model?.generateContent([Content.text(message)]);

      var text = response?.text;

      // Extract grounding metadata to display
      final groundingMetadata =
          response?.candidates.firstOrNull?.groundingMetadata;
      if (groundingMetadata != null) {
        final chunks = groundingMetadata.groundingChunks.map((chunk) {
          if (chunk.web != null) {
            final title = chunk.web!.title ?? chunk.web!.uri;
            return '- [$title](${chunk.web!.uri})';
          }
          if (chunk.maps != null) {
            final title = chunk.maps!.title ?? chunk.maps!.uri;
            return '- [${title ?? 'Maps Result'}](${chunk.maps!.uri ?? ''})';
          }
          return '- Unknown chunk';
        }).join('\n');

        if (chunks.isNotEmpty) {
          text = '$text\n\n**Grounding Sources:**\n$chunks';
        }
      }

      _messages.add(MessageData(text: text, fromUser: false));

      if (text == null) {
        _showError('No response from API.');
        return;
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      _textController.clear();
      setState(() {
        _loading = false;
      });
      _textFieldFocus.requestFocus();
      _scrollDown();
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
            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    title: const Text(
                      'Search Grounding',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: _enableSearchGrounding,
                    onChanged: (bool value) {
                      setState(() {
                        _enableSearchGrounding = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: SwitchListTile(
                    title: const Text(
                      'Maps Grounding',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: _enableMapsGrounding,
                    onChanged: (bool value) {
                      setState(() {
                        _enableMapsGrounding = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            if (_enableMapsGrounding)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _latController,
                        decoration:
                            const InputDecoration(labelText: 'Latitude'),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _lngController,
                        decoration:
                            const InputDecoration(labelText: 'Longitude'),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemBuilder: (context, idx) {
                  final message = _messages[idx];
                  return MessageWidget(
                    text: message.text,
                    isFromUser: message.fromUser ?? false,
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
                      onSubmitted: _sendPrompt,
                      decoration: const InputDecoration(
                        hintText: 'Enter a prompt...',
                      ),
                    ),
                  ),
                  const SizedBox.square(dimension: 15),
                  if (!_loading)
                    IconButton(
                      onPressed: () {
                        _sendPrompt(_textController.text);
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
}
