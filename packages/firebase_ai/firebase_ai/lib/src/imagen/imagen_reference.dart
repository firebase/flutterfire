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
import 'package:meta/meta.dart';

import 'imagen_content.dart';
import 'imagen_edit.dart';

enum _ReferenceType {
  UNSPECIFIED('REFERENCE_TYPE_UNSPECIFIED'),
  RAW('REFERENCE_TYPE_RAW'),
  MASK('REFERENCE_TYPE_MASK'),
  CONTROL('REFERENCE_TYPE_CONTROL'),
  STYLE('REFERENCE_TYPE_STYLE'),
  SUBJECT('REFERENCE_TYPE_SUBJECT'),
  MASKED_SUBJECT('REFERENCE_TYPE_MASKED_SUBJECT'),
  PRODUCT('REFERENCE_TYPE_PRODUCT');

  const _ReferenceType(this._jsonString);
  final String _jsonString;
  String toJson() => _jsonString;
}

/// A reference image for image editing.
@experimental
sealed class ImagenReferenceImage {
  ImagenReferenceImage._({
    this.referenceConfig,
    this.image,
    required this.referenceType,
    this.referenceId,
  });

  /// A config describing the reference image.
  final ImagenReferenceConfig? referenceConfig;

  /// The actual image data of the reference image.
  final ImagenInlineImage? image;

  /// The type of the reference image.
  final _ReferenceType referenceType;

  /// The reference ID of the image.
  final int? referenceId;

  // ignore: public_member_api_docs
  Map<String, Object?> toJson({int referenceIdOverrideIfNull = 0}) {
    final json = <String, Object?>{};
    json['referenceType'] = referenceType.toJson();
    if (referenceId != null) {
      json['referenceId'] = referenceId;
    } else {
      json['referenceId'] = referenceIdOverrideIfNull;
    }
    if (image != null) {
      json['referenceImage'] = image!.toJson();
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
  }) : super._(
          referenceType: _ReferenceType.MASK,
          referenceConfig: maskConfig,
        );
}

/// A raw image.
@experimental
final class ImagenRawImage extends ImagenReferenceImage {
  ImagenRawImage({
    required ImagenInlineImage image,
    super.referenceId,
  }) : super._(image: image, referenceType: _ReferenceType.RAW);
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
            maskClasses: classes,
          ),
        );
}

/// A background mask.
@experimental
final class ImagenBackgroundMask extends ImagenMaskReference {
  ImagenBackgroundMask({
    double? dilation,
    super.referenceId,
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
    String? description,
    ImagenSubjectReferenceType? subjectType,
    super.referenceId,
  }) : super._(
          image: image,
          referenceConfig: ImagenSubjectConfig(
            description: description,
            type: subjectType,
          ),
          referenceType: _ReferenceType.SUBJECT,
        );
}

/// A style reference.
@experimental
final class ImagenStyleReference extends ImagenReferenceImage {
  ImagenStyleReference({
    required ImagenInlineImage image,
    String? description,
    super.referenceId,
  }) : super._(
          image: image,
          referenceConfig: ImagenStyleConfig(
            description: description,
          ),
          referenceType: _ReferenceType.STYLE,
        );
}

/// A control reference.
@experimental
final class ImagenControlReference extends ImagenReferenceImage {
  ImagenControlReference({
    required ImagenControlType controlType,
    ImagenInlineImage? image,
    bool? enableComputation,
    int? superpixelRegionSize,
    int? superpixelRuler,
    super.referenceId,
  }) : super._(
          image: image,
          referenceConfig: ImagenControlConfig(
            controlType: controlType,
            enableComputation: enableComputation,
            superpixelRegionSize: superpixelRegionSize,
            superpixelRuler: superpixelRuler,
          ),
          referenceType: _ReferenceType.CONTROL,
        );
}
