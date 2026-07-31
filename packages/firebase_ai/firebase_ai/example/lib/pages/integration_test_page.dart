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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_ai/firebase_ai.dart';

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
  final Future<TestResult> Function(FirebaseAI provider, TestLogger logger) run;
  TestResult googleAIResult;
  TestResult agentPlatformResult;

  TestItem({
    required this.id,
    required this.name,
    required this.description,
    required this.run,
  })  : googleAIResult = TestResult.pending(),
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

  @override
  void initState() {
    super.initState();
    _initializeTestCases();
  }

  void _initializeTestCases() {
    _testCases = [
      TestItem(
        id: '1',
        name: 'Stateless Text Gen (gemini-3.1-flash-lite)',
        description:
            'Verifies simple stateless text generation with a precise answer target using gemini-3.1-flash-lite.',
        run: (provider, logger) async {
          logger.log('Initializing model gemini-3.1-flash-lite...');
          final model =
              provider.generativeModel(model: 'gemini-3.1-flash-lite');
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
        name: 'Stateless Text Gen (gemini-3.5-flash)',
        description:
            'Verifies simple stateless text generation with a precise answer target using gemini-3.5-flash.',
        run: (provider, logger) async {
          logger.log('Initializing model gemini-3.5-flash...');
          final model = provider.generativeModel(model: 'gemini-3.5-flash');
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
        id: '3',
        name: 'System Instructions',
        description:
            'Verifies system instructions config is serialized and respected.',
        run: (provider, logger) async {
          logger.log('Initializing model with medieval system instruction...');
          final model = provider.generativeModel(
            model: 'gemini-3.1-flash-lite',
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
        description:
            'Verifies stateful conversation preservation across turns via ChatSession.',
        run: (provider, logger) async {
          logger.log('Initializing model and starting ChatSession...');
          final model =
              provider.generativeModel(model: 'gemini-3.1-flash-lite');
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
        description:
            'Verifies automatic function/tool call execution via AutoFunctionDeclaration.',
        run: (provider, logger) async {
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

          final model = provider.generativeModel(
            model: 'gemini-3.1-flash-lite',
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
        description:
            'Verifies manual function call prediction and response handling.',
        run: (provider, logger) async {
          logger.log('Declaring FunctionDeclaration...');
          final powerTool = FunctionDeclaration(
            'getSuperHeroPower',
            'Returns the superpower of a given superhero by name.',
            parameters: {
              'heroName':
                  Schema.string(description: 'The name of the superhero.'),
            },
          );

          final model = provider.generativeModel(
            model: 'gemini-3.1-flash-lite',
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
        description:
            'Verifies Tool.codeExecution() internal code execution and parts extraction.',
        run: (provider, logger) async {
          logger.log(
            'Initializing model gemini-3.5-flash with Tool.codeExecution()...',
          );
          final model = provider.generativeModel(
            model: 'gemini-3.5-flash',
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
        name: 'Search Grounding (gemini-3.5-flash)',
        description:
            'Verifies Google Search Grounding tool configuration and grounding metadata.',
        run: (provider, logger) async {
          logger.log(
            'Initializing model gemini-3.5-flash with Tool.googleSearch()...',
          );
          final model = provider.generativeModel(
            model: 'gemini-3.5-flash',
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
        description:
            'Verifies generateContentStream works and aggregates chunks correctly.',
        run: (provider, logger) async {
          logger.log('Initializing model for streaming...');
          final model =
              provider.generativeModel(model: 'gemini-3.1-flash-lite');

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
        description:
            'Verifies counting tokens on multimodal inputs (text + image asset).',
        run: (provider, logger) async {
          logger.log('Loading cat.jpg asset...');
          final catBytes = await rootBundle.load('assets/images/cat.jpg');

          logger.log('Initializing model for token counting...');
          final model =
              provider.generativeModel(model: 'gemini-3.1-flash-lite');

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
        description:
            'Verifies extraction of thought logs and usage metadata with ThinkingConfig.',
        run: (provider, logger) async {
          logger.log(
            'Initializing model gemini-3.5-flash with ThinkingConfig...',
          );
          final model = provider.generativeModel(
            model: 'gemini-3.5-flash',
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
        description:
            'Verifies text + image response output generation via gemini-2.5-flash-image model.',
        run: (provider, logger) async {
          logger.log(
            'Initializing gemini-2.5-flash-image with dual response modalities...',
          );
          final model = provider.generativeModel(
            model: 'gemini-2.5-flash-image',
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
    ];
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

  Future<void> _runSuite() async {
    if (_isRunning) return;

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
              onPressed: _runSuite,
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
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
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
