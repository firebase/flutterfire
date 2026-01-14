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
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/message_widget.dart';

class FunctionCallingPage extends StatefulWidget {
  const FunctionCallingPage({
    super.key,
    required this.title,
    required this.useVertexBackend,
  });

  final String title;
  final bool useVertexBackend;

  @override
  State<FunctionCallingPage> createState() => _FunctionCallingPageState();
}

class Location {
  final String city;
  final String state;

  Location(this.city, this.state);
}

class _FunctionCallingPageState extends State<FunctionCallingPage> {
  late GenerativeModel _functionCallModel;
  late GenerativeModel _codeExecutionModel;
  final List<MessageData> _messages = <MessageData>[];
  bool _loading = false;
  bool _enableThinking = false;

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  void _initializeModel() {
    final generationConfig = GenerationConfig(
      thinkingConfig: _enableThinking
          ? ThinkingConfig.withThinkingLevel(
              ThinkingLevel.high,
              includeThoughts: true,
            )
          : null,
    );
    if (widget.useVertexBackend) {
      var vertexAI = FirebaseAI.vertexAI(auth: FirebaseAuth.instance);
      _functionCallModel = vertexAI.generativeModel(
        model: 'gemini-2.5-flash',
        generationConfig: generationConfig,
        tools: [
          Tool.functionDeclarations([fetchWeatherTool]),
        ],
      );
      _codeExecutionModel = vertexAI.generativeModel(
        model: 'gemini-2.5-flash',
        generationConfig: generationConfig,
        tools: [
          Tool.codeExecution(),
        ],
      );
    } else {
      var googleAI = FirebaseAI.googleAI(auth: FirebaseAuth.instance);
      _functionCallModel = googleAI.generativeModel(
        model: 'gemini-2.5-flash',
        generationConfig: generationConfig,
        tools: [
          Tool.functionDeclarations([fetchWeatherTool]),
        ],
      );
      _codeExecutionModel = googleAI.generativeModel(
        model: 'gemini-2.5-flash',
        generationConfig: generationConfig,
        tools: [
          Tool.codeExecution(),
        ],
      );
    }
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
            SwitchListTile(
              title: const Text('Enable Thinking'),
              value: _enableThinking,
              onChanged: (bool value) {
                setState(() {
                  _enableThinking = value;
                  _initializeModel();
                });
              },
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, idx) {
                  final message = _messages[idx];
                  return MessageWidget(
                    text: message.text,
                    isFromUser: message.fromUser ?? false,
                    isThought: message.isThought,
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
                              await _testFunctionCalling();
                            }
                          : null,
                      child: const Text('Test Function Calling'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: !_loading
                          ? () async {
                              await _testCodeExecution();
                            }
                          : null,
                      child: const Text('Test Code Execution'),
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

  Future<void> _testFunctionCalling() async {
    setState(() {
      _loading = true;
      _messages.clear();
    });
    try {
      final functionCallChat = _functionCallModel.startChat();
      const prompt =
          'What is the weather like in Boston on 10/02 in year 2024?';

      _messages.add(MessageData(text: prompt, fromUser: true));

      // Send the message to the generative model.
      var response = await functionCallChat.sendMessage(
        Content.text(prompt),
      );

      final thought = response.thoughtSummary;
      if (thought != null) {
        _messages
            .add(MessageData(text: thought, fromUser: false, isThought: true));
      }

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
          final functionResult =
              await fetchWeather(Location(city, state), date);
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
        _messages.add(MessageData(text: text));
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _testCodeExecution() async {
    setState(() {
      _loading = true;
    });
    try {
      final codeExecutionChat = _codeExecutionModel.startChat();
      const prompt = 'What is the sum of the first 50 prime numbers? '
          'Generate and run code for the calculation, and make sure you get all 50.';

      _messages.add(MessageData(text: prompt, fromUser: true));

      final response =
          await codeExecutionChat.sendMessage(Content.text(prompt));

      final thought = response.thoughtSummary;
      if (thought != null) {
        _messages
            .add(MessageData(text: thought, fromUser: false, isThought: true));
      }

      final buffer = StringBuffer();
      for (final part in response.candidates.first.content.parts) {
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
        _messages.add(
          MessageData(
            text: buffer.toString(),
            fromUser: false,
          ),
        );
      }

      setState(() {
        _loading = false;
      });
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      setState(() {
        _loading = false;
      });
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
