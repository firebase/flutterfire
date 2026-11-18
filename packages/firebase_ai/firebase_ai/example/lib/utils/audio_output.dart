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

import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter_soloud/flutter_soloud.dart';

class AudioOutput {
  bool initialized = false;
  AudioSource? stream;
  SoundHandle? streamHandle;
  SoundHandle? fileHandle;
  final int sampleRate = 24000;
  final Channels channels = Channels.mono;
  final BufferType format = BufferType.s16le; // pcm16bits

  Future<void> init() async {
    if (initialized) {
      return;
    }

    /// Initialize the player (singleton).
    await SoLoud.instance.init(sampleRate: sampleRate, channels: channels);
    initialized = true;
  }

  Future<void> dispose() async {
    if (initialized) {
      await SoLoud.instance.disposeAllSources();
      SoLoud.instance.deinit();
      initialized = false;
    }
  }

  SoLoud get instance => SoLoud.instance;

  AudioSource? setupNewStream() {
    if (!SoLoud.instance.isInitialized) {
      return null;
    }

    stream = SoLoud.instance.setBufferStream(
      bufferingType: BufferingType.released,
      bufferingTimeNeeds: 0,
      sampleRate: sampleRate,
      channels: channels,
      format: format,
      onBuffering: (isBuffering, handle, time) {
        log('Buffering: $isBuffering, Time: $time');
      },
    );
    log('New audio output stream buffer created.');
    return stream;
  }

  Future<AudioSource?> playStream() async {
    var myStream = setupNewStream();
    if (!SoLoud.instance.isInitialized || myStream == null) {
      return null;
    }
    // Play audio stream
    streamHandle = SoLoud.instance.play(myStream);
    return stream = myStream;
  }

  void addDataToAudioStream(Uint8List audioChunk) {
    var currentStream = stream;
    if (currentStream != null) {
      SoLoud.instance.addAudioDataStream(currentStream, audioChunk);
    }
  }

  Future<void> stopStream() async {
    var currentStream = stream;
    var currentHandle = streamHandle;

    // Stream doesn't exist or handle is not valid - so nothing to stop.
    if (currentStream == null ||
        currentHandle == null ||
        !SoLoud.instance.getIsValidVoiceHandle(currentHandle)) {
      return;
    }
    // End data to stream & stop currently playing sound from handle
    SoLoud.instance.setDataIsEnded(currentStream);
    await SoLoud.instance.stop(currentHandle);
  }

  void finishStream() {
    var currentStream = stream;
    if (currentStream != null) {
      SoLoud.instance.setDataIsEnded(currentStream);
    }
  }

  /// Whether [mimeType] is raw PCM, such as `audio/l16; rate=24000`, which the
  /// buffer stream can play directly.
  static bool isRawPcm(String mimeType) {
    final type = mimeType.toLowerCase();
    return type.startsWith('audio/l16') || type.startsWith('audio/pcm');
  }

  /// Plays one complete clip and returns how long it lasts.
  ///
  /// Raw PCM goes through the buffer stream, like streamed audio. Anything else
  /// (such as the `audio/wav` some TTS models return from `generateContent`)
  /// is a complete file with headers, so SoLoud decodes it rather than the
  /// buffer stream playing those headers as noise.
  Future<Duration?> playClip(Uint8List bytes, String mimeType) async {
    if (!isRawPcm(mimeType)) return _playFile(bytes);
    if (await playStream() == null) return null;
    addDataToAudioStream(bytes);
    finishStream();
    // 16-bit mono PCM is 2 bytes per sample.
    final bytesPerSecond = sampleRate * 2;
    return Duration(microseconds: bytes.length * 1000000 ~/ bytesPerSecond);
  }

  Future<Duration?> _playFile(Uint8List bytes) async {
    if (!SoLoud.instance.isInitialized) return null;
    // The path only labels the clip; a unique one avoids clashing with a clip
    // that's still loaded. autoDispose frees it once it finishes or is stopped.
    final source = await SoLoud.instance.loadMem(
      'clip-${DateTime.now().microsecondsSinceEpoch}',
      bytes,
      autoDispose: true,
    );
    fileHandle = SoLoud.instance.play(source);
    return SoLoud.instance.getLength(source);
  }

  /// Stops the buffer stream and any clip started by [playClip].
  Future<void> stop() async {
    await stopStream();
    final currentFileHandle = fileHandle;
    if (currentFileHandle != null &&
        SoLoud.instance.getIsValidVoiceHandle(currentFileHandle)) {
      await SoLoud.instance.stop(currentFileHandle);
    }
  }
}
