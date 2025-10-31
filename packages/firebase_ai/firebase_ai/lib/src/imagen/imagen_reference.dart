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
  raw('REFERENCE_TYPE_RAW'),
  mask('REFERENCE_TYPE_MASK'),
  control('REFERENCE_TYPE_CONTROL'),
  style('REFERENCE_TYPE_STYLE'),
  subject('REFERENCE_TYPE_SUBJECT');

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
  // ignore: public_member_api_docs
  ImagenMaskReference({
    ImagenMaskConfig? maskConfig,
    super.image,
    super.referenceId,
  }) : super._(
          referenceType: _ReferenceType.mask,
          referenceConfig: maskConfig,
        );
}

/// A raw image.
@experimental
final class ImagenRawImage extends ImagenReferenceImage {
  // ignore: public_member_api_docs
  ImagenRawImage({
    required ImagenInlineImage image,
    super.referenceId,
  }) : super._(image: image, referenceType: _ReferenceType.raw);
}

/// A raw mask.
@experimental
final class ImagenRawMask extends ImagenMaskReference {
  // ignore: public_member_api_docs
  ImagenRawMask({
    required ImagenInlineImage mask,
    double? dilation,
    super.referenceId,
  }) : super(
          image: mask,
          maskConfig: ImagenMaskConfig(
            maskMode: ImagenMaskMode.userProvided,
            maskDilation: dilation,
          ),
        );
}

/// A semantic mask.
@experimental
final class ImagenSemanticMask extends ImagenMaskReference {
  // ignore: public_member_api_docs
  ImagenSemanticMask({
    required List<int> classes,
    double? dilation,
    super.referenceId,
  }) : super(
          maskConfig: ImagenMaskConfig(
            maskMode: ImagenMaskMode.semantic,
            maskDilation: dilation,
            maskClasses: classes,
          ),
        );
}

/// A background mask.
@experimental
final class ImagenBackgroundMask extends ImagenMaskReference {
  // ignore: public_member_api_docs
  ImagenBackgroundMask({
    double? dilation,
    super.referenceId,
  }) : super(
          maskConfig: ImagenMaskConfig(
            maskMode: ImagenMaskMode.background,
            maskDilation: dilation,
          ),
        );
}

/// A foreground mask.
@experimental
final class ImagenForegroundMask extends ImagenMaskReference {
  // ignore: public_member_api_docs
  ImagenForegroundMask({
    double? dilation,
    super.referenceId,
  }) : super(
          maskConfig: ImagenMaskConfig(
            maskMode: ImagenMaskMode.foreground,
            maskDilation: dilation,
          ),
        );
}

/// A subject reference.
@experimental
final class ImagenSubjectReference extends ImagenReferenceImage {
  // ignore: public_member_api_docs
  ImagenSubjectReference({
    required ImagenInlineImage image,
    String? description,
    ImagenSubjectReferenceType? subjectType,
    required super.referenceId,
  }) : super._(
          image: image,
          referenceConfig: ImagenSubjectConfig(
            description: description,
            type: subjectType,
          ),
          referenceType: _ReferenceType.subject,
        );
}

/// A style reference.
@experimental
final class ImagenStyleReference extends ImagenReferenceImage {
  // ignore: public_member_api_docs
  ImagenStyleReference({
    required ImagenInlineImage image,
    String? description,
    required super.referenceId,
  }) : super._(
          image: image,
          referenceConfig: ImagenStyleConfig(
            description: description,
          ),
          referenceType: _ReferenceType.style,
        );
}

/// A control reference.
@experimental
final class ImagenControlReference extends ImagenReferenceImage {
  // ignore: public_member_api_docs
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
          referenceType: _ReferenceType.control,
        );
}
