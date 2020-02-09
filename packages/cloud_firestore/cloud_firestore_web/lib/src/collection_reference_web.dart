// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:firebase/firestore.dart' as web;
import 'package:meta/meta.dart';

import 'package:cloud_firestore_web/src/document_reference_web.dart';
import 'package:cloud_firestore_web/src/query_web.dart';

/// Web implementation for Firestore [CollectionReferencePlatform]
class CollectionReferenceWeb extends CollectionReferencePlatform {
  /// instance of Firestore from the web plugin
  final web.Firestore _webFirestore;
  final FirestorePlatform _firestorePlatform;
  // disabling lint as it's only visible for testing
  @visibleForTesting
  QueryWeb queryDelegate; // ignore: public_member_api_docs

  /// Creates an instance of [CollectionReferenceWeb] which represents path
  /// at [pathComponents] and uses implementation of [webFirestore]
  CollectionReferenceWeb(
      this._firestorePlatform, this._webFirestore, List<String> pathComponents)
      : queryDelegate = QueryWeb(
          _firestorePlatform,
          pathComponents.join("/"),
          _webFirestore.collection(pathComponents.join("/")),
        ),
        super(_firestorePlatform, pathComponents);

  @override
  DocumentReferencePlatform parent() {
    if (pathComponents.length < 2) {
      return null;
    }
    return DocumentReferenceWeb(
      _webFirestore,
      firestore,
      (List<String>.from(pathComponents)..removeLast()),
    );
  }

  @override
  DocumentReferencePlatform document([String path]) {
    List<String> childPath;
    if (path == null) {
      web.DocumentReference doc =
          _webFirestore.collection(pathComponents.join('/')).doc();
      childPath = doc.path.split('/');
    } else {
      childPath = List<String>.from(pathComponents)..addAll(path.split(('/')));
    }
    return DocumentReferenceWeb(
      _webFirestore,
      firestore,
      childPath,
    );
  }

  @override
  Future<DocumentReferencePlatform> add(Map<String, dynamic> data) async {
    final DocumentReferencePlatform newDocument = document();
    await newDocument.setData(data);
    return newDocument;
  }

  @override
  Map<String, dynamic> buildArguments() => queryDelegate.buildArguments();

  @override
  QueryPlatform endAt(List values) {
    _resetQueryDelegate();
    return queryDelegate.endAt(values);
  }

  @override
  QueryPlatform endAtDocument(DocumentSnapshotPlatform documentSnapshot) {
    _resetQueryDelegate();
    return queryDelegate.endAtDocument(documentSnapshot);
  }

  @override
  QueryPlatform endBefore(List values) {
    _resetQueryDelegate();
    return queryDelegate.endBefore(values);
  }

  @override
  QueryPlatform endBeforeDocument(DocumentSnapshotPlatform documentSnapshot) {
    _resetQueryDelegate();
    return queryDelegate.endBeforeDocument(documentSnapshot);
  }

  @override
  FirestorePlatform get firestore => _firestorePlatform;

  @override
  Future<QuerySnapshotPlatform> getDocuments({
    Source source = Source.serverAndCache,
  }) =>
      queryDelegate.getDocuments(source: source);

  @override
  String get id => pathComponents.isEmpty ? null : pathComponents.last;

  @override
  bool get isCollectionGroup => false;

  @override
  QueryPlatform limit(int length) {
    _resetQueryDelegate();
    return queryDelegate.limit(length);
  }

  @override
  QueryPlatform orderBy(
    field, {
    bool descending = false,
  }) {
    _resetQueryDelegate();
    return queryDelegate.orderBy(field, descending: descending);
  }

  @override
  Map<String, dynamic> get parameters => queryDelegate.parameters;

  @override
  String get path => pathComponents.join("/");

  @override
  CollectionReferencePlatform reference() => queryDelegate.reference();

  @override
  Stream<QuerySnapshotPlatform> snapshots({
    bool includeMetadataChanges = false,
  }) =>
      queryDelegate.snapshots(includeMetadataChanges: includeMetadataChanges);

  @override
  QueryPlatform startAfter(List values) {
    _resetQueryDelegate();
    return queryDelegate.startAfter(values);
  }

  @override
  QueryPlatform startAfterDocument(DocumentSnapshotPlatform documentSnapshot) {
    _resetQueryDelegate();
    return queryDelegate.startAfterDocument(documentSnapshot);
  }

  @override
  QueryPlatform startAt(List values) {
    _resetQueryDelegate();
    return queryDelegate.startAt(values);
  }

  @override
  QueryPlatform startAtDocument(DocumentSnapshotPlatform documentSnapshot) {
    _resetQueryDelegate();
    return queryDelegate.startAtDocument(documentSnapshot);
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
    _resetQueryDelegate();
    return queryDelegate.where(field,
        isEqualTo: isEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        arrayContains: arrayContains,
        arrayContainsAny: arrayContainsAny,
        whereIn: whereIn,
        isNull: isNull);
  }

  void _resetQueryDelegate() =>
      queryDelegate = queryDelegate.resetQueryDelegate();
}
