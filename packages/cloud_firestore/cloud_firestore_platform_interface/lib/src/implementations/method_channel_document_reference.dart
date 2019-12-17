// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show required, visibleForTesting;

import './multi_method_channel.dart';
import '../interfaces/document_reference_platform.dart';
import '../types.dart';

class MethodChannelDocumentReference extends DocumentReferencePlatform {
  MethodChannelDocumentReference(MultiMethodChannel channel) {
    MethodChannelDocumentReference._channel = channel;
    MethodChannelDocumentReference._channel.addMethodCallHandler('DocumentSnapshot', this._handleDocumentSnapshot);
  }

  @visibleForTesting
  static MultiMethodChannel get channel => MethodChannelDocumentReference._channel;
  static MultiMethodChannel _channel;

  void _handleDocumentSnapshot(MethodCall call) {
    final int handle = call.arguments['handle'];
    _documentSnapshotStreamControllers[handle].add(
      PlatformDocumentSnapshot(
          path: call.arguments['path'],
          data: call.arguments['data']?.cast<String, dynamic>(),
          metadata: PlatformSnapshotMetadata(
              hasPendingWrites: call.arguments['metadata']['hasPendingWrites'],
              isFromCache: call.arguments['metadata']['isFromCache'],
            ),
        )
    );
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
  }) {
    return channel.invokeMapMethod<String, dynamic>(
      'DocumentReference#get',
      <String, dynamic>{
        'app': app,
        'path': path,
        'source': getSourceString(source),
      },
    ).then((Map<String, dynamic> data) {
      return PlatformDocumentSnapshot(
          path: data['path'],
          data: data['data']?.cast<String, dynamic>(),
          metadata: PlatformSnapshotMetadata(
              hasPendingWrites: data['metadata']['hasPendingWrites'],
              isFromCache: data['metadata']['isFromCache'],
            ),
        );
    });
  }

  /// Deletes the document referred to by this [path].
  Future<void> delete(
    String app, {
    @required String path,
  }) {
    return channel.invokeMethod<void>(
      'DocumentReference#delete',
      <String, dynamic>{'app': app, 'path': path},
    );
  }

  /// Writes [data] to the document referred to by this [path].
  /// If the document does not yet exist, it will be created.
  /// If you pass [options], the provided data can be merged into an existing document.
  Future<void> set(
    String app, {
    @required String path,
    Map<String, dynamic> data,
    PlatformSetOptions options,
  }) {
    return channel.invokeMethod<void>(
      'DocumentReference#setData',
      <String, dynamic>{
        'app': app,
        'path': path,
        'data': data,
        'options': options.asMap(),
      },
    );
  }

  /// Updates [data] in the document referred to by this [path].
  /// The update will fail if applied to a document that does not exist.
  Future<void> update(
    String app, {
    @required String path,
    Map<String, dynamic> data,
  }) {
    return channel.invokeMethod<void>(
      'DocumentReference#updateData',
      <String, dynamic>{
        'app': app,
        'path': path,
        'data': data,
      },
    );
  }

  // Snapshots

  static final Map<int, StreamController<PlatformDocumentSnapshot>> _documentSnapshotStreamControllers = <int, StreamController<PlatformDocumentSnapshot>>{};

  /// A Stream of QuerySnapshots.
  /// The snapshot stream is never-ending.
  Stream<PlatformDocumentSnapshot> snapshots(
    String app, {
    @required String path,
    bool includeMetadataChanges,
  }) {
    assert(includeMetadataChanges != null);
    Future<int> _handle;
    // It's fine to let the StreamController be garbage collected once all the
    // subscribers have cancelled; this analyzer warning is safe to ignore.
    StreamController<PlatformDocumentSnapshot> controller; // ignore: close_sinks
    controller = StreamController<PlatformDocumentSnapshot>.broadcast(
      onListen: () {
        _handle = _addDocumentReferenceSnapshotListener(
          app,
          path: path,
          includeMetadataChanges: includeMetadataChanges,
        ).then<int>((dynamic result) => result);
        _handle.then((int handle) {
          _documentSnapshotStreamControllers[handle] = controller;
        });
      },
      onCancel: () {
        _handle.then((int handle) async {
          await _removeListener(handle);
          _documentSnapshotStreamControllers.remove(handle);
        });
      },
    );
    return controller.stream;
  }

  Future<int> _addDocumentReferenceSnapshotListener(
    String app, {
    @required String path,
    bool includeMetadataChanges,
  }) {
    return channel.invokeMethod<int>(
      'DocumentReference#addSnapshotListener',
      <String, dynamic>{
        'app': app,
        'path': path,
        'includeMetadataChanges': includeMetadataChanges,
      },
    );
  }

  Future<void> _removeListener(int handle) {
    return channel.invokeMethod<void>(
      'removeListener',
      <String, dynamic>{'handle': handle},
    );
  }
}
