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
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'imagen_content.dart';
import 'imagen_edit.dart';

enum ReferenceType {
  UNSPECIFIED('REFERENCE_TYPE_UNSPECIFIED'),
  RAW('REFERENCE_TYPE_RAW'),
  MASK('REFERENCE_TYPE_MASK'),
  CONTROL('REFERENCE_TYPE_CONTROL'),
  STYLE('REFERENCE_TYPE_STYLE'),
  SUBJECT('REFERENCE_TYPE_SUBJECT'),
  MASKED_SUBJECT('REFERENCE_TYPE_MASKED_SUBJECT'),
  PRODUCT('REFERENCE_TYPE_PRODUCT');

  const ReferenceType(this._jsonString);
  final String _jsonString;

  @override
  String toString() => _jsonString;
}

/// A reference image for image editing.
@experimental
sealed class ImagenReferenceImage {
  ImagenReferenceImage({
    this.referenceConfig,
    this.image,
    this.referenceId,
    required this.referenceType,
  });

  final ImagenReferenceConfig? referenceConfig;
  final ImagenInlineImage? image;
  final int? referenceId;
  final ReferenceType referenceType;

  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    json['referenceType'] = referenceType.toString();
    if (image != null) {
      json['referenceImage'] = image!.toJson();
    }
    if (referenceId != null) {
      json['referenceId'] = referenceId;
    }
    if (referenceConfig != null) {
      json.addAll(referenceConfig!.toJson());
    }

    return json;
  }
}

/// A reference image that is a mask.
@experimental
sealed class ImagenMaskReference extends ImagenReferenceImage {
  ImagenMaskReference({
    ImagenMaskConfig? maskConfig,
    super.image,
    super.referenceId,
  }) : super(referenceType: ReferenceType.MASK, referenceConfig: maskConfig);

  /// Generates a mask and pads the image for outpainting.
  static Future<List<ImagenReferenceImage>> generateMaskAndPadForOutpainting({
    required ImagenInlineImage image,
    required ImagenDimensions newDimensions,
    ImagenImagePlacement newPosition = ImagenImagePlacement.center,
  }) async {
    final originalImage = await image.asUiImage();

    // Validate that the new dimensions are strictly larger.
    if (originalImage.width >= newDimensions.width ||
        originalImage.height >= newDimensions.height) {
      throw ArgumentError(
        'New Dimensions must be strictly larger than original image dimensions. '
        'Original image is: ${originalImage.width}x${originalImage.height}, '
        'new dimensions are ${newDimensions.width}x${newDimensions.height}',
      );
    }

    // Calculate the position of the original image on the new canvas.
    final normalizedPosition = newPosition.normalizeToDimensions(
      ImagenDimensions(
          width: originalImage.width, height: originalImage.height),
      newDimensions,
    );

    final x = normalizedPosition.x;
    final y = normalizedPosition.y;

    if (x == null || y == null) {
      throw StateError('Error normalizing position for mask and padding.');
    }

    // Define the rectangle where the original image will be drawn.
    final imageRect = ui.Rect.fromLTWH(
      x.toDouble(),
      y.toDouble(),
      originalImage.width.toDouble(),
      originalImage.height.toDouble(),
    );

    // Create both the mask and the new image concurrently.
    final results = await Future.wait([
      // Future to create the mask
      _createImageFromPainter(
        width: newDimensions.width,
        height: newDimensions.height,
        painter: (canvas, size) {
          // Fill the mask with white, then draw a black rectangle where the image is.
          canvas.drawPaint(Paint()..color = Colors.white);
          canvas.drawRect(imageRect, Paint()..color = Colors.black);
        },
      ),
      // Future to create the new padded image
      _createImageFromPainter(
        width: newDimensions.width,
        height: newDimensions.height,
        painter: (canvas, size) {
          // Fill the new image with black padding.
          canvas.drawPaint(Paint()..color = Colors.black);
          // Draw the original image into the corresponding spot.
          canvas.drawImageRect(
            originalImage,
            ui.Rect.fromLTWH(0, 0, originalImage.width.toDouble(),
                originalImage.height.toDouble()),
            imageRect,
            Paint(),
          );
        },
      ),
    ]);

    final newPaddedUiImage = results[1];
    final maskUiImage = results[0];

    // Convert the generated ui.Image objects back to byte data.
    final newImageBytes =
        await newPaddedUiImage.toByteData(format: ui.ImageByteFormat.png);
    final maskBytes =
        await maskUiImage.toByteData(format: ui.ImageByteFormat.png);

    if (newImageBytes == null || maskBytes == null) {
      throw StateError('Failed to encode generated images.');
    }

    return [
      ImagenRawImage(
        referenceId: 1,
        image: ImagenInlineImage(
          bytesBase64Encoded: newImageBytes.buffer.asUint8List(),
          mimeType: image.mimeType,
        ),
      ),
      ImagenRawMask(
        referenceId: 2,
        mask: ImagenInlineImage(
          bytesBase64Encoded: maskBytes.buffer.asUint8List(),
          mimeType: image.mimeType,
        ),
      ),
    ];
  }

  /// Helper function to create a ui.Image by drawing on a Canvas.
  static Future<ui.Image> _createImageFromPainter({
    required int width,
    required int height,
    required void Function(ui.Canvas canvas, ui.Size size) painter,
  }) {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final size = ui.Size(width.toDouble(), height.toDouble());

    painter(canvas, size);

    final picture = recorder.endRecording();
    return picture.toImage(width, height);
  }
}

/// A raw image.
@experimental
final class ImagenRawImage extends ImagenReferenceImage {
  ImagenRawImage({
    required ImagenInlineImage image,
    super.referenceId,
  }) : super(image: image, referenceType: ReferenceType.RAW);
}

/// A raw mask.
@experimental
final class ImagenRawMask extends ImagenMaskReference {
  ImagenRawMask({
    required ImagenInlineImage mask,
    double? dilation,
    super.referenceId,
  }) : super(
          image: mask,
          maskConfig: ImagenMaskConfig(
            maskType: ImagenMaskMode.userProvided,
            maskDilation: dilation,
          ),
        );
}

/// A semantic mask.
@experimental
final class ImagenSemanticMask extends ImagenMaskReference {
  ImagenSemanticMask({
    required List<int> classes,
    double? dilation,
    super.referenceId,
  }) : super(
          maskConfig: ImagenMaskConfig(
            maskType: ImagenMaskMode.semantic,
            maskDilation: dilation,
          ),
        );
}

/// A background mask.
@experimental
final class ImagenBackgroundMask extends ImagenMaskReference {
  ImagenBackgroundMask({double? dilation, super.referenceId})
      : super(
          maskConfig: ImagenMaskConfig(
            maskType: ImagenMaskMode.background,
            maskDilation: dilation,
          ),
        );
}

/// A foreground mask.
@experimental
final class ImagenForegroundMask extends ImagenMaskReference {
  ImagenForegroundMask({
    double? dilation,
    super.referenceId,
  }) : super(
          maskConfig: ImagenMaskConfig(
            maskType: ImagenMaskMode.foreground,
            maskDilation: dilation,
          ),
        );
}

/// A subject reference.
@experimental
final class ImagenSubjectReference extends ImagenReferenceImage {
  ImagenSubjectReference({
    required ImagenInlineImage image,
    super.referenceId,
    String? description,
    ImagenSubjectReferenceType? subjectType,
  }) : super(
          image: image,
          referenceConfig: ImagenSubjectConfig(
            description: description,
            type: subjectType,
          ),
          referenceType: ReferenceType.SUBJECT,
        );
}

/// A style reference.
@experimental
final class ImagenStyleReference extends ImagenReferenceImage {
  ImagenStyleReference({
    required ImagenInlineImage image,
    super.referenceId,
    String? description,
  }) : super(
          image: image,
          referenceConfig: ImagenStyleConfig(
            description: description,
          ),
          referenceType: ReferenceType.STYLE,
        );
}

/// A control reference.
@experimental
final class ImagenControlReference extends ImagenReferenceImage {
  ImagenControlReference({
    required ImagenControlType controlType,
    ImagenInlineImage? image,
    super.referenceId,
    bool? enableComputation,
    int? superpixelRegionSize,
    int? superpixelRuler,
  }) : super(
          image: image,
          referenceConfig: ImagenControlConfig(
            controlType: controlType,
            enableComputation: enableComputation,
            superpixelRegionSize: superpixelRegionSize,
            superpixelRuler: superpixelRuler,
          ),
          referenceType: ReferenceType.CONTROL,
        );
}
