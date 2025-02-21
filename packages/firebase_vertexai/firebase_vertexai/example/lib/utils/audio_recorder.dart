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

class Resampler {
  /// Resamples 16-bit integer PCM audio data from a source sample rate to a target sample rate using linear interpolation.
  ///
  /// [sourceRate]: The sample rate of the input audio data.
  /// [targetRate]: The desired sample rate of the output audio data.
  /// [input]: The input audio data as a Uint8List containing 16-bit PCM samples.
  ///
  /// Returns a new Uint8List containing 16-bit PCM samples resampled to the target rate.
  static Uint8List resampleLinear16(
      int sourceRate, int targetRate, Uint8List input) {
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

class PcmConverter {
  /// Converts PCM audio from 32-bit float (pcm_f32le) to 16-bit signed integer (pcm_s16le)
  ///
  /// Input should be a Float32List containing PCM samples in the range [-1.0, 1.0]
  /// Returns an Int16List containing the converted samples
  static Int16List convertF32ToS16(Float32List input) {
    // Create output buffer of the same length
    final output = Int16List(input.length);

    // Convert each sample
    // PCM f32 range is [-1.0, 1.0]
    // PCM s16 range is [-32768, 32767]
    for (var i = 0; i < input.length; i++) {
      // Clamp input to [-1.0, 1.0] range
      final sample = input[i].clamp(-1.0, 1.0);

      // Scale to s16 range and round to nearest integer
      // Multiply by 32767 instead of 32768 to avoid potential overflow
      output[i] = (sample * 0x7fff).round();
    }

    return output;
  }

  /// Converts PCM audio from 16-bit signed integer (pcm_s16le) to 32-bit float (pcm_f32le)
  ///
  /// Input should be an Int16List containing PCM samples
  /// Returns a Float32List containing the converted samples
  static Float32List convertS16ToF32(Int16List input) {
    // Create output buffer of the same length
    final output = Float32List(input.length);

    // Convert each sample
    // PCM s16 range is [-32768, 32767]
    // PCM f32 range is [-1.0, 1.0]
    for (var i = 0; i < input.length; i++) {
      // Scale to f32 range by dividing by 32768
      output[i] = input[i] / 0x7fff;
    }

    return output;
  }

  /// Utility method to convert raw bytes in pcm_f32le format to pcm_s16le
  ///
  /// Input should be a Uint8List containing PCM samples in f32le format
  /// Returns a Uint8List containing the converted samples in s16le format
  static Uint8List convertF32LEBytesToS16LE(Uint8List input) {
    // First convert bytes to f32 samples
    final f32Samples = Float32List.view(input.buffer);

    // Convert to s16
    final s16Samples = convertF32ToS16(f32Samples);

    // Return as bytes
    return Uint8List.view(s16Samples.buffer);
  }

  /// Utility method to convert raw bytes in pcm_s16le format to pcm_f32le
  ///
  /// Input should be a Uint8List containing PCM samples in s16le format
  /// Returns a Uint8List containing the converted samples in f32le format
  static Uint8List convertS16LEBytesToF32LE(Uint8List input) {
    // First convert bytes to s16 samples
    final s16Samples = Int16List.view(input.buffer);

    // Convert to f32
    final f32Samples = convertS16ToF32(s16Samples);

    // Return as bytes
    return Uint8List.view(f32Samples.buffer);
  }
}

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

  Future<void> startRecording({bool fromfile = false}) async {
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
    if (fromfile) {
      await _recorder.start(recordConfig, path: _lastAudioPath!);
    } else {
      final stream = await _recorder.startStream(recordConfig);
      _recordSubscription = stream.listen((data) {
        _audioChunks.add(data);
        //print('captured data $data');
      });
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

  Future<void> startRecordingStream(
    Future<void> Function(Uint8List) onAudioChunk,
  ) async {
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
    final stream = await _recorder.startStream(recordConfig);
    _recordSubscription = stream.listen((data) {
      // _audioChunks.add(data);
      Future.delayed(const Duration(milliseconds: 1));
      // var resamplerData = Resampler.resampleLinear16(44100, 16000, data);
      onAudioChunk(data);
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
    var resultBytes;
    if (fromFile) {
      resultBytes = await _getAudioBytesFromFile(_lastAudioPath!);
    } else {
      final builder = BytesBuilder();
      for (final chunk in _audioChunks) {
        builder.add(chunk);
      }
      resultBytes = builder.toBytes();
    }
    // return resultBytes;
    // convert
    //return PcmConverter.convertF32LEBytesToS16LE(resultBytes);

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
