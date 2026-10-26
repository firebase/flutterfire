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
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:waveform_flutter/waveform_flutter.dart';
import '../constants.dart';
import '../utils/audio_output.dart';
import '../widgets/audio_visualizer.dart';

/// TTS models the page can call.
enum _TtsModel {
  flash31(ExampleModels.flashTts31, 'Gemini 3.1 Flash TTS'),
  flash38(
    ExampleModels.flashTts38,
    'Gemini 3.8 Flash TTS',
    usesSpeechMetadata: true,
  ),
  flashLite38(
    ExampleModels.flashLiteTts38,
    'Gemini 3.8 Flash-Lite TTS',
    usesSpeechMetadata: true,
  );

  const _TtsModel(this.id, this.label, {this.usesSpeechMetadata = false});

  /// The model ID sent to the backend.
  final String id;

  /// The name shown in the model picker.
  final String label;

  /// Whether speakers and styles are sent as [SpeechMetadata] rather than in
  /// the prompt text.
  final bool usesSpeechMetadata;

  /// The default single-speaker prompt. Models that use [SpeechMetadata] take
  /// the style from the Style field, so their prompt has no style prefix.
  String get defaultSinglePrompt => usesSpeechMetadata
      ? 'Have a wonderful day!'
      : 'Say cheerfully: Have a wonderful day!';
}

class TTSPage extends StatefulWidget {
  const TTSPage({
    super.key,
    required this.title,
    required this.useAgentPlatform,
  });

  final String title;
  final bool useAgentPlatform;

  @override
  State<TTSPage> createState() => _TTSPageState();
}

class _TTSPageState extends State<TTSPage> {
  final AudioOutput _audioOutput = AudioOutput();
  final MockAmplitudeGenerator _mockAmpGen = MockAmplitudeGenerator();

  bool _isMultiSpeaker = false;
  _TtsModel _selectedModel = _TtsModel.flash31;
  bool _loading = false;
  bool _isPlaying = false;
  String? _responseText;

  // Single Speaker Controllers
  late final TextEditingController _singlePromptController =
      TextEditingController(text: _selectedModel.defaultSinglePrompt);
  final TextEditingController _singleStyleController =
      TextEditingController(text: 'cheerful');
  String _selectedVoice = 'Kore';

  // Multi Speaker Controllers
  final TextEditingController _speaker1NameController =
      TextEditingController(text: 'Joe');
  final TextEditingController _speaker1LineController = TextEditingController(
    text: "How's it going today Jane?",
  );
  final TextEditingController _speaker1StyleController =
      TextEditingController(text: 'curious');
  String _speaker1Voice = 'Kore';
  final TextEditingController _speaker2NameController =
      TextEditingController(text: 'Jane');
  final TextEditingController _speaker2LineController = TextEditingController(
    text: 'Not too bad, how about you?',
  );
  final TextEditingController _speaker2StyleController =
      TextEditingController(text: 'cheerful');
  String _speaker2Voice = 'Puck';

  final List<String> _availableVoices = [
    'Kore',
    'Puck',
    'Fenrir',
    'Aoede',
    'Charon',
    'Leda',
  ];

  Stream<Amplitude>? _amplitudeStream;
  Timer? _playbackTimer;

  @override
  void initState() {
    super.initState();
    _audioOutput.init();
  }

  @override
  void dispose() {
    _audioOutput.dispose();
    _mockAmpGen.stop();
    _playbackTimer?.cancel();
    _singlePromptController.dispose();
    _singleStyleController.dispose();
    _speaker1NameController.dispose();
    _speaker1LineController.dispose();
    _speaker1StyleController.dispose();
    _speaker2NameController.dispose();
    _speaker2LineController.dispose();
    _speaker2StyleController.dispose();
    super.dispose();
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

  ({GenerativeModel model, Content prompt}) _setupModelAndPrompt() {
    final GenerationConfig config;
    final Content prompt;

    if (_isMultiSpeaker) {
      prompt = _selectedModel.usesSpeechMetadata
          ? _taggedMultiSpeakerPrompt()
          : Content.text(
              '${_speaker1NameController.text}: ${_speaker1LineController.text}\n'
              '${_speaker2NameController.text}: ${_speaker2LineController.text}',
            );
      config = GenerationConfig(
        responseModalities: [ResponseModalities.audio],
        speechConfig: SpeechConfig.multiSpeaker(
          multiSpeakerVoiceConfig: MultiSpeakerVoiceConfig(
            speakerVoiceConfigs: [
              SpeakerVoiceConfig(
                speaker: _speaker1NameController.text,
                voiceName: _speaker1Voice,
              ),
              SpeakerVoiceConfig(
                speaker: _speaker2NameController.text,
                voiceName: _speaker2Voice,
              ),
            ],
          ),
        ),
      );
    } else {
      prompt = _selectedModel.usesSpeechMetadata
          ? _taggedSingleSpeakerPrompt()
          : Content.text(_singlePromptController.text);
      config = GenerationConfig(
        responseModalities: [ResponseModalities.audio],
        speechConfig: SpeechConfig(
          voiceName: _selectedVoice,
          languageCode: 'en-US',
        ),
      );
    }

    // Use the TTS model selected in the picker
    final GenerativeModel model;
    if (widget.useAgentPlatform) {
      model = FirebaseAI.agentPlatform().generativeModel(
        model: _selectedModel.id,
        generationConfig: config,
      );
    } else {
      model = FirebaseAI.googleAI().generativeModel(
        model: _selectedModel.id,
        generationConfig: config,
      );
    }

    return (model: model, prompt: prompt);
  }

  /// Builds the multi-speaker prompt as one [TextPart] per line
  Content _taggedMultiSpeakerPrompt() => Content.multi([
        _speakerLine(
          speaker: _speaker1NameController.text,
          line: _speaker1LineController.text,
          style: _speaker1StyleController.text,
        ),
        _speakerLine(
          speaker: _speaker2NameController.text,
          line: _speaker2LineController.text,
          style: _speaker2StyleController.text,
        ),
      ]);

  TextPart _speakerLine({
    required String speaker,
    required String line,
    required String style,
  }) {
    final trimmedStyle = style.trim();
    return TextPart(
      line,
      speechMetadata: SpeechMetadata(
        speaker: speaker,
        style: trimmedStyle.isEmpty ? null : trimmedStyle,
      ),
    );
  }

  /// Builds the single-speaker prompt, sending the optional style as
  /// [SpeechMetadata] instead of as an instruction in the prompt text.
  Content _taggedSingleSpeakerPrompt() {
    final style = _singleStyleController.text.trim();
    return Content.multi([
      TextPart(
        _singlePromptController.text,
        speechMetadata: style.isEmpty ? null : SpeechMetadata(style: style),
      ),
    ]);
  }

  Future<void> _startPlayback({
    Duration duration = const Duration(minutes: 10),
  }) async {
    await _audioOutput.playStream();
    _showPlaying(duration);
  }

  void _showPlaying(Duration duration) {
    setState(() {
      _loading = false;
      _isPlaying = true;
      _amplitudeStream = _mockAmpGen.start(duration);
    });
  }

  void _schedulePlaybackCompletion(int totalBytes, [DateTime? startTime]) {
    _audioOutput.finishStream();

    // Calculate duration: 24000 Hz, 1 channel, 16-bit (2 bytes) = 48000 bytes/sec
    final durationMs = (totalBytes / 48.0).round();
    final duration = Duration(milliseconds: durationMs);
    final elapsed = startTime != null
        ? DateTime.now().difference(startTime)
        : Duration.zero;
    _endPlaybackAfter(duration - elapsed);
  }

  void _endPlaybackAfter(Duration remaining) {
    if (remaining > Duration.zero) {
      _playbackTimer?.cancel();
      _playbackTimer = Timer(remaining, () {
        setState(() {
          _isPlaying = false;
          _amplitudeStream = null;
        });
      });
    } else {
      setState(() {
        _isPlaying = false;
        _amplitudeStream = null;
      });
    }
  }

  Future<void> _generateAndPlay() async {
    setState(() {
      _loading = true;
      _responseText = null;
    });

    try {
      final (:model, :prompt) = _setupModelAndPrompt();
      final response = await model.generateContent([prompt]);

      // Extract text response
      _responseText = response.text;

      // Find the audio part
      InlineDataPart? audioPart;
      for (final candidate in response.candidates) {
        for (final part in candidate.content.parts) {
          if (part is InlineDataPart && part.mimeType.startsWith('audio/')) {
            audioPart = part;
            break;
          }
        }
        if (audioPart != null) break;
      }

      if (audioPart == null || audioPart.bytes.isEmpty) {
        throw Exception('No audio received from the model.');
      }

      // Play audio and start visualizer. AudioOutput picks how to play it from
      // the MIME type: raw PCM, or a complete file such as `audio/wav`.
      final duration =
          await _audioOutput.playClip(audioPart.bytes, audioPart.mimeType);
      if (duration == null) {
        throw Exception('Audio output is not initialized.');
      }
      _showPlaying(duration);
      _endPlaybackAfter(duration);
    } catch (e) {
      setState(() {
        _loading = false;
      });
      _showError(e.toString());
    }
  }

  void _stopPlayback() {
    _audioOutput.stop();
    _mockAmpGen.stop();
    _playbackTimer?.cancel();
    setState(() {
      _isPlaying = false;
      _amplitudeStream = null;
    });
  }

  Future<void> _generateStreamAndPlay() async {
    setState(() {
      _loading = true;
      _responseText = null;
    });

    try {
      final (:model, :prompt) = _setupModelAndPrompt();
      final responseStream = model.generateContentStream([prompt]);

      final textBuffer = StringBuffer();
      int totalAudioBytes = 0;
      bool streamStarted = false;
      DateTime? startTime;

      await for (final response in responseStream) {
        if (streamStarted && !_isPlaying) {
          break;
        }

        if (response.text != null) {
          textBuffer.write(response.text);
        }

        for (final candidate in response.candidates) {
          for (final part in candidate.content.parts) {
            if (part is InlineDataPart && part.mimeType.startsWith('audio/')) {
              if (!streamStarted) {
                await _startPlayback();
                streamStarted = true;
                startTime = DateTime.now();
              }
              _audioOutput.addDataToAudioStream(part.bytes);
              totalAudioBytes += part.bytes.length;
            }
          }
        }

        if (textBuffer.isNotEmpty) {
          setState(() {
            _responseText = textBuffer.toString();
          });
        }
      }

      if (streamStarted && !_isPlaying) {
        return;
      }

      if (!streamStarted || totalAudioBytes == 0) {
        throw Exception('No audio received from the model.');
      }

      _schedulePlaybackCompletion(totalAudioBytes, startTime);
    } catch (e) {
      setState(() {
        _loading = false;
      });
      _showError(e.toString());
    }
  }

  Widget _buildSingleSpeakerForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _singlePromptController,
          decoration: const InputDecoration(
            labelText: 'Prompt',
            hintText: 'Enter text to generate speech from',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        if (_selectedModel.usesSpeechMetadata) ...[
          TextField(
            controller: _singleStyleController,
            decoration: const InputDecoration(
              labelText: 'Style (optional)',
              hintText: 'How the prompt is delivered, e.g. cheerful',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
        ],
        DropdownButtonFormField<String>(
          initialValue: _selectedVoice,
          decoration: const InputDecoration(
            labelText: 'Voice Name',
            border: OutlineInputBorder(),
          ),
          items: _availableVoices.map((voice) {
            return DropdownMenuItem(
              value: voice,
              child: Text(voice),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedVoice = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildSpeakerCard({
    required String title,
    required TextEditingController nameController,
    required String selectedVoice,
    required ValueChanged<String?> onVoiceChanged,
    required TextEditingController lineController,
    required TextEditingController styleController,
    required Color accentColor,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: accentColor.withAlpha(80),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: accentColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: accentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Speaker Name',
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedVoice,
                    decoration: const InputDecoration(
                      labelText: 'Voice Name',
                      prefixIcon: Icon(Icons.settings_voice_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: _availableVoices.map((voice) {
                      return DropdownMenuItem(
                        value: voice,
                        child: Text(voice),
                      );
                    }).toList(),
                    onChanged: onVoiceChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lineController,
              decoration: const InputDecoration(
                labelText: 'Speech Line',
                prefixIcon: Icon(Icons.chat_bubble_outline),
                hintText: 'Enter what this speaker will say',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            if (_selectedModel.usesSpeechMetadata) ...[
              const SizedBox(height: 12),
              TextField(
                controller: styleController,
                decoration: const InputDecoration(
                  labelText: 'Style (optional)',
                  prefixIcon: Icon(Icons.emoji_emotions_outlined),
                  hintText: 'How this line is delivered, e.g. excitedly',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMultiSpeakerForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSpeakerCard(
          title: 'Speaker 1',
          nameController: _speaker1NameController,
          selectedVoice: _speaker1Voice,
          onVoiceChanged: (value) {
            if (value != null) {
              setState(() {
                _speaker1Voice = value;
              });
            }
          },
          lineController: _speaker1LineController,
          styleController: _speaker1StyleController,
          accentColor: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 8),
        _buildSpeakerCard(
          title: 'Speaker 2',
          nameController: _speaker2NameController,
          selectedVoice: _speaker2Voice,
          onVoiceChanged: (value) {
            if (value != null) {
              setState(() {
                _speaker2Voice = value;
              });
            }
          },
          lineController: _speaker2LineController,
          styleController: _speaker2StyleController,
          accentColor: Theme.of(context).colorScheme.secondary,
        ),
      ],
    );
  }

  /// Selects [model], switching the single-speaker prompt to its default
  /// unless the user has edited the prompt.
  void _selectModel(_TtsModel model) {
    final promptIsDefault =
        _singlePromptController.text == _selectedModel.defaultSinglePrompt;
    setState(() {
      _selectedModel = model;
      if (promptIsDefault) {
        _singlePromptController.text = model.defaultSinglePrompt;
      }
    });
  }

  Widget _buildModelPicker() {
    return DropdownButtonFormField<_TtsModel>(
      initialValue: _selectedModel,
      decoration: InputDecoration(
        labelText: 'Model',
        prefixIcon: const Icon(Icons.memory),
        border: const OutlineInputBorder(),
        helperText: _selectedModel.usesSpeechMetadata
            ? 'Speakers and styles are sent as SpeechMetadata'
            : 'Speakers and styles are written into the prompt text',
      ),
      items: [
        for (final model in _TtsModel.values)
          DropdownMenuItem(value: model, child: Text(model.label)),
      ],
      onChanged: (value) {
        if (value != null) _selectModel(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Single Speaker')),
              ButtonSegment(value: true, label: Text('Multi Speaker')),
            ],
            selected: {_isMultiSpeaker},
            onSelectionChanged: (value) {
              setState(() {
                _isMultiSpeaker = value.first;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildModelPicker(),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: _isMultiSpeaker
                  ? _buildMultiSpeakerForm()
                  : _buildSingleSpeakerForm(),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Row(
              children: [
                if (_loading)
                  const CircularProgressIndicator()
                else if (_isPlaying)
                  IconButton(
                    icon: const Icon(Icons.stop),
                    iconSize: 36,
                    color: Theme.of(context).colorScheme.primary,
                    tooltip: 'Stop Playback',
                    onPressed: _stopPlayback,
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        iconSize: 36,
                        color: Theme.of(context).colorScheme.primary,
                        tooltip: 'Generate and Play',
                        onPressed: _generateAndPlay,
                      ),
                      IconButton(
                        icon: const Icon(Icons.stream),
                        iconSize: 36,
                        color: Theme.of(context).colorScheme.primary,
                        tooltip: 'Generate Stream and Play',
                        onPressed: _generateStreamAndPlay,
                      ),
                    ],
                  ),
                const SizedBox(width: 16),
                AudioVisualizer(
                  audioStreamIsActive: _isPlaying,
                  amplitudeStream: _amplitudeStream,
                ),
                if (!_isPlaying && !_loading && _responseText != null)
                  Expanded(
                    child: Text(
                      _responseText!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MockAmplitudeGenerator {
  StreamController<Amplitude>? _controller;
  Timer? _timer;
  final Random _random = Random();

  Stream<Amplitude> start(Duration duration) {
    stop();
    _controller = StreamController<Amplitude>.broadcast();

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      double current = -60.0 + _random.nextDouble() * 60.0;
      _controller?.add(Amplitude(current: current, max: 0));
    });

    return _controller!.stream;
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _controller?.close();
    _controller = null;
  }
}
