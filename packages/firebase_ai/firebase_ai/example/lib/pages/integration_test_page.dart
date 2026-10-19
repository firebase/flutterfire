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

// ignore_for_file: experimental_member_use

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_ai/firebase_ai.dart';
import '../constants.dart';
import '../utils/function_call_utils.dart';

class IntegrationTestPage extends StatefulWidget {
  const IntegrationTestPage({super.key});

  @override
  State<IntegrationTestPage> createState() => _IntegrationTestPageState();
}

enum TestStatus { pending, running, passed, failed }

class TestResult {
  final TestStatus status;
  final String logs;
  final String? responseJson;
  final String? errorMessage;

  TestResult({
    required this.status,
    required this.logs,
    this.responseJson,
    this.errorMessage,
  });

  static TestResult pending() =>
      TestResult(status: TestStatus.pending, logs: 'Pending...');
}

class TestItem {
  final String id;
  final String name;
  final String description;
  final String model;
  final Future<TestResult> Function(FirebaseAI provider, TestLogger logger) run;
  TestResult googleAIResult;
  TestResult agentPlatformResult;

  TestItem({
    required this.id,
    required String name,
    required this.description,
    required this.model,
    required Future<TestResult> Function(
      FirebaseAI provider,
      TestLogger logger,
      String modelName,
    ) run,
  })  : name = name.contains(model) ? name : '$name ($model)',
        run = ((provider, logger) => run(provider, logger, model)),
        googleAIResult = TestResult.pending(),
        agentPlatformResult = TestResult.pending();
}

class TestLogger {
  final _buffer = StringBuffer();
  void log(String message) {
    final time = DateTime.now().toIso8601String().substring(11, 19);
    _buffer.writeln('[$time] $message');
  }

  @override
  String toString() => _buffer.toString();
}

class _IntegrationTestPageState extends State<IntegrationTestPage> {
  bool _isRunning = false;
  double _progress = 0;
  late List<TestItem> _testCases;

  /// Ids of test items currently being run individually (outside the suite).
  final Set<String> _runningItemIds = {};

  bool get _anyRunning => _isRunning || _runningItemIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _initializeTestCases();
  }

  void _initializeTestCases() {
    _testCases = [
      TestItem(
        id: '1',
        name: 'Stateless Text Gen',
        model: ExampleModels.flashLite,
        description:
            'Verifies simple stateless text generation with a precise answer target using ${ExampleModels.flashLite}.',
        run: (provider, logger, modelName) async {
          logger.log('Initializing model $modelName...');
          final model = provider.generativeModel(model: modelName);
          const prompt = "Reply with exactly the word 'SUCCESS' in uppercase.";
          logger.log('Sending prompt: "$prompt"');
          final response = await model.generateContent([Content.text(prompt)]);
          logger.log('Response text: "${response.text}"');
          if (response.text?.trim().toUpperCase().contains('SUCCESS') ??
              false) {
            return TestResult(
              status: TestStatus.passed,
              logs: logger.toString(),
              responseJson: response.text,
            );
          } else {
            return TestResult(
              status: TestStatus.failed,
              logs: logger.toString(),
              responseJson: response.text,
              errorMessage: 'Expected response to contain "SUCCESS"',
            );
          }
        },
      ),
      TestItem(
        id: '2',
        name: 'Structured JSON Output',
        model: ExampleModels.flashLite,
        description:
            'Verifies responseMimeType + responseSchema return JSON that matches the schema.',
        run: (provider, logger, modelName) async {
          final schema = Schema.object(
            properties: {
              'city': Schema.string(description: 'Name of the city.'),
              'country': Schema.string(description: 'Name of the country.'),
              'landmarks': Schema.array(
                items: Schema.string(),
                minItems: 1,
                description: 'Famous landmarks in the city.',
              ),
            },
          );
          logger.log(
            'Initializing model $modelName with application/json + responseSchema...',
          );
          final model = provider.generativeModel(
            model: modelName,
            generationConfig: GenerationConfig(
              responseMimeType: 'application/json',
              responseSchema: schema,
            ),
          );
          const prompt = 'Describe the capital city of France.';
          logger.log('Sending prompt: "$prompt"');
          final response = await model.generateContent([Content.text(prompt)]);
          final text = response.text ?? '';
          logger.log('Raw response: $text');

          Object? decoded;
          try {
            decoded = jsonDecode(text);
          } on FormatException catch (e) {
            return TestResult(
              status: TestStatus.failed,
              logs: logger.toString(),
              responseJson: text,
              errorMessage: 'Response is not valid JSON: $e',
            );
          }
          final problems = <String>[];
          if (decoded is! Map<String, dynamic>) {
            problems.add('Top-level JSON is not an object');
          } else {
            final city = decoded['city'];
            final country = decoded['country'];
            final landmarks = decoded['landmarks'];
            if (city is! String || !city.toLowerCase().contains('paris')) {
              problems.add('Expected city to be "Paris", got $city');
            }
            if (country is! String ||
                !country.toLowerCase().contains('france')) {
              problems.add('Expected country to be "France", got $country');
            }
            if (landmarks is! List || landmarks.isEmpty) {
              problems
                  .add('Expected non-empty landmarks array, got $landmarks');
            }
          }
          logger.log(
            problems.isEmpty ? 'JSON matches schema.' : problems.join('; '),
          );
          return TestResult(
            status: problems.isEmpty ? TestStatus.passed : TestStatus.failed,
            logs: logger.toString(),
            responseJson: text,
            errorMessage: problems.isEmpty ? null : problems.join('\n'),
          );
        },
      ),
      TestItem(
        id: '3',
        name: 'System Instructions',
        model: ExampleModels.flashLite,
        description:
            'Verifies system instructions config is serialized and respected.',
        run: (provider, logger, modelName) async {
          logger.log(
            'Initializing model $modelName with medieval system instruction...',
          );
          final model = provider.generativeModel(
            model: modelName,
            systemInstruction: Content.text(
              'You are a medieval knight. Respond only with Shakespearean knightly terms.',
            ),
          );
          const prompt = 'Who are you?';
          logger.log('Sending prompt: "$prompt"');
          final response = await model.generateContent([Content.text(prompt)]);
          logger.log('Response received: "${response.text}"');
          final responseText = response.text?.toLowerCase() ?? '';
          final containsKnightTerms = responseText.contains('thou') ||
              responseText.contains('thee') ||
              responseText.contains('sir') ||
              responseText.contains('knight') ||
              responseText.contains('ye') ||
              responseText.contains('hath') ||
              responseText.contains('doth');
          if (containsKnightTerms) {
            return TestResult(
              status: TestStatus.passed,
              logs: logger.toString(),
              responseJson: response.text,
            );
          } else {
            return TestResult(
              status: TestStatus.failed,
              logs: logger.toString(),
              responseJson: response.text,
              errorMessage:
                  'Response did not seem to contain Shakespearean knightly terms.',
            );
          }
        },
      ),
      TestItem(
        id: '4',
        name: 'Stateful Chat History',
        model: ExampleModels.flashLite,
        description:
            'Verifies stateful conversation preservation across turns via ChatSession.',
        run: (provider, logger, modelName) async {
          logger
              .log('Initializing model $modelName and starting ChatSession...');
          final model = provider.generativeModel(model: modelName);
          final chat = model.startChat();

          const prompt1 = 'My secret agent name is Agent Orange.';
          logger.log('Sending message 1: "$prompt1"');
          final resp1 = await chat.sendMessage(Content.text(prompt1));
          logger.log('Response 1: "${resp1.text}"');

          const prompt2 = 'What is my secret agent name?';
          logger.log('Sending message 2: "$prompt2"');
          final resp2 = await chat.sendMessage(Content.text(prompt2));
          logger.log('Response 2: "${resp2.text}"');

          if (resp2.text?.toLowerCase().contains('agent orange') ?? false) {
            return TestResult(
              status: TestStatus.passed,
              logs: logger.toString(),
              responseJson:
                  'Turn 1 Response:\n${resp1.text}\n\nTurn 2 Response:\n${resp2.text}',
            );
          } else {
            return TestResult(
              status: TestStatus.failed,
              logs: logger.toString(),
              responseJson: resp2.text,
              errorMessage: 'Expected second response to recall "Agent Orange"',
            );
          }
        },
      ),
      TestItem(
        id: '5',
        name: 'Auto Function Calling',
        model: ExampleModels.flashLite,
        description:
            'Verifies automatic function/tool call execution via AutoFunctionDeclaration.',
        run: (provider, logger, modelName) async {
          logger.log(
            'Declaring AutoFunctionDeclaration for getSuperHeroPower...',
          );
          final autoPowerTool = AutoFunctionDeclaration(
            name: 'getSuperHeroPower',
            description: 'Returns the superpower of a given superhero by name.',
            parameters: {
              'heroName':
                  Schema.string(description: 'The name of the superhero.'),
            },
            callable: (args) async {
              final hero = args['heroName'] as String?;
              logger.log(
                'CALLBACK TRIGGERED: getSuperHeroPower called for "$hero"',
              );
              if (hero?.toLowerCase().contains('laserman') ?? false) {
                return {'power': 'Laser Eyes'};
              }
              return {'power': 'Super Strength'};
            },
          );

          logger.log(
            'Initializing model $modelName with AutoFunctionDeclaration...',
          );
          final model = provider.generativeModel(
            model: modelName,
            tools: [
              Tool.functionDeclarations([autoPowerTool]),
            ],
          );
          final chat = model.startChat();

          const prompt = 'What superpower does LaserMan have?';
          logger.log('Sending message triggering auto-function: "$prompt"');
          final response = await chat.sendMessage(Content.text(prompt));
          logger.log('Final response: "${response.text}"');

          if (response.text?.toLowerCase().contains('laser') ?? false) {
            return TestResult(
              status: TestStatus.passed,
              logs: logger.toString(),
              responseJson: response.text,
            );
          } else {
            return TestResult(
              status: TestStatus.failed,
              logs: logger.toString(),
              responseJson: response.text,
              errorMessage:
                  'Expected final response to mention "Laser Eyes" or "Laser"',
            );
          }
        },
      ),
      TestItem(
        id: '6',
        name: 'Manual Function Calling',
        model: ExampleModels.flashLite,
        description:
            'Verifies manual function call prediction and response handling.',
        run: (provider, logger, modelName) async {
          logger.log('Declaring FunctionDeclaration...');
          final powerTool = FunctionDeclaration(
            'getSuperHeroPower',
            'Returns the superpower of a given superhero by name.',
            parameters: {
              'heroName':
                  Schema.string(description: 'The name of the superhero.'),
            },
          );

          logger.log(
            'Initializing model $modelName for manual function calling...',
          );
          final model = provider.generativeModel(
            model: modelName,
            tools: [
              Tool.functionDeclarations([powerTool]),
            ],
          );

          const prompt = 'What superpower does LaserMan have?';
          logger.log('Sending prompt: "$prompt"');
          final response = await model.generateContent([Content.text(prompt)]);
          final functionCalls = response.functionCalls;

          logger.log(
            'Function calls predicted: ${functionCalls.map((c) => c.name).toList()}',
          );

          if (functionCalls.isEmpty) {
            return TestResult(
              status: TestStatus.failed,
              logs: logger.toString(),
              responseJson: response.text,
              errorMessage: 'Expected function call prediction but got none.',
            );
          }

          final call = functionCalls.first;
          logger.log(
            'Intercepted call details: name=${call.name}, args=${call.args}',
          );
          final hero = call.args['heroName'] as String?;
          String power = 'Super Strength';
          if (hero?.toLowerCase().contains('laserman') ?? false) {
            power = 'Laser Eyes';
          }

          logger.log(
            'Manually constructing FunctionResponse: {"power": "$power"}',
          );
          final manualResponse = FunctionResponse(call.name, {'power': power});

          logger
              .log('Sending second request with history + FunctionResponse...');
          final nextResponse = await model.generateContent([
            Content.text(prompt),
            response.candidates.first.content,
            Content.functionResponses([manualResponse]),
          ]);

          logger.log('Final response: "${nextResponse.text}"');
          if (nextResponse.text?.toLowerCase().contains('laser') ?? false) {
            return TestResult(
              status: TestStatus.passed,
              logs: logger.toString(),
              responseJson: nextResponse.text,
            );
          } else {
            return TestResult(
              status: TestStatus.failed,
              logs: logger.toString(),
              responseJson: nextResponse.text,
              errorMessage: 'Expected final response to mention "Laser Eyes"',
            );
          }
        },
      ),
      TestItem(
        id: '7',
        name: 'Code Execution Tool',
        model: ExampleModels.flashLite,
        description:
            'Verifies Tool.codeExecution() internal code execution and parts extraction.',
        run: (provider, logger, modelName) async {
          logger.log(
            'Initializing model $modelName with Tool.codeExecution()...',
          );
          final model = provider.generativeModel(
            model: modelName,
            tools: [Tool.codeExecution()],
          );

          const prompt =
              'Write a Python script to print the 10th Fibonacci number, then execute it.';
          logger.log('Sending prompt: "$prompt"');
          final response = await model.generateContent([Content.text(prompt)]);

          final parts = response.candidates.firstOrNull?.content.parts ?? [];
          final hasExecutableCode = parts.any((p) => p is ExecutableCodePart);
          final hasCodeResult = parts.any((p) => p is CodeExecutionResultPart);

          logger.log('Response received. Parsing parts:');
          for (var i = 0; i < parts.length; i++) {
            final p = parts[i];
            logger.log('  Part $i: Type=${p.runtimeType}');
            if (p is ExecutableCodePart) {
              logger.log('    Code:\n${p.code}');
            } else if (p is CodeExecutionResultPart) {
              logger.log('    Output:\n${p.output}');
            }
          }

          if (hasExecutableCode && hasCodeResult) {
            return TestResult(
              status: TestStatus.passed,
              logs: logger.toString(),
              responseJson: response.text,
            );
          } else {
            return TestResult(
              status: TestStatus.failed,
              logs: logger.toString(),
              responseJson: response.text,
              errorMessage:
                  'Missing ExecutableCodePart or CodeExecutionResultPart in response parts.',
            );
          }
        },
      ),
      TestItem(
        id: '8',
        name: 'Search Grounding',
        model: ExampleModels.flashLite,
        description:
            'Verifies Google Search Grounding tool configuration and grounding metadata.',
        run: (provider, logger, modelName) async {
          logger.log(
            'Initializing model $modelName with Tool.googleSearch()...',
          );
          final model = provider.generativeModel(
            model: modelName,
            tools: [Tool.googleSearch()],
          );
          const prompt = 'Who is the current CEO of Google?';
          logger.log('Sending prompt: "$prompt"');
          final response = await model.generateContent([Content.text(prompt)]);
          logger.log('Response text: "${response.text}"');

          final grounding = response.candidates.firstOrNull?.groundingMetadata;
          if (grounding != null) {
            final sources = grounding.groundingChunks
                .map((c) => c.web?.uri ?? '')
                .join('\n');
            logger.log('Grounding chunks found. Web sources:\n$sources');
            return TestResult(
              status: TestStatus.passed,
              logs: logger.toString(),
              responseJson:
                  'Text Response: ${response.text}\n\nGrounding Sources:\n$sources',
            );
          } else {
            return TestResult(
              status: TestStatus.failed,
              logs: logger.toString(),
              responseJson: response.text,
              errorMessage:
                  'Expected GroundingMetadata in response but got null.',
            );
          }
        },
      ),
      TestItem(
        id: '9',
        name: 'Streaming Generation',
        model: ExampleModels.flashLite,
        description:
            'Verifies generateContentStream works and aggregates chunks correctly.',
        run: (provider, logger, modelName) async {
          logger.log('Initializing model $modelName for streaming...');
          final model = provider.generativeModel(model: modelName);

          const prompt = 'Write a 2-paragraph poem about a computer.';
          logger.log('Starting prompt stream: "$prompt"');
          final stream = model.generateContentStream([Content.text(prompt)]);

          final textBuffer = StringBuffer();
          int chunkCount = 0;

          await for (final chunk in stream) {
            chunkCount++;
            final chunkText = chunk.text ?? '';
            logger.log('Chunk $chunkCount: length=${chunkText.length}');
            textBuffer.write(chunkText);
          }

          logger.log(
            'Stream finished. Total chunks=$chunkCount, aggregated length=${textBuffer.length}',
          );
          if (textBuffer.isNotEmpty) {
            return TestResult(
              status: TestStatus.passed,
              logs: logger.toString(),
              responseJson: textBuffer.toString(),
            );
          } else {
            return TestResult(
              status: TestStatus.failed,
              logs: logger.toString(),
              errorMessage: 'Stream aggregated output was empty.',
            );
          }
        },
      ),
      TestItem(
        id: '10',
        name: 'Advanced Token Counting',
        model: ExampleModels.flashLite,
        description:
            'Verifies counting tokens on multimodal inputs (text + image asset).',
        run: (provider, logger, modelName) async {
          logger.log('Loading cat.jpg asset...');
          final catBytes = await rootBundle.load('assets/images/cat.jpg');

          logger.log('Initializing model $modelName for token counting...');
          final model = provider.generativeModel(model: modelName);

          final content = [
            Content.multi([
              const TextPart('Describe this cat.'),
              InlineDataPart('image/jpeg', catBytes.buffer.asUint8List()),
            ]),
          ];

          logger.log('Invoking countTokens API...');
          final response = await model.countTokens(content);
          logger.log('Total Tokens: ${response.totalTokens}');

          if (response.totalTokens > 0) {
            return TestResult(
              status: TestStatus.passed,
              logs: logger.toString(),
              responseJson: 'Total Tokens: ${response.totalTokens}',
            );
          } else {
            return TestResult(
              status: TestStatus.failed,
              logs: logger.toString(),
              errorMessage: 'Expected token count > 0',
            );
          }
        },
      ),
      TestItem(
        id: '11',
        name: 'Usage Metadata & Thinking',
        model: ExampleModels.flashLite,
        description:
            'Verifies extraction of thought logs and usage metadata with ThinkingConfig.',
        run: (provider, logger, modelName) async {
          logger.log(
            'Initializing model $modelName with ThinkingConfig...',
          );
          final model = provider.generativeModel(
            model: modelName,
            generationConfig: GenerationConfig(
              thinkingConfig: ThinkingConfig.withThinkingBudget(
                2048,
                includeThoughts: true,
              ),
            ),
          );

          const prompt =
              'If a train travels 100 miles at 50 mph, and another travels 120 miles at 60 mph, which arrives first?';
          logger.log('Sending prompt with thinking enabled: "$prompt"');
          final response = await model.generateContent([Content.text(prompt)]);

          final usage = response.usageMetadata;
          final thoughts = response.thoughtSummary;
          logger.log('Response text: "${response.text}"');
          logger.log('Thoughts extracted: "$thoughts"');
          logger.log(
            'Usage Details: prompt=${usage?.promptTokenCount}, candidates=${usage?.candidatesTokenCount}, total=${usage?.totalTokenCount}, thoughts=${usage?.thoughtsTokenCount}',
          );

          if (usage != null && usage.totalTokenCount! > 0) {
            return TestResult(
              status: TestStatus.passed,
              logs: logger.toString(),
              responseJson:
                  'Thoughts:\n$thoughts\n\nResponse:\n${response.text}\n\nMetadata:\n- Total Tokens: ${usage.totalTokenCount}\n- Thoughts Tokens: ${usage.thoughtsTokenCount}',
            );
          } else {
            return TestResult(
              status: TestStatus.failed,
              logs: logger.toString(),
              errorMessage: 'Usage metadata was null or invalid.',
            );
          }
        },
      ),
      TestItem(
        id: '12',
        name: 'Multimodal Response Modality',
        model: ExampleModels.flashImage,
        description:
            'Verifies text + image response output generation via ${ExampleModels.flashImage} model.',
        run: (provider, logger, modelName) async {
          logger.log(
            'Initializing model $modelName with dual response modalities...',
          );
          final model = provider.generativeModel(
            model: modelName,
            generationConfig: GenerationConfig(
              responseModalities: [
                ResponseModalities.text,
                ResponseModalities.image,
              ],
            ),
          );

          const prompt = 'Draw a simple red triangle on a blue background.';
          logger.log('Sending multimodal output prompt: "$prompt"');
          final response = await model.generateContent([Content.text(prompt)]);

          final imageParts = response.inlineDataParts
              .where((p) => p.mimeType.startsWith('image/'));
          logger.log('Response text: "${response.text}"');
          logger.log('Image parts returned: ${imageParts.length}');

          if (imageParts.isNotEmpty) {
            final img = imageParts.first;
            logger.log(
              'Generated Image: mime=${img.mimeType}, size=${img.bytes.length} bytes',
            );
            return TestResult(
              status: TestStatus.passed,
              logs: logger.toString(),
              responseJson:
                  'Text Response: ${response.text}\nImage generated successfully: mime=${img.mimeType}, size=${img.bytes.length} bytes',
            );
          } else {
            return TestResult(
              status: TestStatus.failed,
              logs: logger.toString(),
              responseJson: response.text,
              errorMessage:
                  'No generated image was returned in response inline parts.',
            );
          }
        },
      ),
      TestItem(
        id: '13',
        name: 'Streaming Function Calling',
        model: ExampleModels.flashLite,
        description:
            'Verifies ChatSession.sendMessageStream auto-executes an AutoFunctionDeclaration and streams the final answer.',
        run: (provider, logger, modelName) async {
          var callbackCount = 0;
          final weatherTool = AutoFunctionDeclaration(
            name: 'getWeather',
            description: 'Returns the current weather for a city.',
            parameters: {
              'city': Schema.string(description: 'The name of the city.'),
            },
            callable: (args) async {
              callbackCount++;
              logger.log(
                'CALLBACK TRIGGERED: getWeather called with $args',
              );
              return {'temperature_celsius': 21, 'condition': 'Sunny'};
            },
          );

          logger.log('Initializing model $modelName with getWeather tool...');
          final model = provider.generativeModel(
            model: modelName,
            tools: [
              Tool.functionDeclarations([weatherTool]),
            ],
          );
          final chat = model.startChat();

          const prompt =
              'What is the weather in Boston right now? Use the getWeather tool.';
          logger.log('Streaming message: "$prompt"');

          final textBuffer = StringBuffer();
          var chunkCount = 0;
          var functionCallChunks = 0;
          await for (final chunk
              in chat.sendMessageStream(Content.text(prompt))) {
            chunkCount++;
            final calls = chunk.functionCalls.toList();
            if (calls.isNotEmpty) {
              functionCallChunks++;
              logger.log(
                'Chunk $chunkCount: functionCalls=${calls.map((c) => '${c.name}(${c.args})').toList()}',
              );
            }
            final t = chunk.text;
            if (t != null && t.isNotEmpty) {
              logger.log('Chunk $chunkCount: text length=${t.length}');
              textBuffer.write(t);
            }
          }

          final finalText = textBuffer.toString();
          logger.log(
            'Stream finished. chunks=$chunkCount, functionCallChunks=$functionCallChunks, callbacks=$callbackCount',
          );
          final mentionsWeather = finalText.toLowerCase().contains('sunny') ||
              finalText.contains('21');
          final problems = <String>[
            if (callbackCount == 0) 'getWeather callback was never invoked',
            if (functionCallChunks == 0)
              'No streamed chunk contained a function call',
            if (!mentionsWeather)
              'Final streamed text does not mention "Sunny" or "21"',
          ];
          return TestResult(
            status: problems.isEmpty ? TestStatus.passed : TestStatus.failed,
            logs: logger.toString(),
            responseJson: finalText,
            errorMessage: problems.isEmpty ? null : problems.join('\n'),
          );
        },
      ),
      TestItem(
        id: '14',
        name: 'Multimodal Input (Image + Video + PDF)',
        model: ExampleModels.flashLite,
        description:
            'Verifies inline image, video, and PDF inputs are accepted and understood in a single request.',
        run: (provider, logger, modelName) async {
          logger.log('Loading assets (cat.jpg, landscape.mp4, PDF)...');
          final image = await rootBundle.load('assets/images/cat.jpg');
          final video = await rootBundle.load('assets/videos/landscape.mp4');
          final pdf =
              await rootBundle.load('assets/documents/gemini_summary.pdf');
          logger.log(
            'Sizes: image=${image.lengthInBytes}B, video=${video.lengthInBytes}B, pdf=${pdf.lengthInBytes}B',
          );

          final model = provider.generativeModel(model: modelName);
          const prompt =
              'You are given three attachments in this order: an image, a '
              'video, and a PDF document. Reply with exactly three lines in '
              'this format and nothing else:\n'
              'IMAGE: <the animal in the image, one word>\n'
              'VIDEO: <a short description of the video>\n'
              'PDF: <a short description of the document topic>';
          logger.log('Sending multimodal request...');
          final response = await model.generateContent([
            Content.multi([
              const TextPart(prompt),
              InlineDataPart('image/jpeg', image.buffer.asUint8List()),
              InlineDataPart('video/mp4', video.buffer.asUint8List()),
              InlineDataPart('application/pdf', pdf.buffer.asUint8List()),
            ]),
          ]);
          final text = response.text ?? '';
          logger.log('Response:\n$text');

          String? field(String name) => RegExp(
                '^\\s*\\**$name\\**\\s*:\\s*(.+)\$',
                multiLine: true,
                caseSensitive: false,
              ).firstMatch(text)?.group(1)?.trim();
          final imageAnswer = field('IMAGE');
          final videoAnswer = field('VIDEO');
          final pdfAnswer = field('PDF');
          logger.log(
            'Parsed: IMAGE="$imageAnswer", VIDEO="$videoAnswer", PDF="$pdfAnswer"',
          );

          final problems = <String>[
            if (!(imageAnswer?.toLowerCase().contains('cat') ?? false))
              'IMAGE line should identify a cat, got "$imageAnswer"',
            if (videoAnswer == null || videoAnswer.isEmpty)
              'Missing VIDEO description',
            if (pdfAnswer == null || pdfAnswer.isEmpty)
              'Missing PDF description',
          ];
          final usage = response.usageMetadata;
          if (usage != null) {
            logger.log(
              'Prompt tokens by modality: ${usage.promptTokensDetails?.map((d) => '${d.modality.name}=${d.tokenCount}').join(', ')}',
            );
          }
          return TestResult(
            status: problems.isEmpty ? TestStatus.passed : TestStatus.failed,
            logs: logger.toString(),
            responseJson: text,
            errorMessage: problems.isEmpty ? null : problems.join('\n'),
          );
        },
      ),
      // ---------------------------------------------------------------------
      // Server prompt templates. Template ids/inputs mirror ServerTemplatePage
      // so they exist in the example Firebase project. `model` holds the
      // template id.
      // ---------------------------------------------------------------------
      TestItem(
        id: '15',
        name: 'Template generateContent',
        model: 'new-greeting',
        description:
            'Verifies TemplateGenerativeModel.generateContent with template inputs.',
        run: (provider, logger, templateId) async {
          final model = provider.templateGenerativeModel();
          const inputs = {'name': 'Firebase'};
          logger.log('generateContent("$templateId", inputs: $inputs)');
          final response =
              await model.generateContent(templateId, inputs: inputs);
          final text = response.text ?? '';
          logger.log('Response text: "$text"');
          return _expect(
            logger,
            text,
            [if (text.trim().isEmpty) 'Template returned empty text'],
          );
        },
      ),
      TestItem(
        id: '16',
        name: 'Template generateContentStream',
        model: 'new-greeting',
        description:
            'Verifies TemplateGenerativeModel.generateContentStream streams and aggregates chunks.',
        run: (provider, logger, templateId) async {
          final model = provider.templateGenerativeModel();
          const inputs = {'name': 'Firebase'};
          logger.log('generateContentStream("$templateId", inputs: $inputs)');
          final buffer = StringBuffer();
          var chunks = 0;
          await for (final chunk
              in model.generateContentStream(templateId, inputs: inputs)) {
            chunks++;
            final t = chunk.text ?? '';
            logger.log('Chunk $chunks: length=${t.length}');
            buffer.write(t);
          }
          logger.log('Stream finished. chunks=$chunks');
          final text = buffer.toString();
          return _expect(logger, text, [
            if (chunks == 0) 'Stream produced no chunks',
            if (text.trim().isEmpty) 'Aggregated streamed text is empty',
          ]);
        },
      ),
      TestItem(
        id: '17',
        name: 'Template Chat History',
        model: 'cj-chat-history',
        description:
            'Verifies TemplateChatSession keeps history across turns (startChat + sendMessage).',
        run: (provider, logger, templateId) async {
          final chat = provider
              .templateGenerativeModel()
              .startChat(templateId, inputs: {});
          const prompt1 = 'My secret agent name is Agent Orange.';
          logger.log('Turn 1: "$prompt1"');
          final r1 = await chat.sendMessage(Content.text(prompt1));
          logger.log('Response 1: "${r1.text}"');
          const prompt2 = 'What is my secret agent name?';
          logger.log('Turn 2: "$prompt2"');
          final r2 = await chat.sendMessage(Content.text(prompt2));
          logger.log('Response 2: "${r2.text}"');
          final text = r2.text ?? '';
          return _expect(
            logger,
            'Turn 1:\n${r1.text}\n\nTurn 2:\n$text',
            [
              if (!text.toLowerCase().contains('orange'))
                'Second turn did not recall "Agent Orange"',
            ],
          );
        },
      ),
      TestItem(
        id: '18',
        name: 'Template Auto Function Calling',
        model: 'cj-function-calling-weather',
        description:
            'Verifies TemplateAutoFunctionDeclaration is executed automatically in a template chat.',
        run: (provider, logger, templateId) async {
          var callbacks = 0;
          final chat = provider.templateGenerativeModel().startChat(
            templateId,
            inputs: {},
            tools: [
              TemplateTool.functionDeclarations([
                TemplateAutoFunctionDeclaration(
                  name: 'fetchWeather',
                  callable: (args) {
                    callbacks++;
                    logger.log('CALLBACK TRIGGERED: fetchWeather($args)');
                    return fetchWeatherCallable(args);
                  },
                ),
              ]),
            ],
          );
          const prompt =
              'What is the weather like in Boston, MA on 2026-10-21?';
          logger.log('Sending: "$prompt"');
          final response = await chat.sendMessage(Content.text(prompt));
          final text = response.text ?? '';
          logger.log('Final response: "$text"');
          return _expect(logger, text, [
            if (callbacks == 0) 'fetchWeather callback was never invoked',
            if (!_mentionsMockWeather(text))
              'Final text does not reflect the mocked weather (38 / 56% / cloudy)',
          ]);
        },
      ),
      TestItem(
        id: '19',
        name: 'Template Streaming Function Calling',
        model: 'cj-function-calling-weather-stream',
        description:
            'Verifies TemplateChatSession.sendMessageStream auto-executes tools and streams the answer.',
        run: (provider, logger, templateId) async {
          var callbacks = 0;
          final chat = provider.templateGenerativeModel().startChat(
            templateId,
            inputs: {},
            tools: [
              TemplateTool.functionDeclarations([
                TemplateAutoFunctionDeclaration(
                  name: 'fetchWeather',
                  callable: (args) {
                    callbacks++;
                    logger.log('CALLBACK TRIGGERED: fetchWeather($args)');
                    return fetchWeatherCallable(args);
                  },
                ),
              ]),
            ],
          );
          const prompt =
              'What is the weather like in Boston, MA on 2026-10-21?';
          logger.log('Streaming: "$prompt"');
          final buffer = StringBuffer();
          var chunks = 0;
          var functionCallChunks = 0;
          await for (final chunk
              in chat.sendMessageStream(Content.text(prompt))) {
            chunks++;
            final calls = chunk.functionCalls.toList();
            if (calls.isNotEmpty) {
              functionCallChunks++;
              logger.log(
                'Chunk $chunks: functionCalls=${calls.map((c) => c.name).toList()}',
              );
            }
            final t = chunk.text;
            if (t != null && t.isNotEmpty) buffer.write(t);
          }
          final text = buffer.toString();
          logger.log(
            'Stream finished. chunks=$chunks, functionCallChunks=$functionCallChunks, callbacks=$callbacks',
          );
          return _expect(logger, text, [
            if (callbacks == 0) 'fetchWeather callback was never invoked',
            if (functionCallChunks == 0)
              'No streamed chunk contained a function call',
            if (!_mentionsMockWeather(text))
              'Final streamed text does not reflect the mocked weather',
          ]);
        },
      ),
      TestItem(
        id: '20',
        name: 'Template Manual Function Calling',
        model: 'cj-function-calling-weather-override',
        description:
            'Verifies client-declared TemplateFunctionDeclaration override, manual FunctionResponse round trip.',
        run: (provider, logger, templateId) async {
          final chat = provider.templateGenerativeModel().startChat(
            templateId,
            inputs: {},
            tools: [
              TemplateTool.functionDeclarations([
                TemplateFunctionDeclaration(
                  'fetchWeather',
                  parameters: {
                    'location': JSONSchema.object(
                      description:
                          'The city and state to get the weather for. Only '
                          'cities in the USA are supported.',
                      properties: {
                        'city': JSONSchema.string(description: 'The city.'),
                        'state': JSONSchema.string(description: 'The state.'),
                      },
                    ),
                    'date': JSONSchema.string(
                      description: 'The date, in the format YYYY-MM-DD.',
                    ),
                  },
                ),
              ]),
            ],
          );
          const prompt =
              'What is the weather like in Boston, MA on 2026-10-21?';
          logger.log('Sending: "$prompt"');
          final response = await chat.sendMessage(Content.text(prompt));
          final calls = response.functionCalls.toList();
          logger.log(
            'Function calls: ${calls.map((c) => '${c.name}(${c.args})').toList()}',
          );
          if (calls.isEmpty || calls.any((c) => c.name != 'fetchWeather')) {
            return _expect(logger, response.text ?? '', [
              'Expected only fetchWeather function calls, got ${calls.map((c) => c.name).toList()}',
            ]);
          }
          if (!calls.any(
            (c) => '${c.args['location']}'.toLowerCase().contains('boston'),
          )) {
            logger.log('WARNING: no call targets Boston');
          }
          // The model may issue parallel calls (e.g. the template's own example
          // location plus the user's). The backend requires one
          // FunctionResponse per FunctionCall in the next turn.
          final responses = <FunctionResponse>[];
          for (final call in calls) {
            final result = await fetchWeatherCallable(call.args);
            responses.add(FunctionResponse(call.name, result, id: call.id));
          }
          logger.log(
            'Sending ${responses.length} FunctionResponse(s): '
            '${responses.map((r) => r.response).toList()}',
          );
          final next =
              await chat.sendMessage(Content.functionResponses(responses));
          final text = next.text ?? '';
          logger.log('Final response: "$text"');
          return _expect(logger, text, [
            if (!_mentionsMockWeather(text))
              'Final text does not reflect the FunctionResponse data',
          ]);
        },
      ),
      TestItem(
        id: '21',
        name: 'Template Image Input',
        model: 'cj-media-test',
        description:
            'Verifies passing inline image data as a template input variable.',
        run: (provider, logger, templateId) async {
          final bytes = (await rootBundle.load('assets/images/cat.jpg'))
              .buffer
              .asUint8List();
          logger.log('generateContent("$templateId") with cat.jpg '
              '(${bytes.length}B) as imageData[0]');
          // The SDK serializes InlineDataPart template inputs to
          // {isInline, mimeType, contents(base64)}; the `cj-media-test` template loops
          // over `imageData` and renders each with
          // {{media type="mimeType" data="contents"}}.
          final response =
              await provider.templateGenerativeModel().generateContent(
            templateId,
            inputs: {
              'prompt': 'What animal is in this image? Answer in one sentence.',
              'imageData': [InlineDataPart('image/jpeg', bytes)],
            },
          );
          final text = response.text ?? '';
          logger.log('Response: "$text"');
          return _expect(logger, text, [
            if (!text.toLowerCase().contains('cat'))
              'Response does not mention the cat in the image',
          ]);
        },
      ),
      TestItem(
        id: '22',
        name: 'Template Code Execution',
        model: 'cj-code-execution',
        description:
            'Verifies a template with the code execution tool returns code and result parts.',
        run: (provider, logger, templateId) async {
          logger.log('generateContent("$templateId", inputs: {})');
          final response = await provider
              .templateGenerativeModel()
              .generateContent(templateId, inputs: {});
          final parts = response.candidates.firstOrNull?.content.parts ?? [];
          for (final (i, p) in parts.indexed) {
            logger.log('Part $i: ${p.runtimeType}');
            if (p is ExecutableCodePart) logger.log('  code:\n${p.code}');
            if (p is CodeExecutionResultPart) {
              logger.log('  outcome=${p.outcome} output:\n${p.output}');
            }
          }
          return _expect(logger, response.text ?? '', [
            if (!parts.any((p) => p is ExecutableCodePart))
              'Missing ExecutableCodePart',
            if (!parts.any((p) => p is CodeExecutionResultPart))
              'Missing CodeExecutionResultPart',
          ]);
        },
      ),
      TestItem(
        id: '23',
        name: 'Template URL Context',
        model: 'cj-urlcontext',
        description:
            'Verifies a template using the URL context tool returns urlContextMetadata.',
        run: (provider, logger, templateId) async {
          const url = 'https://firebase.google.com/docs/ai-logic';
          logger.log('generateContent("$templateId", inputs: {url: $url})');
          final response = await provider
              .templateGenerativeModel()
              .generateContent(templateId, inputs: {'url': url});
          final candidate = response.candidates.firstOrNull;
          final urlMeta = candidate?.urlContextMetadata?.urlMetadata ?? [];
          for (final m in urlMeta) {
            logger.log('URL: ${m.retrievedUrl} status=${m.urlRetrievalStatus}');
          }
          final text = response.text ?? '';
          logger.log('Response length: ${text.length}');
          return _expect(logger, text, [
            if (text.trim().isEmpty) 'Empty response text',
            if (urlMeta.isEmpty) 'No urlContextMetadata in response',
          ]);
        },
      ),
      TestItem(
        id: '24',
        name: 'Template Maps Grounding',
        model: 'cj-googlemaps',
        description:
            'Verifies TemplateToolConfig retrievalConfig (latLng) with Google Maps grounding.',
        run: (provider, logger, templateId) async {
          const question = 'What are some good coffee shops near me?';
          logger.log('generateContent("$templateId") question="$question" '
              'latLng=Googleplex');
          final response =
              await provider.templateGenerativeModel().generateContent(
                    templateId,
                    inputs: {'question': question},
                    toolConfig: TemplateToolConfig(
                      retrievalConfig: RetrievalConfig(
                        latLng: LatLng(latitude: 37.422, longitude: -122.084),
                      ),
                    ),
                  );
          final grounding = response.candidates.firstOrNull?.groundingMetadata;
          final mapsChunks = grounding?.groundingChunks
                  .where((c) => c.maps != null)
                  .toList() ??
              [];
          for (final c in mapsChunks) {
            logger.log('Maps chunk: ${c.maps!.title} ${c.maps!.uri}');
          }
          final text = response.text ?? '';
          return _expect(logger, text, [
            if (text.trim().isEmpty) 'Empty response text',
            if (grounding == null) 'No groundingMetadata in response',
            if (grounding != null && mapsChunks.isEmpty)
              'groundingMetadata has no Maps chunks',
          ]);
        },
      ),
    ];
  }

  /// Builds a pass/fail [TestResult] from a list of failed checks.
  static TestResult _expect(
    TestLogger logger,
    String response,
    List<String> problems,
  ) {
    logger.log(problems.isEmpty ? 'All checks passed.' : problems.join('; '));
    return TestResult(
      status: problems.isEmpty ? TestStatus.passed : TestStatus.failed,
      logs: logger.toString(),
      responseJson: response,
      errorMessage: problems.isEmpty ? null : problems.join('\n'),
    );
  }

  /// Whether [text] reflects the mocked data from `fetchWeather`
  /// (38 degrees, 56% precipitation, partly cloudy).
  static bool _mentionsMockWeather(String text) {
    final t = text.toLowerCase();
    return t.contains('38') || t.contains('56') || t.contains('cloud');
  }

  Future<void> _runTestItem(TestItem item, bool isAgentPlatform) async {
    final provider =
        isAgentPlatform ? FirebaseAI.agentPlatform() : FirebaseAI.googleAI();
    final logger = TestLogger();

    setState(() {
      if (isAgentPlatform) {
        item.agentPlatformResult =
            TestResult(status: TestStatus.running, logs: 'Running...');
      } else {
        item.googleAIResult =
            TestResult(status: TestStatus.running, logs: 'Running...');
      }
    });

    try {
      logger.log(
        'Starting execution for ${item.name} (${isAgentPlatform ? 'Agent Platform' : 'Google AI'})...',
      );
      final result = await item.run(provider, logger);
      setState(() {
        if (isAgentPlatform) {
          item.agentPlatformResult = result;
        } else {
          item.googleAIResult = result;
        }
      });
    } catch (e, s) {
      logger.log('CRITICAL ERROR: $e\n$s');
      setState(() {
        final failResult = TestResult(
          status: TestStatus.failed,
          logs: logger.toString(),
          errorMessage: e.toString(),
        );
        if (isAgentPlatform) {
          item.agentPlatformResult = failResult;
        } else {
          item.googleAIResult = failResult;
        }
      });
    }
  }

  /// Runs a single test item on the selected backend(s) without running the
  /// full suite. Useful for debugging one case.
  Future<void> _runSingle(
    TestItem item, {
    bool googleAI = true,
    bool agentPlatform = true,
  }) async {
    if (_isRunning || _runningItemIds.contains(item.id)) return;
    setState(() {
      _runningItemIds.add(item.id);
      if (googleAI) item.googleAIResult = TestResult.pending();
      if (agentPlatform) item.agentPlatformResult = TestResult.pending();
    });
    try {
      if (googleAI) await _runTestItem(item, false);
      if (agentPlatform) await _runTestItem(item, true);
    } finally {
      if (mounted) setState(() => _runningItemIds.remove(item.id));
    }
  }

  Future<void> _runSuite() async {
    if (_anyRunning) return;

    setState(() {
      _isRunning = true;
      _progress = 0;
      for (final item in _testCases) {
        item.googleAIResult = TestResult.pending();
        item.agentPlatformResult = TestResult.pending();
      }
    });

    final totalSteps = _testCases.length * 2;
    int completedSteps = 0;

    for (final item in _testCases) {
      // Run Google AI
      await _runTestItem(item, false);
      completedSteps++;
      setState(() {
        _progress = completedSteps / totalSteps;
      });

      // Run Vertex AI
      await _runTestItem(item, true);
      completedSteps++;
      setState(() {
        _progress = completedSteps / totalSteps;
      });
    }

    setState(() {
      _isRunning = false;
    });
  }

  Widget _buildProviderSummary(String title, List<TestResult> results) {
    final total = results.length;
    final passed = results.where((r) => r.status == TestStatus.passed).length;
    final failed = results.where((r) => r.status == TestStatus.failed).length;
    final running = results.where((r) => r.status == TestStatus.running).length;

    Color cardColor = Colors.blueGrey.shade900;
    if (total > 0 && running == 0) {
      if (failed > 0) {
        cardColor = Colors.red.shade900.withAlpha(150);
      } else if (passed == total) {
        cardColor = Colors.green.shade900.withAlpha(150);
      }
    }

    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pass: $passed/$total',
                  style: TextStyle(color: Colors.green.shade300),
                ),
                Text(
                  'Fail: $failed',
                  style: TextStyle(
                    color: failed > 0 ? Colors.red.shade300 : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(TestResult result) {
    switch (result.status) {
      case TestStatus.pending:
        return Chip(
          label: const Text(
            'PENDING',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
          backgroundColor: Colors.grey.shade800,
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      case TestStatus.running:
        return const SizedBox(
          height: 16,
          width: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case TestStatus.passed:
        return Chip(
          label: const Text(
            'PASS',
            style: TextStyle(
              fontSize: 10,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.green.withAlpha(40),
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      case TestStatus.failed:
        return Chip(
          label: const Text(
            'FAIL',
            style: TextStyle(
              fontSize: 10,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.red.withAlpha(40),
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
    }
  }

  Widget _buildLogsConsole(String title, TestResult result) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(150),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const Divider(height: 8),
          if (result.errorMessage != null) ...[
            Text(
              'ERROR:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red.shade300,
              ),
            ),
            SelectableText(
              result.errorMessage!,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: Colors.red.shade200,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (result.responseJson != null) ...[
            const Text(
              'RESPONSE:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.purpleAccent,
              ),
            ),
            SelectableText(
              result.responseJson!,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: Colors.purpleAccent,
              ),
            ),
            const SizedBox(height: 8),
          ],
          const Text(
            'EXECUTION LOGS:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          SelectableText(
            result.logs,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final googleAIResults =
        _testCases.map((item) => item.googleAIResult).toList();
    final vertexAIResults =
        _testCases.map((item) => item.agentPlatformResult).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('One-Click SDK Integration Tests'),
        actions: [
          if (!_isRunning)
            IconButton(
              icon: const Icon(Icons.play_arrow, color: Colors.greenAccent),
              onPressed: _runningItemIds.isEmpty ? _runSuite : null,
              tooltip: 'Run All Tests',
            )
          else
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.cyanAccent,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_isRunning)
            LinearProgressIndicator(
              value: _progress,
              minHeight: 6,
              color: Colors.cyanAccent,
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: _buildProviderSummary(
                    'Google AI Suite',
                    googleAIResults,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildProviderSummary(
                    'Agent Platform Suite',
                    vertexAIResults,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _testCases.length,
              itemBuilder: (context, index) {
                final item = _testCases[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade800,
                      child: Text(
                        item.id,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      item.description,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'G: ',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            _buildStatusBadge(item.googleAIResult),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Text(
                              'AP: ',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            _buildStatusBadge(item.agentPlatformResult),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.play_circle_outline),
                          color: Colors.greenAccent,
                          tooltip: 'Run this test (both backends)',
                          visualDensity: VisualDensity.compact,
                          onPressed:
                              _isRunning || _runningItemIds.contains(item.id)
                                  ? null
                                  : () => _runSingle(item),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.play_arrow, size: 16),
                                  label: const Text('Run Google AI'),
                                  onPressed: _isRunning ||
                                          _runningItemIds.contains(item.id)
                                      ? null
                                      : () => _runSingle(
                                            item,
                                            agentPlatform: false,
                                          ),
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.play_arrow, size: 16),
                                  label: const Text('Run Agent Platform'),
                                  onPressed: _isRunning ||
                                          _runningItemIds.contains(item.id)
                                      ? null
                                      : () => _runSingle(
                                            item,
                                            googleAI: false,
                                          ),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildLogsConsole(
                                    'Google AI Details',
                                    item.googleAIResult,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildLogsConsole(
                                    'Agent Platform Details',
                                    item.agentPlatformResult,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
