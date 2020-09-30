// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_platform_interface/src/internal/pointer.dart';

import 'method_channel_firestore.dart';
import 'method_channel_query_snapshot.dart';
import 'utils/source.dart';
import 'utils/exception.dart';

/// An implementation of [QueryPlatform] that uses [MethodChannel] to
/// communicate with Firebase plugins.
class MethodChannelQuery extends QueryPlatform {
  /// Flags whether the current query is for a collection group.
  final bool isCollectionGroupQuery;

  /// Create a [MethodChannelQuery] from a [path] and optional [parameters]
  MethodChannelQuery(
    FirebaseFirestorePlatform _firestore,
    String path, {
    Map<String, dynamic> parameters,
    this.isCollectionGroupQuery = false,
  }) : super(_firestore, parameters) {
    _pointer = Pointer(path);
  }

  Pointer _pointer;

  /// Returns the Document path that that this query relates to.
  String get path {
    return _pointer.path;
  }

  /// Creates a new instance of [MethodChannelQuery], however overrides
  /// any existing [parameters].
  ///
  /// This is in place to ensure that changes to a query don't mutate
  /// other queries.
  MethodChannelQuery _copyWithParameters(Map<String, dynamic> parameters) {
    return MethodChannelQuery(
      firestore,
      _pointer.path,
      isCollectionGroupQuery: isCollectionGroupQuery,
      parameters: Map<String, dynamic>.unmodifiable(
        Map<String, dynamic>.from(this.parameters)..addAll(parameters),
      ),
    );
  }

  @override
  QueryPlatform endAtDocument(List<dynamic> orders, List<dynamic> values) {
    return _copyWithParameters(<String, dynamic>{
      'orderBy': orders,
      'endAt': values,
      'endBefore': null,
    });
  }

  @override
  QueryPlatform endAt(List<dynamic> fields) {
    return _copyWithParameters(<String, dynamic>{
      'endAt': fields,
      'endBefore': null,
    });
  }

  @override
  QueryPlatform endBeforeDocument(List<dynamic> orders, List<dynamic> values) {
    return _copyWithParameters(<String, dynamic>{
      'orderBy': orders,
      'endAt': null,
      'endBefore': values,
    });
  }

  @override
  QueryPlatform endBefore(List<dynamic> fields) {
    return _copyWithParameters(<String, dynamic>{
      'endAt': null,
      'endBefore': fields,
    });
  }

  /// Fetch the documents for this query
  @override
  Future<QuerySnapshotPlatform> get([GetOptions options]) async {
    try {
      final Map<String, dynamic> data = await MethodChannelFirebaseFirestore
          .channel
          .invokeMapMethod<String, dynamic>(
        'Query#get',
        <String, dynamic>{
          'query': this,
          'firestore': firestore,
          'source': getSourceString(options.source),
        },
      );

      return MethodChannelQuerySnapshot(firestore, data);
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  QueryPlatform limit(int limit) {
    return _copyWithParameters(<String, dynamic>{
      'limit': limit,
      'limitToLast': null,
    });
  }

  @override
  QueryPlatform limitToLast(int limit) {
    return _copyWithParameters(<String, dynamic>{
      'limit': null,
      'limitToLast': limit,
    });
  }

  @override
  Stream<QuerySnapshotPlatform> snapshots({
    bool includeMetadataChanges = false,
  }) {
    assert(includeMetadataChanges != null);
    int handle = MethodChannelFirebaseFirestore.nextMethodChannelHandleId;
    Completer<void> onListenComplete = Completer<void>();

    // It's fine to let the StreamController be garbage collected once all the
    // subscribers have cancelled; this analyzer warning is safe to ignore.
    StreamController<QuerySnapshotPlatform> controller; // ignore: close_sinks
    controller = StreamController<QuerySnapshotPlatform>.broadcast(
      onListen: () async {
        MethodChannelFirebaseFirestore.queryObservers[handle] = controller;
        await MethodChannelFirebaseFirestore.channel.invokeMethod<void>(
          'Query#addSnapshotListener',
          <String, dynamic>{
            'query': this,
            'handle': handle,
            'firestore': firestore,
            'includeMetadataChanges': includeMetadataChanges,
          },
        );

        if (!onListenComplete.isCompleted) {
          onListenComplete.complete();
        }
      },
      onCancel: () async {
        await onListenComplete.future;
        await MethodChannelFirebaseFirestore.channel.invokeMethod<void>(
          'Firestore#removeListener',
          <String, dynamic>{'handle': handle},
        );
        MethodChannelFirebaseFirestore.queryObservers.remove(handle);
      },
    );
    return controller.stream;
  }

  @override
  QueryPlatform orderBy(List<List<dynamic>> orders) {
    return _copyWithParameters(<String, dynamic>{'orderBy': orders});
  }

  @override
  QueryPlatform startAfterDocument(List<dynamic> orders, List<dynamic> values) {
    return _copyWithParameters(<String, dynamic>{
      'orderBy': orders,
      'startAt': null,
      'startAfter': values,
    });
  }

  @override
  QueryPlatform startAfter(List<dynamic> fields) {
    return _copyWithParameters(<String, dynamic>{
      'startAt': null,
      'startAfter': fields,
    });
  }

  @override
  QueryPlatform startAtDocument(List<dynamic> orders, List<dynamic> values) {
    return _copyWithParameters(<String, dynamic>{
      'orderBy': orders,
      'startAt': values,
      'startAfter': null,
    });
  }

  @override
  QueryPlatform startAt(List<dynamic> fields) {
    return _copyWithParameters(<String, dynamic>{
      'startAt': fields,
      'startAfter': null,
    });
  }

  @override
  QueryPlatform where(List<List<dynamic>> conditions) {
    return _copyWithParameters(<String, dynamic>{
      'where': conditions,
    });
  }
}
