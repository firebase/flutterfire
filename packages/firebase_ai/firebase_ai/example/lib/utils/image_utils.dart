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
import 'package:firebase_ai/firebase_ai.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';

/// The parameters passed to the isolate
class _IsolateParams {
  final Uint8List imageBytes;
  // ignore: experimental_member_use
  final ImagenDimensions newDimensions;
  // ignore: experimental_member_use
  final ImagenImagePlacement newPosition;

  _IsolateParams({
    required Uint8List imageBytes,
    required this.newDimensions,
    required this.newPosition,
  }) : imageBytes = Uint8List.fromList(imageBytes);
}

/// The results returned from the isolate
class _IsolateResult {
  final Uint8List paddedImageBytes;
  final Uint8List maskBytes;

  _IsolateResult({
    required this.paddedImageBytes,
    required this.maskBytes,
  });
}

/// Processes the image request.
///
/// This is the top-level function that will run in the background isolate.
/// It uses the 'image' package for all manipulations.
Future<_IsolateResult> _generateMaskAndPadInIsolate(
  _IsolateParams params,
) async {
  // 1. Decode the original image
  final originalImage = img.decodeImage(params.imageBytes);
  if (originalImage == null) {
    throw StateError('Failed to decode image in isolate.');
  }
  // Validate dimensions
  if (originalImage.width >= params.newDimensions.width ||
      originalImage.height >= params.newDimensions.height) {
    throw ArgumentError(
      'New Dimensions must be strictly larger than original image dimensions.',
    );
  }
  // 2. Calculate the position
  // ignore: experimental_member_use
  final originalDimensions = ImagenDimensions(
    width: originalImage.width,
    height: originalImage.height,
  );
  final normalizedPosition = params.newPosition.normalizeToDimensions(
    originalDimensions,
    params.newDimensions,
  );
  final x = normalizedPosition.x ?? 0;
  final y = normalizedPosition.y ?? 0;
  // 3. Create the mask image
  final mask = img.Image(
    width: params.newDimensions.width,
    height: params.newDimensions.height,
  );
  // Fill with white and draw a black rectangle for the original image area
  img.fill(mask, color: img.ColorRgb8(255, 255, 255));
  img.fillRect(
    mask,
    x1: x,
    y1: y,
    x2: x + originalImage.width,
    y2: y + originalImage.height,
    color: img.ColorRgb8(0, 0, 0),
  );
  // 4. Create the padded image
  final paddedImage = img.Image(
    width: params.newDimensions.width,
    height: params.newDimensions.height,
  );
  // Fill with black and draw the original image on top
  img.fill(paddedImage, color: img.ColorRgb8(0, 0, 0));
  img.compositeImage(
    paddedImage,
    originalImage,
    dstX: x,
    dstY: y,
  );
  // 5. Encode both images to PNG format (which is lossless)
  final maskBytes = img.encodePng(mask);
  final paddedBytes = img.encodePng(paddedImage);
  return _IsolateResult(
    paddedImageBytes: Uint8List.fromList(paddedBytes),
    maskBytes: Uint8List.fromList(maskBytes),
  );
}

/// Generates a mask and pads the image for outpainting.
// ignore: experimental_member_use
Future<List<ImagenReferenceImage>> generateMaskAndPadForOutpainting({
  required ImagenInlineImage image,
  // ignore: experimental_member_use
  required ImagenDimensions newDimensions,
  // ignore: experimental_member_use
  ImagenImagePlacement newPosition = ImagenImagePlacement.center,
}) async {
  // Prepare the parameters for the isolate
  // Note: We are assuming `image` has a way to get its raw bytes,
  // which seems to be the case from `bytesBase64Encoded` in your example.
  // If not, you'd need to convert the `ui.Image` to bytes here first.
  final params = _IsolateParams(
    imageBytes: image.bytesBase64Encoded, // Assuming this is Uint8List
    newDimensions: newDimensions,
    newPosition: newPosition,
  );
  // Execute the image processing in a separate isolate and wait for the result
  final result = await compute(_generateMaskAndPadInIsolate, params);

  // Use the resulting bytes to create your final objects
  return [
    // ignore: experimental_member_use
    ImagenRawImage(
      image: ImagenInlineImage(
        bytesBase64Encoded: result.paddedImageBytes,
        mimeType: 'image/png', // The isolate always returns PNG
      ),
    ),
    // ignore: experimental_member_use
    ImagenRawMask(
      mask: ImagenInlineImage(
        bytesBase64Encoded: result.maskBytes,
        mimeType: 'image/png', // The isolate always returns PNG
      ),
    ),
  ];
}
