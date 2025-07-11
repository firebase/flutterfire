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
import 'dart:developer';

import 'package:meta/meta.dart';

/// Specifies the level of safety filtering for image generation.
///
/// If not specified, default will be "block_medium_and_above".
@experimental
enum ImagenSafetyFilterLevel {
  /// Strongest filtering level, most strict blocking.
  blockLowAndAbove('block_low_and_above'),

  /// Block some problematic prompts and responses.
  blockMediumAndAbove('block_medium_and_above'),

  /// Reduces the number of requests blocked due to safety filters.
  /// May increase objectionable content generated by Imagen.
  blockOnlyHigh('block_only_high'),

  /// Block very few problematic prompts and responses.
  /// Access to this feature is restricted.
  blockNone('block_none');

  const ImagenSafetyFilterLevel(this._jsonString);

  final String _jsonString;

  // ignore: public_member_api_docs
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

/// Allow generation of people by the model.
///
/// If not specified, the default value is "allow_adult".
@experimental
enum ImagenPersonFilterLevel {
  /// Disallow the inclusion of people or faces in images.
  blockAll('dont_allow'),

  /// Allow generation of adults only.
  allowAdult('allow_adult'),

  /// Allow generation of people of all ages.
  allowAll('allow_all');

  const ImagenPersonFilterLevel(this._jsonString);

  final String _jsonString;

  // ignore: public_member_api_docs
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

/// A class representing safety settings for image generation.
///
/// It includes a safety filter level and a person filter level.
@experimental
final class ImagenSafetySettings {
  // ignore: public_member_api_docs
  ImagenSafetySettings(this.safetyFilterLevel, this.personFilterLevel);

  /// The safety filter level
  final ImagenSafetyFilterLevel? safetyFilterLevel;

  /// The person filter level
  final ImagenPersonFilterLevel? personFilterLevel;

  // ignore: public_member_api_docs
  Object toJson() => {
        if (safetyFilterLevel != null)
          'safetySetting': safetyFilterLevel!.toJson(),
        if (personFilterLevel != null)
          'personGeneration': personFilterLevel!.toJson(),
      };
}

/// The aspect ratio for the image.
///
/// The default value is "1:1".
@experimental
enum ImagenAspectRatio {
  /// Square (1:1).
  square1x1('1:1'),

  /// Portrait (9:16).
  portrait9x16('9:16'),

  /// Landscape (16:9).
  landscape16x9('16:9'),

  /// Portrait (3:4).
  portrait3x4('3:4'),

  /// Landscape (4:3).
  landscape4x3('4:3');

  const ImagenAspectRatio(this._jsonString);

  final String _jsonString;

  // ignore: public_member_api_docs
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

/// Configuration options for image generation.
@experimental
final class ImagenGenerationConfig {
  // ignore: public_member_api_docs
  ImagenGenerationConfig(
      {this.numberOfImages,
      this.negativePrompt,
      this.aspectRatio,
      this.imageFormat,
      this.addWatermark});

  /// The number of images to generate.
  ///
  /// Default value is 1.
  final int? numberOfImages;

  /// A description of what to discourage in the generated images.
  final String? negativePrompt;

  /// The aspect ratio for the image. The default value is "1:1".
  final ImagenAspectRatio? aspectRatio;

  /// The image format of the generated images.
  final ImagenFormat? imageFormat;

  /// Whether to add an invisible watermark to generated images.
  ///
  /// Default value for each imagen model can be found in
  /// https://cloud.google.com/vertex-ai/generative-ai/docs/model-reference/imagen-api#generate_images
  final bool? addWatermark;

  // ignore: public_member_api_docs
  Map<String, dynamic> toJson() => {
        if (negativePrompt != null) 'negativePrompt': negativePrompt,
        if (numberOfImages != null) 'numberOfImages': numberOfImages,
        if (aspectRatio != null) 'aspectRatio': aspectRatio!.toJson(),
        if (addWatermark != null) 'addWatermark': addWatermark,
        if (imageFormat != null) 'outputOptions': imageFormat!.toJson(),
      };
}

/// Represents the image format and compression quality.
@experimental
final class ImagenFormat {
  // ignore: public_member_api_docs
  ImagenFormat(this.mimeType, this.compressionQuality);

  // ignore: public_member_api_docs
  ImagenFormat.png() : this('image/png', null);

  // ignore: public_member_api_docs
  ImagenFormat.jpeg({this.compressionQuality}) : mimeType = 'image/jpeg' {
    if (compressionQuality != null &&
        (compressionQuality! < 0 || compressionQuality! > 100)) {
      log('ImagenFormat (jpeg): compressionQuality ($compressionQuality) is out of range [0, 100].');
    }
  }

  /// The MIME type of the image format. The default value is "image/png".
  final String mimeType;

  /// The level of compression if the output type is "image/jpeg".
  /// Accepted values are 0 through 100. The default value is 75.
  final int? compressionQuality;

  // ignore: public_member_api_docs
  Map<String, dynamic> toJson() => {
        'mimeType': mimeType,
        if (compressionQuality != null)
          'compressionQuality': compressionQuality,
      };
}
