// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'integration.dart';

// **************************************************************************
// CollectionGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides

class _Sentinel {
  const _Sentinel();
}

const _sentinel = _Sentinel();

/// A collection reference object can be used for adding documents,
/// getting document references, and querying for documents
/// (using the methods inherited from Query).
abstract class EmptyModelCollectionReference
    implements
        EmptyModelQuery,
        FirestoreCollectionReference<EmptyModelQuerySnapshot> {
  factory EmptyModelCollectionReference([
    FirebaseFirestore? firestore,
  ]) = _$EmptyModelCollectionReference;

  static EmptyModel fromFirestore(
    DocumentSnapshot<Map<String, Object?>> snapshot,
    SnapshotOptions? options,
  ) {
    return EmptyModel.fromJson(snapshot.data()!);
  }

  static Map<String, Object?> toFirestore(
    EmptyModel value,
    SetOptions? options,
  ) {
    return value.toJson();
  }

  @override
  EmptyModelDocumentReference doc([String? id]);

  /// Add a new document to this collection with the specified data,
  /// assigning it a document ID automatically.
  Future<EmptyModelDocumentReference> add(EmptyModel value);
}

class _$EmptyModelCollectionReference extends _$EmptyModelQuery
    implements EmptyModelCollectionReference {
  factory _$EmptyModelCollectionReference([FirebaseFirestore? firestore]) {
    firestore ??= FirebaseFirestore.instance;

    return _$EmptyModelCollectionReference._(
      firestore.collection('config').withConverter(
            fromFirestore: EmptyModelCollectionReference.fromFirestore,
            toFirestore: EmptyModelCollectionReference.toFirestore,
          ),
    );
  }

  _$EmptyModelCollectionReference._(
    CollectionReference<EmptyModel> reference,
  ) : super(reference, reference);

  String get path => reference.path;

  @override
  CollectionReference<EmptyModel> get reference =>
      super.reference as CollectionReference<EmptyModel>;

  @override
  EmptyModelDocumentReference doc([String? id]) {
    return EmptyModelDocumentReference(
      reference.doc(id),
    );
  }

  @override
  Future<EmptyModelDocumentReference> add(EmptyModel value) {
    return reference.add(value).then((ref) => EmptyModelDocumentReference(ref));
  }

  @override
  bool operator ==(Object other) {
    return other is _$EmptyModelCollectionReference &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

abstract class EmptyModelDocumentReference
    extends FirestoreDocumentReference<EmptyModelDocumentSnapshot> {
  factory EmptyModelDocumentReference(DocumentReference<EmptyModel> reference) =
      _$EmptyModelDocumentReference;

  DocumentReference<EmptyModel> get reference;

  /// A reference to the [EmptyModelCollectionReference] containing this document.
  EmptyModelCollectionReference get parent {
    return _$EmptyModelCollectionReference(reference.firestore);
  }

  @override
  Stream<EmptyModelDocumentSnapshot> snapshots();

  @override
  Future<EmptyModelDocumentSnapshot> get([GetOptions? options]);

  @override
  Future<void> delete();

  Future<void> set(EmptyModel value);
}

class _$EmptyModelDocumentReference
    extends FirestoreDocumentReference<EmptyModelDocumentSnapshot>
    implements EmptyModelDocumentReference {
  _$EmptyModelDocumentReference(this.reference);

  @override
  final DocumentReference<EmptyModel> reference;

  /// A reference to the [EmptyModelCollectionReference] containing this document.
  EmptyModelCollectionReference get parent {
    return _$EmptyModelCollectionReference(reference.firestore);
  }

  @override
  Stream<EmptyModelDocumentSnapshot> snapshots() {
    return reference.snapshots().map((snapshot) {
      return EmptyModelDocumentSnapshot._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<EmptyModelDocumentSnapshot> get([GetOptions? options]) {
    return reference.get(options).then((snapshot) {
      return EmptyModelDocumentSnapshot._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<void> delete() {
    return reference.delete();
  }

  Future<void> set(EmptyModel value) {
    return reference.set(value);
  }

  @override
  bool operator ==(Object other) {
    return other is EmptyModelDocumentReference &&
        other.runtimeType == runtimeType &&
        other.parent == parent &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, parent, id);
}

class EmptyModelDocumentSnapshot extends FirestoreDocumentSnapshot {
  EmptyModelDocumentSnapshot._(
    this.snapshot,
    this.data,
  );

  @override
  final DocumentSnapshot<EmptyModel> snapshot;

  @override
  EmptyModelDocumentReference get reference {
    return EmptyModelDocumentReference(
      snapshot.reference,
    );
  }

  @override
  final EmptyModel? data;
}

abstract class EmptyModelQuery
    implements QueryReference<EmptyModelQuerySnapshot> {
  @override
  EmptyModelQuery limit(int limit);

  @override
  EmptyModelQuery limitToLast(int limit);
}

class _$EmptyModelQuery extends QueryReference<EmptyModelQuerySnapshot>
    implements EmptyModelQuery {
  _$EmptyModelQuery(
    this.reference,
    this._collection,
  );

  final CollectionReference<Object?> _collection;

  @override
  final Query<EmptyModel> reference;

  EmptyModelQuerySnapshot _decodeSnapshot(
    QuerySnapshot<EmptyModel> snapshot,
  ) {
    final docs = snapshot.docs.map((e) {
      return EmptyModelQueryDocumentSnapshot._(e, e.data());
    }).toList();

    final docChanges = snapshot.docChanges.map((change) {
      return FirestoreDocumentChange<EmptyModelDocumentSnapshot>(
        type: change.type,
        oldIndex: change.oldIndex,
        newIndex: change.newIndex,
        doc: EmptyModelDocumentSnapshot._(change.doc, change.doc.data()),
      );
    }).toList();

    return EmptyModelQuerySnapshot._(
      snapshot,
      docs,
      docChanges,
    );
  }

  @override
  Stream<EmptyModelQuerySnapshot> snapshots([SnapshotOptions? options]) {
    return reference.snapshots().map(_decodeSnapshot);
  }

  @override
  Future<EmptyModelQuerySnapshot> get([GetOptions? options]) {
    return reference.get(options).then(_decodeSnapshot);
  }

  @override
  EmptyModelQuery limit(int limit) {
    return _$EmptyModelQuery(
      reference.limit(limit),
      _collection,
    );
  }

  @override
  EmptyModelQuery limitToLast(int limit) {
    return _$EmptyModelQuery(
      reference.limitToLast(limit),
      _collection,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is _$EmptyModelQuery &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

class EmptyModelQuerySnapshot
    extends FirestoreQuerySnapshot<EmptyModelQueryDocumentSnapshot> {
  EmptyModelQuerySnapshot._(
    this.snapshot,
    this.docs,
    this.docChanges,
  );

  final QuerySnapshot<EmptyModel> snapshot;

  @override
  final List<EmptyModelQueryDocumentSnapshot> docs;

  @override
  final List<FirestoreDocumentChange<EmptyModelDocumentSnapshot>> docChanges;
}

class EmptyModelQueryDocumentSnapshot extends FirestoreQueryDocumentSnapshot
    implements EmptyModelDocumentSnapshot {
  EmptyModelQueryDocumentSnapshot._(this.snapshot, this.data);

  @override
  final QueryDocumentSnapshot<EmptyModel> snapshot;

  @override
  EmptyModelDocumentReference get reference {
    return EmptyModelDocumentReference(snapshot.reference);
  }

  @override
  final EmptyModel data;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmptyModel _$EmptyModelFromJson(Map<String, dynamic> json) => EmptyModel();

Map<String, dynamic> _$EmptyModelToJson(EmptyModel instance) =>
    <String, dynamic>{};
