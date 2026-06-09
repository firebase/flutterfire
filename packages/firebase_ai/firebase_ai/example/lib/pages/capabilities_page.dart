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

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/services.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/message_widget.dart';

final record = AudioRecorder();

class CapabilitiesPage extends StatefulWidget {
  const CapabilitiesPage({super.key, required this.title, required this.model});

  final String title;
  final GenerativeModel model;

  @override
  State<CapabilitiesPage> createState() => _CapabilitiesPageState();
}

class _CapabilitiesPageState extends State<CapabilitiesPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  // Multimodal Tab State
  final ScrollController _multimodalScrollController = ScrollController();
  final List<MessageData> _multimodalMessages = <MessageData>[];
  bool _multimodalLoading = false;
  bool _recording = false;

  // Structured Tab State
  final ScrollController _structuredScrollController = ScrollController();
  final List<MessageData> _structuredMessages = <MessageData>[];
  bool _structuredLoading = false;

  // Tokens Tab State
  final ScrollController _tokensScrollController = ScrollController();
  final List<MessageData> _tokensMessages = <MessageData>[];
  bool _tokensLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _multimodalScrollController.dispose();
    _structuredScrollController.dispose();
    _tokensScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Multimodal'),
            Tab(text: 'Structured'),
            Tab(text: 'Tokens'),
          ],
        ),
      ),
      body: SelectionArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildMultimodalTab(),
            _buildStructuredTab(),
            _buildTokensTab(),
          ],
        ),
      ),
    );
  }

  void _scrollDown(ScrollController controller) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (controller.hasClients) {
          controller.animateTo(
            controller.position.maxScrollExtent,
            duration: const Duration(milliseconds: 750),
            curve: Curves.easeOutCirc,
          );
        }
      },
    );
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

  // ==========================================
  // MULTIMODAL TAB LOGIC
  // ==========================================

  Future<void> _sendImagePrompt() async {
    setState(() {
      _multimodalLoading = true;
    });
    try {
      ByteData catBytes = await rootBundle.load('assets/images/cat.jpg');
      ByteData sconeBytes = await rootBundle.load('assets/images/scones.jpg');
      const promptText =
          "describe the two pictures and compare what's in common";
      final content = [
        Content.multi([
          const TextPart(promptText),
          InlineDataPart('image/jpeg', catBytes.buffer.asUint8List()),
          InlineDataPart('image/jpeg', sconeBytes.buffer.asUint8List()),
        ]),
      ];
      _multimodalMessages.add(
        MessageData(
          imageBytes: catBytes.buffer.asUint8List(),
          text: promptText,
          fromUser: true,
        ),
      );
      _multimodalMessages.add(
        MessageData(
          imageBytes: sconeBytes.buffer.asUint8List(),
          fromUser: true,
        ),
      );

      var response = await widget.model.generateContent(content);
      var text = response.text;
      _multimodalMessages.add(MessageData(text: text, fromUser: false));

      if (text == null) {
        _showError('No response from API.');
      } else {
        setState(() {
          _multimodalLoading = false;
          _scrollDown(_multimodalScrollController);
        });
      }
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _multimodalLoading = false;
      });
    } finally {
      setState(() {
        _multimodalLoading = false;
      });
    }
  }

  Future<void> _sendStorageUriPrompt() async {
    setState(() {
      _multimodalLoading = true;
    });
    try {
      const promptText = 'Describe this image';
      final content = [
        Content.multi([
          const TextPart(promptText),
          const FileData(
            'image/jpeg',
            'gs://vertex-ai-example-ef5a2.appspot.com/foodpic.jpg',
          ),
        ]),
      ];
      _multimodalMessages.add(MessageData(text: promptText, fromUser: true));

      var response = await widget.model.generateContent(content);
      var text = response.text;
      _multimodalMessages.add(MessageData(text: text, fromUser: false));

      if (text == null) {
        _showError('No response from API.');
      } else {
        setState(() {
          _multimodalLoading = false;
          _scrollDown(_multimodalScrollController);
        });
      }
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _multimodalLoading = false;
      });
    } finally {
      setState(() {
        _multimodalLoading = false;
      });
    }
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
        _multimodalMessages.add(MessageData(text: textPrompt, fromUser: true));
        _multimodalLoading = true;
      });

      final response = await widget.model.generateContent([
        Content.multi([prompt, audioPart]),
      ]);

      setState(() {
        _multimodalMessages
            .add(MessageData(text: response.text, fromUser: false));
        _multimodalLoading = false;
      });

      _scrollDown(_multimodalScrollController);
    } catch (e) {
      debugPrint('Error sending audio to model: $e');
      setState(() {
        _multimodalLoading = false;
      });
    }
  }

  Future<void> _testVideo() async {
    try {
      setState(() {
        _multimodalLoading = true;
      });

      ByteData videoBytes =
          await rootBundle.load('assets/videos/landscape.mp4');

      const promptText = 'Can you tell me what is in the video?';

      setState(() {
        _multimodalMessages.add(MessageData(text: promptText, fromUser: true));
      });

      final videoPart =
          InlineDataPart('video/mp4', videoBytes.buffer.asUint8List());

      final response = await widget.model.generateContent([
        Content.multi([const TextPart(promptText), videoPart]),
      ]);

      setState(() {
        _multimodalMessages
            .add(MessageData(text: response.text, fromUser: false));
        _multimodalLoading = false;
      });

      _scrollDown(_multimodalScrollController);
    } catch (e) {
      debugPrint('Error sending video to model: $e');
      setState(() {
        _multimodalLoading = false;
      });
    }
  }

  Future<void> _testDocumentReading() async {
    try {
      setState(() {
        _multimodalLoading = true;
      });

      ByteData docBytes =
          await rootBundle.load('assets/documents/gemini_summary.pdf');

      const promptText =
          'Write me a summary in one sentence what this document is about.';

      setState(() {
        _multimodalMessages.add(MessageData(text: promptText, fromUser: true));
      });

      final pdfPart =
          InlineDataPart('application/pdf', docBytes.buffer.asUint8List());

      final response = await widget.model.generateContent([
        Content.multi([const TextPart(promptText), pdfPart]),
      ]);

      setState(() {
        _multimodalMessages
            .add(MessageData(text: response.text, fromUser: false));
        _multimodalLoading = false;
      });

      _scrollDown(_multimodalScrollController);
    } catch (e) {
      debugPrint('Error sending document to model: $e');
      setState(() {
        _multimodalLoading = false;
      });
    }
  }

  Widget _buildMultimodalTab() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _multimodalScrollController,
              itemBuilder: (context, idx) {
                var content = _multimodalMessages[idx];
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
              itemCount: _multimodalMessages.length,
            ),
          ),
          if (_multimodalLoading && !_recording)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _multimodalLoading
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
                    color: _recording ? Colors.red : null,
                  ),
                  label: Text(_recording ? 'Stop Rec' : 'Record Audio'),
                ),
                ElevatedButton.icon(
                  onPressed: _multimodalLoading ? null : _sendImagePrompt,
                  icon: const Icon(Icons.image),
                  label: const Text('Test Images'),
                ),
                ElevatedButton.icon(
                  onPressed: _multimodalLoading ? null : _sendStorageUriPrompt,
                  icon: const Icon(Icons.storage),
                  label: const Text('Test GCS Image'),
                ),
                ElevatedButton.icon(
                  onPressed: _multimodalLoading ? null : _testVideo,
                  icon: const Icon(Icons.video_collection),
                  label: const Text('Test Video'),
                ),
                ElevatedButton.icon(
                  onPressed: _multimodalLoading ? null : _testDocumentReading,
                  icon: const Icon(Icons.edit_document),
                  label: const Text('Test Doc'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STRUCTURED TAB LOGIC
  // ==========================================

  Future<void> _promptSchemaTest() async {
    setState(() {
      _structuredLoading = true;
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
                'name':
                    Schema.string(description: 'The name of the character.'),
                'species': Schema.string(description: 'The animal species.'),
                'age': Schema.integer(
                  description: 'The age of the character in years.',
                  minimum: 1,
                  maximum: 1000,
                ),
                'isMythical': Schema.boolean(
                  description: 'Whether the animal is a mythical creature.',
                ),
                'powerLevel': Schema.number(
                  description: 'Power level from 0.0 to 10.0.',
                  minimum: 0,
                  maximum: 10,
                ),
                'accessory': Schema.enumString(
                  enumValues: ['hat', 'belt', 'shoes'],
                  description: 'Optional accessory.',
                  nullable: true,
                ),
              },
              propertyOrdering: [
                'name',
                'species',
                'age',
                'isMythical',
                'powerLevel',
                'accessory',
              ],
            ),
          ),
        },
        description: 'A list of characters for a card game.',
        optionalProperties: ['accessory'],
      );

      _structuredMessages.add(
        MessageData(
          text: 'Generate 10 animal-based characters (Schema)',
          fromUser: true,
        ),
      );

      final response = await widget.model.generateContent(
        content,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: jsonSchema,
        ),
      );

      if (response.text == null) {
        _showError('No response from API.');
      } else {
        final text = const JsonEncoder.withIndent('  ')
            .convert(json.decode(response.text!) as Object?);
        _structuredMessages
            .add(MessageData(text: '```json\n$text\n```', fromUser: false));
        setState(() {
          _structuredLoading = false;
          _scrollDown(_structuredScrollController);
        });
      }
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _structuredLoading = false;
      });
    }
  }

  Future<void> _promptJsonSchemaTest() async {
    setState(() {
      _structuredLoading = true;
    });
    try {
      final content = [
        Content.text(
          'Generate a widget hierarchy with a column containing two text widgets ',
        ),
      ];

      final textWidgetSchema = JSONSchema.object(
        properties: {
          'type': JSONSchema.enumString(enumValues: ['Text']),
          'text': JSONSchema.string(),
        },
      );

      final rowWidgetSchema = JSONSchema.object(
        properties: {
          'type': JSONSchema.enumString(enumValues: ['Row']),
          'children': JSONSchema.array(
            items: JSONSchema.ref(r'#/$defs/text_widget'),
          ),
        },
      );

      final jsonSchema = JSONSchema.object(
        defs: {
          'text_widget': textWidgetSchema,
        },
        properties: {
          'type': JSONSchema.enumString(enumValues: ['Column']),
          'children': JSONSchema.array(
            items: JSONSchema.anyOf(
              schemas: [
                JSONSchema.ref(r'#/$defs/text_widget'),
                rowWidgetSchema,
              ],
            ),
          ),
        },
      );

      _structuredMessages.add(
        MessageData(
          text: 'Generate a widget hierarchy... (JSON Schema)',
          fromUser: true,
        ),
      );

      final response = await widget.model.generateContent(
        content,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseJsonSchema: jsonSchema.toJson(),
        ),
      );

      var text = const JsonEncoder.withIndent('  ')
          .convert(json.decode(response.text ?? '') as Object?);
      _structuredMessages
          .add(MessageData(text: '```json\n$text\n```', fromUser: false));

      setState(() {
        _structuredLoading = false;
        _scrollDown(_structuredScrollController);
      });
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _structuredLoading = false;
      });
    }
  }

  Widget _buildStructuredTab() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _structuredScrollController,
              itemBuilder: (context, idx) {
                return MessageWidget(
                  text: _structuredMessages[idx].text,
                  isFromUser: _structuredMessages[idx].fromUser ?? false,
                );
              },
              itemCount: _structuredMessages.length,
            ),
          ),
          if (_structuredLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _structuredLoading ? null : _promptSchemaTest,
                  child: const Text('Schema Prompt'),
                ),
                ElevatedButton(
                  onPressed: _structuredLoading ? null : _promptJsonSchemaTest,
                  child: const Text('JSON Schema Prompt'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TOKENS TAB LOGIC
  // ==========================================

  Future<void> _testCountToken() async {
    setState(() {
      _tokensLoading = true;
    });

    try {
      // 1. Text only
      const prompt = 'tell a short story';
      _tokensMessages.add(
        MessageData(
          text: 'Count tokens for text: "$prompt"',
          fromUser: true,
        ),
      );

      final content = Content.text(prompt);
      final tokenResponse = await widget.model.countTokens([content]);
      _tokensMessages.add(
        MessageData(
          text: 'Token Count (Text): ${tokenResponse.totalTokens}',
          fromUser: false,
        ),
      );

      // 2. Multimodal (Text + Image + PDF)
      _tokensMessages.add(
        MessageData(
          text:
              'Count tokens for Multimodal (Text + cat.jpg + gemini_summary.pdf)',
          fromUser: true,
        ),
      );
      ByteData catBytes = await rootBundle.load('assets/images/cat.jpg');
      ByteData docBytes =
          await rootBundle.load('assets/documents/gemini_summary.pdf');
      final multimodalContent = Content.multi([
        const TextPart('Describe this cat and summarize this document.'),
        InlineDataPart('image/jpeg', catBytes.buffer.asUint8List()),
        InlineDataPart('application/pdf', docBytes.buffer.asUint8List()),
      ]);

      final multimodalTokenResponse =
          await widget.model.countTokens([multimodalContent]);
      final promptDetails = multimodalTokenResponse.promptTokensDetails
          ?.map((d) => '${d.modality.name}: ${d.tokenCount}')
          .join(', ');

      _tokensMessages.add(
        MessageData(
          text:
              'Token Count (Multimodal): ${multimodalTokenResponse.totalTokens}\n'
              'Details: $promptDetails',
          fromUser: false,
        ),
      );
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        _tokensLoading = false;
        _scrollDown(_tokensScrollController);
      });
    }
  }

  Future<void> _testUsageMetadata() async {
    setState(() {
      _tokensLoading = true;
    });

    _tokensMessages.add(
      MessageData(
        text:
            'Generate content with text + cat.jpg (with Thinking enabled) and check Usage Metadata details',
        fromUser: true,
      ),
    );

    try {
      ByteData catBytes = await rootBundle.load('assets/images/cat.jpg');
      final content = [
        Content.multi([
          const TextPart('Describe this image in detail.'),
          InlineDataPart('image/jpeg', catBytes.buffer.asUint8List()),
        ]),
      ];

      final response = await widget.model.generateContent(
        content,
        generationConfig: GenerationConfig(
          thinkingConfig:
              ThinkingConfig.withThinkingBudget(2048, includeThoughts: true),
        ),
      );

      // Extract thoughts if any
      final thoughts = response.candidates.firstOrNull?.content.parts
          .whereType<TextPart>()
          .where((p) => p.isThought ?? false)
          .map((p) => p.text)
          .join();

      if (thoughts != null && thoughts.isNotEmpty) {
        _tokensMessages.add(
          MessageData(
            text: thoughts,
            fromUser: false,
            isThought: true,
          ),
        );
      }

      final usageMetadata = response.usageMetadata;

      if (usageMetadata != null) {
        final promptDetails = usageMetadata.promptTokensDetails
            ?.map((d) => '${d.modality.name}: ${d.tokenCount}')
            .join(', ');
        final candidateDetails = usageMetadata.candidatesTokensDetails
            ?.map((d) => '${d.modality.name}: ${d.tokenCount}')
            .join(', ');

        final message = '''
Usage Metadata:
- promptTokenCount: ${usageMetadata.promptTokenCount} (Details: $promptDetails)
- candidatesTokenCount: ${usageMetadata.candidatesTokenCount} (Details: $candidateDetails)
- totalTokenCount: ${usageMetadata.totalTokenCount}
- thoughtsTokenCount: ${usageMetadata.thoughtsTokenCount}
- cachedContentTokenCount: ${usageMetadata.cachedContentTokenCount}
''';
        _tokensMessages.add(
          MessageData(
            text: message,
            fromUser: false,
          ),
        );
      } else {
        _tokensMessages.add(
          MessageData(
            text: 'No usage metadata available.',
            fromUser: false,
          ),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        _tokensLoading = false;
        _scrollDown(_tokensScrollController);
      });
    }
  }

  Widget _buildTokensTab() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _tokensScrollController,
              itemBuilder: (context, idx) {
                final msg = _tokensMessages[idx];
                return MessageWidget(
                  text: msg.text,
                  isFromUser: msg.fromUser ?? false,
                  isThought: msg.isThought,
                );
              },
              itemCount: _tokensMessages.length,
            ),
          ),
          if (_tokensLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _tokensLoading ? null : _testCountToken,
                  child: const Text('Count Tokens'),
                ),
                ElevatedButton(
                  onPressed: _tokensLoading ? null : _testUsageMetadata,
                  child: const Text('Usage Metadata'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
