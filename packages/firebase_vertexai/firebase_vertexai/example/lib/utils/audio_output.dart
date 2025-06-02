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

import 'package:flutter_soloud/flutter_soloud.dart';

class AudioOutput {
  AudioSource? stream;
  SoundHandle? handle;

  Future<void> init() async {
    // Initialize the player.
    await SoLoud.instance.init(sampleRate: 24000, channels: Channels.mono);
    await setupNewStream();
  }

  Future<void> setupNewStream() async {
    if (SoLoud.instance.isInitialized) {
      // Stop and clear any previous playback handle if it's still valid
      await stopStream(); // Ensure previous sound is stopped

      stream = SoLoud.instance.setBufferStream(
        maxBufferSizeBytes:
            1024 * 1024 * 10, // 10MB of max buffer (not allocated)
        bufferingType: BufferingType.released,
        bufferingTimeNeeds: 0,
        onBuffering: (isBuffering, handle, time) {},
      );
      // Reset handle to null until the stream is played again
      handle = null;
    }
  }

  Future<AudioSource?> playStream() async {
    handle = await SoLoud.instance.play(stream!);
    return stream;
  }

  Future<void> stopStream() async {
    if (stream != null &&
        handle != null &&
        SoLoud.instance.getIsValidVoiceHandle(handle!)) {
      SoLoud.instance.setDataIsEnded(stream!);
      await SoLoud.instance.stop(handle!);

      // Clear old stream, set up new session for next time.
      await setupNewStream();
    }
  }

  void addAudioStream(Uint8List audioChunk) {
    SoLoud.instance.addAudioDataStream(stream!, audioChunk);
  }
}
