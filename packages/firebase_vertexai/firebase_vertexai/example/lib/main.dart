// Copyright 2024 Google LLC
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

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// REQUIRED if you want to run on Web
const FirebaseOptions? options = null;

void main() {
  runApp(const GenerativeAISample());
}

class GenerativeAISample extends StatelessWidget {
  const GenerativeAISample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter + Vertex AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color.fromARGB(255, 171, 222, 244),
        ),
        useMaterial3: true,
      ),
      home: const ChatScreen(title: 'Flutter + Vertex AI'),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.title});

  final String title;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const ChatWidget(),
    );
  }
}

class ChatWidget extends StatefulWidget {
  const ChatWidget({
    super.key,
  });

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

final class Location {
  final String city;
  final String state;

  Location(this.city, this.state);
}

class _ChatWidgetState extends State<ChatWidget> {
  late final GenerativeModel _model;
  late final GenerativeModel _functionCallModel;
  ChatSession? _chat;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  final List<({Image? image, String? text, bool fromUser})> _generatedContent =
      <({Image? image, String? text, bool fromUser})>[];
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    initFirebase().then((value) {
      var vertex_instance =
          FirebaseVertexAI.instanceFor(auth: FirebaseAuth.instance);
      _model = vertex_instance.generativeModel(
        model: 'gemini-1.5-flash',
        requestOptions: RequestOptions(apiVersion: ApiVersion.v1beta),
      );
      _functionCallModel = vertex_instance.generativeModel(
        model: 'gemini-1.5-flash',
        tools: [
          Tool.functionDeclarations([fetchWeatherTool]),
        ],
        requestOptions: RequestOptions(apiVersion: ApiVersion.v1beta),
      );
      _chat = _model.startChat();
    });
  }

  // This is a hypothetical API to return a fake weather data collection for
  // certain location
  Future<Map<String, Object?>> fetchWeather(
    Location location,
    String date,
  ) async {
    // TODO(developer): Call a real weather API.
    // Mock response from the API. In developer live code this would call the
    // external API and return what that API returns.
    final apiResponse = {
      'temperature': 38,
      'chancePrecipitation': '56%',
      'cloudConditions': 'partly-cloudy',
    };
    return apiResponse;
  }

  /// Actual function to demonstrate the function calling feature.
  final fetchWeatherTool = FunctionDeclaration(
    'fetchWeather',
    'Get the weather conditions for a specific city on a specific date.',
    parameters: {
      'location': Schema.object(
        description: 'The name of the city and its state for which to get '
            'the weather. Only cities in the USA are supported.',
        properties: {
          'city': Schema.string(
            description: 'The city of the location.',
          ),
          'state': Schema.string(
            description: 'The state of the location.',
          ),
        },
      ),
      'date': Schema.string(
        description: 'The date for which to get the weather. '
            'Date must be in the format: YYYY-MM-DD.',
      ),
    },
  );

  Future<void> initFirebase() async {
    // ignore: avoid_redundant_argument_values
    await Firebase.initializeApp(options: options);
    await FirebaseAuth.instance.signInAnonymously();
  }

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
    final textFieldDecoration = InputDecoration(
      contentPadding: const EdgeInsets.all(15),
      hintText: 'Enter a prompt...',
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );

    return Padding(
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
                  image: content.image,
                  isFromUser: content.fromUser,
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
                    decoration: textFieldDecoration,
                    controller: _textController,
                    onSubmitted: _sendChatMessage,
                  ),
                ),
                const SizedBox.square(
                  dimension: 15,
                ),
                IconButton(
                  tooltip: 'tokenCount Test',
                  onPressed: !_loading
                      ? () async {
                          await _testCountToken();
                        }
                      : null,
                  icon: Icon(
                    Icons.numbers,
                    color: _loading
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                IconButton(
                  tooltip: 'function calling Test',
                  onPressed: !_loading
                      ? () async {
                          await _testFunctionCalling();
                        }
                      : null,
                  icon: Icon(
                    Icons.functions,
                    color: _loading
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                IconButton(
                  tooltip: 'image prompt',
                  onPressed: !_loading
                      ? () async {
                          await _sendImagePrompt(_textController.text);
                        }
                      : null,
                  icon: Icon(
                    Icons.image,
                    color: _loading
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                IconButton(
                  tooltip: 'storage prompt',
                  onPressed: !_loading
                      ? () async {
                          await _sendStorageUriPrompt(_textController.text);
                        }
                      : null,
                  icon: Icon(
                    Icons.folder,
                    color: _loading
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                IconButton(
                  tooltip: 'schema prompt',
                  onPressed: !_loading
                      ? () async {
                          await _promptSchemaTest(_textController.text);
                        }
                      : null,
                  icon: Icon(
                    Icons.schema,
                    color: _loading
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                if (!_loading)
                  IconButton(
                    onPressed: () async {
                      await _sendChatMessage(_textController.text);
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
          Padding(
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
              bottom: 25,
            ),
            child: Text(
              'Total message count: ${_chat?.history.length ?? 0}',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _promptSchemaTest(String subject) async {
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

      final response = await _model.generateContent(
        content,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: jsonSchema,
        ),
      );

      var text = response.text;
      _generatedContent.add((image: null, text: text, fromUser: false));

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
          FileData(
            'image/jpeg',
            'gs://vertex-ai-example-ef5a2.appspot.com/foodpic.jpg',
          ),
        ]),
      ];
      _generatedContent.add((image: null, text: message, fromUser: true));

      var response = await _model.generateContent(content);
      var text = response.text;
      _generatedContent.add((image: null, text: text, fromUser: false));

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
        (
          image: Image.asset('assets/images/cat.jpg'),
          text: message,
          fromUser: true
        ),
      );
      _generatedContent.add(
        (
          image: Image.asset('assets/images/scones.jpg'),
          text: null,
          fromUser: true
        ),
      );

      var response = await _model.generateContent(content);
      var text = response.text;
      _generatedContent.add((image: null, text: text, fromUser: false));

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

  Future<void> _sendChatMessage(String message) async {
    setState(() {
      _loading = true;
    });

    try {
      _generatedContent.add((image: null, text: message, fromUser: true));
      var response = await _chat?.sendMessage(
        Content.text(message),
      );
      var text = response?.text;
      _generatedContent.add((image: null, text: text, fromUser: false));

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

  Future<void> _testFunctionCalling() async {
    setState(() {
      _loading = true;
    });
    final functionCallChat = _functionCallModel.startChat();
    const prompt = 'What is the weather like in Boston on 10/02 this year?';

    // Send the message to the generative model.
    var response = await functionCallChat.sendMessage(
      Content.text(prompt),
    );

    final functionCalls = response.functionCalls.toList();
    // When the model response with a function call, invoke the function.
    if (functionCalls.isNotEmpty) {
      final functionCall = functionCalls.first;
      if (functionCall.name == 'fetchWeather') {
        Map<String, dynamic> location =
            functionCall.args['location']! as Map<String, dynamic>;
        var date = functionCall.args['date']! as String;
        var city = location['city'] as String;
        var state = location['state'] as String;
        final functionResult = await fetchWeather(Location(city, state), date);
        // Send the response to the model so that it can use the result to
        // generate text for the user.
        response = await functionCallChat.sendMessage(
          Content.functionResponse(functionCall.name, functionResult),
        );
      } else {
        throw UnimplementedError(
          'Function not declared to the model: ${functionCall.name}',
        );
      }
    }
    // When the model responds with non-null text content, print it.
    if (response.text case final text?) {
      _generatedContent.add((image: null, text: text, fromUser: false));
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _testCountToken() async {
    setState(() {
      _loading = true;
    });

    const prompt = 'tell a short story';
    var content = Content.text(prompt);
    var tokenResponse = await _model.countTokens([content]);
    final tokenResult = 'Count token: ${tokenResponse.totalTokens}, billable '
        'characters: ${tokenResponse.totalBillableCharacters}';
    _generatedContent.add((image: null, text: tokenResult, fromUser: false));

    var contentResponse = await _model.generateContent([content]);
    final contentMetaData = 'result metadata, promptTokenCount:'
        '${contentResponse.usageMetadata!.promptTokenCount}, '
        'candidatesTokenCount:'
        '${contentResponse.usageMetadata!.candidatesTokenCount}, '
        'totalTokenCount:'
        '${contentResponse.usageMetadata!.totalTokenCount}';
    _generatedContent
        .add((image: null, text: contentMetaData, fromUser: false));
    setState(() {
      _loading = false;
    });
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

class MessageWidget extends StatelessWidget {
  final Image? image;
  final String? text;
  final bool isFromUser;

  const MessageWidget({
    super.key,
    this.image,
    this.text,
    required this.isFromUser,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            decoration: BoxDecoration(
              color: isFromUser
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 20,
            ),
            margin: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                if (text case final text?) MarkdownBody(data: text),
                if (image case final image?) image,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
