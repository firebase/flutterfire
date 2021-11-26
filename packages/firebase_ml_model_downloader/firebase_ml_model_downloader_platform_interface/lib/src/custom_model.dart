// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

/// Stores information about custom models that are being downloaded or are
/// already downloaded on a device
///
/// In the case where an update is available, after the updated model file is
/// fully downloaded, the original model file will be removed once it is safe
/// to do so.
class CustomModel {
  /// Creates a new [CustomModel] instance.
  CustomModel(
      {required this.file,
      required this.size,
      required this.name,
      required this.hash});

  /// The locally downloaded model file.
  final File file;

  /// The model name and identifier.
  final String name;

  /// The size of the file currently associated with this model.
  ///
  /// If a download is in progress, this will be the size of the current model,
  /// not the new model currently being downloaded.
  final int size;

  /// Retrieves the model hash.
  final String hash;

  @override
  bool operator ==(o) => o is CustomModel && hash == o.hash;

  @override
  int get hashCode => hash.hashCode;
}
