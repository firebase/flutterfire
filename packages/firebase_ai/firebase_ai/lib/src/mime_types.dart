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

/// MIME types supported by Gemini multimodal models.
///
/// Model capabilities can vary. Check the
/// [Firebase AI Logic documentation](https://firebase.google.com/docs/ai-logic)
/// before relying on a MIME type for a specific model.
abstract final class FirebaseAIMimeTypes {
  /// Supported image MIME types.
  static const List<String> image = <String>[
    'image/png',
    'image/jpeg',
    'image/webp',
  ];

  /// Supported video MIME types.
  static const List<String> video = <String>[
    'video/x-flv',
    'video/quicktime',
    'video/mpeg',
    'video/mpegps',
    'video/mpg',
    'video/mp4',
    'video/webm',
    'video/wmv',
    'video/3gpp',
  ];

  /// Supported audio MIME types.
  static const List<String> audio = <String>[
    'audio/aac',
    'audio/flac',
    'audio/mp3',
    'audio/m4a',
    'audio/mpeg',
    'audio/mpga',
    'audio/mp4',
    'audio/opus',
    'audio/pcm',
    'audio/wav',
    'audio/webm',
  ];

  /// Supported document MIME types.
  static const List<String> document = <String>[
    'application/pdf',
    'text/plain',
  ];

  /// All supported multimodal MIME types.
  static const List<String> all = <String>[
    ...image,
    ...video,
    ...audio,
    ...document,
  ];
}
