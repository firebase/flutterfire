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

/// An exception thrown when microphone permission is denied or not granted.
class MicrophonePermissionDeniedException implements Exception {
  /// The optional message associated with the permission denial.
  final String? message;

  /// Creates a new [MicrophonePermissionDeniedException] with an optional [message].
  MicrophonePermissionDeniedException([this.message]);

  @override
  String toString() {
    if (message == null) {
      return 'MicrophonePermissionDeniedException';
    }
    return 'MicrophonePermissionDeniedException: $message';
  }
}

class Resampler {
  /// Resamples 16-bit integer PCM audio data from a source sample rate to a
  /// target sample rate using linear interpolation.
  ///
  /// [sourceRate]: The sample rate of the input audio data.
  /// [targetRate]: The desired sample rate of the output audio data.
  /// [input]: The input audio data as a Uint8List containing 16-bit PCM samples.
  ///
  /// Returns a new Uint8List containing 16-bit PCM samples resampled to the
  /// target rate.
  static Uint8List resampleLinear16(
    int sourceRate,
    int targetRate,
    Uint8List input,
  ) {
    if (sourceRate == targetRate) return input; // No resampling needed

    final outputLength = (input.length * targetRate / sourceRate).round();
    final output = Uint8List(outputLength);
    final inputData = Int16List.view(input.buffer);
    final outputData = Int16List.view(output.buffer);

    for (int i = 0; i < outputLength ~/ 2; i++) {
      final sourcePosition = i * sourceRate / targetRate;
      final index1 = sourcePosition.floor();
      final index2 = index1 + 1;
      final weight2 = sourcePosition - index1;
      final weight1 = 1.0 - weight2;

      // Ensure indices are within the valid range
      final sample1 = inputData[index1.clamp(0, inputData.length - 1)];
      final sample2 = inputData[index2.clamp(0, inputData.length - 1)];

      // Interpolate and convert back to 16-bit integer
      final interpolatedSample =
          (sample1 * weight1 + sample2 * weight2).toInt();

      outputData[i] = interpolatedSample;
    }

    return output;
  }
}

class InMemoryAudioRecorder {
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
    return path;
  }

  Future<void> checkPermission() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw MicrophonePermissionDeniedException('Not having mic permission');
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

  Future<void> startRecording({bool fromFile = false}) async {
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
    if (fromFile) {
      await _recorder.start(recordConfig, path: _lastAudioPath!);
    } else {
      final stream = await _recorder.startStream(recordConfig);
      _recordSubscription = stream.listen(_audioChunks.add);
    }
  }

  Future<void> startRecordingFile() async {
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
    await _recorder.start(recordConfig, path: _lastAudioPath!);
  }

  Stream<Uint8List> startRecordingStream() async* {
    if (!await _isEncoderSupported(_encoder)) {
      return;
    }
    var recordConfig = RecordConfig(
      encoder: _encoder,
      sampleRate: 16000,
      numChannels: 1,
    );
    final devices = await _recorder.listInputDevices();
    debugPrint(devices.toString());
    final stream = await _recorder.startStream(recordConfig);

    await for (final data in stream) {
      yield data;
    }
  }

  Future<void> stopRecording() async {
    await _recordSubscription?.cancel();
    _recordSubscription = null;

    await _recorder.stop();
  }

  Future<Uint8List> fetchAudioBytes({
    bool fromFile = false,
    bool removeHeader = false,
  }) async {
    Uint8List resultBytes;
    if (fromFile) {
      resultBytes = await _getAudioBytesFromFile(_lastAudioPath!);
    } else {
      final builder = BytesBuilder();
      _audioChunks.forEach(builder.add);
      resultBytes = builder.toBytes();
    }

    // resample
    resultBytes = Resampler.resampleLinear16(44100, 16000, resultBytes);
    final dir = await getDownloadsDirectory();
    final path = '${dir!.path}/audio_resampled.pcm';
    final file = File(path);
    final sink = file.openWrite();

    sink.add(resultBytes);

    await sink.close();
    return resultBytes;
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

    if (!file.existsSync()) {
      throw Exception('Audio file not found: ${file.path}');
    }

    var pcmBytes = await file.readAsBytes();
    if (removeHeader) {
      pcmBytes = await _removeWavHeader(pcmBytes);
    }
    return pcmBytes;
  }
}
