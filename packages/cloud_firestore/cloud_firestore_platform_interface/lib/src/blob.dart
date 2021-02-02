// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

/// Represents binary data stored in [Uint8List].

@immutable
class Blob {
  /// Creates a blob.
  const Blob(this.bytes);

  /// The bytes that are contained in this blob.
  final Uint8List bytes;

  @override
  bool operator ==(dynamic other) =>
      other is Blob &&
      const DeepCollectionEquality().equals(other.bytes, bytes);

  @override
  int get hashCode => hashList(bytes);
}
