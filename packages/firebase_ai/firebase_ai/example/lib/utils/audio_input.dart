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

import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'dart:async';
import 'package:waveform_flutter/waveform_flutter.dart' as wf;

class AudioInput extends ChangeNotifier {
  final _recorder = AudioRecorder();

  final AudioEncoder _mobileEncoder = AudioEncoder.pcm16bits;

  bool isRecording = false;
  bool isPaused = false;
  Stream<Uint8List>? audioStream;

  Stream<wf.Amplitude>? amplitudeStream;
  StreamSubscription? _amplitudeSubscription;
  StreamController<wf.Amplitude>? _amplitudeStreamController;

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
    await _amplitudeSubscription?.cancel();
    if (_amplitudeStreamController != null &&
        !_amplitudeStreamController!.isClosed) {
      await _amplitudeStreamController!.close();
    }

    // 1. DEVICE SELECTION LOGIC
    // Fetch all devices to find the real microphone
    final devices = await _recorder.listInputDevices();
    InputDevice? selectedDevice;

    try {
      // Find the device that is NOT BlackHole and looks like a built-in mic.
      // Browsers often name it "Default - Internal Microphone" or "Built-in Audio".
      selectedDevice = devices.firstWhere(
        (device) {
          final label = device.label.toLowerCase();
          return !label.contains('blackhole') &&
              (label.contains('internal') ||
                  label.contains('built-in') ||
                  label.contains('macbook'));
        },
        // Fallback: Just find anything that isn't Blackhole
        orElse: () => devices.firstWhere(
          (d) => !d.label.toLowerCase().contains('blackhole'),
          orElse: () => devices.first, // Absolute fallback
        ),
      );
    } catch (e) {
      debugPrint('Error selecting device: $e');
    }

    var recordConfig = RecordConfig(
      encoder: _mobileEncoder,
      sampleRate: 24000,
      device: selectedDevice,
      numChannels: 1,
      echoCancel: true,
      noiseSuppress: true,
      androidConfig: const AndroidRecordConfig(
        audioSource: AndroidAudioSource.voiceCommunication,
      ),
      iosConfig: const IosRecordConfig(categoryOptions: []),
    );

    audioStream = await _recorder.startStream(recordConfig);

    _amplitudeStreamController = StreamController<wf.Amplitude>.broadcast();
    _amplitudeSubscription = _recorder!
        .onAmplitudeChanged(const Duration(milliseconds: 100))
        .listen((amp) {
      _amplitudeStreamController?.add(
        wf.Amplitude(current: amp.current, max: amp.max),
      );
    });
    amplitudeStream = _amplitudeStreamController?.stream;
    isRecording = true;
    notifyListeners();
    return audioStream;
  }

  Future<void> stopRecording() async {
    await _recorder.stop();
    await _amplitudeSubscription?.cancel();
    await _amplitudeStreamController?.close();
    amplitudeStream = null;
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
