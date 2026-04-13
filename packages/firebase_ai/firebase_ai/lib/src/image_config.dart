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

/// Configuration options for generating images with Gemini models.
final class ImageConfig {
  /// Initializes configuration options for generating images with Gemini.
  const ImageConfig({this.aspectRatio, this.imageSize});

  /// The aspect ratio of generated images.
  final ImageAspectRatio? aspectRatio;

  /// The size of the generated images.
  final ImageSize? imageSize;

  /// Convert to json format.
  Map<String, Object?> toJson() => {
        if (aspectRatio case final aspectRatio?)
          'aspectRatio': aspectRatio.toJson(),
        if (imageSize case final imageSize?) 'imageSize': imageSize.toJson(),
      };
}

/// An aspect ratio for generated images.
enum ImageAspectRatio {
  /// Square (1:1) aspect ratio.
  square1x1('1:1'),

  /// Portrait widescreen (9:16) aspect ratio.
  portrait9x16('9:16'),

  /// Widescreen (16:9) aspect ratio.
  landscape16x9('16:9'),

  /// Portrait full screen (3:4) aspect ratio.
  portrait3x4('3:4'),

  /// Fullscreen (4:3) aspect ratio.
  landscape4x3('4:3'),

  /// Portrait (2:3) aspect ratio.
  portrait2x3('2:3'),

  /// Landscape (3:2) aspect ratio.
  landscape3x2('3:2'),

  /// Portrait (4:5) aspect ratio.
  portrait4x5('4:5'),

  /// Landscape (5:4) aspect ratio.
  landscape5x4('5:4'),

  /// Portrait (1:4) aspect ratio.
  portrait1x4('1:4'),

  /// Landscape (4:1) aspect ratio.
  landscape4x1('4:1'),

  /// Portrait (1:8) aspect ratio.
  portrait1x8('1:8'),

  /// Landscape (8:1) aspect ratio.
  landscape8x1('8:1'),

  /// Ultrawide (21:9) aspect ratio.
  ultrawide21x9('21:9');

  const ImageAspectRatio(this._jsonString);
  final String _jsonString;

  /// Convert to json format.
  String toJson() => _jsonString;
}

/// The size of images to generate.
enum ImageSize {
  /// 512px (0.5K) image size.
  size512('512'),

  /// 1K image size.
  size1K('1K'),

  /// 2K image size.
  size2K('2K'),

  /// 4K image size.
  size4K('4K');

  const ImageSize(this._jsonString);
  final String _jsonString;

  /// Convert to json format.
  String toJson() => _jsonString;
}
