import 'package:flutter_soloud/flutter_soloud.dart';

class AudioOutput {
  AudioSource? stream; // Start playback
  SoundHandle? handle;

  Future<void> init() async {
    /// Initialize the player.
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
        sampleRate: 24000, // <<< MATCH SoLoud init and input
        channels: Channels.mono, // <<< MATCH input (likely mono)
        format: BufferType.s16le, // Should match pcm16bits
        onBuffering: (isBuffering, handle, time) {
          // When isBuffering==true, the stream is set to paused automatically till
          // it reaches bufferingTimeNeeds of audio data or until setDataIsEnded is called
          // or maxBufferSizeBytes is reached. When isBuffering==false, the playback stream
          // is resumed.
          print('Buffering: $isBuffering, Time: $time');
        },
      );
      print("New audio output stream buffer created.");
      // Reset handle to null until the stream is played again
      handle = null;
    }
  }

  Future<AudioSource?> playStream() async {
    print('playing');
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
      setupNewStream();
    }
  }
}
