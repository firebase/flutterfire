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

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class InMemoryAudioRecorder {
  // final _audioSession = AudioSession();
  // final _chunkStreamController = StreamController<Uint8List>.broadcast();
  // Stream<Uint8List> get onAudioChunk => _chunkStreamController.stream;
  final _audioChunks = <Uint8List>[];
  final _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _recordSubscription;
  late String? _lastAudioPath;
  AudioEncoder _encoder = AudioEncoder.pcm16bits;

  Future<String> _getPath() async {
    String suffix;
    if (_encoder == AudioEncoder.pcm16bits) {
      suffix = 'pcm';
    } else if (_encoder == AudioEncoder.aacLc) {
      suffix = 'm4a';
    } else {
      suffix = 'wav';
    }
    final dir = await getDownloadsDirectory();
    final path =
        '${dir!.path}/audio_${DateTime.now().millisecondsSinceEpoch}.$suffix';
    print('audio file saved to $path');
    return path;
  }

  Future<void> checkPermission() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      print('Not having mic permission');
    }
  }

  Future<bool> _isEncoderSupported(AudioEncoder encoder) async {
    final isSupported = await _recorder.isEncoderSupported(
      encoder,
    );

    if (!isSupported) {
      debugPrint('${encoder.name} is not supported on this platform.');
      debugPrint('Supported encoders are:');

      for (final e in AudioEncoder.values) {
        if (await _recorder.isEncoderSupported(e)) {
          debugPrint('- ${e.name}');
        }
      }
    }

    return isSupported;
  }

  Future<void> startRecording() async {
    if (!await _isEncoderSupported(_encoder)) {
      return;
    }
    var recordConfig = RecordConfig(
      encoder: _encoder,
      sampleRate: 16000,
      numChannels: 1,
    );
    final devs = await _recorder.listInputDevices();
    debugPrint(devs.toString());

    _lastAudioPath = await _getPath();

    //await _recorder.start(recordConfig, path: _lastAudioPath!);

    final stream = await _recorder.startStream(recordConfig);
    _recordSubscription = stream.listen((data) {
      _audioChunks.add(data);
      //print('captured data $data');
    });
  }

  Future<void> stopRecording() async {
    await _recordSubscription?.cancel();
    _recordSubscription = null;

    await _recorder.stop();
  }

  Future<Uint8List> getAudioBytes({
    bool fromFile = false,
    bool removeHeader = false,
  }) async {
    if (fromFile) {
      return _getAudioBytesFromFile(_lastAudioPath!);
    } else {
      final builder = BytesBuilder();
      for (final chunk in _audioChunks) {
        builder.add(chunk);
      }
      return builder.toBytes();
    }
  }

  Future<Uint8List> _removeWavHeader(Uint8List audio) async {
    // Assuming a standard WAV header size of 44 bytes
    const wavHeaderSize = 44;
    final audioData = audio.sublist(wavHeaderSize);
    return audioData;
  }

  Future<Uint8List> _getAudioBytesFromFile(
    String filePath, {
    bool removeHeader = false,
  }) async {
    final file = File(_lastAudioPath!);
    if (!await file.exists()) {
      throw Exception('Audio file not found: ${file.path}');
    }

    var pcmBytes = await file.readAsBytes();
    print('pcm file ${file.path} has byte size of ${pcmBytes.length}');
    if (removeHeader) {
      pcmBytes = await _removeWavHeader(pcmBytes);
    }
    return pcmBytes;
  }
}
