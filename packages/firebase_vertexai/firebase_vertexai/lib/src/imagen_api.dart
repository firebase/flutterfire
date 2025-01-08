// Copyright 2024 Google LLC
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

///
enum ImagenSafetyFilterLevel {
  ///
  blockLowAndAbove('block_low_and_above'),

  ///
  blockMediumAndAbove('block_medium_and_above'),

  ///
  blockOnlyHigh('block_only_high'),

  ///
  blockNone('block_none');

  const ImagenSafetyFilterLevel(this._jsonString);

  final String _jsonString;

  /// Convert to json format
  String toJson() => _jsonString;

  // ignore: unused_element
  static ImagenSafetyFilterLevel _parseValue(Object jsonObject) {
    return switch (jsonObject) {
      'block_low_and_above' => ImagenSafetyFilterLevel.blockLowAndAbove,
      'block_medium_and_above' => ImagenSafetyFilterLevel.blockMediumAndAbove,
      'block_only_high' => ImagenSafetyFilterLevel.blockOnlyHigh,
      'block_none' => ImagenSafetyFilterLevel.blockNone,
      _ => throw FormatException(
          'Unhandled ImagenSafetyFilterLevel format', jsonObject),
    };
  }

  @override
  String toString() => name;
}

///
enum ImagenPersonFilterLevel {
  ///
  blockAll('dont_allow'),

  ///
  allowAdult('allow_adult'),

  ///
  allowAll('allow_all');

  const ImagenPersonFilterLevel(this._jsonString);

  final String _jsonString;

  /// Convert to json format
  String toJson() => _jsonString;

  // ignore: unused_element
  static ImagenPersonFilterLevel _parseValue(Object jsonObject) {
    return switch (jsonObject) {
      'dont_allow' => ImagenPersonFilterLevel.blockAll,
      'allow_adult' => ImagenPersonFilterLevel.allowAdult,
      'allow_all' => ImagenPersonFilterLevel.allowAll,
      _ => throw FormatException(
          'Unhandled ImagenPersonFilterLevel format', jsonObject),
    };
  }

  @override
  String toString() => name;
}

///
final class ImagenSafetySettings {
  /// Constructor
  ImagenSafetySettings(this.safetyFilterLevel, this.personFilterLevel);

  ///
  final ImagenSafetyFilterLevel? safetyFilterLevel;

  ///
  final ImagenPersonFilterLevel? personFilterLevel;

  /// Convert to json format.
  Object toJson() => {
        if (safetyFilterLevel != null)
          'safetySetting': safetyFilterLevel!.toJson(),
        if (personFilterLevel != null)
          'personGeneration': personFilterLevel!.toJson(),
      };
}

///
enum ImagenAspectRatio {
  ///
  square1x1('1:1'),

  ///
  portrait9x16('9:16'),

  ///
  landscape16x9('16:9'),

  ///
  portrait3x4('3:4'),

  ///
  landscape4x3('4:3');

  const ImagenAspectRatio(this._jsonString);

  final String _jsonString;

  /// Convert to json format
  String toJson() => _jsonString;

  // ignore: unused_element
  static ImagenAspectRatio _parseValue(Object jsonObject) {
    return switch (jsonObject) {
      '1:1' => ImagenAspectRatio.square1x1,
      '9:16' => ImagenAspectRatio.portrait9x16,
      '16:9' => ImagenAspectRatio.landscape16x9,
      '3:4' => ImagenAspectRatio.portrait3x4,
      '4:3' => ImagenAspectRatio.landscape4x3,
      _ =>
        throw FormatException('Unhandled ImagenAspectRatio format', jsonObject),
    };
  }

  @override
  String toString() => name;
}

final class ImagenGenerationConfig {
  ImagenGenerationConfig(
      this.negativePrompt, this.numberOfImages, this.aspectRatio);
  final String? negativePrompt;
  final int? numberOfImages;
  final ImagenAspectRatio? aspectRatio;
}

final class ImagenFormat {
  ImagenFormat(this.mimeType, this.compressionQuality);

  ImagenFormat.png() : this("image/png", null);
  ImagenFormat.jpeg({int? compressionQuality})
      : this("image/jpeg", compressionQuality);
  final String mimeType;
  final int? compressionQuality;
}

final class ImagenModelConfig {
  ImagenModelConfig(this.imagenFormat, this.addWatermark);
  final ImagenFormat imagenFormat;
  final bool? addWatermark;
}
