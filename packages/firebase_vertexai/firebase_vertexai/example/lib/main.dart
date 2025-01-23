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
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';

import 'pages/chat_page.dart';
import 'pages/function_calling_page.dart';
import 'pages/image_prompt_page.dart';
import 'pages/token_count_page.dart';
import 'pages/schema_page.dart';
import 'pages/storage_uri_page.dart';

// REQUIRED if you want to run on Web
const FirebaseOptions? options = null;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: options);
  await FirebaseAuth.instance.signInAnonymously();

  var vertex_instance =
      FirebaseVertexAI.instanceFor(auth: FirebaseAuth.instance);
  final model = vertex_instance.generativeModel(model: 'gemini-1.5-flash');

  runApp(GenerativeAISample(model: model));
}

class GenerativeAISample extends StatelessWidget {
  final GenerativeModel model;

  const GenerativeAISample({super.key, required this.model});

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
      home: HomeScreen(model: model),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final GenerativeModel model;
  const HomeScreen({super.key, required this.model});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Widget> get _pages => <Widget>[
        // Build _pages dynamically
        ChatPage(title: 'Chat', model: widget.model),
        TokenCountPage(title: 'Token Count', model: widget.model),
        const FunctionCallingPage(
          title: 'Function Calling',
        ), // function calling will initial its own model
        ImagePromptPage(title: 'Image Prompt', model: widget.model),
        StorageUriPromptPage(title: 'Storage URI Prompt', model: widget.model),
        SchemaPromptPage(title: 'Schema Prompt', model: widget.model),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter + Vertex AI'),
      ),
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.chat,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Chat',
            tooltip: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.numbers,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Token Count',
            tooltip: 'Token Count',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.functions,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Function Calling',
            tooltip: 'Function Calling',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.image,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Image Prompt',
            tooltip: 'Image Prompt',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.folder,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Storage URI Prompt',
            tooltip: 'Storage URI Prompt',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.schema,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Schema Prompt',
            tooltip: 'Schema Prompt',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
