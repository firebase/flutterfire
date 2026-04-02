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
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/function_call_utils.dart';
import '../widgets/message_widget.dart';
import 'package:firebase_ai/firebase_ai.dart';

class ServerTemplatePage extends StatefulWidget {
  const ServerTemplatePage({
    super.key,
    required this.title,
    required this.useVertexBackend,
  });

  final String title;
  final bool useVertexBackend;

  @override
  State<ServerTemplatePage> createState() => _ServerTemplatePageState();
}

class _ServerTemplatePageState extends State<ServerTemplatePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  final List<MessageData> _messages = <MessageData>[];
  bool _loading = false;

  // ignore: experimental_member_use
  TemplateGenerativeModel? _templateGenerativeModel;

  TemplateChatSession? _chatSession;
  TemplateChatSession? _chatFunctionOverrideSession;
  TemplateChatSession? _chatAutoFunctionSession;
  TemplateChatSession? _chatStreamFunctionSession;

  @override
  void initState() {
    super.initState();
    _initializeServerTemplate();
  }

  void _initializeServerTemplate() {
    if (widget.useVertexBackend) {
      _templateGenerativeModel =
          // ignore: experimental_member_use
          FirebaseAI.vertexAI(location: 'global').templateGenerativeModel();
    } else {
      _templateGenerativeModel =
          // ignore: experimental_member_use
          FirebaseAI.googleAI().templateGenerativeModel();
    }

    // Inputs are now provided ONCE here when creating the session
    _chatSession = _templateGenerativeModel?.startChat(
      'chat_history.prompt',
      inputs: {},
    );
    _chatFunctionOverrideSession = _templateGenerativeModel?.startChat(
      'cj-function-calling-weather-override',
      inputs: {},
      tools: [
        TemplateTool.functionDeclarations([
          TemplateFunctionDeclaration(
            'fetchWeather',
            parameters: {
              'location': JSONSchema.object(
                description:
                    'The name of the city and its state for which to get '
                    'the weather. Only cities in the USA are supported.',
                properties: {
                  'city': JSONSchema.string(
                    description: 'The city of the location.',
                  ),
                  'state': JSONSchema.string(
                    description: 'The state of the location.',
                  ),
                  'zipCode': JSONSchema.integer(
                    description: 'Optional zip code of the location.',
                    nullable: true,
                  ),
                },
                optionalProperties: ['zipCode'],
              ),
              'date': JSONSchema.string(
                description:
                    'The date for which to get the weather. '
                    'Date must be in the format: YYYY-MM-DD.',
              ),
              'unit': JSONSchema.enumString(
                enumValues: ['CELSIUS', 'FAHRENHEIT'],
                description: 'The temperature unit.',
                nullable: true,
              ),
            },
            optionalParameters: ['unit'],
          ),
        ]),
      ],
    );
    _chatAutoFunctionSession = _templateGenerativeModel?.startChat(
      'cj-function-calling-weather',
      inputs: {},
      tools: [
        TemplateTool.functionDeclarations([
          TemplateAutoFunctionDeclaration(
            name: 'fetchWeather',
            callable: fetchWeatherCallable,
          ),
        ]),
      ],
    );
    _chatStreamFunctionSession = _templateGenerativeModel?.startChat(
      'cj-function-calling-weather-stream',
      inputs: {},
      tools: [
        TemplateTool.functionDeclarations([
          TemplateAutoFunctionDeclaration(
            name: 'fetchWeather',
            callable: fetchWeatherCallable,
          ),
        ]),
      ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
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
                  final message = _messages[idx];
                  return MessageWidget(
                    text: message.text,
                    image: message.imageBytes != null
                        ? Image.memory(
                            message.imageBytes!,
                            cacheWidth: 400,
                            cacheHeight: 400,
                          )
                        : null,
                    isFromUser: message.fromUser ?? false,
                  );
                },
                itemCount: _messages.length,
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
                      onSubmitted: _sendServerTemplateMessage,
                    ),
                  ),
                  const SizedBox.square(dimension: 15),
                  if (!_loading) ...[
                    if (!_loading)
                      IconButton(
                        onPressed: () async {
                          await _serverTemplateAutoFunctionCall(
                            _textController.text,
                          );
                        },
                        icon: Icon(
                          Icons.auto_mode,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        tooltip: 'Auto Function Calling',
                      ),
                    if (!_loading)
                      IconButton(
                        onPressed: () async {
                          await _serverTemplateFunctionCall(
                            _textController.text,
                          );
                        },
                        icon: Icon(
                          Icons.functions,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        tooltip: 'Function Calling (client override)',
                      ),
                    if (!_loading)
                      IconButton(
                        onPressed: () async {
                          await _serverTemplateAutoStreamFunctionCall(
                            _textController.text,
                          );
                        },
                        icon: Icon(
                          Icons.smart_toy,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        tooltip: 'Auto Stream Function Calling',
                      ),
                    if (!_loading)
                      IconButton(
                        onPressed: () async {
                          await _serverTemplateChat(_textController.text);
                        },
                        icon: Icon(
                          Icons.chat,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        tooltip: 'Chat',
                      ),
                    IconButton(
                      onPressed: () async {
                        await _serverTemplateImageInput(_textController.text);
                      },
                      icon: Icon(
                        Icons.image,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      tooltip: 'Image Input',
                    ),
                    IconButton(
                      onPressed: () async {
                        await _serverTemplateUrlContext(_textController.text);
                      },
                      icon: Icon(
                        Icons.link,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      tooltip: 'URL Context',
                    ),
                    IconButton(
                      onPressed: () async {
                        await _sendServerTemplateMessage(_textController.text);
                      },
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      tooltip: 'Generate',
                    ),
                    IconButton(
                      onPressed: _testCodeExecution,
                      icon: Icon(
                        Icons.code,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      tooltip: 'Test Code Execution',
                    ),
                  ] else
                    const CircularProgressIndicator(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleServerTemplateMessage(
    String message,
    Future<void> Function(String) generateContent,
  ) async {
    setState(() {
      _loading = true;
    });

    try {
      _messages.add(MessageData(text: message, fromUser: true));
      await generateContent(message);
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

  Future<void> _serverTemplateUrlContext(String message) async {
    await _handleServerTemplateMessage(
      message,
      (message) async {
        var response = await _templateGenerativeModel
            // ignore: experimental_member_use
            ?.generateContent('cj-urlcontext', inputs: {'url': message});

      final candidate = response?.candidates.first;
      if (candidate == null) {
        _messages.add(MessageData(text: 'No response', fromUser: false));
      } else {
        final responseText = candidate.text ?? '';
        final groundingMetadata = candidate.groundingMetadata;
        final urlContextMetadata = candidate.urlContextMetadata;

        final buffer = StringBuffer(responseText);
        if (groundingMetadata != null) {
          buffer.writeln('\n\n--- Grounding Metadata ---');
          buffer.writeln('Web Search Queries:');
          for (final query in groundingMetadata.webSearchQueries) {
            buffer.writeln(' - $query');
          }
          buffer.writeln('\nGrounding Chunks:');
          for (final chunk in groundingMetadata.groundingChunks) {
            if (chunk.web != null) {
              buffer.writeln(' - Web Chunk:');
              buffer.writeln('   - Title: ${chunk.web!.title}');
              buffer.writeln('   - URI: ${chunk.web!.uri}');
              buffer.writeln('   - Domain: ${chunk.web!.domain}');
            }
          }
        }

        if (urlContextMetadata != null) {
          buffer.writeln('\n\n--- URL Context Metadata ---');
          for (final data in urlContextMetadata.urlMetadata) {
            buffer.writeln(' - URL: ${data.retrievedUrl}');
            buffer.writeln('   Status: ${data.urlRetrievalStatus}');
          }
        }
        _messages.add(MessageData(text: buffer.toString(), fromUser: false));
      }
    });
  }

  Future<void> _serverTemplateAutoFunctionCall(String message) async {
    await _handleServerTemplateMessage(message, (message) async {
      // Inputs are no longer passed during sendMessage
      var response = await _chatAutoFunctionSession?.sendMessage(
        Content.text(message),
      );

      _messages.add(MessageData(text: response?.text, fromUser: false));
    });
  }

  Future<void> _serverTemplateFunctionCall(String message) async {
    await _handleServerTemplateMessage(message, (message) async {
      // Inputs are no longer passed during sendMessage
      var response = await _chatFunctionOverrideSession?.sendMessage(
        Content.text(message),
      );

      _messages.add(MessageData(text: response?.text, fromUser: false));
      final functionCalls = response?.functionCalls.toList();
      if (functionCalls!.isNotEmpty) {
        final functionCall = functionCalls.first;
        if (functionCall.name == 'fetchWeather') {
          final location =
              functionCall.args['location']! as Map<String, dynamic>;
          final date = functionCall.args['date']! as String;
          final city = location['city'] as String;
          final state = location['state'] as String;
          final functionResult = await fetchWeather(
            Location(city, state),
            date,
          );

          // Respond to the function call
          var functionResponse = await _chatFunctionOverrideSession
              ?.sendMessage(
                Content.functionResponse(functionCall.name, functionResult),
              );
          _messages.add(
            MessageData(text: functionResponse?.text, fromUser: false),
          );
        }
      }
    });
  }

  Future<void> _serverTemplateAutoStreamFunctionCall(String message) async {
    await _handleServerTemplateMessage(message, (message) async {
      var responseStream = _chatStreamFunctionSession?.sendMessageStream(
        Content.text(message),
      );

      var accumulatedText = '';
      MessageData? modelMessage;

      if (responseStream != null) {
        await for (final response in responseStream) {
          if (response.text case final text?) {
            accumulatedText += text;
            if (modelMessage == null) {
              modelMessage = MessageData(
                text: accumulatedText,
                fromUser: false,
              );
              _messages.add(modelMessage);
            } else {
              modelMessage = modelMessage.copyWith(text: accumulatedText);
              _messages.last = modelMessage;
            }
            setState(() {});
          }
        }
      }

      if (accumulatedText.isEmpty) {
        _messages.add(
          MessageData(text: 'No text response from model.', fromUser: false),
        );
      }
    });
  }

  Future<void> _serverTemplateChat(String message) async {
    await _handleServerTemplateMessage(message, (message) async {
      // Inputs are no longer passed during sendMessage
      var response = await _chatSession?.sendMessage(Content.text(message));

      var text = response?.text;

      _messages.add(MessageData(text: text, fromUser: false));
    });
  }

  Future<void> _serverTemplateImageInput(String message) async {
    await _handleServerTemplateMessage(message, (message) async {
      ByteData catBytes = await rootBundle.load('assets/images/cat.jpg');
      var imageBytes = catBytes.buffer.asUint8List();
      _messages.add(
        MessageData(text: message, imageBytes: imageBytes, fromUser: true),
      );

      // ignore: experimental_member_use
      var response = await _templateGenerativeModel?.generateContent(
        'media',
        inputs: {
          'imageData': {
            'isInline': true,
            'mimeType': 'image/jpeg',
            'contents': base64Encode(imageBytes),
          },
        },
      );
      _messages.add(MessageData(text: response?.text, fromUser: false));
    });
  }

  Future<void> _sendServerTemplateMessage(String message) async {
    setState(() {
      _loading = true;
    });

    try {
      _messages.add(MessageData(text: message, fromUser: true));
      var response = await _templateGenerativeModel
          // ignore: experimental_member_use
          ?.generateContent('new-greeting', inputs: {});

      _messages.add(MessageData(text: response?.text, fromUser: false));
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

  Future<void> _testCodeExecution() async {
    setState(() {
      _loading = true;
    });

    try {
      _messages.add(
        MessageData(text: 'Testing code execution', fromUser: true),
      );
      final response = await _templateGenerativeModel
          // ignore: experimental_member_use
          ?.generateContent('cj-code-execution', inputs: {});

      final buffer = StringBuffer();
      for (final part in response!.candidates.first.content.parts) {
        if (part is ExecutableCodePart) {
          buffer.writeln('Executable Code:');
          buffer.writeln('Language: ${part.language}');
          buffer.writeln('Code:');
          buffer.writeln(part.code);
        } else if (part is CodeExecutionResultPart) {
          buffer.writeln('Code Execution Result:');
          buffer.writeln('Outcome: ${part.outcome}');
          buffer.writeln('Output:');
          buffer.writeln(part.output);
        } else if (part is TextPart) {
          buffer.writeln(part.text);
        }
      }

      if (buffer.isNotEmpty) {
        _messages.add(MessageData(text: buffer.toString(), fromUser: false));
      }

      setState(() {
        _loading = false;
        _scrollDown();
      });
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
          content: SingleChildScrollView(child: SelectableText(message)),
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
