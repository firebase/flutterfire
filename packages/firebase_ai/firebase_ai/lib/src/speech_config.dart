// Copyright 2026 Google LLC
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

import 'package:meta/meta.dart';

/// Speech configuration class for controlling the model's speech and audio generation behaviors.
class SpeechConfig {
  /// Constructs a [SpeechConfig] for a single-speaker setup.
  SpeechConfig({this.voiceName, this.languageCode})
      : multiSpeakerVoiceConfig = null;

  /// Constructs a [SpeechConfig] for a multi-speaker setup.
  SpeechConfig.multiSpeaker(
      {required this.multiSpeakerVoiceConfig, this.languageCode})
      : voiceName = null;

  /// The voice name to use for a single-speaker setup.
  final String? voiceName;

  /// The multi-speaker configuration.
  final MultiSpeakerVoiceConfig? multiSpeakerVoiceConfig;

  /// The optional IETF BCP-47 language code.
  final String? languageCode;

  /// Convert to json format.
  @internal
  Map<String, Object?> toJson() => {
        if (voiceName != null)
          'voice_config': VoiceConfig(
            prebuiltVoiceConfig: PrebuiltVoiceConfig(voiceName: voiceName),
          ).toJson(),
        if (multiSpeakerVoiceConfig case final multiSpeakerVoiceConfig?)
          'multi_speaker_voice_config': multiSpeakerVoiceConfig.toJson(),
        if (languageCode case final languageCode?)
          'language_code': languageCode,
      };
}

/// Configuration for a multi-speaker audio generation setup.
class MultiSpeakerVoiceConfig {
  /// Constructor
  MultiSpeakerVoiceConfig({required this.speakerVoiceConfigs});

  /// A list of voice configurations for the participating speakers.
  final List<SpeakerVoiceConfig> speakerVoiceConfigs;

  /// Convert to json format.
  Map<String, Object?> toJson() => {
        'speaker_voice_configs':
            speakerVoiceConfigs.map((e) => e.toJson()).toList(),
      };
}

/// Configures a participating speaker within a multi-speaker setup.
class SpeakerVoiceConfig {
  /// Constructor
  SpeakerVoiceConfig({required this.speaker, required this.voiceName});

  /// The unique name/identifier of the speaker.
  final String speaker;

  /// The specific voice assigned to this speaker.
  final String voiceName;

  /// Convert to json format.
  Map<String, Object?> toJson() => {
        'speaker': speaker,
        'voice_config': VoiceConfig(
          prebuiltVoiceConfig: PrebuiltVoiceConfig(voiceName: voiceName),
        ).toJson(),
      };
}

/// Configuration for a prebuilt voice.
class PrebuiltVoiceConfig {
  /// Constructor
  const PrebuiltVoiceConfig({this.voiceName});

  /// The voice name to use for speech synthesis.
  final String? voiceName;

  /// Convert to json format.
  Map<String, Object?> toJson() =>
      {if (voiceName case final voiceName?) 'voice_name': voiceName};
}

/// Configuration for the voice to be used in speech synthesis.
class VoiceConfig {
  /// Constructor
  VoiceConfig({this.prebuiltVoiceConfig});

  /// The prebuilt voice configuration.
  final PrebuiltVoiceConfig? prebuiltVoiceConfig;

  /// Convert to json format.
  Map<String, Object?> toJson() => {
        if (prebuiltVoiceConfig case final prebuiltVoiceConfig?)
          'prebuilt_voice_config': prebuiltVoiceConfig.toJson()
      };
}
