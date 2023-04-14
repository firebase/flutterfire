// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import 'lib.dart';

/// A policy that defines how to name files on upload.
/// Default implementation is [KeepOriginalNameUploadPolicy].
///
/// See also:
///   * [KeepOriginalNameUploadPolicy]
abstract class FileUploadNamingPolicy {
  /// Returns a name for the file that will be uploaded to Firebase Storage.
  String getUploadFileName(String fullPath);

  /// Creates a [KeepOriginalNameUploadPolicy]
  factory FileUploadNamingPolicy.keepName() {
    return const KeepOriginalNameUploadPolicy();
  }

  /// Creates a [KeepPathUploadPolicy]
  factory FileUploadNamingPolicy.keepPath() => const KeepPathUploadPolicy();

  /// Creates a [UuidFileUploadNamingPolicy]
  factory FileUploadNamingPolicy.uuid([Map<String, String>? options]) {
    return UuidFileUploadNamingPolicy(options: options);
  }
}

/// An upload naming policy that keeps original file name.
class KeepOriginalNameUploadPolicy implements FileUploadNamingPolicy {
  const KeepOriginalNameUploadPolicy();

  @override
  String getUploadFileName(String fullPath) {
    return path.basename(fullPath);
  }
}

/// An upload naming policy that keeps original file path.
class KeepPathUploadPolicy implements FileUploadNamingPolicy {
  const KeepPathUploadPolicy();

  @override
  String getUploadFileName(String fullPath) {
    return fullPath;
  }
}

/// An upload naming policy that generates a new file name using Uuid
/// preserving file extension.
class UuidFileUploadNamingPolicy implements FileUploadNamingPolicy {
  final Uuid uuid;
  final Map<String, dynamic>? options;

  const UuidFileUploadNamingPolicy({
    this.uuid = const Uuid(),
    this.options,
  });

  @override
  String getUploadFileName(String fullPath) {
    final extension = path.extension(fullPath);
    final name = uuid.v4(options: options);

    return '$name$extension';
  }
}

/// A configuration object that is used by the widgets from Firebase UI Storage
class FirebaseUIStorageConfiguration {
  final FirebaseStorage storage;
  late final Reference uploadRoot;
  final FileUploadNamingPolicy namingPolicy;

  FirebaseUIStorageConfiguration({
    FirebaseStorage? storage,
    Reference? uploadRoot,
    this.namingPolicy = const KeepOriginalNameUploadPolicy(),
  }) : storage = storage ?? FirebaseStorage.instance {
    this.uploadRoot = uploadRoot ?? this.storage.ref();
  }
}

/// A widget that could be used to override [FirebaseUIStorageConfiguration]
/// for a specific part of the widget tree.
///
/// ```dart
/// FirebaseUIStorageConfigOverride(
///   config: FirebaseUIStorageConfiguration(
///     namingPolicy: UuidFileUploadNamingPolicy(),
///   ),
///   // all file uploads will use UuidFileUploadNamingPolicy
///   // inside MyUploadPage widget (unless overriden again)
///   child: MyUploadPage(),
/// ),
/// ```
class FirebaseUIStorageConfigOverride extends InheritedWidget {
  final FirebaseUIStorageConfiguration config;

  const FirebaseUIStorageConfigOverride({
    super.key,
    required super.child,
    required this.config,
  });

  @override
  bool updateShouldNotify(FirebaseUIStorageConfigOverride oldWidget) {
    return oldWidget.config != config;
  }
}

extension FirebaseUIStorageContextExtensions on BuildContext {
  FirebaseUIStorageConfiguration configFor(FirebaseStorage storage) {
    final w =
        dependOnInheritedWidgetOfExactType<FirebaseUIStorageConfigOverride>();

    if (w == null) {
      return FirebaseUIStorage.configurationFor(storage);
    }

    return w.config;
  }
}
