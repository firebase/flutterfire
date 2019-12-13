// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';

import 'package:meta/meta.dart' show required;
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../implementations/method_channel_write_batch.dart';
import '../types.dart';

/// The WriteBatch platform interface.
abstract class WriteBatchPlatform extends PlatformInterface {
  /// Constructor
  WriteBatchPlatform() : super(token: _token);

  static final Object _token = Object();

  /// The default instance of [WriteBatchPlatform] to use.
  ///
  /// Platform-specific plugins should override this with their own class
  /// that extends [WriteBatchPlatform] when they register themselves.
  ///
  /// Defaults to [MethodChannelWriteBatch].
  static WriteBatchPlatform get instance => _instance;

  static WriteBatchPlatform _instance = MethodChannelWriteBatch();

  // TODO(amirh): Extract common platform interface logic.
  // https://github.com/flutter/flutter/issues/43368
  static set instance(WriteBatchPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // Actual interface
  /// Creates a new Write Batch
  // Android returns a WriteBatch id int
  Future<PlatformWriteBatch> create(String app) async {
    throw UnimplementedError('WriteBatchPlatform::create() is not implemented');
  }

  /// Commits all of the writes in this write batch as a single atomic unit.
  /// Returns a Promise resolved once all of the writes in the batch have been
  /// successfully written to the backend as an atomic unit.
  /// Note that it won't resolve while you're offline.
  Future<void> commit({
    @required PlatformWriteBatch handle,
  }) async {
    throw UnimplementedError('WriteBatchPlatform::commit() is not implemented');
  }

  /// Deletes the document referred to by the provided [handle] and [path].
  Future<void> delete(
    String app, {
    @required PlatformWriteBatch handle,
    @required String path,
  }) async {
    throw UnimplementedError('WriteBatchPlatform::delete() is not implemented');
  }

  /// Writes to the document referred to by the provided [handle] and [path].
  /// If the document does not exist yet, it will be created.
  /// If you pass [options], the provided data can be merged into the existing document.
  Future<void> set(
    String app, {
    @required PlatformWriteBatch handle,
    @required String path,
    Map<String, dynamic> data,
    PlatformSetOptions options,
  }) async {
    throw UnimplementedError('WriteBatchPlatform::set() is not implemented');
  }

  /// Updates [data] in the document referred to by the provided [handle] and [path].
  /// The update will fail if applied to a document that does not exist.
  Future<void> update(
    String app, {
    @required PlatformWriteBatch handle,
    @required String path,
    Map<String, dynamic> data,
  }) async {
    throw UnimplementedError('WriteBatchPlatform::update() is not implemented');
  }
}
