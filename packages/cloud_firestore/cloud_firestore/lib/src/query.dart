// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// Represents a query over the data at a particular location.
class Query {
  final platform.QueryPlatform _delegate;

  /// The Firestore instance associated with this query
  final Firestore firestore;

  Query._(this._delegate, this.firestore) {
    platform.QueryPlatform.verifyExtends(_delegate);
  }

  List<String> get _pathComponents => _delegate.pathComponents;

  String get _path => _pathComponents.join('/');

  Map<String, dynamic> buildArguments() {
    return _delegate.buildArguments();
  }

  /// Notifies of query results at this location
  Stream<QuerySnapshot> snapshots({bool includeMetadataChanges = false}) =>
      _delegate
          .snapshots(includeMetadataChanges: includeMetadataChanges)
          .map((item) => QuerySnapshot._(item, firestore));

  /// Fetch the documents for this query
  Future<QuerySnapshot> getDocuments({
    platform.Source source = platform.Source.serverAndCache,
  }) async {
    assert(source != null);
    final docs = await _delegate.getDocuments(source: source);
    return QuerySnapshot._(docs, firestore);
  }

  /// Obtains a CollectionReference corresponding to this query's location.
  CollectionReference reference() =>
      CollectionReference._(_delegate.reference(), firestore);

  /// Creates and returns a new [Query] with additional filter on specified
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
  Query where(
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
  }) =>
      Query._(
          _delegate.where(_CodecUtility.valueEncode(field),
              isEqualTo: _CodecUtility.valueEncode(isEqualTo),
              isLessThan: _CodecUtility.valueEncode(isLessThan),
              isLessThanOrEqualTo:
                  _CodecUtility.valueEncode(isLessThanOrEqualTo),
              isGreaterThan: _CodecUtility.valueEncode(isGreaterThan),
              isGreaterThanOrEqualTo:
                  _CodecUtility.valueEncode(isGreaterThanOrEqualTo),
              arrayContainsAny: _CodecUtility.valueEncode(arrayContainsAny),
              arrayContains: _CodecUtility.valueEncode(arrayContains),
              whereIn: _CodecUtility.valueEncode(whereIn),
              isNull: isNull),
          firestore);

  /// Creates and returns a new [Query] that's additionally sorted by the specified
  /// [field].
  /// The field may be a [String] representing a single field name or a [FieldPath].
  ///
  /// After a [FieldPath.documentId] order by call, you cannot add any more [orderBy]
  /// calls.
  /// Furthermore, you may not use [orderBy] on the [FieldPath.documentId] [field] when
  /// using [startAfterDocument], [startAtDocument], [endAfterDocument],
  /// or [endAtDocument] because the order by clause on the document id
  /// is added by these methods implicitly.
  Query orderBy(dynamic field, {bool descending = false}) =>
      Query._(_delegate.orderBy(field, descending: descending), firestore);

  /// Creates and returns a new [Query] that starts after the provided document
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
  Query startAfterDocument(DocumentSnapshot documentSnapshot) => Query._(
      _delegate.startAfterDocument(
          _PlatformUtils.toPlatformDocumentSnapshot(documentSnapshot)),
      firestore);

  /// Creates and returns a new [Query] that starts at the provided document
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
  Query startAtDocument(DocumentSnapshot documentSnapshot) => Query._(
      _delegate.startAtDocument(
          _PlatformUtils.toPlatformDocumentSnapshot(documentSnapshot)),
      firestore);

  /// Takes a list of [values], creates and returns a new [Query] that starts
  /// after the provided fields relative to the order of the query.
  ///
  /// The [values] must be in order of [orderBy] filters.
  ///
  /// Cannot be used in combination with [startAt], [startAfterDocument], or
  /// [startAtDocument], but can be used in combination with [endAt],
  /// [endBefore], [endAtDocument] and [endBeforeDocument].
  Query startAfter(List<dynamic> values) =>
      Query._(_delegate.startAfter(values), firestore);

  /// Takes a list of [values], creates and returns a new [Query] that starts at
  /// the provided fields relative to the order of the query.
  ///
  /// The [values] must be in order of [orderBy] filters.
  ///
  /// Cannot be used in combination with [startAfter], [startAfterDocument],
  /// or [startAtDocument], but can be used in combination with [endAt],
  /// [endBefore], [endAtDocument] and [endBeforeDocument].
  Query startAt(List<dynamic> values) =>
      Query._(_delegate.startAt(values), firestore);

  /// Creates and returns a new [Query] that ends at the provided document
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
  Query endAtDocument(DocumentSnapshot documentSnapshot) => Query._(
      _delegate.endAtDocument(
          _PlatformUtils.toPlatformDocumentSnapshot(documentSnapshot)),
      firestore);

  /// Takes a list of [values], creates and returns a new [Query] that ends at the
  /// provided fields relative to the order of the query.
  ///
  /// The [values] must be in order of [orderBy] filters.
  ///
  /// Cannot be used in combination with [endBefore], [endBeforeDocument], or
  /// [endAtDocument], but can be used in combination with [startAt],
  /// [startAfter], [startAtDocument] and [startAfterDocument].
  Query endAt(List<dynamic> values) =>
      Query._(_delegate.endAt(values), firestore);

  /// Creates and returns a new [Query] that ends before the provided document
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
  Query endBeforeDocument(DocumentSnapshot documentSnapshot) => Query._(
      _delegate.endBeforeDocument(
          _PlatformUtils.toPlatformDocumentSnapshot(documentSnapshot)),
      firestore);

  /// Takes a list of [values], creates and returns a new [Query] that ends before
  /// the provided fields relative to the order of the query.
  ///
  /// The [values] must be in order of [orderBy] filters.
  ///
  /// Cannot be used in combination with [endAt], [endBeforeDocument], or
  /// [endBeforeDocument], but can be used in combination with [startAt],
  /// [startAfter], [startAtDocument] and [startAfterDocument].
  Query endBefore(List<dynamic> values) =>
      Query._(_delegate.endBefore(values), firestore);

  /// Creates and returns a new Query that's additionally limited to only return up
  /// to the specified number of documents.
  Query limit(int length) => Query._(_delegate.limit(length), firestore);
}
