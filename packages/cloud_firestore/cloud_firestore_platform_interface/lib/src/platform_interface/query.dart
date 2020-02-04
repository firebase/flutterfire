// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart' show required;
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

/// Represents a query over the data at a particular location.
abstract class QueryPlatform extends PlatformInterface {
  /// Create a [QueryPlatform] instance
  QueryPlatform({
    @required this.firestore,
    @required List<String> pathComponents,
    bool isCollectionGroup = false,
    Map<String, dynamic> parameters,
  })  : pathComponents = pathComponents,
        isCollectionGroup = isCollectionGroup,
        parameters = parameters ??
            Map<String, dynamic>.unmodifiable(<String, dynamic>{
              'where': List<List<dynamic>>.unmodifiable(<List<dynamic>>[]),
              'orderBy': List<List<dynamic>>.unmodifiable(<List<dynamic>>[]),
            }),
        assert(firestore != null),
        assert(pathComponents != null),
        super(token: _token);

  static final Object _token = Object();

  /// Throws an [AssertionError] if [instance] does not extend
  /// [QueryPlatform].
  ///
  /// This is used by the app-facing [Query] to ensure that
  /// the object in which it's going to delegate calls has been
  /// constructed properly.
  static verifyExtends(QueryPlatform instance) {
    if (instance is! CollectionReferencePlatform) {
      PlatformInterface.verifyToken(instance, _token);
    }
  }

  /// The Firestore instance associated with this query
  final FirestorePlatform firestore;

  /// Represents the components of the path referenced by `this` [QueryPlatform]
  final List<String> pathComponents;

  /// Map of the parameters used for filtering and sorting documents
  final Map<String, dynamic> parameters;

  /// Indicates if `this` [QueryPlatform] is for a collection group
  final bool isCollectionGroup;

  /// Represents the path referenced by `this` [QueryPlatform]
  String get path => pathComponents.join('/');

  /// Returns a copy of this query, with additional [parameters].
  QueryPlatform copyWithParameters(Map<String, dynamic> parameters) {
    throw UnimplementedError("copyWithParameters() is not implemented");
  }

  /// Builds a map of all the parameters used and appends the [QueryPlatform.path]
  Map<String, dynamic> buildArguments() {
    throw UnimplementedError("buildArguments() is not imlpmented");
  }

  /// Notifies of query results at this location
  Stream<QuerySnapshotPlatform> snapshots({
    bool includeMetadataChanges = false,
  }) {
    throw UnimplementedError("snapshots() is not implemented");
  }

  /// Fetch the documents for this query
  Future<QuerySnapshotPlatform> getDocuments({
    Source source = Source.serverAndCache,
  }) async {
    throw UnimplementedError("getDocuments() is not implemented");
  }

  /// Obtains a CollectionReference corresponding to this query's location.
  CollectionReferencePlatform reference() =>
      firestore.collection(pathComponents.join("/"));

  /// Creates and returns a new [QueryPlatform] with additional filter on specified
  /// [field]. [field] refers to a field in a document.
  ///
  /// The [field] may be a [String] consisting of a single field name
  /// (referring to a top level field in the document),
  /// or a series of field names separated by dots '.'
  /// (referring to a nested field in the document).
  /// Alternatively, the [field] can also be a [FieldPath].
  ///
  /// Only documents satisfying provided condition are included in the result
  /// set.
  QueryPlatform where(
    dynamic field, {
    dynamic isEqualTo,
    dynamic isLessThan,
    dynamic isLessThanOrEqualTo,
    dynamic isGreaterThan,
    dynamic isGreaterThanOrEqualTo,
    dynamic arrayContains,
    List<dynamic> arrayContainsAny,
    List<dynamic> whereIn,
    bool isNull,
  }) {
    throw UnimplementedError("where() is not implemented");
  }

  /// Creates and returns a new [QueryPlatform] that's additionally sorted by the specified
  /// [field].
  /// The field may be a [String] representing a single field name or a [FieldPath].
  ///
  /// After a [FieldPath.documentId] order by call, you cannot add any more [orderBy]
  /// calls.
  /// Furthermore, you may not use [orderBy] on the [FieldPath.documentId] [field] when
  /// using [startAfterDocument], [startAtDocument], [endAfterDocument],
  /// or [endAtDocument] because the order by clause on the document id
  /// is added by these methods implicitly.
  QueryPlatform orderBy(
    dynamic field, {
    bool descending = false,
  }) {
    throw UnimplementedError("orderBy() is not implemented");
  }

  /// Creates and returns a new [QueryPlatform] that starts after the provided document
  /// (exclusive). The starting position is relative to the order of the query.
  /// The document must contain all of the fields provided in the orderBy of
  /// this query.
  ///
  /// Cannot be used in combination with [startAtDocument], [startAt], or
  /// [startAfter], but can be used in combination with [endAt],
  /// [endBefore], [endAtDocument] and [endBeforeDocument].
  ///
  /// See also:
  ///
  ///  * [endAfterDocument] for a query that ends after a document.
  ///  * [startAtDocument] for a query that starts at a document.
  ///  * [endAtDocument] for a query that ends at a document.
  QueryPlatform startAfterDocument(DocumentSnapshotPlatform documentSnapshot) {
    throw UnimplementedError("startAfterDocument() is not implemented");
  }

  /// Creates and returns a new [QueryPlatform] that starts at the provided document
  /// (inclusive). The starting position is relative to the order of the query.
  /// The document must contain all of the fields provided in the orderBy of
  /// this query.
  ///
  /// Cannot be used in combination with [startAfterDocument], [startAfter], or
  /// [startAt], but can be used in combination with [endAt],
  /// [endBefore], [endAtDocument] and [endBeforeDocument].
  ///
  /// See also:
  ///
  ///  * [startAfterDocument] for a query that starts after a document.
  ///  * [endAtDocument] for a query that ends at a document.
  ///  * [endBeforeDocument] for a query that ends before a document.
  QueryPlatform startAtDocument(DocumentSnapshotPlatform documentSnapshot) {
    throw UnimplementedError("startAtDocument() is not implemented");
  }

  /// Takes a list of [values], creates and returns a new [QueryPlatform] that starts
  /// after the provided fields relative to the order of the query.
  ///
  /// The [values] must be in order of [orderBy] filters.
  ///
  /// Cannot be used in combination with [startAt], [startAfterDocument], or
  /// [startAtDocument], but can be used in combination with [endAt],
  /// [endBefore], [endAtDocument] and [endBeforeDocument].
  QueryPlatform startAfter(List<dynamic> values) {
    throw UnimplementedError("startAfter() is not implemented");
  }

  /// Takes a list of [values], creates and returns a new [QueryPlatform] that starts at
  /// the provided fields relative to the order of the query.
  ///
  /// The [values] must be in order of [orderBy] filters.
  ///
  /// Cannot be used in combination with [startAfter], [startAfterDocument],
  /// or [startAtDocument], but can be used in combination with [endAt],
  /// [endBefore], [endAtDocument] and [endBeforeDocument].
  QueryPlatform startAt(List<dynamic> values) {
    throw UnimplementedError("startAt() is not implemented");
  }

  /// Creates and returns a new [QueryPlatform] that ends at the provided document
  /// (inclusive). The end position is relative to the order of the query.
  /// The document must contain all of the fields provided in the orderBy of
  /// this query.
  ///
  /// Cannot be used in combination with [endBefore], [endBeforeDocument], or
  /// [endAt], but can be used in combination with [startAt],
  /// [startAfter], [startAtDocument] and [startAfterDocument].
  ///
  /// See also:
  ///
  ///  * [startAfterDocument] for a query that starts after a document.
  ///  * [startAtDocument] for a query that starts at a document.
  ///  * [endBeforeDocument] for a query that ends before a document.
  QueryPlatform endAtDocument(DocumentSnapshotPlatform documentSnapshot) {
    throw UnimplementedError("endAtDocument() is not implemented");
  }

  /// Takes a list of [values], creates and returns a new [QueryPlatform] that ends at the
  /// provided fields relative to the order of the query.
  ///
  /// The [values] must be in order of [orderBy] filters.
  ///
  /// Cannot be used in combination with [endBefore], [endBeforeDocument], or
  /// [endAtDocument], but can be used in combination with [startAt],
  /// [startAfter], [startAtDocument] and [startAfterDocument].
  QueryPlatform endAt(List<dynamic> values) {
    throw UnimplementedError("endAt() is not implemented");
  }

  /// Creates and returns a new [QueryPlatform] that ends before the provided document
  /// (exclusive). The end position is relative to the order of the query.
  /// The document must contain all of the fields provided in the orderBy of
  /// this query.
  ///
  /// Cannot be used in combination with [endAt], [endBefore], or
  /// [endAtDocument], but can be used in combination with [startAt],
  /// [startAfter], [startAtDocument] and [startAfterDocument].
  ///
  /// See also:
  ///
  ///  * [startAfterDocument] for a query that starts after document.
  ///  * [startAtDocument] for a query that starts at a document.
  ///  * [endAtDocument] for a query that ends at a document.
  QueryPlatform endBeforeDocument(DocumentSnapshotPlatform documentSnapshot) {
    throw UnimplementedError("endBeforeDocument() is not implemented");
  }

  /// Takes a list of [values], creates and returns a new [QueryPlatform] that ends before
  /// the provided fields relative to the order of the query.
  ///
  /// The [values] must be in order of [orderBy] filters.
  ///
  /// Cannot be used in combination with [endAt], [endBeforeDocument], or
  /// [endBeforeDocument], but can be used in combination with [startAt],
  /// [startAfter], [startAtDocument] and [startAfterDocument].
  QueryPlatform endBefore(List<dynamic> values) {
    throw UnimplementedError("endBefore() is not implemented");
  }

  /// Creates and returns a new Query that's additionally limited to only return up
  /// to the specified number of documents.
  QueryPlatform limit(int length) {
    assert(!parameters.containsKey('limit'));
    return copyWithParameters(<String, dynamic>{'limit': length});
  }
}
