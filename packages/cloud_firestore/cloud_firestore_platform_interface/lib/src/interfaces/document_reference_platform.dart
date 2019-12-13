// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';

import 'package:meta/meta.dart' show required;
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../implementations/method_channel_document_reference.dart';
import '../types.dart';

/// The Document Reference platform interface.
abstract class DocumentReferencePlatform extends PlatformInterface {
  /// Constructor
  DocumentReferencePlatform() : super(token: _token);

  static const Object _token = Object();

  /// The default instance of [DocumentReferencePlatform] to use.
  ///
  /// Platform-specific plugins should override this with their own class
  /// that extends [DocumentReferencePlatform] when they register themselves.
  ///
  /// Defaults to [MethodChannelDocumentReference].
  static DocumentReferencePlatform get instance => _instance;

  static DocumentReferencePlatform _instance = MethodChannelDocumentReference();

  // TODO(amirh): Extract common platform interface logic.
  // https://github.com/flutter/flutter/issues/43368
  static set instance(DocumentReferencePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // Actual interface

  /// A Stream of Document Snapshots.
  /// The snapshot stream is never-ending.
  Stream<PlatformDocumentSnapshot> snapshots(
    String app, {
    @required String path,
    bool includeMetadataChanges,
  }) {
    throw UnimplementedError(
        'DocumentReferencePlatform::snapshots() is not implemented');
  }

  /// Reads the document referred to by this [path].
  /// By default, get() attempts to provide up-to-date data when possible by waiting for
  /// data from the server, but it may return cached data or fail if you are offline and
  /// the server cannot be reached.
  /// This behavior can be altered via the [source] parameter.
  Future<PlatformDocumentSnapshot> get(
    String app, {
    @required String path,
    @required Source source,
  }) async {
    throw UnimplementedError(
        'DocumentReferencePlatform::get() is not implemented');
  }

  /// Deletes the document referred to by this [path].
  Future<void> delete(
    String app, {
    @required String path,
  }) async {
    throw UnimplementedError(
        'DocumentReferencePlatform::delete() is not implemented');
  }

  /// Writes [data] to the document referred to by this [path].
  /// If the document does not yet exist, it will be created.
  /// If you pass [options], the provided data can be merged into an existing document.
  Future<void> set(
    String app, {
    @required String path,
    Map<String, dynamic> data,
    PlatformSetOptions options,
  }) async {
    throw UnimplementedError(
        'DocumentReferencePlatform::set() is not implemented');
  }

  /// Updates [data] in the document referred to by this [path].
  /// The update will fail if applied to a document that does not exist.
  Future<void> update(
    String app, {
    @required String path,
    Map<String, dynamic> data,
  }) async {
    throw UnimplementedError(
        'DocumentReferencePlatform::update() is not implemented');
  }
}
