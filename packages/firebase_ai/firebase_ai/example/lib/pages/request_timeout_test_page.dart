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
import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants.dart';

/// Manual verification page for configurable request timeouts
/// (https://github.com/firebase/flutterfire/pull/18846).
///
/// For every call type (unary, streaming, Live, server template) it runs:
///  * no [RequestOptions] (SDK default of 180s)    -> expected to succeed
///  * a generous explicit [RequestOptions] timeout -> expected to succeed
///  * a tiny [RequestOptions] timeout              -> expected to throw a
///    [TimeoutException] quickly
class RequestTimeoutTestPage extends StatefulWidget {
  const RequestTimeoutTestPage({super.key});

  @override
  State<RequestTimeoutTestPage> createState() => _RequestTimeoutTestPageState();
}

/// Default server template id/inputs. Both are editable on the page because
/// they must match a template that exists in your Firebase project.
const String _kDefaultTemplateId = 'new-greeting';
const String _kDefaultTemplateInputs = '{"name": "Firebase"}';

/// A timeout no real network round trip can satisfy.
const Duration _kTinyTimeout = Duration(milliseconds: 10);

/// A timeout comfortably larger than any expected response time.
const Duration _kGenerousTimeout = Duration(seconds: 60);

/// Upper bound for how long a "should time out" scenario may take before we
/// consider the SDK timeout as not being honoured.
const Duration _kMaxTimeoutLatency = Duration(seconds: 5);

/// Test-level guard so a hung Live session doesn't block the suite forever.
/// This is intentionally independent of the SDK timeout under test.
const Duration _kLiveTurnGuard = Duration(seconds: 45);

enum _CallType { generate, stream, live, template, templateStream }

enum _Expectation { succeed, timeout }

enum _Status { pending, running, passed, failed }

class _Result {
  _Result(this.status, {this.logs = '', this.elapsed, this.failure});

  final _Status status;
  final String logs;
  final Duration? elapsed;

  /// Human-readable reason the case failed (null unless [status] is failed).
  final String? failure;
}

class _Scenario {
  _Scenario({
    required this.callType,
    required this.optionsLabel,
    required this.requestOptions,
    required this.expectation,
  });

  final _CallType callType;
  final String optionsLabel;
  final RequestOptions? requestOptions;
  final _Expectation expectation;

  _Result googleAI = _Result(_Status.pending);
  _Result agentPlatform = _Result(_Status.pending);

  String get title {
    final call = switch (callType) {
      _CallType.generate => 'generateContent',
      _CallType.stream => 'generateContentStream',
      _CallType.live => 'Live connect + turn',
      _CallType.template => 'Template generateContent',
      _CallType.templateStream => 'Template generateContentStream',
    };
    return '$call · $optionsLabel';
  }

  String get expectationLabel => expectation == _Expectation.succeed
      ? 'expect: success'
      : 'expect: TimeoutException < ${_kMaxTimeoutLatency.inSeconds}s';
}

class _Logger {
  final _buffer = StringBuffer();
  final _stopwatch = Stopwatch()..start();

  void log(String message) {
    _buffer.writeln('[+${_stopwatch.elapsedMilliseconds}ms] $message');
  }

  @override
  String toString() => _buffer.toString();
}

class _RequestTimeoutTestPageState extends State<RequestTimeoutTestPage> {
  late final List<_Scenario> _scenarios = [
    for (final callType in _CallType.values) ...[
      _Scenario(
        callType: callType,
        optionsLabel: 'default (no RequestOptions)',
        requestOptions: null,
        expectation: _Expectation.succeed,
      ),
      _Scenario(
        callType: callType,
        optionsLabel: 'timeout ${_kGenerousTimeout.inSeconds}s',
        requestOptions: const RequestOptions(timeout: _kGenerousTimeout),
        expectation: _Expectation.succeed,
      ),
      _Scenario(
        callType: callType,
        optionsLabel: 'timeout ${_kTinyTimeout.inMilliseconds}ms',
        requestOptions: const RequestOptions(timeout: _kTinyTimeout),
        expectation: _Expectation.timeout,
      ),
    ],
  ];

  bool _isRunning = false;

  final _templateIdController =
      TextEditingController(text: _kDefaultTemplateId);
  final _templateInputsController =
      TextEditingController(text: _kDefaultTemplateInputs);

  @override
  void dispose() {
    _templateIdController.dispose();
    _templateInputsController.dispose();
    super.dispose();
  }

  FirebaseAI _provider(bool agentPlatform) => agentPlatform
      ? FirebaseAI.agentPlatform(
          useLimitedUseAppCheckTokens: kUseLimitedUseAppCheckTokens,
        )
      : FirebaseAI.googleAI(
          useLimitedUseAppCheckTokens: kUseLimitedUseAppCheckTokens,
        );

  /// Executes the call under test. Returns a short description of what was
  /// received on success; throws on any failure (including timeouts).
  Future<String> _execute(
    _Scenario scenario,
    bool agentPlatform,
    _Logger logger,
  ) async {
    final provider = _provider(agentPlatform);
    final options = scenario.requestOptions;

    switch (scenario.callType) {
      case _CallType.generate:
        final model = provider.generativeModel(
          model: ExampleModels.flashLite,
          requestOptions: options,
        );
        logger.log('generateContent -> ${ExampleModels.flashLite}');
        final response = await model.generateContent(
          [Content.text('Reply with exactly the word SUCCESS.')],
        );
        return 'text="${response.text?.trim()}"';

      case _CallType.stream:
        final model = provider.generativeModel(
          model: ExampleModels.flashLite,
          requestOptions: options,
        );
        logger.log('generateContentStream -> ${ExampleModels.flashLite}');
        return _drainStream(
          model.generateContentStream(
            [Content.text('Count from 1 to 20, one number per line.')],
          ),
          logger,
        );

      case _CallType.live:
        // Mirrors the config used by BidiPage (minus tools) so failures here
        // are attributable to the timeout plumbing rather than setup config.
        final liveProvider = agentPlatform
            ? FirebaseAI.agentPlatform(
                location: ExampleModels.liveAgentPlatformLocation,
                useLimitedUseAppCheckTokens: kUseLimitedUseAppCheckTokens,
              )
            : provider;
        final model = liveProvider.liveGenerativeModel(
          model: agentPlatform
              ? ExampleModels.liveAgentPlatform
              : ExampleModels.liveGoogleAI,
          liveGenerationConfig: LiveGenerationConfig(
            speechConfig: SpeechConfig(voiceName: 'Fenrir'),
            responseModalities: [ResponseModalities.audio],
            inputAudioTranscription: AudioTranscriptionConfig(),
            outputAudioTranscription: AudioTranscriptionConfig(),
          ),
          requestOptions: options,
        );
        logger.log('LiveGenerativeModel.connect()');
        final session = await model.connect(
          sessionResumption: SessionResumptionConfig(),
        );
        logger.log('WebSocket ready, setup sent');
        try {
          return await _runLiveTurn(session, logger).timeout(
            _kLiveTurnGuard,
            onTimeout: () => throw StateError(
              'No non-empty turnComplete within ${_kLiveTurnGuard.inSeconds}s '
              '(test guard, not SDK timeout)',
            ),
          );
        } finally {
          await session.close();
          logger.log('Session closed');
        }

      case _CallType.template:
        final (templateId, inputs) = _templateArgs();
        // ignore: experimental_member_use
        final model = provider.templateGenerativeModel(requestOptions: options);
        logger.log('template generateContent("$templateId", inputs: $inputs)');
        final response =
            // ignore: experimental_member_use
            await model.generateContent(templateId, inputs: inputs);
        return 'text="${response.text?.trim()}"';

      case _CallType.templateStream:
        final (templateId, inputs) = _templateArgs();
        // ignore: experimental_member_use
        final model = provider.templateGenerativeModel(requestOptions: options);
        logger.log(
          'template generateContentStream("$templateId", inputs: $inputs)',
        );
        return _drainStream(
          // ignore: experimental_member_use
          model.generateContentStream(templateId, inputs: inputs),
          logger,
        );
    }
  }

  /// Reads the template id / JSON inputs from the text fields.
  (String, Map<String, Object?>) _templateArgs() {
    final id = _templateIdController.text.trim();
    final raw = _templateInputsController.text.trim();
    final decoded = raw.isEmpty ? <String, Object?>{} : jsonDecode(raw);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Template inputs must be a JSON object');
    }
    return (id, decoded);
  }

  Future<String> _drainStream(
    Stream<GenerateContentResponse> stream,
    _Logger logger,
  ) async {
    var chunks = 0;
    final text = StringBuffer();
    await for (final chunk in stream) {
      chunks++;
      final t = chunk.text ?? '';
      logger.log('chunk #$chunks (${t.length} chars)');
      text.write(t);
    }
    if (chunks == 0 || text.isEmpty) {
      throw StateError('Stream completed without any text ($chunks chunks)');
    }
    return '$chunks chunks, ${text.length} chars';
  }

  /// Runs a single Live turn.
  ///
  /// `LiveSession` uses a broadcast controller, so we subscribe *before*
  /// sending anything and only send the prompt once the first server message
  /// (setupComplete) arrives. Sending before setup completes can produce an
  /// empty `turnComplete` on some backends. An empty `turnComplete` is logged
  /// and, once, retried via `send(turnComplete: true)` (clientContent) instead
  /// of `sendTextRealtime`.
  Future<String> _runLiveTurn(LiveSession session, _Logger logger) async {
    const prompt = 'Say hello in one short sentence.';
    final done = Completer<String>();
    final transcript = StringBuffer();
    var audioBytes = 0;
    var messageCount = 0;
    var sent = false;
    var retriedWithClientContent = false;

    Future<void> sendPrompt(String reason) async {
      if (sent) return;
      sent = true;
      logger.log('sendTextRealtime("$prompt") [$reason]');
      await session.sendTextRealtime(prompt);
    }

    final sub = session.receive().listen(
      (response) {
        final message = response.message;
        messageCount++;
        if (message is LiveServerContent) {
          final parts = message.modelTurn?.parts ?? const <Part>[];
          for (final part in parts) {
            if (part is InlineDataPart) audioBytes += part.bytes.length;
          }
          final t = message.outputTranscription?.text;
          if (t != null) transcript.write(t);
          final hasContent = audioBytes > 0 || transcript.isNotEmpty;
          if (message.turnComplete ?? false) {
            logger.log('msg #$messageCount turnComplete '
                '(audio=${audioBytes}B, transcript=${transcript.length} chars, '
                'interrupted=${message.interrupted})');
            if (hasContent) {
              if (!done.isCompleted) {
                done.complete('audio=${audioBytes}B, '
                    'transcript="${transcript.toString().trim()}"');
              }
            } else if (!retriedWithClientContent) {
              retriedWithClientContent = true;
              logger.log('Empty turnComplete; retrying with '
                  'send(input: Content.text, turnComplete: true)');
              unawaited(
                session.send(input: Content.text(prompt), turnComplete: true),
              );
            } else {
              logger.log('Empty turnComplete again; still waiting...');
            }
          } else if (messageCount <= 3) {
            logger.log('msg #$messageCount LiveServerContent '
                '(parts=${parts.map((p) => p.runtimeType).toList()}, '
                'transcript="${t ?? ''}")');
          }
        } else {
          logger.log('msg #$messageCount ${message.runtimeType}');
        }
        // The first server message is setupComplete; now it is safe to send.
        if (!sent) unawaited(sendPrompt('after ${message.runtimeType}'));
      },
      onError: (Object e, StackTrace s) {
        if (!done.isCompleted) done.completeError(e, s);
      },
      onDone: () {
        if (!done.isCompleted) {
          done.completeError(
            StateError(
              messageCount == 0
                  ? 'Server closed the Live WebSocket before setupComplete '
                      '(setup rejected: model/location/auth/config). Check the '
                      '[LiveSession] WebSocket closed log for code/reason.'
                  : 'Live stream closed after $messageCount messages '
                      'without a non-empty turnComplete',
            ),
          );
        }
      },
    );

    // Fallback in case setupComplete was emitted before we subscribed.
    final fallback = Timer(
      const Duration(seconds: 3),
      () => sendPrompt('fallback: no server message within 3s'),
    );
    try {
      return await done.future;
    } finally {
      fallback.cancel();
      await sub.cancel();
    }
  }

  Future<void> _run(_Scenario scenario, bool agentPlatform) async {
    void update(_Result r) {
      if (!mounted) return;
      setState(() {
        if (agentPlatform) {
          scenario.agentPlatform = r;
        } else {
          scenario.googleAI = r;
        }
      });
    }

    update(_Result(_Status.running));
    final logger = _Logger()
      ..log('${_backendName(agentPlatform)}: '
          '${scenario.title} (${scenario.expectationLabel})');
    final stopwatch = Stopwatch()..start();

    _Status status;
    String? failure;
    try {
      final summary = await _execute(scenario, agentPlatform, logger);
      stopwatch.stop();
      logger.log('Completed: $summary');
      if (scenario.expectation == _Expectation.succeed) {
        status = _Status.passed;
      } else {
        status = _Status.failed;
        failure = 'Expected TimeoutException but call succeeded after '
            '${stopwatch.elapsedMilliseconds}ms ($summary).';
      }
    } catch (e, s) {
      stopwatch.stop();
      logger.log('Threw ${e.runtimeType}: $e');
      if (scenario.expectation == _Expectation.timeout) {
        if (e is! TimeoutException) {
          status = _Status.failed;
          failure = 'Expected TimeoutException, got ${e.runtimeType}: $e';
          logger.log('$s');
        } else if (stopwatch.elapsed > _kMaxTimeoutLatency) {
          status = _Status.failed;
          failure = 'TimeoutException thrown but took '
              '${stopwatch.elapsedMilliseconds}ms (> '
              '${_kMaxTimeoutLatency.inSeconds}s); configured timeout not '
              'honoured.';
        } else {
          status = _Status.passed;
        }
      } else {
        status = _Status.failed;
        failure = 'Unexpected ${e.runtimeType}: $e';
        logger.log('$s');
      }
    }
    if (failure != null) logger.log('FAIL: $failure');
    logger.log('Elapsed: ${stopwatch.elapsedMilliseconds}ms -> ${status.name}');
    final result = _Result(
      status,
      logs: logger.toString(),
      elapsed: stopwatch.elapsed,
      failure: failure,
    );
    if (status == _Status.failed) {
      _printLines(_formatFailure(scenario, agentPlatform, result));
    }
    update(result);
  }

  String _backendName(bool agentPlatform) =>
      agentPlatform ? 'Agent Platform' : 'Google AI';

  String _formatFailure(_Scenario s, bool agentPlatform, _Result r) {
    return [
      '✗ [${_backendName(agentPlatform)}] ${s.title}',
      '  ${s.expectationLabel}',
      '  reason: ${r.failure}',
      '  logs:',
      for (final line in r.logs.trimRight().split('\n')) '    $line',
    ].join('\n');
  }

  /// `debugPrint` throttles and avoids truncation of long lines on Android.
  void _printLines(String text) {
    for (final line in text.split('\n')) {
      debugPrint('[RequestTimeoutTest] $line');
    }
  }

  /// Builds a report of every failed case, prints it to the console and
  /// copies it to the clipboard. Returns the number of failures.
  Future<int> _reportFailures() async {
    final failures = <String>[
      for (final s in _scenarios)
        for (final agentPlatform in [false, true])
          if ((agentPlatform ? s.agentPlatform : s.googleAI).status ==
              _Status.failed)
            _formatFailure(
              s,
              agentPlatform,
              agentPlatform ? s.agentPlatform : s.googleAI,
            ),
    ];
    final total = _scenarios.length * 2;
    final header = '===== Request timeout test failures: '
        '${failures.length} / $total =====';
    final report = [header, ...failures, '=' * header.length].join('\n\n');
    _printLines(report);
    await Clipboard.setData(ClipboardData(text: report));
    return failures.length;
  }

  Future<void> _printFailures() async {
    final count = await _reportFailures();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          count == 0
              ? 'No failures. Report printed to console.'
              : '$count failure(s) printed to console and copied to clipboard.',
        ),
      ),
    );
  }

  /// Scenarios currently being run individually (outside Run all).
  final Set<_Scenario> _runningScenarios = {};

  bool _canRun(_Scenario s) => !_isRunning && !_runningScenarios.contains(s);

  /// Runs one scenario on the selected backend(s) without the full suite.
  Future<void> _runScenario(
    _Scenario s, {
    bool googleAI = true,
    bool agentPlatform = true,
  }) async {
    if (!_canRun(s)) return;
    setState(() => _runningScenarios.add(s));
    try {
      if (googleAI) await _run(s, false);
      if (agentPlatform) await _run(s, true);
    } finally {
      if (mounted) setState(() => _runningScenarios.remove(s));
    }
  }

  Future<void> _runAll() async {
    if (_isRunning || _runningScenarios.isNotEmpty) return;
    setState(() {
      _isRunning = true;
      for (final s in _scenarios) {
        s.googleAI = _Result(_Status.pending);
        s.agentPlatform = _Result(_Status.pending);
      }
    });
    for (final s in _scenarios) {
      await _run(s, false);
      await _run(s, true);
    }
    setState(() => _isRunning = false);
    await _printFailures();
  }

  Widget _chip(String label, _Result r, VoidCallback onTap) {
    final (Color color, IconData icon) = switch (r.status) {
      _Status.pending => (Colors.grey, Icons.schedule),
      _Status.running => (Colors.blue, Icons.sync),
      _Status.passed => (Colors.green, Icons.check_circle),
      _Status.failed => (Colors.red, Icons.error),
    };
    final ms = r.elapsed == null ? '' : ' ${r.elapsed!.inMilliseconds}ms';
    return ActionChip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text('$label$ms', style: TextStyle(fontSize: 11, color: color)),
      onPressed: _isRunning ? null : onTap,
    );
  }

  void _showLogs(_Scenario s, bool agentPlatform) {
    final r = agentPlatform ? s.agentPlatform : s.googleAI;
    final isFailed = r.status == _Status.failed;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${_backendName(agentPlatform)}\n${s.title}',
          style: const TextStyle(fontSize: 14),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isFailed) ...[
                SelectableText(
                  'FAILURE: ${r.failure}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade300,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              SelectableText(
                r.logs.isEmpty ? 'No logs yet. Tap Run.' : r.logs,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              ),
            ],
          ),
        ),
        actions: [
          if (isFailed)
            TextButton(
              onPressed: () async {
                final text = _formatFailure(s, agentPlatform, r);
                _printLines(text);
                await Clipboard.setData(ClipboardData(text: text));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failure printed to console and copied.'),
                  ),
                );
              },
              child: const Text('Print & copy'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _runScenario(
                s,
                googleAI: !agentPlatform,
                agentPlatform: agentPlatform,
              );
            },
            child: const Text('Run'),
          ),
        ],
      ),
    );
  }

  Widget _failureLine(String backend, _Result r) {
    if (r.status != _Status.failed) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: SelectableText(
        '✗ $backend: ${r.failure}',
        maxLines: 3,
        style: TextStyle(fontSize: 11, color: Colors.red.shade300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = [
      for (final s in _scenarios) ...[s.googleAI, s.agentPlatform],
    ];
    final passed = results.where((r) => r.status == _Status.passed).length;
    final failed = results.where((r) => r.status == _Status.failed).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Timeout Tests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Print failures to console & copy',
            onPressed: _isRunning ? null : _printFailures,
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            tooltip: 'Run all',
            onPressed:
                _isRunning || _runningScenarios.isNotEmpty ? null : _runAll,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isRunning) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Passed $passed / ${results.length} · Failed $failed\n'
              'Tap a chip to view logs or re-run a single case. '
              'Failures are printed to the console with the '
              '[RequestTimeoutTest] prefix.',
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _templateIdController,
                    enabled: !_isRunning,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      labelText: 'Template id',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _templateInputsController,
                    enabled: !_isRunning,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      labelText: 'Template inputs (JSON)',
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _scenarios.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final s = _scenarios[i];
                return ListTile(
                  title: Text(s.title, style: const TextStyle(fontSize: 13)),
                  trailing: _runningScenarios.contains(s)
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : PopupMenuButton<String>(
                          enabled: _canRun(s),
                          tooltip: 'Run this test',
                          icon: const Icon(
                            Icons.play_circle_outline,
                            color: Colors.greenAccent,
                          ),
                          onSelected: (v) => _runScenario(
                            s,
                            googleAI: v != 'ap',
                            agentPlatform: v != 'google',
                          ),
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'both',
                              child: Text('Run both backends'),
                            ),
                            PopupMenuItem(
                              value: 'google',
                              child: Text('Run Google AI only'),
                            ),
                            PopupMenuItem(
                              value: 'ap',
                              child: Text('Run Agent Platform only'),
                            ),
                          ],
                        ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.expectationLabel,
                          style: const TextStyle(fontSize: 11),
                        ),
                        Wrap(
                          spacing: 8,
                          children: [
                            _chip(
                              'Google AI',
                              s.googleAI,
                              () => _showLogs(s, false),
                            ),
                            _chip(
                              'Agent Platform',
                              s.agentPlatform,
                              () => _showLogs(s, true),
                            ),
                          ],
                        ),
                        _failureLine('Google AI', s.googleAI),
                        _failureLine('Agent Platform', s.agentPlatform),
                      ],
                    ),
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
