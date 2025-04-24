import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'dart:typed_data';

class AudioInput extends ChangeNotifier {
  final _recorder = AudioRecorder();
  final AudioEncoder _encoder = AudioEncoder.pcm16bits;
  bool isRecording = false;
  bool isPaused = false;
  Stream<Uint8List>? audioStream;

  init() {
    checkPermission();
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  Future<void> checkPermission() async {
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
      //sampleRate: 16000,
      //numChannels: 2,
    );
    final devices = await _recorder.listInputDevices();
    print(devices.toString());
    audioStream = await _recorder.startStream(recordConfig);
    isRecording = true;
    print("${isRecording ? "Is" : "Not"} Recording");
    notifyListeners();
    return audioStream;
    /*await for (final data in stream) {
      yield data;
    }*/
  }

  Future<void> stopRecording() async {
    await _recorder.stop();
    isRecording = false;
    print("${isRecording ? "Is" : "Not"} Recording");
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
    print("${isPaused ? "Is" : "Not"} Paused");
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
    if (message == null) {
      return 'MicrophonePermissionDeniedException';
    }
    return 'MicrophonePermissionDeniedException: $message';
  }
}
