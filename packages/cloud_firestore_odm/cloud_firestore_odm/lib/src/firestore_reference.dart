// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'firestore_builder.dart';

/// A base-class for objects that can be used with [FirestoreBuilder]
// ignore: one_member_abstracts, false positive
abstract class FirestoreListenable<Result> {}

/// An implementation detail of [FirestoreReference.select].
@sealed
class FirestoreSelector<Snapshot, Selected>
    implements FirestoreListenable<Selected> {
  FirestoreSelector._(this.reference, this.selector);

  /// The selected [FirestoreReference]
  final FirestoreReference<Snapshot> reference;

  /// The selector function
  final Selected Function(Snapshot snapshot) selector;

  /// An implementation detail for calling [selector] from a code that doesn't
  /// have access to the selector generics.
  Selected runSelector(Object? obj) => selector(obj as Snapshot);
}

abstract class FirestoreReference<Snapshot>
    implements FirestoreListenable<Snapshot> {
  /// The original Firebase reference.
  Object? get reference;

  /// Listens to a reference.
  Stream<Snapshot> snapshots();

  /// Read a reference once.
  Future<Snapshot> get([GetOptions options]);

  /// Combined with [FirestoreBuilder], allows filtering rebuilds of a widget
  /// by listening only to a subset of the snapshot.
  FirestoreListenable<Selected> select<Selected>(
    Selected Function(Snapshot snapshot) selector,
  );
}

abstract class FirestoreDocumentReference<Model,
        Snapshot extends FirestoreDocumentSnapshot<Model>>
    implements FirestoreReference<Snapshot> {
  @override
  FirestoreListenable<Selected> select<Selected>(
    Selected Function(Snapshot snapshot) selector,
  ) {
    return FirestoreSelector._(this, selector);
  }

  /// The original reference obtained from Firebase.
  @override
  DocumentReference<Model> get reference;

  /// The document's identifier within its collection.
  String get id => reference.id;

  /// A string representing the path of the referenced documen
  /// (relative to the root of the database).
  String get path => reference.path;

  /// Deletes the document referred to by this DocumentReference.
  Future<void> delete() {
    return reference.delete();
  }

  /// Deletes the document using the transaction API.
  void transactionDelete(Transaction transaction) {
    transaction.delete(reference);
  }

  /// Sets data on the document, overwriting any existing data. If the document
  /// does not yet exist, it will be created.
  ///
  /// If [SetOptions] are provided, the data will be merged into an existing
  /// document instead of overwriting.
  Future<void> set(Model model, [SetOptions? setOptions]) {
    return reference.set(model, setOptions);
  }

  /// Writes to the document using the transaction API.
  ///
  /// If the document does not exist yet, it will be created. If you pass
  /// [SetOptions], the provided data can be merged into the existing document.
  void transactionSet(
    Transaction transaction,
    Model model, [
    SetOptions? setOptions,
  ]) {
    transaction.set(reference, model, setOptions);
  }

  /// Reads the document referred to by this DocumentReference.
  ///
  /// Note:
  /// By default, get() attempts to provide up-to-date data when possible
  /// by waiting for data from the server, but it may return cached data or fail
  /// if you are offline and the server cannot be reached. This behavior can be
  /// altered via the GetOptions parameter.
  @override
  Future<Snapshot> get([GetOptions options]);

  /// Reads the document using the transaction API.
  ///
  /// If the document changes whilst the transaction is in progress, it will
  /// be re-tried up to five times.
  Future<Snapshot> transactionGet(Transaction transaction);
}

abstract class FirestoreCollectionReference<
        Model,
        Snapshot extends FirestoreQuerySnapshot<Model,
            FirestoreDocumentSnapshot<Model>>>
    extends QueryReference<Model, Snapshot>
    implements FirestoreReference<Snapshot> {
  FirestoreCollectionReference({
    required Query<Model> $referenceWithoutCursor,
    $QueryCursor $queryCursor = const $QueryCursor(),
  }) : super(
          $referenceWithoutCursor: $referenceWithoutCursor,
          $queryCursor: $queryCursor,
        );

  @override
  CollectionReference<Model> get reference;

  /// A string representing the path of the referenced collection
  /// (relative to the root of the database).
  String get path;

  /// Get a [FirestoreCollectionReference] for the document within the collection
  /// with the specified document ID.
  ///
  /// If no path is specified, an automatically-generated unique ID
  /// will be used for the returned [${data.documentReferenceName}].
  FirestoreDocumentReference doc([String? id]);
}

abstract class FirestoreDocumentSnapshot<Model> {
  /// The reference for this document.
  FirestoreDocumentReference<Model, FirestoreDocumentSnapshot<Model>>
      get reference;

  /// The original [DocumentSnapshot] returned by Firebase.
  DocumentSnapshot<Model> get snapshot;

  /// Property of the DocumentSnapshot that provides the document's ID.
  String get id => snapshot.id;

  /// Property of the DocumentSnapshot that signals whether or not the data exists.
  /// True if the document exists.
  bool get exists => snapshot.exists;

  /// Metadata about this snapshot, concerning its source and if it has
  /// local modifications.
  SnapshotMetadata get metadata => snapshot.metadata;

  /// Retrieves all fields in the document as an Object.
  Model? get data;
}

abstract class FirestoreQueryDocumentSnapshot<Model>
    extends FirestoreDocumentSnapshot<Model> {
  /// The original [QueryDocumentSnapshot] returned by Firebase.
  @override
  QueryDocumentSnapshot<Model> get snapshot;

  @override
  Model get data;
}

abstract class FirestoreQuerySnapshot<Model,
    Snapshot extends FirestoreDocumentSnapshot<Model>> {
  /// The original [QuerySnapshot] from Firebase.
  QuerySnapshot<Model> get snapshot;

  /// Metadata about this snapshot, concerning its source and if it has
  /// local modifications.
  SnapshotMetadata get metadata => snapshot.metadata;

  /// Gets a list of all the documents included in this snapshot.
  List<Snapshot> get docs;

  /// An array of the documents that changed since the last snapshot. If this
  /// is the first snapshot, all documents will be in the list as Added changes.
  List<FirestoreDocumentChange<FirestoreDocumentSnapshot<Model>>>
      get docChanges;
}

/// A [DocumentChange] represents a change to the documents matching a query.
///
/// It contains the document affected and the type of change that occurred
/// (added, modified, or removed).
@sealed
class FirestoreDocumentChange<
    DocumentSnapshot extends FirestoreDocumentSnapshot<Object?>> {
  /// A [DocumentChange] represents a change to the documents matching a query.
  ///
  /// It contains the document affected and the type of change that occurred
  /// (added, modified, or removed).
  FirestoreDocumentChange({
    required this.type,
    required this.oldIndex,
    required this.newIndex,
    required this.doc,
  });

  /// The type of change that occurred (added, modified, or removed).
  final DocumentChangeType type;

  /// The index of the changed document in the result set immediately prior to
  /// this [FirestoreDocumentChange] (i.e. supposing that all prior [FirestoreDocumentChange] objects
  /// have been applied).
  ///
  /// -1 is returned for [DocumentChangeType.added] events.
  final int oldIndex;

  /// The index of the changed document in the result set immediately after this
  /// [FirestoreDocumentChange] (i.e. supposing that all prior [FirestoreDocumentChange] objects
  /// and the current [FirestoreDocumentChange] object have been applied).
  ///
  /// -1 is returned for [DocumentChangeType.removed] events.
  final int newIndex;

  /// Returns the [DocumentSnapshot] for this instance.
  final DocumentSnapshot doc;
}

/// An implementation detail for applying operators such as `startAt` to queries.
///
/// Do not use.
@sealed
@immutable
class $QueryCursor {
  const $QueryCursor({
    this.startAt = const [],
    this.startAtDocumentSnapshot,
    this.startAfter = const [],
    this.startAfterDocumentSnapshot,
    this.endAt = const [],
    this.endAtDocumentSnapshot,
    this.endBefore = const [],
    this.endBeforeDocumentSnapshot,
  });

  /// Information for `startAt`.
  /// Do not use
  final List<Object?> startAt;

  /// Information for `startAtDocumentSnapshot`.
  /// Do not use
  final DocumentSnapshot<Object?>? startAtDocumentSnapshot;

  /// Information for `startAfter`
  /// Do not use
  final List<Object?> startAfter;

  /// Information for `startAfterDocumentSnapshot`
  /// Do not use
  final DocumentSnapshot<Object?>? startAfterDocumentSnapshot;

  /// Information for `endAt`
  /// Do not use
  final List<Object?> endAt;

  /// Information for `endAtDocumentSnapshot`
  /// Do not use
  final DocumentSnapshot<Object?>? endAtDocumentSnapshot;

  /// Information for `endBefore`
  /// Do not use
  final List<Object?> endBefore;

  /// Information for `endBeforeDocumentSnapshot`
  /// Do not use
  final DocumentSnapshot<Object?>? endBeforeDocumentSnapshot;

  /// Updates a [$QueryCursor] with new values
  ///
  /// Do not use
  $QueryCursor Function({
    List<Object?> startAt,
    DocumentSnapshot<Object?>? startAtDocumentSnapshot,
    List<Object?> startAfter,
    DocumentSnapshot<Object?>? startAfterDocumentSnapshot,
    List<Object?> endAt,
    DocumentSnapshot<Object?>? endAtDocumentSnapshot,
    List<Object?> endBefore,
    DocumentSnapshot<Object?>? endBeforeDocumentSnapshot,
  }) get copyWith {
    return ({
      Object startAt = const Object(),
      Object? startAtDocumentSnapshot = const Object(),
      Object startAfter = const Object(),
      Object? startAfterDocumentSnapshot = const Object(),
      Object endAt = const Object(),
      Object? endAtDocumentSnapshot = const Object(),
      Object endBefore = const Object(),
      Object? endBeforeDocumentSnapshot = const Object(),
    }) {
      return $QueryCursor(
        startAt:
            startAt == const Object() ? this.startAt : startAt as List<Object?>,
        startAtDocumentSnapshot: startAtDocumentSnapshot == const Object()
            ? this.startAtDocumentSnapshot
            : startAtDocumentSnapshot as DocumentSnapshot<Object?>?,
        startAfter: startAfter == const Object()
            ? this.startAfter
            : startAfter as List<Object?>,
        startAfterDocumentSnapshot: startAfterDocumentSnapshot == const Object()
            ? this.startAfterDocumentSnapshot
            : startAfterDocumentSnapshot as DocumentSnapshot<Object?>?,
        endAt: endAt == const Object() ? this.endAt : endAt as List<Object?>,
        endAtDocumentSnapshot: endAtDocumentSnapshot == const Object()
            ? this.endAtDocumentSnapshot
            : endAtDocumentSnapshot as DocumentSnapshot<Object?>?,
        endBefore: endBefore == const Object()
            ? this.endBefore
            : endBefore as List<Object?>,
        endBeforeDocumentSnapshot: endBeforeDocumentSnapshot == const Object()
            ? this.endBeforeDocumentSnapshot
            : endBeforeDocumentSnapshot as DocumentSnapshot<Object?>?,
      );
    };
  }

  /// Transforms a query using the given cursor information.
  Query<T> _apply<T>(Query<T> query) {
    var result = query;

    if (startAt.isNotEmpty) {
      result = result.startAt(startAt);
    }
    if (startAtDocumentSnapshot != null) {
      result = result.startAtDocument(startAtDocumentSnapshot!);
    }

    if (startAfter.isNotEmpty) {
      result = result.startAfter(startAfter);
    }
    if (startAfterDocumentSnapshot != null) {
      result = result.startAfterDocument(startAfterDocumentSnapshot!);
    }

    if (endBefore.isNotEmpty) {
      result = result.endBefore(endBefore);
    }
    if (endBeforeDocumentSnapshot != null) {
      result = result.endBeforeDocument(endBeforeDocumentSnapshot!);
    }

    if (endAt.isNotEmpty) {
      result = result.endAt(endAt);
    }
    if (endAtDocumentSnapshot != null) {
      result = result.endAtDocument(endAtDocumentSnapshot!);
    }

    return result;
  }
}

abstract class QueryReference<
        Model,
        Snapshot extends FirestoreQuerySnapshot<Model,
            FirestoreDocumentSnapshot<Model>>>
    implements FirestoreReference<Snapshot> {
  QueryReference({
    required this.$referenceWithoutCursor,
    this.$queryCursor = const $QueryCursor(),
  });

  @override
  FirestoreListenable<Selected> select<Selected>(
    Selected Function(Snapshot snapshot) selector,
  ) {
    return FirestoreSelector._(this, selector);
  }

  /// The reference to a query, without operations such as `startAt`.
  ///
  /// Do not use.
  @protected
  final Query<Model> $referenceWithoutCursor;

  /// A function which takes [$referenceWithoutCursor] and applies cursors like
  /// `startAt`.
  ///
  /// Do not use.
  @protected
  final $QueryCursor $queryCursor;

  // Since we cannot do `orderBy().startAt().orderBy()`, the ODM needs to convert
  // `orderBy(startAt: ).orderBy()` into a valid query.
  @override
  late final Query<Model> reference =
      $queryCursor._apply($referenceWithoutCursor);

  /// Executes the query and returns the results as a QuerySnapshot.
  ///
  /// Note:
  /// By default, get() attempts to provide up-to-date data when possible by
  /// waiting for data from the server, but it may return cached data or fail
  /// if you are offline and the server cannot be reached.
  /// This behavior can be altered via the GetOptions parameter.
  @override
  Future<Snapshot> get([GetOptions options]);

  /// Creates and returns a new Query that only returns the first matching documents.
  QueryReference<Model, Snapshot> limit(int limit);

  /// Creates and returns a new Query that only returns the last matching documents.
  ///
  /// You must specify at least one orderBy clause for limitToLast queries,
  /// otherwise an exception will be thrown during execution.
  QueryReference<Model, Snapshot> limitToLast(int limit);

  /// Filter a collection based on the documents' ID.
  ///
  /// This is similar to using [FieldPath.documentId].
  QueryReference<Model, Snapshot> whereDocumentId({
    String isEqualTo,
    String isNotEqualTo,
    String isLessThan,
    String isLessThanOrEqualTo,
    String isGreaterThan,
    String isGreaterThanOrEqualTo,
    bool isNull,
    List<String> whereIn,
    List<String> whereNotIn,
  });

  /// Sorts a collection based on the documents' ID.
  ///
  /// This is similar to using [FieldPath.documentId].
  QueryReference<Model, Snapshot> orderByDocumentId({
    bool descending,
    String startAt,
    String startAfter,
    String endAt,
    String endBefore,
  });
}
