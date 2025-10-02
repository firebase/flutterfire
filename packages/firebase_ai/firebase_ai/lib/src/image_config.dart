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

/// The aspect ratio for the image.
///
/// The default value is "1:1".
enum AspectRatio {
  /// 1:1 aspect ratio.
  ratio1x1('1:1'),

  /// 2:3 aspect ratio.
  ratio2x3('2:3'),

  /// 3:2 aspect ratio.
  ratio3x2('3:2'),

  /// 3:4 aspect ratio.
  ratio3x4('3:4'),

  /// 4:3 aspect ratio.
  ratio4x3('4:3'),

  /// 4:5 aspect ratio.
  ratio4x5('4:5'),

  /// 5:4 aspect ratio.
  ratio5x4('5:4'),

  /// 9:16 aspect ratio.
  ratio9x16('9:16'),

  /// 16:9 aspect ratio.
  ratio16x9('16:9'),

  /// 21:9 aspect ratio.
  ratio21x9('21:9');

  const AspectRatio(this._jsonString);

  final String _jsonString;

  /// Convert to json format.
  String toJson() => _jsonString;

  /// Parse the json to [AspectRatio] object.
  static AspectRatio parseValue(Object jsonObject) {
    return switch (jsonObject) {
      '1:1' => AspectRatio.ratio1x1,
      '2:3' => AspectRatio.ratio2x3,
      '3:2' => AspectRatio.ratio3x2,
      '3:4' => AspectRatio.ratio3x4,
      '4:3' => AspectRatio.ratio4x3,
      '4:5' => AspectRatio.ratio4x5,
      '5:4' => AspectRatio.ratio5x4,
      '9:16' => AspectRatio.ratio9x16,
      '16:9' => AspectRatio.ratio16x9,
      '21:9' => AspectRatio.ratio21x9,
      _ => throw FormatException('Unhandled AspectRatio format', jsonObject),
    };
  }

  @override
  String toString() => name;
}

/// Configuration options for image generation.
final class ImageConfig {
  // ignore: public_member_api_docs
  ImageConfig({this.aspectRatio});

  /// The aspect ratio for the image. The default value is "1:1".
  final AspectRatio? aspectRatio;

  // ignore: public_member_api_docs
  Map<String, dynamic> toJson() => {
        if (aspectRatio != null) 'aspectRatio': aspectRatio!.toJson(),
      };
}
