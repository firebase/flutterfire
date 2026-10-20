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

/// Centralized model identifiers used across the example app.
abstract final class ExampleModels {
  /// Default fast multimodal model.
  static const String flashLite = 'gemini-3.5-flash-lite';

  /// Multimodal text and image generation model.
  static const String flashImage = 'gemini-3.1-flash-image';

  /// Text-to-speech audio model preview.
  static const String flashTTS = 'gemini-3.1-flash-tts-preview';

  /// Live bidirectional audio streaming model for Agent Platform.
  static const String liveAgentPlatform =
      'gemini-live-2.5-flash-preview-native-audio-09-2025';

  /// Live bidirectional audio streaming model for Google AI.
  static const String liveGoogleAI =
      'gemini-2.5-flash-native-audio-preview-09-2025';
}
