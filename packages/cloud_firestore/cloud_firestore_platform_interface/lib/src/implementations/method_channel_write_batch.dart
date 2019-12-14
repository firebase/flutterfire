// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show required, visibleForTesting;

import '../types.dart';
import '../interfaces/write_batch_platform.dart';

class MethodChannelWriteBatch extends WriteBatchPlatform {
  /// Constructor
  MethodChannelWriteBatch(StandardMessageCodec codec) {
    MethodChannelWriteBatch._channel = MethodChannel(
      'plugins.flutter.io/cloud_firestore',
      StandardMethodCodec(codec),
    );
  }

  @visibleForTesting
  static MethodChannel get channel => MethodChannelWriteBatch._channel;
  static MethodChannel _channel;

  /// Creates a new Write Batch
  // Android returns a WriteBatch id int
  @override
  Future<PlatformWriteBatch> create(String app) {
    return channel.invokeMethod<dynamic>(
        'WriteBatch#create', <String, dynamic>{'app': app}).then((id) => PlatformWriteBatch(writeBatchId: id));
  }

  /// Commits all of the writes in this write batch as a single atomic unit.
  /// Returns a Promise resolved once all of the writes in the batch have been
  /// successfully written to the backend as an atomic unit.
  /// Note that it won't resolve while you're offline.
  @override
  Future<void> commit({
    @required PlatformWriteBatch handle,
  }) async {
    return channel.invokeMethod<void>(
        'WriteBatch#commit', <String, dynamic>{'handle': handle.writeBatchId});
  }

  /// Deletes the document referred to by the provided [handle] and [path].
  @override
  Future<void> delete(
    String app, {
    @required PlatformWriteBatch handle,
    @required String path,
  }) async {
    return channel.invokeMethod<void>(
      'WriteBatch#delete',
      <String, dynamic>{
        'app': app,
        'handle': handle.writeBatchId,
        'path': path,
      },
    );
  }

  /// Writes to the document referred to by the provided [handle] and [path].
  /// If the document does not exist yet, it will be created.
  /// If you pass [options], the provided data can be merged into the existing document.
  @override
  Future<void> set(
    String app, {
    @required PlatformWriteBatch handle,
    @required String path,
    Map<String, dynamic> data,
    PlatformSetOptions options,
  }) async {
    return channel.invokeMethod<void>(
      'WriteBatch#setData',
      <String, dynamic>{
        'app': app,
        'handle': handle.writeBatchId,
        'path': path,
        'data': data,
        'options': options.asMap(),
      },
    );
  }

  /// Updates [data] in the document referred to by the provided [handle] and [path].
  /// The update will fail if applied to a document that does not exist.
  @override
  Future<void> update(
    String app, {
    @required PlatformWriteBatch handle,
    @required String path,
    Map<String, dynamic> data,
  }) async {
    return channel.invokeMethod<void>(
      'WriteBatch#updateData',
      <String, dynamic>{
        'app': app,
        'handle': handle.writeBatchId,
        'path': path,
        'data': data,
      },
    );
  }
}
