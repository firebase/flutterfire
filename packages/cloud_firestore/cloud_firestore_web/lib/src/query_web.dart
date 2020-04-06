// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_web/src/utils/codec_utility.dart';
import 'package:firebase/firestore.dart' as web;

import 'package:cloud_firestore_web/src/utils/document_reference_utils.dart';

/// Web implementation for firestore [QueryPlatform]
class QueryWeb extends QueryPlatform {
  final web.Query _webQuery;
  final FirestorePlatform _firestore;
  final bool _isCollectionGroup;
  final String _path;
  final List<dynamic> _orderByKeys;
  static const _kChangeTypeAdded = "added";
  static const _kChangeTypeModified = "modified";
  static const _kChangeTypeRemoved = "removed";

  /// Builds an instance of [QueryWeb] delegating to a package:firebase [Query]
  /// to delegate queries to underlying firestore web plugin
  QueryWeb(
    this._firestore,
    this._path,
    this._webQuery, {
    bool isCollectionGroup,
    List<dynamic> orderByKeys,
  })  : this._isCollectionGroup = isCollectionGroup ?? false,
        this._orderByKeys = orderByKeys ?? [],
        super(
          firestore: _firestore,
          pathComponents: _path.split('/'),
          isCollectionGroup: isCollectionGroup,
        );

  @override
  Stream<QuerySnapshotPlatform> snapshots({
    bool includeMetadataChanges = false,
  }) {
    assert(_webQuery != null);
    Stream<web.QuerySnapshot> querySnapshots = _webQuery.onSnapshot;
    if (includeMetadataChanges) {
      querySnapshots = _webQuery.onSnapshotMetadata;
    }
    return querySnapshots.map(_webQuerySnapshotToQuerySnapshot);
  }

  @override
  Future<QuerySnapshotPlatform> getDocuments({
    Source source = Source.serverAndCache,
  }) async {
    assert(_webQuery != null);
    return _webQuerySnapshotToQuerySnapshot(await _webQuery.get());
  }

  @override
  Map<String, dynamic> buildArguments() => Map();

  @override
  QueryPlatform endAt(List values) => QueryWeb(
        this._firestore,
        this._path,
        _webQuery != null
            ? _webQuery.endAt(fieldValues: CodecUtility.valueEncode(values))
            : null,
        isCollectionGroup: _isCollectionGroup,
      );

  @override
  QueryPlatform endAtDocument(DocumentSnapshotPlatform documentSnapshot) {
    assert(_webQuery != null && _orderByKeys.isNotEmpty);
    return QueryWeb(
        this._firestore,
        this._path,
        _webQuery.endAt(
          fieldValues: CodecUtility.valueEncode(
            _orderByKeys.map((key) => documentSnapshot.data[key]).toList(),
          ),
        ),
        isCollectionGroup: _isCollectionGroup);
  }

  @override
  QueryPlatform endBefore(List values) => QueryWeb(
        this._firestore,
        this._path,
        _webQuery != null
            ? _webQuery.endBefore(fieldValues: CodecUtility.valueEncode(values))
            : null,
        isCollectionGroup: _isCollectionGroup,
      );

  @override
  QueryPlatform endBeforeDocument(DocumentSnapshotPlatform documentSnapshot) {
    assert(_webQuery != null && _orderByKeys.isNotEmpty);
    return QueryWeb(
        this._firestore,
        this._path,
        _webQuery.endBefore(
          fieldValues: CodecUtility.valueEncode(
            _orderByKeys.map((key) => documentSnapshot.data[key]).toList(),
          ),
        ),
        isCollectionGroup: _isCollectionGroup);
  }

  @override
  FirestorePlatform get firestore => _firestore;

  @override
  bool get isCollectionGroup => _isCollectionGroup;

  @override
  QueryPlatform limit(int length) => QueryWeb(
        this._firestore,
        this._path,
        _webQuery != null ? _webQuery.limit(length) : null,
        orderByKeys: _orderByKeys,
        isCollectionGroup: _isCollectionGroup,
      );

  @override
  QueryPlatform orderBy(
    field, {
    bool descending = false,
  }) {
    dynamic usableField = field;
    if (field == FieldPath.documentId) {
      usableField = web.FieldPath.documentId();
    }
    return QueryWeb(
      this._firestore,
      this._path,
      _webQuery.orderBy(usableField, descending ? "desc" : "asc"),
      orderByKeys: _orderByKeys..add(usableField),
      isCollectionGroup: _isCollectionGroup,
    );
  }

  @override
  String get path => this._path;

  @override
  List<String> get pathComponents => this._path.split("/");

  @override
  CollectionReferencePlatform reference() => firestore.collection(_path);

  @override
  QueryPlatform startAfter(List values) => QueryWeb(
        this._firestore,
        this._path,
        _webQuery.startAfter(fieldValues: CodecUtility.valueEncode(values)),
        orderByKeys: _orderByKeys,
        isCollectionGroup: _isCollectionGroup,
      );

  @override
  QueryPlatform startAfterDocument(DocumentSnapshotPlatform documentSnapshot) {
    assert(_webQuery != null && _orderByKeys.isNotEmpty);
    return QueryWeb(
        this._firestore,
        this._path,
        _webQuery.startAfter(
          fieldValues: CodecUtility.valueEncode(
            _orderByKeys.map((key) => documentSnapshot.data[key]).toList(),
          ),
        ),
        orderByKeys: _orderByKeys,
        isCollectionGroup: _isCollectionGroup);
  }

  @override
  QueryPlatform startAt(List values) => QueryWeb(
        this._firestore,
        this._path,
        _webQuery.startAt(fieldValues: CodecUtility.valueEncode(values)),
        orderByKeys: _orderByKeys,
        isCollectionGroup: _isCollectionGroup,
      );

  @override
  QueryPlatform startAtDocument(DocumentSnapshotPlatform documentSnapshot) {
    assert(_webQuery != null && _orderByKeys.isNotEmpty);
    return QueryWeb(
      this._firestore,
      this._path,
      _webQuery.startAt(
        fieldValues: CodecUtility.valueEncode(
          _orderByKeys.map((key) => documentSnapshot.data[key]).toList(),
        ),
      ),
      orderByKeys: _orderByKeys,
      isCollectionGroup: _isCollectionGroup,
    );
  }

  @override
  QueryPlatform where(
    field, {
    isEqualTo,
    isLessThan,
    isLessThanOrEqualTo,
    isGreaterThan,
    isGreaterThanOrEqualTo,
    arrayContains,
    List arrayContainsAny,
    List whereIn,
    bool isNull,
  }) {
    assert(field is String || field is FieldPath,
        'Supported [field] types are [String] and [FieldPath].');
    assert(_webQuery != null);
    dynamic usableField = CodecUtility.valueEncode(field);
    if (field == FieldPath.documentId) {
      usableField = web.FieldPath.documentId();
    }
    web.Query query = _webQuery;

    if (isEqualTo != null) {
      query =
          query.where(usableField, "==", CodecUtility.valueEncode(isEqualTo));
    }
    if (isLessThan != null) {
      query =
          query.where(usableField, "<", CodecUtility.valueEncode(isLessThan));
    }
    if (isLessThanOrEqualTo != null) {
      query = query.where(
          usableField, "<=", CodecUtility.valueEncode(isLessThanOrEqualTo));
    }
    if (isGreaterThan != null) {
      query = query.where(
          usableField, ">", CodecUtility.valueEncode(isGreaterThan));
    }
    if (isGreaterThanOrEqualTo != null) {
      query = query.where(
          usableField, ">=", CodecUtility.valueEncode(isGreaterThanOrEqualTo));
    }
    if (arrayContains != null) {
      query = query.where(usableField, "array-contains",
          CodecUtility.valueEncode(arrayContains));
    }
    if (arrayContainsAny != null) {
      assert(arrayContainsAny.length <= 10,
          "array contains can have maximum of 10 items");
      query = query.where(usableField, "array-contains-any",
          CodecUtility.valueEncode(arrayContainsAny));
    }
    if (whereIn != null) {
      assert(
          whereIn.length <= 10, "array contains can have maximum of 10 items");
      query = query.where(usableField, "in", CodecUtility.valueEncode(whereIn));
    }
    if (isNull != null) {
      assert(
          isNull,
          'isNull can only be set to true. '
          'Use isEqualTo to filter on non-null values.');
      query = query.where(usableField, "==", null);
    }
    return QueryWeb(this._firestore, this._path, query,
        orderByKeys: _orderByKeys, isCollectionGroup: _isCollectionGroup);
  }

  QuerySnapshotPlatform _webQuerySnapshotToQuerySnapshot(
    web.QuerySnapshot webSnapshot,
  ) {
    return QuerySnapshotPlatform(
        webSnapshot.docs
            .map((webSnapshot) =>
                fromWebDocumentSnapshotToPlatformDocumentSnapshot(
                    webSnapshot, this._firestore))
            .toList(),
        webSnapshot.docChanges().map(_webChangeToChange).toList(),
        _webMetadataToMetada(webSnapshot.metadata));
  }

  DocumentChangePlatform _webChangeToChange(web.DocumentChange webChange) {
    return DocumentChangePlatform(
        _fromString(webChange.type),
        webChange.oldIndex,
        webChange.newIndex,
        fromWebDocumentSnapshotToPlatformDocumentSnapshot(
            webChange.doc, this._firestore));
  }

  DocumentChangeType _fromString(String item) {
    switch (item.toLowerCase()) {
      case _kChangeTypeAdded:
        return DocumentChangeType.added;
      case _kChangeTypeModified:
        return DocumentChangeType.modified;
      case _kChangeTypeRemoved:
        return DocumentChangeType.removed;
      default:
        throw ArgumentError("Invalid type");
    }
  }

  SnapshotMetadataPlatform _webMetadataToMetada(
      web.SnapshotMetadata webMetadata) {
    return SnapshotMetadataPlatform(
      webMetadata.hasPendingWrites,
      webMetadata.fromCache,
    );
  }

  @override
  Map<String, dynamic> get parameters => Map();

  /// Returns a clean clone of this QueryWeb.
  QueryWeb resetQueryDelegate() =>
      QueryWeb(firestore, pathComponents.join("/"), _webQuery);
}
