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
import 'package:record/record.dart';
import 'dart:typed_data';

class AudioInput extends ChangeNotifier {
  final _recorder = AudioRecorder();
  final AudioEncoder _encoder = AudioEncoder.pcm16bits;
  bool isRecording = false;
  bool isPaused = false;
  Stream<Uint8List>? audioStream;

  Future<void> init() async {
    await _checkPermission();
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw MicrophonePermissionDeniedException(
        'App does not have mic permissions',
      );
    }
  }

  Future<Stream<Uint8List>?> startRecordingStream() async {
    var recordConfig = RecordConfig(
      encoder: _encoder,
      sampleRate: 24000,
      numChannels: 1,
      echoCancel: true,
      noiseSuppress: true,
      androidConfig: const AndroidRecordConfig(
        audioSource: AndroidAudioSource.voiceCommunication,
      ),
      iosConfig: const IosRecordConfig(categoryOptions: []),
    );
    await _recorder.listInputDevices();
    audioStream = await _recorder.startStream(recordConfig);
    isRecording = true;
    notifyListeners();
    return audioStream;
  }

  Future<void> stopRecording() async {
    await _recorder.stop();
    isRecording = false;
    notifyListeners();
  }

  Future<void> togglePause() async {
    if (isPaused) {
      await _recorder.resume();
      isPaused = false;
    } else {
      await _recorder.pause();
      isPaused = true;
    }
    notifyListeners();
    return;
  }
}

/// An exception thrown when microphone permission is denied or not granted.
class MicrophonePermissionDeniedException implements Exception {
  /// The optional message associated with the permission denial.
  final String? message;

  /// Creates a new [MicrophonePermissionDeniedException] with an optional [message].
  MicrophonePermissionDeniedException([this.message]);

  @override
  String toString() {
    return 'MicrophonePermissionDeniedException: $message';
  }
}
