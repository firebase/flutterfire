// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_storage;

/// Class returned as a result of calling a list method ([list] or [listAll])
/// on a [Reference].
class ListResult {
  ListResultPlatform _delegate;

  /// The [FirebaseStorage] instance for this result.
  final FirebaseStorage storage;

  ListResult._(this.storage, this._delegate) {
    ListResultPlatform.verifyExtends(_delegate);
  }

  /// Objects in this directory.
  ///
  /// Returns a [List] of [Reference] instances.
  List<Reference> get items {
    return _delegate.items
        .map<Reference>(
            (referencePlatform) => Reference._(storage, referencePlatform))
        .toList();
  }

  /// If set, there might be more results for this list.
  ///
  /// Use this token to resume the list with [ListOptions].
  String get nextPageToken => _delegate.nextPageToken;

  /// References to prefixes (sub-folders). You can call list() on them to get
  /// its contents.
  ///
  /// Folders are implicit based on '/' in the object paths. For example, if a
  /// bucket has two objects '/a/b/1' and '/a/b/2', list('/a') will return '/a/b'
  /// as a prefix.
  List<Reference> get prefixes {
    return _delegate.prefixes
        .map<Reference>(
            (referencePlatform) => Reference._(storage, referencePlatform))
        .toList();
  }
}
