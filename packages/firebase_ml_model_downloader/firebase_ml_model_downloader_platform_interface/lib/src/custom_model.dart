// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

import 'dart:io';

/// Stores information about custom models that are being downloaded or are
/// already downloaded on a device
///
/// In the case where an update is available, after the updated model file is
/// fully downloaded, the original model file will be removed once it is safe
/// to do so.
class FirebaseCustomModel {
  /// Creates a new [FirebaseCustomModel] instance.
  FirebaseCustomModel({
    required this.file,
    required this.size,
    required this.name,
    required this.hash,
  });

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
  // ignore: avoid_renaming_method_parameters
  bool operator ==(Object o) => o is FirebaseCustomModel && hash == o.hash;

  @override
  int get hashCode => hash.hashCode;
}
