// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_web/src/utils/codec_utility.dart';
import 'package:cloud_firestore_web/src/utils/exception.dart';

import 'interop/firestore.dart' as firestore_interop;
import 'utils/web_utils.dart';

/// Web implementation of Firestore [QueryPlatform].
class QueryWeb extends QueryPlatform {
  final firestore_interop.Query _webQuery;
  final FirebaseFirestorePlatform _firestore;
  final String _path;

  /// Flags whether the current query is for a collection group.
  @override
  final bool isCollectionGroupQuery;

  /// Builds an instance of [QueryWeb] delegating to a package:firebase [Query]
  /// to delegate queries to underlying firestore web plugin
  QueryWeb(
    this._firestore,
    this._path,
    this._webQuery, {
    Map<String, dynamic>? parameters,
    this.isCollectionGroupQuery = false,
  }) : super(_firestore, parameters);

  QueryWeb _copyWithParameters(Map<String, dynamic> parameters) {
    return QueryWeb(_firestore, _path, _webQuery,
        isCollectionGroupQuery: isCollectionGroupQuery,
        parameters: Map<String, dynamic>.unmodifiable(
          Map<String, dynamic>.from(this.parameters)..addAll(parameters),
        ));
  }

  /// Builds a [web.Query] from given [parameters].
  firestore_interop.Query _buildWebQueryWithParameters() {
    firestore_interop.Query query = _webQuery;

    for (final List<dynamic> order in parameters['orderBy']) {
      query = query.orderBy(
          CodecUtility.valueEncode(order[0]), order[1] ? 'desc' : 'asc');
    }

    if (parameters['startAt'] != null) {
      query = query.startAt(
          fieldValues: CodecUtility.valueEncode(parameters['startAt']));
    }

    if (parameters['startAfter'] != null) {
      query = query.startAfter(
          fieldValues: CodecUtility.valueEncode(parameters['startAfter']));
    }

    if (parameters['endAt'] != null) {
      query = query.endAt(
          fieldValues: CodecUtility.valueEncode(parameters['endAt']));
    }

    if (parameters['endBefore'] != null) {
      query = query.endBefore(
          fieldValues: CodecUtility.valueEncode(parameters['endBefore']));
    }

    if (parameters['limit'] != null) {
      query = query.limit(parameters['limit']);
    }

    if (parameters['limitToLast'] != null) {
      query = query.limitToLast(parameters['limitToLast']);
    }

    for (final List<dynamic> condition in parameters['where']) {
      dynamic fieldPath = CodecUtility.valueEncode(condition[0]);
      String opStr = condition[1];
      dynamic value = CodecUtility.valueEncode(condition[2]);

      query = query.where(fieldPath, opStr, value);
    }

    return query;
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

  @override
  Future<QuerySnapshotPlatform> get(
      [GetOptions options = const GetOptions()]) async {
    try {
      return convertWebQuerySnapshot(firestore,
          await _buildWebQueryWithParameters().get(convertGetOptions(options)));
    } catch (e) {
      throw getFirebaseException(e);
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
    Stream<firestore_interop.QuerySnapshot> querySnapshots;
    if (includeMetadataChanges) {
      querySnapshots = _buildWebQueryWithParameters().onSnapshotMetadata;
    } else {
      querySnapshots = _buildWebQueryWithParameters().onSnapshot;
    }
    return querySnapshots
        .map((webQuerySnapshot) =>
            convertWebQuerySnapshot(firestore, webQuerySnapshot))
        .handleError((e) {
      throw getFirebaseException(e);
    });
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
