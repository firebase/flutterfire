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

import 'dart:typed_data';
import 'dart:async';

import 'package:just_audio/just_audio.dart';

/// Creates a WAV audio chunk with a properly formatted header.
Future<Uint8List> audioChunkWithHeader(
  List<int> data,
  int sampleRate,
) async {
  var channels = 1;

  int byteRate = ((16 * sampleRate * channels) / 8).round();

  var size = data.length;
  var fileSize = size + 36;

  Uint8List header = Uint8List.fromList([
    // "RIFF"
    82, 73, 70, 70,
    fileSize & 0xff,
    (fileSize >> 8) & 0xff,
    (fileSize >> 16) & 0xff,
    (fileSize >> 24) & 0xff,
    // WAVE
    87, 65, 86, 69,
    // fmt
    102, 109, 116, 32,
    // fmt chunk size 16
    16, 0, 0, 0,
    // Type of format
    1, 0,
    // One channel
    channels, 0,
    // Sample rate
    sampleRate & 0xff,
    (sampleRate >> 8) & 0xff,
    (sampleRate >> 16) & 0xff,
    (sampleRate >> 24) & 0xff,
    // Byte rate
    byteRate & 0xff,
    (byteRate >> 8) & 0xff,
    (byteRate >> 16) & 0xff,
    (byteRate >> 24) & 0xff,
    // Uhm
    ((16 * channels) / 8).round(), 0,
    // bitsize
    16, 0,
    // "data"
    100, 97, 116, 97,
    size & 0xff,
    (size >> 8) & 0xff,
    (size >> 16) & 0xff,
    (size >> 24) & 0xff,
    // incoming data
    ...data,
  ]);
  return header;
}

class ByteStreamAudioSource extends StreamAudioSource {
  ByteStreamAudioSource(this.bytes) : super(tag: 'Byte Stream Audio');

  final Uint8List bytes;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/wav', // Or the appropriate content type
    );
  }
}

class AudioStreamManager {
  final _audioPlayer = AudioPlayer();
  final _audioChunkController = StreamController<Uint8List>();
  var _audioSource = ConcatenatingAudioSource(
    children: [],
  );

  AudioStreamManager() {
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    // 1. Create a ConcatenatingAudioSource to handle the stream
    await _audioPlayer.setAudioSource(_audioSource);

    // 2. Listen to the stream of audio chunks
    _audioChunkController.stream.listen(_addAudioChunk);

    await _audioPlayer.play(); // Start playing (even if initially empty)

    _audioPlayer.processingStateStream.listen((state) async {
      if (state == ProcessingState.completed) {
        await _audioPlayer
            .pause(); // Or player.stop() if you want to release resources
        await _audioPlayer.seek(Duration.zero, index: 0);
        await _audioSource.clear();
        await _audioPlayer.play();
      }
    });
  }

  Future<void> _addAudioChunk(Uint8List chunk) async {
    var buffer = ByteStreamAudioSource(chunk);

    await _audioSource.add(buffer);
  }

  void addAudio(Uint8List chunk) {
    _audioChunkController.add(chunk);
  }

  Future<void> stopAudioPlayer() async {
    await _audioPlayer.stop();
  }

  Future<void> disposeAudioPlayer() async {
    await _audioPlayer.dispose();
    await _audioChunkController.close();
  }
}
