// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:async';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:flutter/services.dart';

import 'method_channel_firestore.dart';
import 'utils/maps.dart';

/// A [MethodChannelDocumentReference] is an implementation of
/// [DocumentReferencePlatform] that uses [MethodChannel] to communicate with
/// Firebase plugins.
class MethodChannelDocumentReference extends DocumentReferencePlatform {
  /// Creates a [DocumentReferencePlatform] that is implemented using [MethodChannel].
  MethodChannelDocumentReference(
      FirestorePlatform firestore, List<String> pathComponents)
      : assert(firestore != null),
        super(firestore, pathComponents);

  @override
  Future<void> setData(Map<String, dynamic> data, {bool merge = false}) {
    return MethodChannelFirestore.channel.invokeMethod<void>(
      'DocumentReference#setData',
      <String, dynamic>{
        'app': firestore.app.name,
        'path': path,
        'data': FieldValuePlatform.serverDelegates(data),
        'options': <String, bool>{'merge': merge},
      },
    );
  }

  @override
  Future<void> updateData(Map<String, dynamic> data) {
    return MethodChannelFirestore.channel.invokeMethod<void>(
      'DocumentReference#updateData',
      <String, dynamic>{
        'app': firestore.app.name,
        'path': path,
        'data': FieldValuePlatform.serverDelegates(data),
      },
    );
  }

  @override
  Future<DocumentSnapshot> get({Source source = Source.serverAndCache}) async {
    final Map<String, dynamic> data =
        await MethodChannelFirestore.channel.invokeMapMethod<String, dynamic>(
      'DocumentReference#get',
      <String, dynamic>{
        'app': firestore.app.name,
        'path': path,
        'source': getSourceString(source),
      },
    );
    return DocumentSnapshot(
      data['path'],
      asStringKeyedMap(data['data']),
      SnapshotMetadata(data['metadata']['hasPendingWrites'],
          data['metadata']['isFromCache']),
      firestore,
    );
  }

  @override
  Future<void> delete() {
    return MethodChannelFirestore.channel.invokeMethod<void>(
      'DocumentReference#delete',
      <String, dynamic>{'app': firestore.app.name, 'path': path},
    );
  }

  // TODO(jackson): Reduce code duplication with [Query]
  @override
  Stream<DocumentSnapshot> snapshots({bool includeMetadataChanges = false}) {
    assert(includeMetadataChanges != null);
    Future<int> _handle;
    // It's fine to let the StreamController be garbage collected once all the
    // subscribers have cancelled; this analyzer warning is safe to ignore.
    StreamController<DocumentSnapshot> controller; // ignore: close_sinks
    controller = StreamController<DocumentSnapshot>.broadcast(
      onListen: () {
        _handle = MethodChannelFirestore.channel.invokeMethod<int>(
          'DocumentReference#addSnapshotListener',
          <String, dynamic>{
            'app': firestore.app.name,
            'path': path,
            'includeMetadataChanges': includeMetadataChanges,
          },
        ).then<int>((dynamic result) => result);
        _handle.then((int handle) {
          MethodChannelFirestore.documentObservers[handle] = controller;
        });
      },
      onCancel: () {
        _handle.then((int handle) async {
          await MethodChannelFirestore.channel.invokeMethod<void>(
            'removeListener',
            <String, dynamic>{'handle': handle},
          );
          MethodChannelFirestore.documentObservers.remove(handle);
        });
      },
    );
    return controller.stream;
  }
}
