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

abstract class FirestoreDocumentReference<
        Snapshot extends FirestoreDocumentSnapshot>
    implements FirestoreReference<Snapshot> {
  @override
  FirestoreListenable<Selected> select<Selected>(
    Selected Function(Snapshot snapshot) selector,
  ) {
    return FirestoreSelector._(this, selector);
  }

  /// The original reference obtained from Firebase.
  @override
  DocumentReference<Object?> get reference;

  /// The document's identifier within its collection.
  String get id => reference.id;

  /// A string representing the path of the referenced documen
  /// (relative to the root of the database).
  String get path => reference.path;

  /// Deletes the document referred to by this DocumentReference.
  Future<void> delete();

  /// Reads the document referred to by this DocumentReference.
  ///
  /// Note:
  /// By default, get() attempts to provide up-to-date data when possible
  /// by waiting for data from the server, but it may return cached data or fail
  /// if you are offline and the server cannot be reached. This behavior can be
  /// altered via the GetOptions parameter.
  @override
  Future<Snapshot> get([GetOptions options]);
}

abstract class FirestoreCollectionReference<
        Snapshot extends FirestoreQuerySnapshot>
    implements FirestoreReference<Snapshot> {
  @override
  CollectionReference<Object?> get reference;

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

abstract class FirestoreDocumentSnapshot {
  /// The reference for this document.
  FirestoreDocumentReference get reference;

  /// The original [DocumentSnapshot] returned by Firebase.
  DocumentSnapshot<Object?> get snapshot;

  /// Property of the DocumentSnapshot that provides the document's ID.
  String get id => snapshot.id;

  /// Property of the DocumentSnapshot that signals whether or not the data exists.
  /// True if the document exists.
  bool get exists => snapshot.exists;

  /// Metadata about this snapshot, concerning its source and if it has
  /// local modifications.
  SnapshotMetadata get metadata => snapshot.metadata;

  /// Retrieves all fields in the document as an Object.
  Object? get data;
}

abstract class FirestoreQueryDocumentSnapshot
    extends FirestoreDocumentSnapshot {
  /// The original [QueryDocumentSnapshot] returned by Firebase.
  @override
  QueryDocumentSnapshot<Object?> get snapshot;

  @override
  Object? get data;
}

abstract class FirestoreQuerySnapshot<
    Snapshot extends FirestoreDocumentSnapshot> {
  /// The original [QuerySnapshot] from Firebase.
  QuerySnapshot<Object?> get snapshot;

  /// Metadata about this snapshot, concerning its source and if it has
  /// local modifications.
  SnapshotMetadata get metadata => snapshot.metadata;

  /// Gets a list of all the documents included in this snapshot.
  List<Snapshot> get docs;

  /// An array of the documents that changed since the last snapshot. If this
  /// is the first snapshot, all documents will be in the list as Added changes.
  List<FirestoreDocumentChange<Object?>> get docChanges;
}

/// A [DocumentChange] represents a change to the documents matching a query.
///
/// It contains the document affected and the type of change that occurred
/// (added, modified, or removed).
@sealed
class FirestoreDocumentChange<
    DocumentSnapshot extends FirestoreDocumentSnapshot> {
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

abstract class QueryReference<Snapshot extends FirestoreQuerySnapshot>
    implements FirestoreReference<Snapshot> {
  @override
  FirestoreListenable<Selected> select<Selected>(
    Selected Function(Snapshot snapshot) selector,
  ) {
    return FirestoreSelector._(this, selector);
  }

  @override
  Query<Object?> get reference;

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
  QueryReference<Snapshot> limit(int limit);

  /// Creates and returns a new Query that only returns the last matching documents.
  ///
  /// You must specify at least one orderBy clause for limitToLast queries,
  /// otherwise an exception will be thrown during execution.
  QueryReference<Snapshot> limitToLast(int limit);
}
