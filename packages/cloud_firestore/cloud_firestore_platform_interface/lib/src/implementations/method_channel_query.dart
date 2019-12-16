// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show visibleForTesting, required;

import './multi_method_channel.dart';

import '../interfaces/query_platform.dart';
import '../types.dart';

class MethodChannelQuery extends QueryPlatform {
  MethodChannelQuery(MultiMethodChannel channel) {
    MethodChannelQuery._channel = channel;
    MethodChannelQuery._channel.addMethodCallHandler('QuerySnapshot', this._handleQuerySnapshot);
  }

  @visibleForTesting
  static MultiMethodChannel get channel => MethodChannelQuery._channel;
  static MultiMethodChannel _channel;

  void _handleQuerySnapshot(MethodCall call) {
    final int handle = call.arguments['handle'];
    _querySnapshotStreamControllers[handle].add(PlatformQuerySnapshot(data: call.arguments));
  }

  /// What does this method correspond to in the Firebase API?
  Future<PlatformQuerySnapshot> getDocuments(
    String app, {
    @required String path,
    bool isCollectionGroup,
    Map<String, dynamic> parameters,
    Source source,
  }) {
    return channel.invokeMapMethod<String, dynamic>(
      'Query#getDocuments',
      <String, dynamic>{
        'app': app,
        'path': path,
        'isCollectionGroup': isCollectionGroup,
        'parameters': parameters,
        'source': getSourceString(source),
      },
    ).then((Map<String, dynamic> response) {
      return PlatformQuerySnapshot(data: response);
    });
  }

  // Snapshots

  static final Map<int, StreamController<PlatformQuerySnapshot>> _querySnapshotStreamControllers = <int, StreamController<PlatformQuerySnapshot>>{};

  /// A Stream of QuerySnapshots.
  /// The snapshot stream is never-ending.
  Stream<PlatformQuerySnapshot> snapshots(
    String app, {
    @required String path,
    bool isCollectionGroup,
    Map<String, dynamic> parameters,
    bool includeMetadataChanges,
  }) {
    assert(includeMetadataChanges != null);
    Future<int> _handle;
    // It's fine to let the StreamController be garbage collected once all the
    // subscribers have cancelled; this analyzer warning is safe to ignore.
    StreamController<PlatformQuerySnapshot> controller; // ignore: close_sinks
    controller = StreamController<PlatformQuerySnapshot>.broadcast(
      onListen: () {
        _handle = _addQuerySnapshotListener(
          app,
          path: path,
          isCollectionGroup: isCollectionGroup,
          parameters: parameters,
          includeMetadataChanges: includeMetadataChanges,
        ).then<int>((dynamic result) => result);
        _handle.then((int handle) {
          _querySnapshotStreamControllers[handle] = controller;
        });
      },
      onCancel: () {
        _handle.then((int handle) async {
          await _removeListener(handle);
          _querySnapshotStreamControllers.remove(handle);
        });
      },
    );
    return controller.stream;
  }

  Future<int> _addQuerySnapshotListener(
    String app, {
    @required String path,
    bool isCollectionGroup,
    Map<String, dynamic> parameters,
    bool includeMetadataChanges,
  }) {
    return channel.invokeMethod<int>(
      'Query#addSnapshotListener',
      <String, dynamic>{
        'app': app,
        'path': path,
        'isCollectionGroup': isCollectionGroup,
        'parameters': parameters,
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
