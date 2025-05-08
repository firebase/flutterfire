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
  late final GenerativeModel _functionCallModel;
  final List<MessageData> _messages = <MessageData>[];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.useVertexBackend) {
      var vertexAI = FirebaseAI.vertexAI(auth: FirebaseAuth.instance);
      _functionCallModel = vertexAI.generativeModel(
        model: 'gemini-2.0-flash',
        tools: [
          Tool.functionDeclarations([fetchWeatherTool]),
        ],
      );
    } else {
      var googleAI = FirebaseAI.googleAI(auth: FirebaseAuth.instance);
      _functionCallModel = googleAI.generativeModel(
        model: 'gemini-2.0-flash',
        tools: [
          Tool.functionDeclarations([fetchWeatherTool]),
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
                              await _testFunctionCalling();
                            }
                          : null,
                      child: const Text('Test Function Calling'),
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
    });
    final functionCallChat = _functionCallModel.startChat();
    const prompt = 'What is the weather like in Boston on 10/02 in year 2024?';

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
      _messages.add(MessageData(text: text));
      setState(() {
        _loading = false;
      });
    }
  }
}
