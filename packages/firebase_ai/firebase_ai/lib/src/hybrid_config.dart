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

import 'package:flutter_gemma/flutter_gemma.dart' as gemma;

/// Routing and fallback policies for the Hybrid Generative Model.
enum HybridPreference {
  /// Use the local on-device model if it is installed and ready.
  /// Fallback to the cloud model if the local model is not downloaded or fails to load.
  preferLocal,

  /// Use the cloud model by default.
  /// Fallback to the local on-device model if the cloud call fails (e.g., network offline or quota exceeded).
  preferCloud,

  /// Only use the local on-device model.
  /// Throws a [StateError] or exception if the model is not downloaded/ready.
  /// Never attempts to contact the cloud.
  onlyLocal,

  /// Only use the cloud model.
  /// Throws an exception if the cloud call fails.
  /// Never attempts to load or use local resources.
  onlyCloud,
}

/// Configuration options specifically for the local on-device model powered by flutter_gemma.
class LocalModelConfig {

  /// Creates a new [LocalModelConfig] for on-device model execution.
  LocalModelConfig({
    required this.modelType,
    this.fileType = gemma.ModelFileType.task,
    this.modelPath,
    this.modelUrl,
    this.hfToken,
    this.preferredBackend,
    this.maxTokens = 1024,
    this.supportImage = false,
    this.supportAudio = false,
  });
  /// The type of model (e.g., gemmaIt, gemma4, deepSeek, qwen, etc.).
  final gemma.ModelType modelType;

  /// The file type of the model (task or binary). Defaults to task.
  final gemma.ModelFileType fileType;

  /// The local path to the model file on the device (if already downloaded or bundled).
  final String? modelPath;

  /// The remote HTTP/HTTPS URL to download the model from if not installed.
  final String? modelUrl;

  /// Optional HuggingFace authentication token for gated model downloads (e.g., Gemma 3).
  final String? hfToken;

  /// Backend preference (CPU or GPU). GPU is highly recommended if available.
  final gemma.PreferredBackend? preferredBackend;

  /// The maximum context length for the model (default: 1024).
  final int maxTokens;

  /// Whether the model supports multimodal image inputs (default: false).
  final bool supportImage;

  /// Whether the model supports audio inputs (default: false, Gemma 3n E4B only).
  final bool supportAudio;
}

/// Configuration wrapper for Hybrid Mode, containing local configurations and initial routing preference.
class HybridConfig {

  /// Creates a new [HybridConfig] with [localConfig] and [initialPreference].
  HybridConfig({
    required this.localConfig,
    this.initialPreference = HybridPreference.preferCloud,
  });
  /// Configuration for the on-device local model.
  final LocalModelConfig localConfig;

  /// Initial routing preference policy. Defaults to [HybridPreference.preferCloud].
  final HybridPreference initialPreference;
}
