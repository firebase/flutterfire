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
import 'package:waveform_flutter/waveform_flutter.dart';
import 'sound_waves.dart';

class AudioVisualizer extends StatelessWidget {
  const AudioVisualizer({
    super.key,
    required this.audioStreamIsActive,
    this.amplitudeStream,
  });

  final bool audioStreamIsActive;
  final Stream<Amplitude>? amplitudeStream;

  @override
  Widget build(BuildContext context) {
    return (audioStreamIsActive && amplitudeStream != null)
        ? Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Soundwaves(amplitudeStream: amplitudeStream!),
            ),
          )
        : const Spacer();
  }
}
