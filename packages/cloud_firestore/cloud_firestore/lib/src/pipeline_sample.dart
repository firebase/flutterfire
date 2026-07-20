// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../cloud_firestore.dart';

/// Base class for pipeline sampling strategies
abstract class PipelineSample implements PipelineSerializable {
  const PipelineSample();

  /// Creates a sample with a fixed size
  factory PipelineSample.withSize(int size) = _PipelineSampleSize;

  /// Creates a sample with a percentage
  factory PipelineSample.withPercentage(double percentage) =
      _PipelineSamplePercentage;
}

/// Sample stage with a fixed size
class _PipelineSampleSize extends PipelineSample {
  final int size;

  const _PipelineSampleSize(this.size);

  @override
  Map<String, dynamic> toMap() => {
        'type': 'size',
        'value': size,
      };
}

/// Sample stage with a percentage
class _PipelineSamplePercentage extends PipelineSample {
  final double percentage;

  const _PipelineSamplePercentage(this.percentage);

  @override
  Map<String, dynamic> toMap() => {
        'type': 'percentage',
        'value': percentage,
      };
}
