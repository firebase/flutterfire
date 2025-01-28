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

/// Base type of Imagen Image.
sealed class ImagenImage {
  /// Constructor
  ImagenImage({required this.mimeType});

  /// The MIME type of the image format.
  final String mimeType;

  /// Convert the [ImagenImage] content to json format.
  Object toJson();
}

/// Represents an image stored as a base64-encoded string.
final class ImagenInlineImage implements ImagenImage {
  /// Constructor
  ImagenInlineImage({
    required this.bytesBase64Encoded,
    required this.mimeType,
  });

  /// The data contents in bytes, encoded as base64.
  final Uint8List bytesBase64Encoded;

  @override
  final String mimeType;

  @override
  Object toJson() => {
        'mimeType': mimeType,
        'bytesBase64Encoded': bytesBase64Encoded,
      };
}

/// Represents an image stored in Google Cloud Storage.
final class ImagenGCSImage implements ImagenImage {
  /// Constructor
  ImagenGCSImage({
    required this.gcsUri,
    required this.mimeType,
  });

  /// The storage URI of the image.
  final String gcsUri;

  @override
  final String mimeType;

  @override
  Object toJson() => {
        'mimeType': mimeType,
        'gcsUri': gcsUri,
      };
}

/// Represents the response from an image generation request.
final class ImagenGenerationResponse<T extends ImagenImage> {
  /// Constructor
  ImagenGenerationResponse({
    required this.images,
    this.filteredReason,
  });

  /// Factory method to create an ImagenGenerationResponse from a JSON object.
  factory ImagenGenerationResponse.fromJson(Map<String, dynamic> json) {
    final filteredReason = json['filteredReason'] as String?;
    final imagesJson = json['predictions'] as List<dynamic>;

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

  /// A list of generated images. The type of the images depends on the T parameter.
  final List<T> images;

  /// If the generation was filtered due to safety reasons, a message explaining the reason.
  final String? filteredReason;
}

/// Parse the json to [ImagenGenerationResponse]
ImagenGenerationResponse<T>
    parseImagenGenerationResponse<T extends ImagenImage>(Object jsonObject) {
  if (jsonObject case {'error': final Object error}) throw parseError(error);
  Map<String, dynamic> json = jsonObject as Map<String, dynamic>;
  return ImagenGenerationResponse<T>.fromJson(json);
}
