// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../../firebase_storage_platform_interface.dart';

/// Result returned by [list].
abstract class ListResultPlatform extends PlatformInterface {
  /// Creates a new [ListResultPlatform] instance.
  ListResultPlatform(this.storage, this.nextPageToken) : super(token: _token);

  static final Object _token = Object();

  /// Throws an [AssertionError] if [instance] does not extend
  /// [ReferencePlatform].
  ///
  /// This is used by the app-facing [Reference] to ensure that
  /// the object in which it's going to delegate calls has been
  /// constructed properly.
  static void verifyExtends(ListResultPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
  }

  /// The [FirebaseStoragePlatform] used when fetching list items.
  final FirebaseStoragePlatform? storage;

  /// Objects in this directory. You can call [getMetadata] and [getDownloadUrl] on them.
  List<ReferencePlatform> get items {
    throw UnimplementedError('items is not implemented');
  }

  /// If set, there might be more results for this list. Use this token to resume the list.
  final String? nextPageToken;

  /// References to prefixes (sub-folders). You can call [list] on them to get its contents.
  ///
  /// Folders are implicit based on '/' in the object paths. For example, if a
  /// bucket has two objects '/a/b/1' and '/a/b/2', list('/a') will
  /// return '/a/b' as a prefix.
  List<ReferencePlatform> get prefixes {
    throw UnimplementedError('prefixes is not implemented');
  }
}
