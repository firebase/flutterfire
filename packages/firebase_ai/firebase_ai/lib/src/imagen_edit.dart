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

part of 'base_model.dart';

/// The desired outcome of the image editing.
@experimental
final class ImagenEditMode {
  const ImagenEditMode._(this._jsonString);

  final String _jsonString;

  /// The result of the editing will be an insertion of the prompt in the masked
  /// region.
  static const ImagenEditMode inpaintInsertion =
      ImagenEditMode._('inpaint-insertion');

  /// The result of the editing will be a removal of the masked region.
  static const ImagenEditMode inpaintRemoval =
      ImagenEditMode._('inpaint-removal');

  /// The result of the editing will be an outpainting of the source image.
  static const ImagenEditMode outpaint = ImagenEditMode._('outpaint');

  @override
  String toString() => _jsonString;
}

/// The type of the subject in the image.
@experimental
final class ImagenSubjectReferenceType {
  const ImagenSubjectReferenceType._(this._jsonString);

  final String _jsonString;

  /// The subject is a person.
  static const ImagenSubjectReferenceType person =
      ImagenSubjectReferenceType._('person');

  /// The subject is an animal.
  static const ImagenSubjectReferenceType animal =
      ImagenSubjectReferenceType._('animal');

  /// The subject is a product.
  static const ImagenSubjectReferenceType product =
      ImagenSubjectReferenceType._('product');

  @override
  String toString() => _jsonString;
}

/// The type of control image.
@experimental
final class ImagenControlType {
  const ImagenControlType._(this._jsonString);

  final String _jsonString;

  /// Canny edge detection.
  static const ImagenControlType canny = ImagenControlType._('canny');

  /// Scribble.
  static const ImagenControlType scribble = ImagenControlType._('scribble');

  /// Face mesh.
  static const ImagenControlType faceMesh = ImagenControlType._('face-mesh');

  /// Color superpixel.
  static const ImagenControlType colorSuperpixel =
      ImagenControlType._('color-superpixel');

  @override
  String toString() => _jsonString;
}

/// The mode of the mask.
@experimental
final class ImagenMaskMode {
  const ImagenMaskMode._(this._jsonString);

  final String _jsonString;

  /// The mask is user provided.
  static const ImagenMaskMode userProvided = ImagenMaskMode._('user-provided');

  /// The mask is the background.
  static const ImagenMaskMode background = ImagenMaskMode._('background');

  /// The mask is the foreground.
  static const ImagenMaskMode foreground = ImagenMaskMode._('foreground');

  /// The mask is semantic.
  static const ImagenMaskMode semantic = ImagenMaskMode._('semantic');

  @override
  String toString() => _jsonString;
}

/// The configuration for the mask.
@experimental
final class ImagenMaskConfig {
  ImagenMaskConfig({
    required this.maskType,
    this.maskDilation,
  });

  final ImagenMaskMode maskType;
  final double? maskDilation;
}

/// The configuration for the subject.
@experimental
final class ImagenSubjectConfig {
  ImagenSubjectConfig({
    this.description,
    this.type,
  });

  final String? description;
  final ImagenSubjectReferenceType? type;
}

/// The configuration for the style.
@experimental
final class ImagenStyleConfig {
  ImagenStyleConfig({
    this.description,
  });

  final String? description;
}

/// The configuration for the control.
@experimental
final class ImagenControlConfig {
  ImagenControlConfig({
    required this.controlType,
    this.enableComputation,
    this.superpixelRegionSize,
    this.superpixelRuler,
  });

  final ImagenControlType controlType;
  final bool? enableComputation;
  final int? superpixelRegionSize;
  final int? superpixelRuler;
}

/// A reference image for image editing.
@experimental
sealed class ImagenReferenceImage {
  ImagenReferenceImage({
    this.maskConfig,
    this.subjectConfig,
    this.styleConfig,
    this.controlConfig,
    this.image,
    this.referenceId,
  });

  final ImagenMaskConfig? maskConfig;
  final ImagenSubjectConfig? subjectConfig;
  final ImagenStyleConfig? styleConfig;
  final ImagenControlConfig? controlConfig;
  final ImagenInlineImage? image;
  final int? referenceId;

  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (image != null) {
      json['image'] = image!.toJson();
    }
    if (referenceId != null) {
      json['referenceId'] = referenceId;
    }
    if (maskConfig != null) {
      json['mask'] = {
        'type': maskConfig!.maskType.toString(),
        if (maskConfig!.maskDilation != null)
          'dilation': maskConfig!.maskDilation,
      };
    }
    if (subjectConfig != null) {
      json['subject'] = {
        if (subjectConfig!.description != null)
          'description': subjectConfig!.description,
        if (subjectConfig!.type != null) 'type': subjectConfig!.type.toString(),
      };
    }
    if (styleConfig != null) {
      json['style'] = {
        if (styleConfig!.description != null)
          'description': styleConfig!.description,
      };
    }
    if (controlConfig != null) {
      json['control'] = {
        'type': controlConfig!.controlType.toString(),
        if (controlConfig!.enableComputation != null)
          'enableComputation': controlConfig!.enableComputation,
        if (controlConfig!.superpixelRegionSize != null)
          'superpixelRegionSize': controlConfig!.superpixelRegionSize,
        if (controlConfig!.superpixelRuler != null)
          'superpixelRuler': controlConfig!.superpixelRuler,
      };
    }
    return json;
  }
}

/// A reference image that is a mask.
@experimental
sealed class ImagenMaskReference extends ImagenReferenceImage {
  ImagenMaskReference({
    super.maskConfig,
    super.image,
  });

  /// Generates a mask and pads the image for outpainting.
  static List<ImagenReferenceImage> generateMaskAndPadForOutpainting({
    required ImagenInlineImage image,
    required Dimensions newDimensions,
    ImagenImagePlacement newPosition = ImagenImagePlacement.center,
  }) {
    // TODO: implement
    return [];
  }
}

/// A raw image.
@experimental
final class ImagenRawImage extends ImagenReferenceImage {
  ImagenRawImage({
    required ImagenInlineImage image,
  }) : super(image: image);
}

/// A raw mask.
@experimental
final class ImagenRawMask extends ImagenMaskReference {
  ImagenRawMask({
    required ImagenInlineImage mask,
    double? dilation,
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
  ImagenBackgroundMask({
    double? dilation,
  }) : super(
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
    int? referenceId,
    String? description,
    ImagenSubjectReferenceType? subjectType,
  }) : super(
          image: image,
          referenceId: referenceId,
          subjectConfig: ImagenSubjectConfig(
            description: description,
            type: subjectType,
          ),
        );
}

/// A style reference.
@experimental
final class ImagenStyleReference extends ImagenReferenceImage {
  ImagenStyleReference({
    required ImagenInlineImage image,
    int? referenceId,
    String? description,
  }) : super(
          image: image,
          referenceId: referenceId,
          styleConfig: ImagenStyleConfig(
            description: description,
          ),
        );
}

/// A control reference.
@experimental
final class ImagenControlReference extends ImagenReferenceImage {
  ImagenControlReference({
    required ImagenControlType controlType,
    ImagenInlineImage? image,
    int? referenceId,
    bool? enableComputation,
    int? superpixelRegionSize,
    int? superpixelRuler,
  }) : super(
          image: image,
          referenceId: referenceId,
          controlConfig: ImagenControlConfig(
            controlType: controlType,
            enableComputation: enableComputation,
            superpixelRegionSize: superpixelRegionSize,
            superpixelRuler: superpixelRuler,
          ),
        );
}

/// The configuration for image editing.
@experimental
final class ImagenEditingConfig {
  ImagenEditingConfig({
    this.editMode,
    this.editSteps,
  });

  final ImagenEditMode? editMode;
  final int? editSteps;
}

/// The dimensions of an image.
@experimental
final class Dimensions {
  Dimensions({
    required this.width,
    required this.height,
  });

  final int width;
  final int height;
}

/// The placement of an image.
@experimental
final class ImagenImagePlacement {
  const ImagenImagePlacement._(this.x, this.y);

  final int? x;
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
}

extension on Bitmap {
  /// Converts a [Bitmap] to an [ImagenInlineImage].
  ImagenInlineImage get toImagenInlineImage =>
      ImagenInlineImage(data: asUint8List());
}
