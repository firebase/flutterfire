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

import 'dart:convert';

import 'package:meta/meta.dart';

/// The desired outcome of the image editing.
@experimental
enum ImagenEditMode {
  /// The result of the editing will be an insertion of the prompt in the masked
  /// region.
  inpaintInsertion('EDIT_MODE_INPAINT_INSERTION'),

  /// The result of the editing will be a removal of the masked region.
  inpaintRemoval('EDIT_MODE_INPAINT_REMOVAL'),

  /// The result of the editing will be an outpainting of the source image.
  outpaint('EDIT_MODE_OUTPAINT');

  const ImagenEditMode(this._jsonString);
  final String _jsonString;
  // ignore: public_member_api_docs
  String toJson() => _jsonString;
}

/// The type of the subject in the image.
@experimental
enum ImagenSubjectReferenceType {
  /// The subject is a person.
  person('SUBJECT_TYPE_PERSON'),

  /// The subject is an animal.
  animal('SUBJECT_TYPE_ANIMAL'),

  /// The subject is a product.
  product('SUBJECT_TYPE_PRODUCT');

  const ImagenSubjectReferenceType(this._jsonString);
  final String _jsonString;

  // ignore: public_member_api_docs
  String toJson() => _jsonString;
}

/// The type of control image.
@experimental
enum ImagenControlType {
  /// Use edge detection to ensure the new image follow the same outlines.
  canny('CONTROL_TYPE_CANNY'),

  /// Use enhanced edge detection to ensure the new image follow similar
  /// outlines.
  scribble('CONTROL_TYPE_SCRIBBLE'),

  /// Use face mesh control to ensure that the new image has the same facial
  /// expressions.
  faceMesh('CONTROL_TYPE_FACE_MESH'),

  /// Use color superpixels to ensure that the new image is similar in shape
  /// and color to the original.
  colorSuperpixel('CONTROL_TYPE_COLOR_SUPERPIXEL');

  const ImagenControlType(this._jsonString);
  final String _jsonString;

  // ignore: public_member_api_docs
  String toJson() => _jsonString;
}

/// The mode of the mask.
@experimental
enum ImagenMaskMode {
  /// The mask is user provided.
  userProvided('MASK_MODE_USER_PROVIDED'),

  /// The mask is the background.
  background('MASK_MODE_BACKGROUND'),

  /// The mask is the foreground.
  foreground('MASK_MODE_FOREGROUND'),

  /// The mask is semantic.
  semantic('MASK_MODE_SEMANTIC');

  const ImagenMaskMode(this._jsonString);
  final String _jsonString;
  // ignore: public_member_api_docs
  String toJson() => _jsonString;
}

/// Base class for reference image configurations.
sealed class ImagenReferenceConfig {
  /// Convert the [ImagenReferenceConfig] content to json format.
  Map<String, Object?> toJson();
}

/// The configuration for the mask.
@experimental
final class ImagenMaskConfig extends ImagenReferenceConfig {
  // ignore: public_member_api_docs
  ImagenMaskConfig({
    required this.maskMode,
    this.maskDilation,
    this.maskClasses,
  });

  /// The type of the mask.
  final ImagenMaskMode maskMode;

  /// The dilation of the mask.
  final double? maskDilation;

  /// The classes of the mask.
  final List<int>? maskClasses;

  @override
  Map<String, Object?> toJson() => {
        'maskImageConfig': {
          'maskMode': maskMode.toJson(),
          if (maskDilation != null) 'dilation': maskDilation,
          if (maskClasses != null) 'maskClasses': jsonEncode(maskClasses),
        },
      };
}

/// The configuration for the subject.
@experimental
final class ImagenSubjectConfig extends ImagenReferenceConfig {
  // ignore: public_member_api_docs
  ImagenSubjectConfig({
    this.description,
    this.type,
  });

  /// A description of the subject.
  final String? description;

  /// The type of the subject.
  final ImagenSubjectReferenceType? type;

  @override
  Map<String, Object?> toJson() => {
        'subjectImageConfig': {
          if (description != null) 'subjectDescription': description,
          if (type != null) 'subjectType': type!.toJson(),
        },
      };
}

/// The configuration for the style.
@experimental
final class ImagenStyleConfig extends ImagenReferenceConfig {
  // ignore: public_member_api_docs
  ImagenStyleConfig({
    this.description,
  });

  /// A description of the style.
  final String? description;
  @override
  Map<String, Object?> toJson() => {
        'styleImageConfig': {
          if (description != null) 'styleDescription': description,
        },
      };
}

/// The configuration for the control.
@experimental
final class ImagenControlConfig extends ImagenReferenceConfig {
  // ignore: public_member_api_docs
  ImagenControlConfig({
    required this.controlType,
    this.enableComputation,
    this.superpixelRegionSize,
    this.superpixelRuler,
  });

  /// The type of control.
  final ImagenControlType controlType;

  /// Whether to enable computation.
  final bool? enableComputation;

  /// The size of the superpixel region.
  final int? superpixelRegionSize;

  /// The ruler for the superpixel.
  final int? superpixelRuler;
  @override
  Map<String, Object?> toJson() => {
        'controlImageConfig': {
          'controlType': controlType.toJson(),
          if (enableComputation != null)
            'enableControlImageComputation': enableComputation,
          if (superpixelRegionSize != null)
            'superpixelRegionSize': superpixelRegionSize,
          if (superpixelRuler != null) 'superpixelRuler': superpixelRuler,
        },
      };
}

/// The configuration for image editing.
@experimental
final class ImagenEditingConfig {
  // ignore: public_member_api_docs
  ImagenEditingConfig({
    this.editMode,
    this.editSteps,
  });

  /// The mode of the editing.
  final ImagenEditMode? editMode;

  /// The number of steps for the editing.
  final int? editSteps;
}

/// The dimensions of an image.
@experimental
final class ImagenDimensions {
  // ignore: public_member_api_docs
  ImagenDimensions({
    required this.width,
    required this.height,
  });

  /// The width of the image.
  final int width;

  /// The height of the image.
  final int height;
}

/// The placement of an image.
@experimental
final class ImagenImagePlacement {
  const ImagenImagePlacement._(this.x, this.y);

  /// The x coordinate of the placement.
  final int? x;

  /// The y coordinate of the placement.
  final int? y;

  /// Creates a placement from a coordinate.
  static ImagenImagePlacement fromCoordinate(int x, int y) =>
      ImagenImagePlacement._(x, y);

  /// The center of the image.
  static const ImagenImagePlacement center = ImagenImagePlacement._(null, null);

  /// The top center of the image.
  static const ImagenImagePlacement topCenter =
      ImagenImagePlacement._(null, null);

  /// The bottom center of the image.
  static const ImagenImagePlacement bottomCenter =
      ImagenImagePlacement._(null, null);

  /// The left center of the image.
  static const ImagenImagePlacement leftCenter =
      ImagenImagePlacement._(null, null);

  /// The right center of the image.
  static const ImagenImagePlacement rightCenter =
      ImagenImagePlacement._(null, null);

  /// The top left of the image.
  static const ImagenImagePlacement topLeft = ImagenImagePlacement._(0, 0);

  /// The top right of the image.
  static const ImagenImagePlacement topRight =
      ImagenImagePlacement._(null, null);

  /// The bottom left of the image.
  static const ImagenImagePlacement bottomLeft =
      ImagenImagePlacement._(null, null);

  /// The bottom right of the image.
  static const ImagenImagePlacement bottomRight =
      ImagenImagePlacement._(null, null);

  /// Normalizes the placement to the given dimensions.
  ImagenImagePlacement normalizeToDimensions(
    ImagenDimensions original,
    ImagenDimensions newDim,
  ) {
    // In a real implementation, this would calculate the top-left (x, y)
    // based on the placement strategy (e.g., center, top-left).
    final x = (newDim.width - original.width) / 2;
    final y = (newDim.height - original.height) / 2;
    return ImagenImagePlacement.fromCoordinate(x.toInt(), y.toInt());
  }
}
