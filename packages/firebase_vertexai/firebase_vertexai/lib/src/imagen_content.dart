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
import 'dart:convert';
import 'dart:typed_data';
import 'error.dart';

///
sealed class ImagenImage {
  final String mimeType;

  /// Convert the [ImagenImage] content to json format.
  Object toJson();

  ImagenImage({required this.mimeType});
}

final class ImagenInlineImage implements ImagenImage {
  /// Data contents in bytes.
  final Uint8List bytesBase64Encoded;

  @override
  final String mimeType;

  ImagenInlineImage({
    required this.bytesBase64Encoded,
    required this.mimeType,
  });

  @override
  Object toJson() => {
        'mimeType': mimeType,
        'bytesBase64Encoded': bytesBase64Encoded,
      };
}

final class ImagenGCSImage implements ImagenImage {
  @override
  final String mimeType;

  final String gcsUri;

  ImagenGCSImage({
    required this.gcsUri,
    required this.mimeType,
  });

  @override
  Object toJson() => {
        'mimeType': mimeType,
        'gcsUri': gcsUri,
      };
}

final class ImagenGenerationResponse<T extends ImagenImage> {
  ImagenGenerationResponse({
    required this.images,
    this.filteredReason,
  });

  final List<T> images;
  final String? filteredReason;

  factory ImagenGenerationResponse.fromJson(Map<String, dynamic> json) {
    final filteredReason = json['filteredReason'] as String?;
    final imagesJson = json['images'] as List<dynamic>;

    if (T == ImagenInlineImage) {
      final images = imagesJson.map((imageJson) {
        final mimeType = imageJson['mimeType'] as String;
        final bytes = imageJson['bytesBase64Encoded'] as String;
        final decodedBytes = base64Decode(bytes);
        return ImagenInlineImage(
          mimeType: mimeType,
          bytesBase64Encoded: Uint8List.fromList(decodedBytes),
        ) as T;
      }).toList();
      return ImagenGenerationResponse<T>(
          images: images, filteredReason: filteredReason);
    } else if (T == ImagenGCSImage) {
      final images = imagesJson.map((imageJson) {
        final mimeType = imageJson['mimeType'] as String;
        final gcsUri = imageJson['gcsUri'] as String;
        return ImagenGCSImage(
          mimeType: mimeType,
          gcsUri: gcsUri,
        ) as T;
      }).toList();
      return ImagenGenerationResponse<T>(
          images: images, filteredReason: filteredReason);
    } else {
      throw ArgumentError('Unsupported ImagenImage type: $T');
    }
  }
}

/// Parse the json to [ImagenGenerationResponse]
ImagenGenerationResponse parseImagenGenerationResponse(Object jsonObject) {
  if (jsonObject case {'error': final Object error}) throw parseError(error);
  Map<String, dynamic> json = jsonObject as Map<String, dynamic>;
  return ImagenGenerationResponse.fromJson(json);
}
