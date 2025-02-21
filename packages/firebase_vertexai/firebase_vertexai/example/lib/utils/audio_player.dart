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

class AudioUtil {
  static final Uint8List wavHeaderBase = Uint8List.fromList([
    // "RIFF" (Size will be updated later)
    82, 73, 70, 70, 0, 0, 0, 0,
    // WAVE
    87, 65, 86, 69,
    // fmt
    102, 109, 116, 32,
    // fmt chunk size 16
    16, 0, 0, 0,
    // Type of format
    1, 0,
    // One channel (Adjust if needed)
    1, 0,
    // Sample rate (Will be updated)
    0, 0, 0, 0,
    // Byte rate (Will be updated)
    0, 0, 0, 0,
    // Block align
    2, 0, // For 16-bit mono
    // bitsize
    16, 0,
    // "data" (Size will be updated later)
    100, 97, 116, 97, 0, 0, 0, 0,
  ]);

  static Future<Uint8List> audioChunkWithHeader(
    List<int> data,
    int sampleRate,
  ) async {
    // var channels = 1;
    // int byteRate = ((16 * sampleRate * channels) / 8).round();
    // var size = data.length;
    // var fileSize = size + 36;

    // // 1. *Copy* the header base:
    // final header = Uint8List.fromList(
    //   wavHeaderBase,
    // ); // Create a *new* Uint8List by copying

    // // 2. Update the *copy* (using byteData view for efficient manipulation)
    // final byteData = ByteData.view(header.buffer);

    // // RIFF size
    // byteData.setUint32(4, fileSize, Endian.little);
    // // Sample rate
    // byteData.setUint32(20, sampleRate, Endian.little);
    // // Byte rate
    // byteData.setUint32(24, byteRate, Endian.little);
    // // Data size
    // byteData.setUint32(40, size, Endian.little);

    // // 3. Append the data *after* the header
    // final combined = Uint8List(36 + size);
    // combined.setAll(0, header);
    // combined.setRange(36, 36 + size, data);

    // return combined;
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
      ...data
    ]);
    return header;
  }
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
  final AudioPlayer _audioPlayer = AudioPlayer();
  final StreamController<Uint8List> _audioChunkController =
      StreamController<Uint8List>();
  var _chunkIndex = 0;
  ConcatenatingAudioSource _audioSource = ConcatenatingAudioSource(
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

    print('Add new Audio Chunk to player');

    // The crucial change: use add instead of insert
    await _audioSource.add(buffer);

    _chunkIndex++;
    print('play audio chunk $_chunkIndex');
  }

  void addAudio(Uint8List chunk) {
    _audioChunkController.add(chunk);
  }

  Future<void> stopAudioPlayer() async {
    print('Stopped and total audio chunks are $_chunkIndex');
    await _audioPlayer.stop();
  }

  Future<void> disposeAudioPlayer() async {
    print('Disposed and total audio chunks are $_chunkIndex');
    await _audioPlayer.dispose();
    await _audioChunkController.close();
  }
}
