// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple.dart';

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
abstract class SplitFileModelCollectionReference
    implements
        SplitFileModelQuery,
        FirestoreCollectionReference<SplitFileModelQuerySnapshot> {
  factory SplitFileModelCollectionReference([
    FirebaseFirestore? firestore,
  ]) = _$SplitFileModelCollectionReference;

  static SplitFileModel fromFirestore(
    DocumentSnapshot<Map<String, Object?>> snapshot,
    SnapshotOptions? options,
  ) {
    return SplitFileModel.fromJson(snapshot.data()!);
  }

  static Map<String, Object?> toFirestore(
    SplitFileModel value,
    SetOptions? options,
  ) {
    return value.toJson();
  }

  @override
  SplitFileModelDocumentReference doc([String? id]);

  /// Add a new document to this collection with the specified data,
  /// assigning it a document ID automatically.
  Future<SplitFileModelDocumentReference> add(SplitFileModel value);
}

class _$SplitFileModelCollectionReference extends _$SplitFileModelQuery
    implements SplitFileModelCollectionReference {
  factory _$SplitFileModelCollectionReference([FirebaseFirestore? firestore]) {
    firestore ??= FirebaseFirestore.instance;

    return _$SplitFileModelCollectionReference._(
      firestore.collection('split-file').withConverter(
            fromFirestore: SplitFileModelCollectionReference.fromFirestore,
            toFirestore: SplitFileModelCollectionReference.toFirestore,
          ),
    );
  }

  _$SplitFileModelCollectionReference._(
    CollectionReference<SplitFileModel> reference,
  ) : super(reference, reference);

  String get path => reference.path;

  @override
  CollectionReference<SplitFileModel> get reference =>
      super.reference as CollectionReference<SplitFileModel>;

  @override
  SplitFileModelDocumentReference doc([String? id]) {
    return SplitFileModelDocumentReference(
      reference.doc(id),
    );
  }

  @override
  Future<SplitFileModelDocumentReference> add(SplitFileModel value) {
    return reference
        .add(value)
        .then((ref) => SplitFileModelDocumentReference(ref));
  }

  @override
  bool operator ==(Object other) {
    return other is _$SplitFileModelCollectionReference &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

abstract class SplitFileModelDocumentReference
    extends FirestoreDocumentReference<SplitFileModelDocumentSnapshot> {
  factory SplitFileModelDocumentReference(
          DocumentReference<SplitFileModel> reference) =
      _$SplitFileModelDocumentReference;

  DocumentReference<SplitFileModel> get reference;

  /// A reference to the [SplitFileModelCollectionReference] containing this document.
  SplitFileModelCollectionReference get parent {
    return _$SplitFileModelCollectionReference(reference.firestore);
  }

  @override
  Stream<SplitFileModelDocumentSnapshot> snapshots();

  @override
  Future<SplitFileModelDocumentSnapshot> get([GetOptions? options]);

  @override
  Future<void> delete();

  Future<void> set(SplitFileModel value);
}

class _$SplitFileModelDocumentReference
    extends FirestoreDocumentReference<SplitFileModelDocumentSnapshot>
    implements SplitFileModelDocumentReference {
  _$SplitFileModelDocumentReference(this.reference);

  @override
  final DocumentReference<SplitFileModel> reference;

  /// A reference to the [SplitFileModelCollectionReference] containing this document.
  SplitFileModelCollectionReference get parent {
    return _$SplitFileModelCollectionReference(reference.firestore);
  }

  @override
  Stream<SplitFileModelDocumentSnapshot> snapshots() {
    return reference.snapshots().map((snapshot) {
      return SplitFileModelDocumentSnapshot._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<SplitFileModelDocumentSnapshot> get([GetOptions? options]) {
    return reference.get(options).then((snapshot) {
      return SplitFileModelDocumentSnapshot._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<void> delete() {
    return reference.delete();
  }

  Future<void> set(SplitFileModel value) {
    return reference.set(value);
  }

  @override
  bool operator ==(Object other) {
    return other is SplitFileModelDocumentReference &&
        other.runtimeType == runtimeType &&
        other.parent == parent &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, parent, id);
}

class SplitFileModelDocumentSnapshot extends FirestoreDocumentSnapshot {
  SplitFileModelDocumentSnapshot._(
    this.snapshot,
    this.data,
  );

  @override
  final DocumentSnapshot<SplitFileModel> snapshot;

  @override
  SplitFileModelDocumentReference get reference {
    return SplitFileModelDocumentReference(
      snapshot.reference,
    );
  }

  @override
  final SplitFileModel? data;
}

abstract class SplitFileModelQuery
    implements QueryReference<SplitFileModelQuerySnapshot> {
  @override
  SplitFileModelQuery limit(int limit);

  @override
  SplitFileModelQuery limitToLast(int limit);
}

class _$SplitFileModelQuery extends QueryReference<SplitFileModelQuerySnapshot>
    implements SplitFileModelQuery {
  _$SplitFileModelQuery(
    this.reference,
    this._collection,
  );

  final CollectionReference<Object?> _collection;

  @override
  final Query<SplitFileModel> reference;

  SplitFileModelQuerySnapshot _decodeSnapshot(
    QuerySnapshot<SplitFileModel> snapshot,
  ) {
    final docs = snapshot.docs.map((e) {
      return SplitFileModelQueryDocumentSnapshot._(e, e.data());
    }).toList();

    final docChanges = snapshot.docChanges.map((change) {
      return FirestoreDocumentChange<SplitFileModelDocumentSnapshot>(
        type: change.type,
        oldIndex: change.oldIndex,
        newIndex: change.newIndex,
        doc: SplitFileModelDocumentSnapshot._(change.doc, change.doc.data()),
      );
    }).toList();

    return SplitFileModelQuerySnapshot._(
      snapshot,
      docs,
      docChanges,
    );
  }

  @override
  Stream<SplitFileModelQuerySnapshot> snapshots([SnapshotOptions? options]) {
    return reference.snapshots().map(_decodeSnapshot);
  }

  @override
  Future<SplitFileModelQuerySnapshot> get([GetOptions? options]) {
    return reference.get(options).then(_decodeSnapshot);
  }

  @override
  SplitFileModelQuery limit(int limit) {
    return _$SplitFileModelQuery(
      reference.limit(limit),
      _collection,
    );
  }

  @override
  SplitFileModelQuery limitToLast(int limit) {
    return _$SplitFileModelQuery(
      reference.limitToLast(limit),
      _collection,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is _$SplitFileModelQuery &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

class SplitFileModelQuerySnapshot
    extends FirestoreQuerySnapshot<SplitFileModelQueryDocumentSnapshot> {
  SplitFileModelQuerySnapshot._(
    this.snapshot,
    this.docs,
    this.docChanges,
  );

  final QuerySnapshot<SplitFileModel> snapshot;

  @override
  final List<SplitFileModelQueryDocumentSnapshot> docs;

  @override
  final List<FirestoreDocumentChange<SplitFileModelDocumentSnapshot>>
      docChanges;
}

class SplitFileModelQueryDocumentSnapshot extends FirestoreQueryDocumentSnapshot
    implements SplitFileModelDocumentSnapshot {
  SplitFileModelQueryDocumentSnapshot._(this.snapshot, this.data);

  @override
  final QueryDocumentSnapshot<SplitFileModel> snapshot;

  @override
  SplitFileModelDocumentReference get reference {
    return SplitFileModelDocumentReference(snapshot.reference);
  }

  @override
  final SplitFileModel data;
}

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

/// A collection reference object can be used for adding documents,
/// getting document references, and querying for documents
/// (using the methods inherited from Query).
abstract class OptionalJsonCollectionReference
    implements
        OptionalJsonQuery,
        FirestoreCollectionReference<OptionalJsonQuerySnapshot> {
  factory OptionalJsonCollectionReference([
    FirebaseFirestore? firestore,
  ]) = _$OptionalJsonCollectionReference;

  static OptionalJson fromFirestore(
    DocumentSnapshot<Map<String, Object?>> snapshot,
    SnapshotOptions? options,
  ) {
    return _$OptionalJsonFromJson(snapshot.data()!);
  }

  static Map<String, Object?> toFirestore(
    OptionalJson value,
    SetOptions? options,
  ) {
    return _$OptionalJsonToJson(value);
  }

  @override
  OptionalJsonDocumentReference doc([String? id]);

  /// Add a new document to this collection with the specified data,
  /// assigning it a document ID automatically.
  Future<OptionalJsonDocumentReference> add(OptionalJson value);
}

class _$OptionalJsonCollectionReference extends _$OptionalJsonQuery
    implements OptionalJsonCollectionReference {
  factory _$OptionalJsonCollectionReference([FirebaseFirestore? firestore]) {
    firestore ??= FirebaseFirestore.instance;

    return _$OptionalJsonCollectionReference._(
      firestore.collection('root').withConverter(
            fromFirestore: OptionalJsonCollectionReference.fromFirestore,
            toFirestore: OptionalJsonCollectionReference.toFirestore,
          ),
    );
  }

  _$OptionalJsonCollectionReference._(
    CollectionReference<OptionalJson> reference,
  ) : super(reference, reference);

  String get path => reference.path;

  @override
  CollectionReference<OptionalJson> get reference =>
      super.reference as CollectionReference<OptionalJson>;

  @override
  OptionalJsonDocumentReference doc([String? id]) {
    return OptionalJsonDocumentReference(
      reference.doc(id),
    );
  }

  @override
  Future<OptionalJsonDocumentReference> add(OptionalJson value) {
    return reference
        .add(value)
        .then((ref) => OptionalJsonDocumentReference(ref));
  }

  @override
  bool operator ==(Object other) {
    return other is _$OptionalJsonCollectionReference &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

abstract class OptionalJsonDocumentReference
    extends FirestoreDocumentReference<OptionalJsonDocumentSnapshot> {
  factory OptionalJsonDocumentReference(
          DocumentReference<OptionalJson> reference) =
      _$OptionalJsonDocumentReference;

  DocumentReference<OptionalJson> get reference;

  /// A reference to the [OptionalJsonCollectionReference] containing this document.
  OptionalJsonCollectionReference get parent {
    return _$OptionalJsonCollectionReference(reference.firestore);
  }

  @override
  Stream<OptionalJsonDocumentSnapshot> snapshots();

  @override
  Future<OptionalJsonDocumentSnapshot> get([GetOptions? options]);

  @override
  Future<void> delete();

  Future<void> update({
    int value,
  });

  Future<void> set(OptionalJson value);
}

class _$OptionalJsonDocumentReference
    extends FirestoreDocumentReference<OptionalJsonDocumentSnapshot>
    implements OptionalJsonDocumentReference {
  _$OptionalJsonDocumentReference(this.reference);

  @override
  final DocumentReference<OptionalJson> reference;

  /// A reference to the [OptionalJsonCollectionReference] containing this document.
  OptionalJsonCollectionReference get parent {
    return _$OptionalJsonCollectionReference(reference.firestore);
  }

  @override
  Stream<OptionalJsonDocumentSnapshot> snapshots() {
    return reference.snapshots().map((snapshot) {
      return OptionalJsonDocumentSnapshot._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<OptionalJsonDocumentSnapshot> get([GetOptions? options]) {
    return reference.get(options).then((snapshot) {
      return OptionalJsonDocumentSnapshot._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<void> delete() {
    return reference.delete();
  }

  Future<void> update({
    Object? value = _sentinel,
  }) async {
    final json = {
      if (value != _sentinel) "value": value as int,
    };

    return reference.update(json);
  }

  Future<void> set(OptionalJson value) {
    return reference.set(value);
  }

  @override
  bool operator ==(Object other) {
    return other is OptionalJsonDocumentReference &&
        other.runtimeType == runtimeType &&
        other.parent == parent &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, parent, id);
}

class OptionalJsonDocumentSnapshot extends FirestoreDocumentSnapshot {
  OptionalJsonDocumentSnapshot._(
    this.snapshot,
    this.data,
  );

  @override
  final DocumentSnapshot<OptionalJson> snapshot;

  @override
  OptionalJsonDocumentReference get reference {
    return OptionalJsonDocumentReference(
      snapshot.reference,
    );
  }

  @override
  final OptionalJson? data;
}

abstract class OptionalJsonQuery
    implements QueryReference<OptionalJsonQuerySnapshot> {
  @override
  OptionalJsonQuery limit(int limit);

  @override
  OptionalJsonQuery limitToLast(int limit);

  OptionalJsonQuery whereValue({
    int? isEqualTo,
    int? isNotEqualTo,
    int? isLessThan,
    int? isLessThanOrEqualTo,
    int? isGreaterThan,
    int? isGreaterThanOrEqualTo,
    bool? isNull,
    List<int>? whereIn,
    List<int>? whereNotIn,
  });

  OptionalJsonQuery orderByValue({
    bool descending = false,
    int startAt,
    int startAfter,
    int endAt,
    int endBefore,
    OptionalJsonDocumentSnapshot? startAtDocument,
    OptionalJsonDocumentSnapshot? endAtDocument,
    OptionalJsonDocumentSnapshot? endBeforeDocument,
    OptionalJsonDocumentSnapshot? startAfterDocument,
  });
}

class _$OptionalJsonQuery extends QueryReference<OptionalJsonQuerySnapshot>
    implements OptionalJsonQuery {
  _$OptionalJsonQuery(
    this.reference,
    this._collection,
  );

  final CollectionReference<Object?> _collection;

  @override
  final Query<OptionalJson> reference;

  OptionalJsonQuerySnapshot _decodeSnapshot(
    QuerySnapshot<OptionalJson> snapshot,
  ) {
    final docs = snapshot.docs.map((e) {
      return OptionalJsonQueryDocumentSnapshot._(e, e.data());
    }).toList();

    final docChanges = snapshot.docChanges.map((change) {
      return FirestoreDocumentChange<OptionalJsonDocumentSnapshot>(
        type: change.type,
        oldIndex: change.oldIndex,
        newIndex: change.newIndex,
        doc: OptionalJsonDocumentSnapshot._(change.doc, change.doc.data()),
      );
    }).toList();

    return OptionalJsonQuerySnapshot._(
      snapshot,
      docs,
      docChanges,
    );
  }

  @override
  Stream<OptionalJsonQuerySnapshot> snapshots([SnapshotOptions? options]) {
    return reference.snapshots().map(_decodeSnapshot);
  }

  @override
  Future<OptionalJsonQuerySnapshot> get([GetOptions? options]) {
    return reference.get(options).then(_decodeSnapshot);
  }

  @override
  OptionalJsonQuery limit(int limit) {
    return _$OptionalJsonQuery(
      reference.limit(limit),
      _collection,
    );
  }

  @override
  OptionalJsonQuery limitToLast(int limit) {
    return _$OptionalJsonQuery(
      reference.limitToLast(limit),
      _collection,
    );
  }

  OptionalJsonQuery whereValue({
    int? isEqualTo,
    int? isNotEqualTo,
    int? isLessThan,
    int? isLessThanOrEqualTo,
    int? isGreaterThan,
    int? isGreaterThanOrEqualTo,
    bool? isNull,
    List<int>? whereIn,
    List<int>? whereNotIn,
  }) {
    return _$OptionalJsonQuery(
      reference.where(
        'value',
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        isNull: isNull,
        whereIn: whereIn,
        whereNotIn: whereNotIn,
      ),
      _collection,
    );
  }

  OptionalJsonQuery orderByValue({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    OptionalJsonDocumentSnapshot? startAtDocument,
    OptionalJsonDocumentSnapshot? endAtDocument,
    OptionalJsonDocumentSnapshot? endBeforeDocument,
    OptionalJsonDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy('value', descending: false);

    if (startAtDocument != null) {
      query = query.startAtDocument(startAtDocument.snapshot);
    }
    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument.snapshot);
    }
    if (endAtDocument != null) {
      query = query.endAtDocument(endAtDocument.snapshot);
    }
    if (endBeforeDocument != null) {
      query = query.endBeforeDocument(endBeforeDocument.snapshot);
    }

    if (startAt != _sentinel) {
      query = query.startAt([startAt]);
    }
    if (startAfter != _sentinel) {
      query = query.startAfter([startAfter]);
    }
    if (endAt != _sentinel) {
      query = query.endAt([endAt]);
    }
    if (endBefore != _sentinel) {
      query = query.endBefore([endBefore]);
    }

    return _$OptionalJsonQuery(query, _collection);
  }

  @override
  bool operator ==(Object other) {
    return other is _$OptionalJsonQuery &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

class OptionalJsonQuerySnapshot
    extends FirestoreQuerySnapshot<OptionalJsonQueryDocumentSnapshot> {
  OptionalJsonQuerySnapshot._(
    this.snapshot,
    this.docs,
    this.docChanges,
  );

  final QuerySnapshot<OptionalJson> snapshot;

  @override
  final List<OptionalJsonQueryDocumentSnapshot> docs;

  @override
  final List<FirestoreDocumentChange<OptionalJsonDocumentSnapshot>> docChanges;
}

class OptionalJsonQueryDocumentSnapshot extends FirestoreQueryDocumentSnapshot
    implements OptionalJsonDocumentSnapshot {
  OptionalJsonQueryDocumentSnapshot._(this.snapshot, this.data);

  @override
  final QueryDocumentSnapshot<OptionalJson> snapshot;

  @override
  OptionalJsonDocumentReference get reference {
    return OptionalJsonDocumentReference(snapshot.reference);
  }

  @override
  final OptionalJson data;
}

/// A collection reference object can be used for adding documents,
/// getting document references, and querying for documents
/// (using the methods inherited from Query).
abstract class MixedJsonCollectionReference
    implements
        MixedJsonQuery,
        FirestoreCollectionReference<MixedJsonQuerySnapshot> {
  factory MixedJsonCollectionReference([
    FirebaseFirestore? firestore,
  ]) = _$MixedJsonCollectionReference;

  static MixedJson fromFirestore(
    DocumentSnapshot<Map<String, Object?>> snapshot,
    SnapshotOptions? options,
  ) {
    return MixedJson.fromJson(snapshot.data()!);
  }

  static Map<String, Object?> toFirestore(
    MixedJson value,
    SetOptions? options,
  ) {
    return value.toJson();
  }

  @override
  MixedJsonDocumentReference doc([String? id]);

  /// Add a new document to this collection with the specified data,
  /// assigning it a document ID automatically.
  Future<MixedJsonDocumentReference> add(MixedJson value);
}

class _$MixedJsonCollectionReference extends _$MixedJsonQuery
    implements MixedJsonCollectionReference {
  factory _$MixedJsonCollectionReference([FirebaseFirestore? firestore]) {
    firestore ??= FirebaseFirestore.instance;

    return _$MixedJsonCollectionReference._(
      firestore.collection('root').withConverter(
            fromFirestore: MixedJsonCollectionReference.fromFirestore,
            toFirestore: MixedJsonCollectionReference.toFirestore,
          ),
    );
  }

  _$MixedJsonCollectionReference._(
    CollectionReference<MixedJson> reference,
  ) : super(reference, reference);

  String get path => reference.path;

  @override
  CollectionReference<MixedJson> get reference =>
      super.reference as CollectionReference<MixedJson>;

  @override
  MixedJsonDocumentReference doc([String? id]) {
    return MixedJsonDocumentReference(
      reference.doc(id),
    );
  }

  @override
  Future<MixedJsonDocumentReference> add(MixedJson value) {
    return reference.add(value).then((ref) => MixedJsonDocumentReference(ref));
  }

  @override
  bool operator ==(Object other) {
    return other is _$MixedJsonCollectionReference &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

abstract class MixedJsonDocumentReference
    extends FirestoreDocumentReference<MixedJsonDocumentSnapshot> {
  factory MixedJsonDocumentReference(DocumentReference<MixedJson> reference) =
      _$MixedJsonDocumentReference;

  DocumentReference<MixedJson> get reference;

  /// A reference to the [MixedJsonCollectionReference] containing this document.
  MixedJsonCollectionReference get parent {
    return _$MixedJsonCollectionReference(reference.firestore);
  }

  @override
  Stream<MixedJsonDocumentSnapshot> snapshots();

  @override
  Future<MixedJsonDocumentSnapshot> get([GetOptions? options]);

  @override
  Future<void> delete();

  Future<void> update({
    int value,
  });

  Future<void> set(MixedJson value);
}

class _$MixedJsonDocumentReference
    extends FirestoreDocumentReference<MixedJsonDocumentSnapshot>
    implements MixedJsonDocumentReference {
  _$MixedJsonDocumentReference(this.reference);

  @override
  final DocumentReference<MixedJson> reference;

  /// A reference to the [MixedJsonCollectionReference] containing this document.
  MixedJsonCollectionReference get parent {
    return _$MixedJsonCollectionReference(reference.firestore);
  }

  @override
  Stream<MixedJsonDocumentSnapshot> snapshots() {
    return reference.snapshots().map((snapshot) {
      return MixedJsonDocumentSnapshot._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<MixedJsonDocumentSnapshot> get([GetOptions? options]) {
    return reference.get(options).then((snapshot) {
      return MixedJsonDocumentSnapshot._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<void> delete() {
    return reference.delete();
  }

  Future<void> update({
    Object? value = _sentinel,
  }) async {
    final json = {
      if (value != _sentinel) "value": value as int,
    };

    return reference.update(json);
  }

  Future<void> set(MixedJson value) {
    return reference.set(value);
  }

  @override
  bool operator ==(Object other) {
    return other is MixedJsonDocumentReference &&
        other.runtimeType == runtimeType &&
        other.parent == parent &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, parent, id);
}

class MixedJsonDocumentSnapshot extends FirestoreDocumentSnapshot {
  MixedJsonDocumentSnapshot._(
    this.snapshot,
    this.data,
  );

  @override
  final DocumentSnapshot<MixedJson> snapshot;

  @override
  MixedJsonDocumentReference get reference {
    return MixedJsonDocumentReference(
      snapshot.reference,
    );
  }

  @override
  final MixedJson? data;
}

abstract class MixedJsonQuery
    implements QueryReference<MixedJsonQuerySnapshot> {
  @override
  MixedJsonQuery limit(int limit);

  @override
  MixedJsonQuery limitToLast(int limit);

  MixedJsonQuery whereValue({
    int? isEqualTo,
    int? isNotEqualTo,
    int? isLessThan,
    int? isLessThanOrEqualTo,
    int? isGreaterThan,
    int? isGreaterThanOrEqualTo,
    bool? isNull,
    List<int>? whereIn,
    List<int>? whereNotIn,
  });

  MixedJsonQuery orderByValue({
    bool descending = false,
    int startAt,
    int startAfter,
    int endAt,
    int endBefore,
    MixedJsonDocumentSnapshot? startAtDocument,
    MixedJsonDocumentSnapshot? endAtDocument,
    MixedJsonDocumentSnapshot? endBeforeDocument,
    MixedJsonDocumentSnapshot? startAfterDocument,
  });
}

class _$MixedJsonQuery extends QueryReference<MixedJsonQuerySnapshot>
    implements MixedJsonQuery {
  _$MixedJsonQuery(
    this.reference,
    this._collection,
  );

  final CollectionReference<Object?> _collection;

  @override
  final Query<MixedJson> reference;

  MixedJsonQuerySnapshot _decodeSnapshot(
    QuerySnapshot<MixedJson> snapshot,
  ) {
    final docs = snapshot.docs.map((e) {
      return MixedJsonQueryDocumentSnapshot._(e, e.data());
    }).toList();

    final docChanges = snapshot.docChanges.map((change) {
      return FirestoreDocumentChange<MixedJsonDocumentSnapshot>(
        type: change.type,
        oldIndex: change.oldIndex,
        newIndex: change.newIndex,
        doc: MixedJsonDocumentSnapshot._(change.doc, change.doc.data()),
      );
    }).toList();

    return MixedJsonQuerySnapshot._(
      snapshot,
      docs,
      docChanges,
    );
  }

  @override
  Stream<MixedJsonQuerySnapshot> snapshots([SnapshotOptions? options]) {
    return reference.snapshots().map(_decodeSnapshot);
  }

  @override
  Future<MixedJsonQuerySnapshot> get([GetOptions? options]) {
    return reference.get(options).then(_decodeSnapshot);
  }

  @override
  MixedJsonQuery limit(int limit) {
    return _$MixedJsonQuery(
      reference.limit(limit),
      _collection,
    );
  }

  @override
  MixedJsonQuery limitToLast(int limit) {
    return _$MixedJsonQuery(
      reference.limitToLast(limit),
      _collection,
    );
  }

  MixedJsonQuery whereValue({
    int? isEqualTo,
    int? isNotEqualTo,
    int? isLessThan,
    int? isLessThanOrEqualTo,
    int? isGreaterThan,
    int? isGreaterThanOrEqualTo,
    bool? isNull,
    List<int>? whereIn,
    List<int>? whereNotIn,
  }) {
    return _$MixedJsonQuery(
      reference.where(
        'value',
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        isNull: isNull,
        whereIn: whereIn,
        whereNotIn: whereNotIn,
      ),
      _collection,
    );
  }

  MixedJsonQuery orderByValue({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    MixedJsonDocumentSnapshot? startAtDocument,
    MixedJsonDocumentSnapshot? endAtDocument,
    MixedJsonDocumentSnapshot? endBeforeDocument,
    MixedJsonDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy('value', descending: false);

    if (startAtDocument != null) {
      query = query.startAtDocument(startAtDocument.snapshot);
    }
    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument.snapshot);
    }
    if (endAtDocument != null) {
      query = query.endAtDocument(endAtDocument.snapshot);
    }
    if (endBeforeDocument != null) {
      query = query.endBeforeDocument(endBeforeDocument.snapshot);
    }

    if (startAt != _sentinel) {
      query = query.startAt([startAt]);
    }
    if (startAfter != _sentinel) {
      query = query.startAfter([startAfter]);
    }
    if (endAt != _sentinel) {
      query = query.endAt([endAt]);
    }
    if (endBefore != _sentinel) {
      query = query.endBefore([endBefore]);
    }

    return _$MixedJsonQuery(query, _collection);
  }

  @override
  bool operator ==(Object other) {
    return other is _$MixedJsonQuery &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

class MixedJsonQuerySnapshot
    extends FirestoreQuerySnapshot<MixedJsonQueryDocumentSnapshot> {
  MixedJsonQuerySnapshot._(
    this.snapshot,
    this.docs,
    this.docChanges,
  );

  final QuerySnapshot<MixedJson> snapshot;

  @override
  final List<MixedJsonQueryDocumentSnapshot> docs;

  @override
  final List<FirestoreDocumentChange<MixedJsonDocumentSnapshot>> docChanges;
}

class MixedJsonQueryDocumentSnapshot extends FirestoreQueryDocumentSnapshot
    implements MixedJsonDocumentSnapshot {
  MixedJsonQueryDocumentSnapshot._(this.snapshot, this.data);

  @override
  final QueryDocumentSnapshot<MixedJson> snapshot;

  @override
  MixedJsonDocumentReference get reference {
    return MixedJsonDocumentReference(snapshot.reference);
  }

  @override
  final MixedJson data;
}

/// A collection reference object can be used for adding documents,
/// getting document references, and querying for documents
/// (using the methods inherited from Query).
abstract class RootCollectionReference
    implements RootQuery, FirestoreCollectionReference<RootQuerySnapshot> {
  factory RootCollectionReference([
    FirebaseFirestore? firestore,
  ]) = _$RootCollectionReference;

  static Root fromFirestore(
    DocumentSnapshot<Map<String, Object?>> snapshot,
    SnapshotOptions? options,
  ) {
    return Root.fromJson(snapshot.data()!);
  }

  static Map<String, Object?> toFirestore(
    Root value,
    SetOptions? options,
  ) {
    return value.toJson();
  }

  @override
  RootDocumentReference doc([String? id]);

  /// Add a new document to this collection with the specified data,
  /// assigning it a document ID automatically.
  Future<RootDocumentReference> add(Root value);
}

class _$RootCollectionReference extends _$RootQuery
    implements RootCollectionReference {
  factory _$RootCollectionReference([FirebaseFirestore? firestore]) {
    firestore ??= FirebaseFirestore.instance;

    return _$RootCollectionReference._(
      firestore.collection('root').withConverter(
            fromFirestore: RootCollectionReference.fromFirestore,
            toFirestore: RootCollectionReference.toFirestore,
          ),
    );
  }

  _$RootCollectionReference._(
    CollectionReference<Root> reference,
  ) : super(reference, reference);

  String get path => reference.path;

  @override
  CollectionReference<Root> get reference =>
      super.reference as CollectionReference<Root>;

  @override
  RootDocumentReference doc([String? id]) {
    return RootDocumentReference(
      reference.doc(id),
    );
  }

  @override
  Future<RootDocumentReference> add(Root value) {
    return reference.add(value).then((ref) => RootDocumentReference(ref));
  }

  @override
  bool operator ==(Object other) {
    return other is _$RootCollectionReference &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

abstract class RootDocumentReference
    extends FirestoreDocumentReference<RootDocumentSnapshot> {
  factory RootDocumentReference(DocumentReference<Root> reference) =
      _$RootDocumentReference;

  DocumentReference<Root> get reference;

  /// A reference to the [RootCollectionReference] containing this document.
  RootCollectionReference get parent {
    return _$RootCollectionReference(reference.firestore);
  }

  late final SubCollectionReference sub = _$SubCollectionReference(
    reference,
  );

  late final AsCamelCaseCollectionReference asCamelCase =
      _$AsCamelCaseCollectionReference(
    reference,
  );

  late final CustomSubNameCollectionReference thisIsACustomName =
      _$CustomSubNameCollectionReference(
    reference,
  );

  @override
  Stream<RootDocumentSnapshot> snapshots();

  @override
  Future<RootDocumentSnapshot> get([GetOptions? options]);

  @override
  Future<void> delete();

  Future<void> update({
    String nonNullable,
    int? nullable,
  });

  Future<void> set(Root value);
}

class _$RootDocumentReference
    extends FirestoreDocumentReference<RootDocumentSnapshot>
    implements RootDocumentReference {
  _$RootDocumentReference(this.reference);

  @override
  final DocumentReference<Root> reference;

  /// A reference to the [RootCollectionReference] containing this document.
  RootCollectionReference get parent {
    return _$RootCollectionReference(reference.firestore);
  }

  late final SubCollectionReference sub = _$SubCollectionReference(
    reference,
  );

  late final AsCamelCaseCollectionReference asCamelCase =
      _$AsCamelCaseCollectionReference(
    reference,
  );

  late final CustomSubNameCollectionReference thisIsACustomName =
      _$CustomSubNameCollectionReference(
    reference,
  );

  @override
  Stream<RootDocumentSnapshot> snapshots() {
    return reference.snapshots().map((snapshot) {
      return RootDocumentSnapshot._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<RootDocumentSnapshot> get([GetOptions? options]) {
    return reference.get(options).then((snapshot) {
      return RootDocumentSnapshot._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<void> delete() {
    return reference.delete();
  }

  Future<void> update({
    Object? nonNullable = _sentinel,
    Object? nullable = _sentinel,
  }) async {
    final json = {
      if (nonNullable != _sentinel) "nonNullable": nonNullable as String,
      if (nullable != _sentinel) "nullable": nullable as int?,
    };

    return reference.update(json);
  }

  Future<void> set(Root value) {
    return reference.set(value);
  }

  @override
  bool operator ==(Object other) {
    return other is RootDocumentReference &&
        other.runtimeType == runtimeType &&
        other.parent == parent &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, parent, id);
}

class RootDocumentSnapshot extends FirestoreDocumentSnapshot {
  RootDocumentSnapshot._(
    this.snapshot,
    this.data,
  );

  @override
  final DocumentSnapshot<Root> snapshot;

  @override
  RootDocumentReference get reference {
    return RootDocumentReference(
      snapshot.reference,
    );
  }

  @override
  final Root? data;
}

abstract class RootQuery implements QueryReference<RootQuerySnapshot> {
  @override
  RootQuery limit(int limit);

  @override
  RootQuery limitToLast(int limit);

  RootQuery whereNonNullable({
    String? isEqualTo,
    String? isNotEqualTo,
    String? isLessThan,
    String? isLessThanOrEqualTo,
    String? isGreaterThan,
    String? isGreaterThanOrEqualTo,
    bool? isNull,
    List<String>? whereIn,
    List<String>? whereNotIn,
  });
  RootQuery whereNullable({
    int? isEqualTo,
    int? isNotEqualTo,
    int? isLessThan,
    int? isLessThanOrEqualTo,
    int? isGreaterThan,
    int? isGreaterThanOrEqualTo,
    bool? isNull,
    List<int?>? whereIn,
    List<int?>? whereNotIn,
  });

  RootQuery orderByNonNullable({
    bool descending = false,
    String startAt,
    String startAfter,
    String endAt,
    String endBefore,
    RootDocumentSnapshot? startAtDocument,
    RootDocumentSnapshot? endAtDocument,
    RootDocumentSnapshot? endBeforeDocument,
    RootDocumentSnapshot? startAfterDocument,
  });

  RootQuery orderByNullable({
    bool descending = false,
    int? startAt,
    int? startAfter,
    int? endAt,
    int? endBefore,
    RootDocumentSnapshot? startAtDocument,
    RootDocumentSnapshot? endAtDocument,
    RootDocumentSnapshot? endBeforeDocument,
    RootDocumentSnapshot? startAfterDocument,
  });
}

class _$RootQuery extends QueryReference<RootQuerySnapshot>
    implements RootQuery {
  _$RootQuery(
    this.reference,
    this._collection,
  );

  final CollectionReference<Object?> _collection;

  @override
  final Query<Root> reference;

  RootQuerySnapshot _decodeSnapshot(
    QuerySnapshot<Root> snapshot,
  ) {
    final docs = snapshot.docs.map((e) {
      return RootQueryDocumentSnapshot._(e, e.data());
    }).toList();

    final docChanges = snapshot.docChanges.map((change) {
      return FirestoreDocumentChange<RootDocumentSnapshot>(
        type: change.type,
        oldIndex: change.oldIndex,
        newIndex: change.newIndex,
        doc: RootDocumentSnapshot._(change.doc, change.doc.data()),
      );
    }).toList();

    return RootQuerySnapshot._(
      snapshot,
      docs,
      docChanges,
    );
  }

  @override
  Stream<RootQuerySnapshot> snapshots([SnapshotOptions? options]) {
    return reference.snapshots().map(_decodeSnapshot);
  }

  @override
  Future<RootQuerySnapshot> get([GetOptions? options]) {
    return reference.get(options).then(_decodeSnapshot);
  }

  @override
  RootQuery limit(int limit) {
    return _$RootQuery(
      reference.limit(limit),
      _collection,
    );
  }

  @override
  RootQuery limitToLast(int limit) {
    return _$RootQuery(
      reference.limitToLast(limit),
      _collection,
    );
  }

  RootQuery whereNonNullable({
    String? isEqualTo,
    String? isNotEqualTo,
    String? isLessThan,
    String? isLessThanOrEqualTo,
    String? isGreaterThan,
    String? isGreaterThanOrEqualTo,
    bool? isNull,
    List<String>? whereIn,
    List<String>? whereNotIn,
  }) {
    return _$RootQuery(
      reference.where(
        'nonNullable',
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        isNull: isNull,
        whereIn: whereIn,
        whereNotIn: whereNotIn,
      ),
      _collection,
    );
  }

  RootQuery whereNullable({
    int? isEqualTo,
    int? isNotEqualTo,
    int? isLessThan,
    int? isLessThanOrEqualTo,
    int? isGreaterThan,
    int? isGreaterThanOrEqualTo,
    bool? isNull,
    List<int?>? whereIn,
    List<int?>? whereNotIn,
  }) {
    return _$RootQuery(
      reference.where(
        'nullable',
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        isNull: isNull,
        whereIn: whereIn,
        whereNotIn: whereNotIn,
      ),
      _collection,
    );
  }

  RootQuery orderByNonNullable({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    RootDocumentSnapshot? startAtDocument,
    RootDocumentSnapshot? endAtDocument,
    RootDocumentSnapshot? endBeforeDocument,
    RootDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy('nonNullable', descending: false);

    if (startAtDocument != null) {
      query = query.startAtDocument(startAtDocument.snapshot);
    }
    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument.snapshot);
    }
    if (endAtDocument != null) {
      query = query.endAtDocument(endAtDocument.snapshot);
    }
    if (endBeforeDocument != null) {
      query = query.endBeforeDocument(endBeforeDocument.snapshot);
    }

    if (startAt != _sentinel) {
      query = query.startAt([startAt]);
    }
    if (startAfter != _sentinel) {
      query = query.startAfter([startAfter]);
    }
    if (endAt != _sentinel) {
      query = query.endAt([endAt]);
    }
    if (endBefore != _sentinel) {
      query = query.endBefore([endBefore]);
    }

    return _$RootQuery(query, _collection);
  }

  RootQuery orderByNullable({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    RootDocumentSnapshot? startAtDocument,
    RootDocumentSnapshot? endAtDocument,
    RootDocumentSnapshot? endBeforeDocument,
    RootDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy('nullable', descending: false);

    if (startAtDocument != null) {
      query = query.startAtDocument(startAtDocument.snapshot);
    }
    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument.snapshot);
    }
    if (endAtDocument != null) {
      query = query.endAtDocument(endAtDocument.snapshot);
    }
    if (endBeforeDocument != null) {
      query = query.endBeforeDocument(endBeforeDocument.snapshot);
    }

    if (startAt != _sentinel) {
      query = query.startAt([startAt]);
    }
    if (startAfter != _sentinel) {
      query = query.startAfter([startAfter]);
    }
    if (endAt != _sentinel) {
      query = query.endAt([endAt]);
    }
    if (endBefore != _sentinel) {
      query = query.endBefore([endBefore]);
    }

    return _$RootQuery(query, _collection);
  }

  @override
  bool operator ==(Object other) {
    return other is _$RootQuery &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

class RootQuerySnapshot
    extends FirestoreQuerySnapshot<RootQueryDocumentSnapshot> {
  RootQuerySnapshot._(
    this.snapshot,
    this.docs,
    this.docChanges,
  );

  final QuerySnapshot<Root> snapshot;

  @override
  final List<RootQueryDocumentSnapshot> docs;

  @override
  final List<FirestoreDocumentChange<RootDocumentSnapshot>> docChanges;
}

class RootQueryDocumentSnapshot extends FirestoreQueryDocumentSnapshot
    implements RootDocumentSnapshot {
  RootQueryDocumentSnapshot._(this.snapshot, this.data);

  @override
  final QueryDocumentSnapshot<Root> snapshot;

  @override
  RootDocumentReference get reference {
    return RootDocumentReference(snapshot.reference);
  }

  @override
  final Root data;
}

/// A collection reference object can be used for adding documents,
/// getting document references, and querying for documents
/// (using the methods inherited from Query).
abstract class SubCollectionReference
    implements SubQuery, FirestoreCollectionReference<SubQuerySnapshot> {
  factory SubCollectionReference(
    DocumentReference<Root> parent,
  ) = _$SubCollectionReference;

  static Sub fromFirestore(
    DocumentSnapshot<Map<String, Object?>> snapshot,
    SnapshotOptions? options,
  ) {
    return Sub.fromJson(snapshot.data()!);
  }

  static Map<String, Object?> toFirestore(
    Sub value,
    SetOptions? options,
  ) {
    return value.toJson();
  }

  /// A reference to the containing [RootDocumentReference] if this is a subcollection.
  RootDocumentReference get parent;

  @override
  SubDocumentReference doc([String? id]);

  /// Add a new document to this collection with the specified data,
  /// assigning it a document ID automatically.
  Future<SubDocumentReference> add(Sub value);
}

class _$SubCollectionReference extends _$SubQuery
    implements SubCollectionReference {
  factory _$SubCollectionReference(
    DocumentReference<Root> parent,
  ) {
    return _$SubCollectionReference._(
      RootDocumentReference(parent),
      parent.collection('sub').withConverter(
            fromFirestore: SubCollectionReference.fromFirestore,
            toFirestore: SubCollectionReference.toFirestore,
          ),
    );
  }

  _$SubCollectionReference._(
    this.parent,
    CollectionReference<Sub> reference,
  ) : super(reference, reference);

  @override
  final RootDocumentReference parent;

  String get path => reference.path;

  @override
  CollectionReference<Sub> get reference =>
      super.reference as CollectionReference<Sub>;

  @override
  SubDocumentReference doc([String? id]) {
    return SubDocumentReference(
      reference.doc(id),
    );
  }

  @override
  Future<SubDocumentReference> add(Sub value) {
    return reference.add(value).then((ref) => SubDocumentReference(ref));
  }

  @override
  bool operator ==(Object other) {
    return other is _$SubCollectionReference &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

abstract class SubDocumentReference
    extends FirestoreDocumentReference<SubDocumentSnapshot> {
  factory SubDocumentReference(DocumentReference<Sub> reference) =
      _$SubDocumentReference;

  DocumentReference<Sub> get reference;

  /// A reference to the [SubCollectionReference] containing this document.
  SubCollectionReference get parent {
    return _$SubCollectionReference(
      reference.parent.parent!.withConverter<Root>(
        fromFirestore: RootCollectionReference.fromFirestore,
        toFirestore: RootCollectionReference.toFirestore,
      ),
    );
  }

  @override
  Stream<SubDocumentSnapshot> snapshots();

  @override
  Future<SubDocumentSnapshot> get([GetOptions? options]);

  @override
  Future<void> delete();

  Future<void> update({
    String nonNullable,
    int? nullable,
  });

  Future<void> set(Sub value);
}

class _$SubDocumentReference
    extends FirestoreDocumentReference<SubDocumentSnapshot>
    implements SubDocumentReference {
  _$SubDocumentReference(this.reference);

  @override
  final DocumentReference<Sub> reference;

  /// A reference to the [SubCollectionReference] containing this document.
  SubCollectionReference get parent {
    return _$SubCollectionReference(
      reference.parent.parent!.withConverter<Root>(
        fromFirestore: RootCollectionReference.fromFirestore,
        toFirestore: RootCollectionReference.toFirestore,
      ),
    );
  }

  @override
  Stream<SubDocumentSnapshot> snapshots() {
    return reference.snapshots().map((snapshot) {
      return SubDocumentSnapshot._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<SubDocumentSnapshot> get([GetOptions? options]) {
    return reference.get(options).then((snapshot) {
      return SubDocumentSnapshot._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<void> delete() {
    return reference.delete();
  }

  Future<void> update({
    Object? nonNullable = _sentinel,
    Object? nullable = _sentinel,
  }) async {
    final json = {
      if (nonNullable != _sentinel) "nonNullable": nonNullable as String,
      if (nullable != _sentinel) "nullable": nullable as int?,
    };

    return reference.update(json);
  }

  Future<void> set(Sub value) {
    return reference.set(value);
  }

  @override
  bool operator ==(Object other) {
    return other is SubDocumentReference &&
        other.runtimeType == runtimeType &&
        other.parent == parent &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, parent, id);
}

class SubDocumentSnapshot extends FirestoreDocumentSnapshot {
  SubDocumentSnapshot._(
    this.snapshot,
    this.data,
  );

  @override
  final DocumentSnapshot<Sub> snapshot;

  @override
  SubDocumentReference get reference {
    return SubDocumentReference(
      snapshot.reference,
    );
  }

  @override
  final Sub? data;
}

abstract class SubQuery implements QueryReference<SubQuerySnapshot> {
  @override
  SubQuery limit(int limit);

  @override
  SubQuery limitToLast(int limit);

  SubQuery whereNonNullable({
    String? isEqualTo,
    String? isNotEqualTo,
    String? isLessThan,
    String? isLessThanOrEqualTo,
    String? isGreaterThan,
    String? isGreaterThanOrEqualTo,
    bool? isNull,
    List<String>? whereIn,
    List<String>? whereNotIn,
  });
  SubQuery whereNullable({
    int? isEqualTo,
    int? isNotEqualTo,
    int? isLessThan,
    int? isLessThanOrEqualTo,
    int? isGreaterThan,
    int? isGreaterThanOrEqualTo,
    bool? isNull,
    List<int?>? whereIn,
    List<int?>? whereNotIn,
  });

  SubQuery orderByNonNullable({
    bool descending = false,
    String startAt,
    String startAfter,
    String endAt,
    String endBefore,
    SubDocumentSnapshot? startAtDocument,
    SubDocumentSnapshot? endAtDocument,
    SubDocumentSnapshot? endBeforeDocument,
    SubDocumentSnapshot? startAfterDocument,
  });

  SubQuery orderByNullable({
    bool descending = false,
    int? startAt,
    int? startAfter,
    int? endAt,
    int? endBefore,
    SubDocumentSnapshot? startAtDocument,
    SubDocumentSnapshot? endAtDocument,
    SubDocumentSnapshot? endBeforeDocument,
    SubDocumentSnapshot? startAfterDocument,
  });
}

class _$SubQuery extends QueryReference<SubQuerySnapshot> implements SubQuery {
  _$SubQuery(
    this.reference,
    this._collection,
  );

  final CollectionReference<Object?> _collection;

  @override
  final Query<Sub> reference;

  SubQuerySnapshot _decodeSnapshot(
    QuerySnapshot<Sub> snapshot,
  ) {
    final docs = snapshot.docs.map((e) {
      return SubQueryDocumentSnapshot._(e, e.data());
    }).toList();

    final docChanges = snapshot.docChanges.map((change) {
      return FirestoreDocumentChange<SubDocumentSnapshot>(
        type: change.type,
        oldIndex: change.oldIndex,
        newIndex: change.newIndex,
        doc: SubDocumentSnapshot._(change.doc, change.doc.data()),
      );
    }).toList();

    return SubQuerySnapshot._(
      snapshot,
      docs,
      docChanges,
    );
  }

  @override
  Stream<SubQuerySnapshot> snapshots([SnapshotOptions? options]) {
    return reference.snapshots().map(_decodeSnapshot);
  }

  @override
  Future<SubQuerySnapshot> get([GetOptions? options]) {
    return reference.get(options).then(_decodeSnapshot);
  }

  @override
  SubQuery limit(int limit) {
    return _$SubQuery(
      reference.limit(limit),
      _collection,
    );
  }

  @override
  SubQuery limitToLast(int limit) {
    return _$SubQuery(
      reference.limitToLast(limit),
      _collection,
    );
  }

  SubQuery whereNonNullable({
    String? isEqualTo,
    String? isNotEqualTo,
    String? isLessThan,
    String? isLessThanOrEqualTo,
    String? isGreaterThan,
    String? isGreaterThanOrEqualTo,
    bool? isNull,
    List<String>? whereIn,
    List<String>? whereNotIn,
  }) {
    return _$SubQuery(
      reference.where(
        'nonNullable',
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        isNull: isNull,
        whereIn: whereIn,
        whereNotIn: whereNotIn,
      ),
      _collection,
    );
  }

  SubQuery whereNullable({
    int? isEqualTo,
    int? isNotEqualTo,
    int? isLessThan,
    int? isLessThanOrEqualTo,
    int? isGreaterThan,
    int? isGreaterThanOrEqualTo,
    bool? isNull,
    List<int?>? whereIn,
    List<int?>? whereNotIn,
  }) {
    return _$SubQuery(
      reference.where(
        'nullable',
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        isNull: isNull,
        whereIn: whereIn,
        whereNotIn: whereNotIn,
      ),
      _collection,
    );
  }

  SubQuery orderByNonNullable({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    SubDocumentSnapshot? startAtDocument,
    SubDocumentSnapshot? endAtDocument,
    SubDocumentSnapshot? endBeforeDocument,
    SubDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy('nonNullable', descending: false);

    if (startAtDocument != null) {
      query = query.startAtDocument(startAtDocument.snapshot);
    }
    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument.snapshot);
    }
    if (endAtDocument != null) {
      query = query.endAtDocument(endAtDocument.snapshot);
    }
    if (endBeforeDocument != null) {
      query = query.endBeforeDocument(endBeforeDocument.snapshot);
    }

    if (startAt != _sentinel) {
      query = query.startAt([startAt]);
    }
    if (startAfter != _sentinel) {
      query = query.startAfter([startAfter]);
    }
    if (endAt != _sentinel) {
      query = query.endAt([endAt]);
    }
    if (endBefore != _sentinel) {
      query = query.endBefore([endBefore]);
    }

    return _$SubQuery(query, _collection);
  }

  SubQuery orderByNullable({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    SubDocumentSnapshot? startAtDocument,
    SubDocumentSnapshot? endAtDocument,
    SubDocumentSnapshot? endBeforeDocument,
    SubDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy('nullable', descending: false);

    if (startAtDocument != null) {
      query = query.startAtDocument(startAtDocument.snapshot);
    }
    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument.snapshot);
    }
    if (endAtDocument != null) {
      query = query.endAtDocument(endAtDocument.snapshot);
    }
    if (endBeforeDocument != null) {
      query = query.endBeforeDocument(endBeforeDocument.snapshot);
    }

    if (startAt != _sentinel) {
      query = query.startAt([startAt]);
    }
    if (startAfter != _sentinel) {
      query = query.startAfter([startAfter]);
    }
    if (endAt != _sentinel) {
      query = query.endAt([endAt]);
    }
    if (endBefore != _sentinel) {
      query = query.endBefore([endBefore]);
    }

    return _$SubQuery(query, _collection);
  }

  @override
  bool operator ==(Object other) {
    return other is _$SubQuery &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

class SubQuerySnapshot
    extends FirestoreQuerySnapshot<SubQueryDocumentSnapshot> {
  SubQuerySnapshot._(
    this.snapshot,
    this.docs,
    this.docChanges,
  );

  final QuerySnapshot<Sub> snapshot;

  @override
  final List<SubQueryDocumentSnapshot> docs;

  @override
  final List<FirestoreDocumentChange<SubDocumentSnapshot>> docChanges;
}

class SubQueryDocumentSnapshot extends FirestoreQueryDocumentSnapshot
    implements SubDocumentSnapshot {
  SubQueryDocumentSnapshot._(this.snapshot, this.data);

  @override
  final QueryDocumentSnapshot<Sub> snapshot;

  @override
  SubDocumentReference get reference {
    return SubDocumentReference(snapshot.reference);
  }

  @override
  final Sub data;
}

/// A collection reference object can be used for adding documents,
/// getting document references, and querying for documents
/// (using the methods inherited from Query).
abstract class AsCamelCaseCollectionReference
    implements
        AsCamelCaseQuery,
        FirestoreCollectionReference<AsCamelCaseQuerySnapshot> {
  factory AsCamelCaseCollectionReference(
    DocumentReference<Root> parent,
  ) = _$AsCamelCaseCollectionReference;

  static AsCamelCase fromFirestore(
    DocumentSnapshot<Map<String, Object?>> snapshot,
    SnapshotOptions? options,
  ) {
    return AsCamelCase.fromJson(snapshot.data()!);
  }

  static Map<String, Object?> toFirestore(
    AsCamelCase value,
    SetOptions? options,
  ) {
    return value.toJson();
  }

  /// A reference to the containing [RootDocumentReference] if this is a subcollection.
  RootDocumentReference get parent;

  @override
  AsCamelCaseDocumentReference doc([String? id]);

  /// Add a new document to this collection with the specified data,
  /// assigning it a document ID automatically.
  Future<AsCamelCaseDocumentReference> add(AsCamelCase value);
}

class _$AsCamelCaseCollectionReference extends _$AsCamelCaseQuery
    implements AsCamelCaseCollectionReference {
  factory _$AsCamelCaseCollectionReference(
    DocumentReference<Root> parent,
  ) {
    return _$AsCamelCaseCollectionReference._(
      RootDocumentReference(parent),
      parent.collection('as-camel-case').withConverter(
            fromFirestore: AsCamelCaseCollectionReference.fromFirestore,
            toFirestore: AsCamelCaseCollectionReference.toFirestore,
          ),
    );
  }

  _$AsCamelCaseCollectionReference._(
    this.parent,
    CollectionReference<AsCamelCase> reference,
  ) : super(reference, reference);

  @override
  final RootDocumentReference parent;

  String get path => reference.path;

  @override
  CollectionReference<AsCamelCase> get reference =>
      super.reference as CollectionReference<AsCamelCase>;

  @override
  AsCamelCaseDocumentReference doc([String? id]) {
    return AsCamelCaseDocumentReference(
      reference.doc(id),
    );
  }

  @override
  Future<AsCamelCaseDocumentReference> add(AsCamelCase value) {
    return reference
        .add(value)
        .then((ref) => AsCamelCaseDocumentReference(ref));
  }

  @override
  bool operator ==(Object other) {
    return other is _$AsCamelCaseCollectionReference &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

abstract class AsCamelCaseDocumentReference
    extends FirestoreDocumentReference<AsCamelCaseDocumentSnapshot> {
  factory AsCamelCaseDocumentReference(
          DocumentReference<AsCamelCase> reference) =
      _$AsCamelCaseDocumentReference;

  DocumentReference<AsCamelCase> get reference;

  /// A reference to the [AsCamelCaseCollectionReference] containing this document.
  AsCamelCaseCollectionReference get parent {
    return _$AsCamelCaseCollectionReference(
      reference.parent.parent!.withConverter<Root>(
        fromFirestore: RootCollectionReference.fromFirestore,
        toFirestore: RootCollectionReference.toFirestore,
      ),
    );
  }

  @override
  Stream<AsCamelCaseDocumentSnapshot> snapshots();

  @override
  Future<AsCamelCaseDocumentSnapshot> get([GetOptions? options]);

  @override
  Future<void> delete();

  Future<void> update({
    num value,
  });

  Future<void> set(AsCamelCase value);
}

class _$AsCamelCaseDocumentReference
    extends FirestoreDocumentReference<AsCamelCaseDocumentSnapshot>
    implements AsCamelCaseDocumentReference {
  _$AsCamelCaseDocumentReference(this.reference);

  @override
  final DocumentReference<AsCamelCase> reference;

  /// A reference to the [AsCamelCaseCollectionReference] containing this document.
  AsCamelCaseCollectionReference get parent {
    return _$AsCamelCaseCollectionReference(
      reference.parent.parent!.withConverter<Root>(
        fromFirestore: RootCollectionReference.fromFirestore,
        toFirestore: RootCollectionReference.toFirestore,
      ),
    );
  }

  @override
  Stream<AsCamelCaseDocumentSnapshot> snapshots() {
    return reference.snapshots().map((snapshot) {
      return AsCamelCaseDocumentSnapshot._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<AsCamelCaseDocumentSnapshot> get([GetOptions? options]) {
    return reference.get(options).then((snapshot) {
      return AsCamelCaseDocumentSnapshot._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<void> delete() {
    return reference.delete();
  }

  Future<void> update({
    Object? value = _sentinel,
  }) async {
    final json = {
      if (value != _sentinel) "value": value as num,
    };

    return reference.update(json);
  }

  Future<void> set(AsCamelCase value) {
    return reference.set(value);
  }

  @override
  bool operator ==(Object other) {
    return other is AsCamelCaseDocumentReference &&
        other.runtimeType == runtimeType &&
        other.parent == parent &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, parent, id);
}

class AsCamelCaseDocumentSnapshot extends FirestoreDocumentSnapshot {
  AsCamelCaseDocumentSnapshot._(
    this.snapshot,
    this.data,
  );

  @override
  final DocumentSnapshot<AsCamelCase> snapshot;

  @override
  AsCamelCaseDocumentReference get reference {
    return AsCamelCaseDocumentReference(
      snapshot.reference,
    );
  }

  @override
  final AsCamelCase? data;
}

abstract class AsCamelCaseQuery
    implements QueryReference<AsCamelCaseQuerySnapshot> {
  @override
  AsCamelCaseQuery limit(int limit);

  @override
  AsCamelCaseQuery limitToLast(int limit);

  AsCamelCaseQuery whereValue({
    num? isEqualTo,
    num? isNotEqualTo,
    num? isLessThan,
    num? isLessThanOrEqualTo,
    num? isGreaterThan,
    num? isGreaterThanOrEqualTo,
    bool? isNull,
    List<num>? whereIn,
    List<num>? whereNotIn,
  });

  AsCamelCaseQuery orderByValue({
    bool descending = false,
    num startAt,
    num startAfter,
    num endAt,
    num endBefore,
    AsCamelCaseDocumentSnapshot? startAtDocument,
    AsCamelCaseDocumentSnapshot? endAtDocument,
    AsCamelCaseDocumentSnapshot? endBeforeDocument,
    AsCamelCaseDocumentSnapshot? startAfterDocument,
  });
}

class _$AsCamelCaseQuery extends QueryReference<AsCamelCaseQuerySnapshot>
    implements AsCamelCaseQuery {
  _$AsCamelCaseQuery(
    this.reference,
    this._collection,
  );

  final CollectionReference<Object?> _collection;

  @override
  final Query<AsCamelCase> reference;

  AsCamelCaseQuerySnapshot _decodeSnapshot(
    QuerySnapshot<AsCamelCase> snapshot,
  ) {
    final docs = snapshot.docs.map((e) {
      return AsCamelCaseQueryDocumentSnapshot._(e, e.data());
    }).toList();

    final docChanges = snapshot.docChanges.map((change) {
      return FirestoreDocumentChange<AsCamelCaseDocumentSnapshot>(
        type: change.type,
        oldIndex: change.oldIndex,
        newIndex: change.newIndex,
        doc: AsCamelCaseDocumentSnapshot._(change.doc, change.doc.data()),
      );
    }).toList();

    return AsCamelCaseQuerySnapshot._(
      snapshot,
      docs,
      docChanges,
    );
  }

  @override
  Stream<AsCamelCaseQuerySnapshot> snapshots([SnapshotOptions? options]) {
    return reference.snapshots().map(_decodeSnapshot);
  }

  @override
  Future<AsCamelCaseQuerySnapshot> get([GetOptions? options]) {
    return reference.get(options).then(_decodeSnapshot);
  }

  @override
  AsCamelCaseQuery limit(int limit) {
    return _$AsCamelCaseQuery(
      reference.limit(limit),
      _collection,
    );
  }

  @override
  AsCamelCaseQuery limitToLast(int limit) {
    return _$AsCamelCaseQuery(
      reference.limitToLast(limit),
      _collection,
    );
  }

  AsCamelCaseQuery whereValue({
    num? isEqualTo,
    num? isNotEqualTo,
    num? isLessThan,
    num? isLessThanOrEqualTo,
    num? isGreaterThan,
    num? isGreaterThanOrEqualTo,
    bool? isNull,
    List<num>? whereIn,
    List<num>? whereNotIn,
  }) {
    return _$AsCamelCaseQuery(
      reference.where(
        'value',
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        isNull: isNull,
        whereIn: whereIn,
        whereNotIn: whereNotIn,
      ),
      _collection,
    );
  }

  AsCamelCaseQuery orderByValue({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    AsCamelCaseDocumentSnapshot? startAtDocument,
    AsCamelCaseDocumentSnapshot? endAtDocument,
    AsCamelCaseDocumentSnapshot? endBeforeDocument,
    AsCamelCaseDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy('value', descending: false);

    if (startAtDocument != null) {
      query = query.startAtDocument(startAtDocument.snapshot);
    }
    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument.snapshot);
    }
    if (endAtDocument != null) {
      query = query.endAtDocument(endAtDocument.snapshot);
    }
    if (endBeforeDocument != null) {
      query = query.endBeforeDocument(endBeforeDocument.snapshot);
    }

    if (startAt != _sentinel) {
      query = query.startAt([startAt]);
    }
    if (startAfter != _sentinel) {
      query = query.startAfter([startAfter]);
    }
    if (endAt != _sentinel) {
      query = query.endAt([endAt]);
    }
    if (endBefore != _sentinel) {
      query = query.endBefore([endBefore]);
    }

    return _$AsCamelCaseQuery(query, _collection);
  }

  @override
  bool operator ==(Object other) {
    return other is _$AsCamelCaseQuery &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

class AsCamelCaseQuerySnapshot
    extends FirestoreQuerySnapshot<AsCamelCaseQueryDocumentSnapshot> {
  AsCamelCaseQuerySnapshot._(
    this.snapshot,
    this.docs,
    this.docChanges,
  );

  final QuerySnapshot<AsCamelCase> snapshot;

  @override
  final List<AsCamelCaseQueryDocumentSnapshot> docs;

  @override
  final List<FirestoreDocumentChange<AsCamelCaseDocumentSnapshot>> docChanges;
}

class AsCamelCaseQueryDocumentSnapshot extends FirestoreQueryDocumentSnapshot
    implements AsCamelCaseDocumentSnapshot {
  AsCamelCaseQueryDocumentSnapshot._(this.snapshot, this.data);

  @override
  final QueryDocumentSnapshot<AsCamelCase> snapshot;

  @override
  AsCamelCaseDocumentReference get reference {
    return AsCamelCaseDocumentReference(snapshot.reference);
  }

  @override
  final AsCamelCase data;
}

/// A collection reference object can be used for adding documents,
/// getting document references, and querying for documents
/// (using the methods inherited from Query).
abstract class CustomSubNameCollectionReference
    implements
        CustomSubNameQuery,
        FirestoreCollectionReference<CustomSubNameQuerySnapshot> {
  factory CustomSubNameCollectionReference(
    DocumentReference<Root> parent,
  ) = _$CustomSubNameCollectionReference;

  static CustomSubName fromFirestore(
    DocumentSnapshot<Map<String, Object?>> snapshot,
    SnapshotOptions? options,
  ) {
    return CustomSubName.fromJson(snapshot.data()!);
  }

  static Map<String, Object?> toFirestore(
    CustomSubName value,
    SetOptions? options,
  ) {
    return value.toJson();
  }

  /// A reference to the containing [RootDocumentReference] if this is a subcollection.
  RootDocumentReference get parent;

  @override
  CustomSubNameDocumentReference doc([String? id]);

  /// Add a new document to this collection with the specified data,
  /// assigning it a document ID automatically.
  Future<CustomSubNameDocumentReference> add(CustomSubName value);
}

class _$CustomSubNameCollectionReference extends _$CustomSubNameQuery
    implements CustomSubNameCollectionReference {
  factory _$CustomSubNameCollectionReference(
    DocumentReference<Root> parent,
  ) {
    return _$CustomSubNameCollectionReference._(
      RootDocumentReference(parent),
      parent.collection('custom-sub-name').withConverter(
            fromFirestore: CustomSubNameCollectionReference.fromFirestore,
            toFirestore: CustomSubNameCollectionReference.toFirestore,
          ),
    );
  }

  _$CustomSubNameCollectionReference._(
    this.parent,
    CollectionReference<CustomSubName> reference,
  ) : super(reference, reference);

  @override
  final RootDocumentReference parent;

  String get path => reference.path;

  @override
  CollectionReference<CustomSubName> get reference =>
      super.reference as CollectionReference<CustomSubName>;

  @override
  CustomSubNameDocumentReference doc([String? id]) {
    return CustomSubNameDocumentReference(
      reference.doc(id),
    );
  }

  @override
  Future<CustomSubNameDocumentReference> add(CustomSubName value) {
    return reference
        .add(value)
        .then((ref) => CustomSubNameDocumentReference(ref));
  }

  @override
  bool operator ==(Object other) {
    return other is _$CustomSubNameCollectionReference &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

abstract class CustomSubNameDocumentReference
    extends FirestoreDocumentReference<CustomSubNameDocumentSnapshot> {
  factory CustomSubNameDocumentReference(
          DocumentReference<CustomSubName> reference) =
      _$CustomSubNameDocumentReference;

  DocumentReference<CustomSubName> get reference;

  /// A reference to the [CustomSubNameCollectionReference] containing this document.
  CustomSubNameCollectionReference get parent {
    return _$CustomSubNameCollectionReference(
      reference.parent.parent!.withConverter<Root>(
        fromFirestore: RootCollectionReference.fromFirestore,
        toFirestore: RootCollectionReference.toFirestore,
      ),
    );
  }

  @override
  Stream<CustomSubNameDocumentSnapshot> snapshots();

  @override
  Future<CustomSubNameDocumentSnapshot> get([GetOptions? options]);

  @override
  Future<void> delete();

  Future<void> update({
    num value,
  });

  Future<void> set(CustomSubName value);
}

class _$CustomSubNameDocumentReference
    extends FirestoreDocumentReference<CustomSubNameDocumentSnapshot>
    implements CustomSubNameDocumentReference {
  _$CustomSubNameDocumentReference(this.reference);

  @override
  final DocumentReference<CustomSubName> reference;

  /// A reference to the [CustomSubNameCollectionReference] containing this document.
  CustomSubNameCollectionReference get parent {
    return _$CustomSubNameCollectionReference(
      reference.parent.parent!.withConverter<Root>(
        fromFirestore: RootCollectionReference.fromFirestore,
        toFirestore: RootCollectionReference.toFirestore,
      ),
    );
  }

  @override
  Stream<CustomSubNameDocumentSnapshot> snapshots() {
    return reference.snapshots().map((snapshot) {
      return CustomSubNameDocumentSnapshot._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<CustomSubNameDocumentSnapshot> get([GetOptions? options]) {
    return reference.get(options).then((snapshot) {
      return CustomSubNameDocumentSnapshot._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<void> delete() {
    return reference.delete();
  }

  Future<void> update({
    Object? value = _sentinel,
  }) async {
    final json = {
      if (value != _sentinel) "value": value as num,
    };

    return reference.update(json);
  }

  Future<void> set(CustomSubName value) {
    return reference.set(value);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomSubNameDocumentReference &&
        other.runtimeType == runtimeType &&
        other.parent == parent &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, parent, id);
}

class CustomSubNameDocumentSnapshot extends FirestoreDocumentSnapshot {
  CustomSubNameDocumentSnapshot._(
    this.snapshot,
    this.data,
  );

  @override
  final DocumentSnapshot<CustomSubName> snapshot;

  @override
  CustomSubNameDocumentReference get reference {
    return CustomSubNameDocumentReference(
      snapshot.reference,
    );
  }

  @override
  final CustomSubName? data;
}

abstract class CustomSubNameQuery
    implements QueryReference<CustomSubNameQuerySnapshot> {
  @override
  CustomSubNameQuery limit(int limit);

  @override
  CustomSubNameQuery limitToLast(int limit);

  CustomSubNameQuery whereValue({
    num? isEqualTo,
    num? isNotEqualTo,
    num? isLessThan,
    num? isLessThanOrEqualTo,
    num? isGreaterThan,
    num? isGreaterThanOrEqualTo,
    bool? isNull,
    List<num>? whereIn,
    List<num>? whereNotIn,
  });

  CustomSubNameQuery orderByValue({
    bool descending = false,
    num startAt,
    num startAfter,
    num endAt,
    num endBefore,
    CustomSubNameDocumentSnapshot? startAtDocument,
    CustomSubNameDocumentSnapshot? endAtDocument,
    CustomSubNameDocumentSnapshot? endBeforeDocument,
    CustomSubNameDocumentSnapshot? startAfterDocument,
  });
}

class _$CustomSubNameQuery extends QueryReference<CustomSubNameQuerySnapshot>
    implements CustomSubNameQuery {
  _$CustomSubNameQuery(
    this.reference,
    this._collection,
  );

  final CollectionReference<Object?> _collection;

  @override
  final Query<CustomSubName> reference;

  CustomSubNameQuerySnapshot _decodeSnapshot(
    QuerySnapshot<CustomSubName> snapshot,
  ) {
    final docs = snapshot.docs.map((e) {
      return CustomSubNameQueryDocumentSnapshot._(e, e.data());
    }).toList();

    final docChanges = snapshot.docChanges.map((change) {
      return FirestoreDocumentChange<CustomSubNameDocumentSnapshot>(
        type: change.type,
        oldIndex: change.oldIndex,
        newIndex: change.newIndex,
        doc: CustomSubNameDocumentSnapshot._(change.doc, change.doc.data()),
      );
    }).toList();

    return CustomSubNameQuerySnapshot._(
      snapshot,
      docs,
      docChanges,
    );
  }

  @override
  Stream<CustomSubNameQuerySnapshot> snapshots([SnapshotOptions? options]) {
    return reference.snapshots().map(_decodeSnapshot);
  }

  @override
  Future<CustomSubNameQuerySnapshot> get([GetOptions? options]) {
    return reference.get(options).then(_decodeSnapshot);
  }

  @override
  CustomSubNameQuery limit(int limit) {
    return _$CustomSubNameQuery(
      reference.limit(limit),
      _collection,
    );
  }

  @override
  CustomSubNameQuery limitToLast(int limit) {
    return _$CustomSubNameQuery(
      reference.limitToLast(limit),
      _collection,
    );
  }

  CustomSubNameQuery whereValue({
    num? isEqualTo,
    num? isNotEqualTo,
    num? isLessThan,
    num? isLessThanOrEqualTo,
    num? isGreaterThan,
    num? isGreaterThanOrEqualTo,
    bool? isNull,
    List<num>? whereIn,
    List<num>? whereNotIn,
  }) {
    return _$CustomSubNameQuery(
      reference.where(
        'value',
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        isNull: isNull,
        whereIn: whereIn,
        whereNotIn: whereNotIn,
      ),
      _collection,
    );
  }

  CustomSubNameQuery orderByValue({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    CustomSubNameDocumentSnapshot? startAtDocument,
    CustomSubNameDocumentSnapshot? endAtDocument,
    CustomSubNameDocumentSnapshot? endBeforeDocument,
    CustomSubNameDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy('value', descending: false);

    if (startAtDocument != null) {
      query = query.startAtDocument(startAtDocument.snapshot);
    }
    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument.snapshot);
    }
    if (endAtDocument != null) {
      query = query.endAtDocument(endAtDocument.snapshot);
    }
    if (endBeforeDocument != null) {
      query = query.endBeforeDocument(endBeforeDocument.snapshot);
    }

    if (startAt != _sentinel) {
      query = query.startAt([startAt]);
    }
    if (startAfter != _sentinel) {
      query = query.startAfter([startAfter]);
    }
    if (endAt != _sentinel) {
      query = query.endAt([endAt]);
    }
    if (endBefore != _sentinel) {
      query = query.endBefore([endBefore]);
    }

    return _$CustomSubNameQuery(query, _collection);
  }

  @override
  bool operator ==(Object other) {
    return other is _$CustomSubNameQuery &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

class CustomSubNameQuerySnapshot
    extends FirestoreQuerySnapshot<CustomSubNameQueryDocumentSnapshot> {
  CustomSubNameQuerySnapshot._(
    this.snapshot,
    this.docs,
    this.docChanges,
  );

  final QuerySnapshot<CustomSubName> snapshot;

  @override
  final List<CustomSubNameQueryDocumentSnapshot> docs;

  @override
  final List<FirestoreDocumentChange<CustomSubNameDocumentSnapshot>> docChanges;
}

class CustomSubNameQueryDocumentSnapshot extends FirestoreQueryDocumentSnapshot
    implements CustomSubNameDocumentSnapshot {
  CustomSubNameQueryDocumentSnapshot._(this.snapshot, this.data);

  @override
  final QueryDocumentSnapshot<CustomSubName> snapshot;

  @override
  CustomSubNameDocumentReference get reference {
    return CustomSubNameDocumentReference(snapshot.reference);
  }

  @override
  final CustomSubName data;
}

/// A collection reference object can be used for adding documents,
/// getting document references, and querying for documents
/// (using the methods inherited from Query).
abstract class ExplicitPathCollectionReference
    implements
        ExplicitPathQuery,
        FirestoreCollectionReference<ExplicitPathQuerySnapshot> {
  factory ExplicitPathCollectionReference([
    FirebaseFirestore? firestore,
  ]) = _$ExplicitPathCollectionReference;

  static ExplicitPath fromFirestore(
    DocumentSnapshot<Map<String, Object?>> snapshot,
    SnapshotOptions? options,
  ) {
    return ExplicitPath.fromJson(snapshot.data()!);
  }

  static Map<String, Object?> toFirestore(
    ExplicitPath value,
    SetOptions? options,
  ) {
    return value.toJson();
  }

  @override
  ExplicitPathDocumentReference doc([String? id]);

  /// Add a new document to this collection with the specified data,
  /// assigning it a document ID automatically.
  Future<ExplicitPathDocumentReference> add(ExplicitPath value);
}

class _$ExplicitPathCollectionReference extends _$ExplicitPathQuery
    implements ExplicitPathCollectionReference {
  factory _$ExplicitPathCollectionReference([FirebaseFirestore? firestore]) {
    firestore ??= FirebaseFirestore.instance;

    return _$ExplicitPathCollectionReference._(
      firestore.collection('root/doc/path').withConverter(
            fromFirestore: ExplicitPathCollectionReference.fromFirestore,
            toFirestore: ExplicitPathCollectionReference.toFirestore,
          ),
    );
  }

  _$ExplicitPathCollectionReference._(
    CollectionReference<ExplicitPath> reference,
  ) : super(reference, reference);

  String get path => reference.path;

  @override
  CollectionReference<ExplicitPath> get reference =>
      super.reference as CollectionReference<ExplicitPath>;

  @override
  ExplicitPathDocumentReference doc([String? id]) {
    return ExplicitPathDocumentReference(
      reference.doc(id),
    );
  }

  @override
  Future<ExplicitPathDocumentReference> add(ExplicitPath value) {
    return reference
        .add(value)
        .then((ref) => ExplicitPathDocumentReference(ref));
  }

  @override
  bool operator ==(Object other) {
    return other is _$ExplicitPathCollectionReference &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

abstract class ExplicitPathDocumentReference
    extends FirestoreDocumentReference<ExplicitPathDocumentSnapshot> {
  factory ExplicitPathDocumentReference(
          DocumentReference<ExplicitPath> reference) =
      _$ExplicitPathDocumentReference;

  DocumentReference<ExplicitPath> get reference;

  /// A reference to the [ExplicitPathCollectionReference] containing this document.
  ExplicitPathCollectionReference get parent {
    return _$ExplicitPathCollectionReference(reference.firestore);
  }

  late final ExplicitSubPathCollectionReference sub =
      _$ExplicitSubPathCollectionReference(
    reference,
  );

  @override
  Stream<ExplicitPathDocumentSnapshot> snapshots();

  @override
  Future<ExplicitPathDocumentSnapshot> get([GetOptions? options]);

  @override
  Future<void> delete();

  Future<void> update({
    num value,
  });

  Future<void> set(ExplicitPath value);
}

class _$ExplicitPathDocumentReference
    extends FirestoreDocumentReference<ExplicitPathDocumentSnapshot>
    implements ExplicitPathDocumentReference {
  _$ExplicitPathDocumentReference(this.reference);

  @override
  final DocumentReference<ExplicitPath> reference;

  /// A reference to the [ExplicitPathCollectionReference] containing this document.
  ExplicitPathCollectionReference get parent {
    return _$ExplicitPathCollectionReference(reference.firestore);
  }

  late final ExplicitSubPathCollectionReference sub =
      _$ExplicitSubPathCollectionReference(
    reference,
  );

  @override
  Stream<ExplicitPathDocumentSnapshot> snapshots() {
    return reference.snapshots().map((snapshot) {
      return ExplicitPathDocumentSnapshot._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<ExplicitPathDocumentSnapshot> get([GetOptions? options]) {
    return reference.get(options).then((snapshot) {
      return ExplicitPathDocumentSnapshot._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<void> delete() {
    return reference.delete();
  }

  Future<void> update({
    Object? value = _sentinel,
  }) async {
    final json = {
      if (value != _sentinel) "value": value as num,
    };

    return reference.update(json);
  }

  Future<void> set(ExplicitPath value) {
    return reference.set(value);
  }

  @override
  bool operator ==(Object other) {
    return other is ExplicitPathDocumentReference &&
        other.runtimeType == runtimeType &&
        other.parent == parent &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, parent, id);
}

class ExplicitPathDocumentSnapshot extends FirestoreDocumentSnapshot {
  ExplicitPathDocumentSnapshot._(
    this.snapshot,
    this.data,
  );

  @override
  final DocumentSnapshot<ExplicitPath> snapshot;

  @override
  ExplicitPathDocumentReference get reference {
    return ExplicitPathDocumentReference(
      snapshot.reference,
    );
  }

  @override
  final ExplicitPath? data;
}

abstract class ExplicitPathQuery
    implements QueryReference<ExplicitPathQuerySnapshot> {
  @override
  ExplicitPathQuery limit(int limit);

  @override
  ExplicitPathQuery limitToLast(int limit);

  ExplicitPathQuery whereValue({
    num? isEqualTo,
    num? isNotEqualTo,
    num? isLessThan,
    num? isLessThanOrEqualTo,
    num? isGreaterThan,
    num? isGreaterThanOrEqualTo,
    bool? isNull,
    List<num>? whereIn,
    List<num>? whereNotIn,
  });

  ExplicitPathQuery orderByValue({
    bool descending = false,
    num startAt,
    num startAfter,
    num endAt,
    num endBefore,
    ExplicitPathDocumentSnapshot? startAtDocument,
    ExplicitPathDocumentSnapshot? endAtDocument,
    ExplicitPathDocumentSnapshot? endBeforeDocument,
    ExplicitPathDocumentSnapshot? startAfterDocument,
  });
}

class _$ExplicitPathQuery extends QueryReference<ExplicitPathQuerySnapshot>
    implements ExplicitPathQuery {
  _$ExplicitPathQuery(
    this.reference,
    this._collection,
  );

  final CollectionReference<Object?> _collection;

  @override
  final Query<ExplicitPath> reference;

  ExplicitPathQuerySnapshot _decodeSnapshot(
    QuerySnapshot<ExplicitPath> snapshot,
  ) {
    final docs = snapshot.docs.map((e) {
      return ExplicitPathQueryDocumentSnapshot._(e, e.data());
    }).toList();

    final docChanges = snapshot.docChanges.map((change) {
      return FirestoreDocumentChange<ExplicitPathDocumentSnapshot>(
        type: change.type,
        oldIndex: change.oldIndex,
        newIndex: change.newIndex,
        doc: ExplicitPathDocumentSnapshot._(change.doc, change.doc.data()),
      );
    }).toList();

    return ExplicitPathQuerySnapshot._(
      snapshot,
      docs,
      docChanges,
    );
  }

  @override
  Stream<ExplicitPathQuerySnapshot> snapshots([SnapshotOptions? options]) {
    return reference.snapshots().map(_decodeSnapshot);
  }

  @override
  Future<ExplicitPathQuerySnapshot> get([GetOptions? options]) {
    return reference.get(options).then(_decodeSnapshot);
  }

  @override
  ExplicitPathQuery limit(int limit) {
    return _$ExplicitPathQuery(
      reference.limit(limit),
      _collection,
    );
  }

  @override
  ExplicitPathQuery limitToLast(int limit) {
    return _$ExplicitPathQuery(
      reference.limitToLast(limit),
      _collection,
    );
  }

  ExplicitPathQuery whereValue({
    num? isEqualTo,
    num? isNotEqualTo,
    num? isLessThan,
    num? isLessThanOrEqualTo,
    num? isGreaterThan,
    num? isGreaterThanOrEqualTo,
    bool? isNull,
    List<num>? whereIn,
    List<num>? whereNotIn,
  }) {
    return _$ExplicitPathQuery(
      reference.where(
        'value',
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        isNull: isNull,
        whereIn: whereIn,
        whereNotIn: whereNotIn,
      ),
      _collection,
    );
  }

  ExplicitPathQuery orderByValue({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    ExplicitPathDocumentSnapshot? startAtDocument,
    ExplicitPathDocumentSnapshot? endAtDocument,
    ExplicitPathDocumentSnapshot? endBeforeDocument,
    ExplicitPathDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy('value', descending: false);

    if (startAtDocument != null) {
      query = query.startAtDocument(startAtDocument.snapshot);
    }
    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument.snapshot);
    }
    if (endAtDocument != null) {
      query = query.endAtDocument(endAtDocument.snapshot);
    }
    if (endBeforeDocument != null) {
      query = query.endBeforeDocument(endBeforeDocument.snapshot);
    }

    if (startAt != _sentinel) {
      query = query.startAt([startAt]);
    }
    if (startAfter != _sentinel) {
      query = query.startAfter([startAfter]);
    }
    if (endAt != _sentinel) {
      query = query.endAt([endAt]);
    }
    if (endBefore != _sentinel) {
      query = query.endBefore([endBefore]);
    }

    return _$ExplicitPathQuery(query, _collection);
  }

  @override
  bool operator ==(Object other) {
    return other is _$ExplicitPathQuery &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

class ExplicitPathQuerySnapshot
    extends FirestoreQuerySnapshot<ExplicitPathQueryDocumentSnapshot> {
  ExplicitPathQuerySnapshot._(
    this.snapshot,
    this.docs,
    this.docChanges,
  );

  final QuerySnapshot<ExplicitPath> snapshot;

  @override
  final List<ExplicitPathQueryDocumentSnapshot> docs;

  @override
  final List<FirestoreDocumentChange<ExplicitPathDocumentSnapshot>> docChanges;
}

class ExplicitPathQueryDocumentSnapshot extends FirestoreQueryDocumentSnapshot
    implements ExplicitPathDocumentSnapshot {
  ExplicitPathQueryDocumentSnapshot._(this.snapshot, this.data);

  @override
  final QueryDocumentSnapshot<ExplicitPath> snapshot;

  @override
  ExplicitPathDocumentReference get reference {
    return ExplicitPathDocumentReference(snapshot.reference);
  }

  @override
  final ExplicitPath data;
}

/// A collection reference object can be used for adding documents,
/// getting document references, and querying for documents
/// (using the methods inherited from Query).
abstract class ExplicitSubPathCollectionReference
    implements
        ExplicitSubPathQuery,
        FirestoreCollectionReference<ExplicitSubPathQuerySnapshot> {
  factory ExplicitSubPathCollectionReference(
    DocumentReference<ExplicitPath> parent,
  ) = _$ExplicitSubPathCollectionReference;

  static ExplicitSubPath fromFirestore(
    DocumentSnapshot<Map<String, Object?>> snapshot,
    SnapshotOptions? options,
  ) {
    return ExplicitSubPath.fromJson(snapshot.data()!);
  }

  static Map<String, Object?> toFirestore(
    ExplicitSubPath value,
    SetOptions? options,
  ) {
    return value.toJson();
  }

  /// A reference to the containing [ExplicitPathDocumentReference] if this is a subcollection.
  ExplicitPathDocumentReference get parent;

  @override
  ExplicitSubPathDocumentReference doc([String? id]);

  /// Add a new document to this collection with the specified data,
  /// assigning it a document ID automatically.
  Future<ExplicitSubPathDocumentReference> add(ExplicitSubPath value);
}

class _$ExplicitSubPathCollectionReference extends _$ExplicitSubPathQuery
    implements ExplicitSubPathCollectionReference {
  factory _$ExplicitSubPathCollectionReference(
    DocumentReference<ExplicitPath> parent,
  ) {
    return _$ExplicitSubPathCollectionReference._(
      ExplicitPathDocumentReference(parent),
      parent.collection('sub').withConverter(
            fromFirestore: ExplicitSubPathCollectionReference.fromFirestore,
            toFirestore: ExplicitSubPathCollectionReference.toFirestore,
          ),
    );
  }

  _$ExplicitSubPathCollectionReference._(
    this.parent,
    CollectionReference<ExplicitSubPath> reference,
  ) : super(reference, reference);

  @override
  final ExplicitPathDocumentReference parent;

  String get path => reference.path;

  @override
  CollectionReference<ExplicitSubPath> get reference =>
      super.reference as CollectionReference<ExplicitSubPath>;

  @override
  ExplicitSubPathDocumentReference doc([String? id]) {
    return ExplicitSubPathDocumentReference(
      reference.doc(id),
    );
  }

  @override
  Future<ExplicitSubPathDocumentReference> add(ExplicitSubPath value) {
    return reference
        .add(value)
        .then((ref) => ExplicitSubPathDocumentReference(ref));
  }

  @override
  bool operator ==(Object other) {
    return other is _$ExplicitSubPathCollectionReference &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

abstract class ExplicitSubPathDocumentReference
    extends FirestoreDocumentReference<ExplicitSubPathDocumentSnapshot> {
  factory ExplicitSubPathDocumentReference(
          DocumentReference<ExplicitSubPath> reference) =
      _$ExplicitSubPathDocumentReference;

  DocumentReference<ExplicitSubPath> get reference;

  /// A reference to the [ExplicitSubPathCollectionReference] containing this document.
  ExplicitSubPathCollectionReference get parent {
    return _$ExplicitSubPathCollectionReference(
      reference.parent.parent!.withConverter<ExplicitPath>(
        fromFirestore: ExplicitPathCollectionReference.fromFirestore,
        toFirestore: ExplicitPathCollectionReference.toFirestore,
      ),
    );
  }

  @override
  Stream<ExplicitSubPathDocumentSnapshot> snapshots();

  @override
  Future<ExplicitSubPathDocumentSnapshot> get([GetOptions? options]);

  @override
  Future<void> delete();

  Future<void> update({
    num value,
  });

  Future<void> set(ExplicitSubPath value);
}

class _$ExplicitSubPathDocumentReference
    extends FirestoreDocumentReference<ExplicitSubPathDocumentSnapshot>
    implements ExplicitSubPathDocumentReference {
  _$ExplicitSubPathDocumentReference(this.reference);

  @override
  final DocumentReference<ExplicitSubPath> reference;

  /// A reference to the [ExplicitSubPathCollectionReference] containing this document.
  ExplicitSubPathCollectionReference get parent {
    return _$ExplicitSubPathCollectionReference(
      reference.parent.parent!.withConverter<ExplicitPath>(
        fromFirestore: ExplicitPathCollectionReference.fromFirestore,
        toFirestore: ExplicitPathCollectionReference.toFirestore,
      ),
    );
  }

  @override
  Stream<ExplicitSubPathDocumentSnapshot> snapshots() {
    return reference.snapshots().map((snapshot) {
      return ExplicitSubPathDocumentSnapshot._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<ExplicitSubPathDocumentSnapshot> get([GetOptions? options]) {
    return reference.get(options).then((snapshot) {
      return ExplicitSubPathDocumentSnapshot._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<void> delete() {
    return reference.delete();
  }

  Future<void> update({
    Object? value = _sentinel,
  }) async {
    final json = {
      if (value != _sentinel) "value": value as num,
    };

    return reference.update(json);
  }

  Future<void> set(ExplicitSubPath value) {
    return reference.set(value);
  }

  @override
  bool operator ==(Object other) {
    return other is ExplicitSubPathDocumentReference &&
        other.runtimeType == runtimeType &&
        other.parent == parent &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, parent, id);
}

class ExplicitSubPathDocumentSnapshot extends FirestoreDocumentSnapshot {
  ExplicitSubPathDocumentSnapshot._(
    this.snapshot,
    this.data,
  );

  @override
  final DocumentSnapshot<ExplicitSubPath> snapshot;

  @override
  ExplicitSubPathDocumentReference get reference {
    return ExplicitSubPathDocumentReference(
      snapshot.reference,
    );
  }

  @override
  final ExplicitSubPath? data;
}

abstract class ExplicitSubPathQuery
    implements QueryReference<ExplicitSubPathQuerySnapshot> {
  @override
  ExplicitSubPathQuery limit(int limit);

  @override
  ExplicitSubPathQuery limitToLast(int limit);

  ExplicitSubPathQuery whereValue({
    num? isEqualTo,
    num? isNotEqualTo,
    num? isLessThan,
    num? isLessThanOrEqualTo,
    num? isGreaterThan,
    num? isGreaterThanOrEqualTo,
    bool? isNull,
    List<num>? whereIn,
    List<num>? whereNotIn,
  });

  ExplicitSubPathQuery orderByValue({
    bool descending = false,
    num startAt,
    num startAfter,
    num endAt,
    num endBefore,
    ExplicitSubPathDocumentSnapshot? startAtDocument,
    ExplicitSubPathDocumentSnapshot? endAtDocument,
    ExplicitSubPathDocumentSnapshot? endBeforeDocument,
    ExplicitSubPathDocumentSnapshot? startAfterDocument,
  });
}

class _$ExplicitSubPathQuery
    extends QueryReference<ExplicitSubPathQuerySnapshot>
    implements ExplicitSubPathQuery {
  _$ExplicitSubPathQuery(
    this.reference,
    this._collection,
  );

  final CollectionReference<Object?> _collection;

  @override
  final Query<ExplicitSubPath> reference;

  ExplicitSubPathQuerySnapshot _decodeSnapshot(
    QuerySnapshot<ExplicitSubPath> snapshot,
  ) {
    final docs = snapshot.docs.map((e) {
      return ExplicitSubPathQueryDocumentSnapshot._(e, e.data());
    }).toList();

    final docChanges = snapshot.docChanges.map((change) {
      return FirestoreDocumentChange<ExplicitSubPathDocumentSnapshot>(
        type: change.type,
        oldIndex: change.oldIndex,
        newIndex: change.newIndex,
        doc: ExplicitSubPathDocumentSnapshot._(change.doc, change.doc.data()),
      );
    }).toList();

    return ExplicitSubPathQuerySnapshot._(
      snapshot,
      docs,
      docChanges,
    );
  }

  @override
  Stream<ExplicitSubPathQuerySnapshot> snapshots([SnapshotOptions? options]) {
    return reference.snapshots().map(_decodeSnapshot);
  }

  @override
  Future<ExplicitSubPathQuerySnapshot> get([GetOptions? options]) {
    return reference.get(options).then(_decodeSnapshot);
  }

  @override
  ExplicitSubPathQuery limit(int limit) {
    return _$ExplicitSubPathQuery(
      reference.limit(limit),
      _collection,
    );
  }

  @override
  ExplicitSubPathQuery limitToLast(int limit) {
    return _$ExplicitSubPathQuery(
      reference.limitToLast(limit),
      _collection,
    );
  }

  ExplicitSubPathQuery whereValue({
    num? isEqualTo,
    num? isNotEqualTo,
    num? isLessThan,
    num? isLessThanOrEqualTo,
    num? isGreaterThan,
    num? isGreaterThanOrEqualTo,
    bool? isNull,
    List<num>? whereIn,
    List<num>? whereNotIn,
  }) {
    return _$ExplicitSubPathQuery(
      reference.where(
        'value',
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        isNull: isNull,
        whereIn: whereIn,
        whereNotIn: whereNotIn,
      ),
      _collection,
    );
  }

  ExplicitSubPathQuery orderByValue({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    ExplicitSubPathDocumentSnapshot? startAtDocument,
    ExplicitSubPathDocumentSnapshot? endAtDocument,
    ExplicitSubPathDocumentSnapshot? endBeforeDocument,
    ExplicitSubPathDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy('value', descending: false);

    if (startAtDocument != null) {
      query = query.startAtDocument(startAtDocument.snapshot);
    }
    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument.snapshot);
    }
    if (endAtDocument != null) {
      query = query.endAtDocument(endAtDocument.snapshot);
    }
    if (endBeforeDocument != null) {
      query = query.endBeforeDocument(endBeforeDocument.snapshot);
    }

    if (startAt != _sentinel) {
      query = query.startAt([startAt]);
    }
    if (startAfter != _sentinel) {
      query = query.startAfter([startAfter]);
    }
    if (endAt != _sentinel) {
      query = query.endAt([endAt]);
    }
    if (endBefore != _sentinel) {
      query = query.endBefore([endBefore]);
    }

    return _$ExplicitSubPathQuery(query, _collection);
  }

  @override
  bool operator ==(Object other) {
    return other is _$ExplicitSubPathQuery &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

class ExplicitSubPathQuerySnapshot
    extends FirestoreQuerySnapshot<ExplicitSubPathQueryDocumentSnapshot> {
  ExplicitSubPathQuerySnapshot._(
    this.snapshot,
    this.docs,
    this.docChanges,
  );

  final QuerySnapshot<ExplicitSubPath> snapshot;

  @override
  final List<ExplicitSubPathQueryDocumentSnapshot> docs;

  @override
  final List<FirestoreDocumentChange<ExplicitSubPathDocumentSnapshot>>
      docChanges;
}

class ExplicitSubPathQueryDocumentSnapshot
    extends FirestoreQueryDocumentSnapshot
    implements ExplicitSubPathDocumentSnapshot {
  ExplicitSubPathQueryDocumentSnapshot._(this.snapshot, this.data);

  @override
  final QueryDocumentSnapshot<ExplicitSubPath> snapshot;

  @override
  ExplicitSubPathDocumentReference get reference {
    return ExplicitSubPathDocumentReference(snapshot.reference);
  }

  @override
  final ExplicitSubPath data;
}

// **************************************************************************
// ValidatorGenerator
// **************************************************************************

_$assertMinValidation(MinValidation instance) {
  const Min(0).validate(instance.intNbr, "intNbr");
  const Max(42).validate(instance.intNbr, "intNbr");
  const Min(10).validate(instance.doubleNbr, "doubleNbr");
  const Min(-10).validate(instance.numNbr, "numNbr");
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmptyModel _$EmptyModelFromJson(Map<String, dynamic> json) => EmptyModel();

Map<String, dynamic> _$EmptyModelToJson(EmptyModel instance) =>
    <String, dynamic>{};

MinValidation _$MinValidationFromJson(Map<String, dynamic> json) =>
    MinValidation(
      json['intNbr'] as int,
      (json['doubleNbr'] as num).toDouble(),
      json['numNbr'] as num,
    );

Map<String, dynamic> _$MinValidationToJson(MinValidation instance) =>
    <String, dynamic>{
      'intNbr': instance.intNbr,
      'doubleNbr': instance.doubleNbr,
      'numNbr': instance.numNbr,
    };

Root _$RootFromJson(Map<String, dynamic> json) => Root(
      json['nonNullable'] as String,
      json['nullable'] as int?,
    );

Map<String, dynamic> _$RootToJson(Root instance) => <String, dynamic>{
      'nonNullable': instance.nonNullable,
      'nullable': instance.nullable,
    };

OptionalJson _$OptionalJsonFromJson(Map<String, dynamic> json) => OptionalJson(
      json['value'] as int,
    );

Map<String, dynamic> _$OptionalJsonToJson(OptionalJson instance) =>
    <String, dynamic>{
      'value': instance.value,
    };

MixedJson _$MixedJsonFromJson(Map<String, dynamic> json) => MixedJson(
      json['value'] as int,
    );

Map<String, dynamic> _$MixedJsonToJson(MixedJson instance) => <String, dynamic>{
      'value': instance.value,
    };

Sub _$SubFromJson(Map<String, dynamic> json) => Sub(
      json['nonNullable'] as String,
      json['nullable'] as int?,
    );

Map<String, dynamic> _$SubToJson(Sub instance) => <String, dynamic>{
      'nonNullable': instance.nonNullable,
      'nullable': instance.nullable,
    };

CustomSubName _$CustomSubNameFromJson(Map<String, dynamic> json) =>
    CustomSubName(
      json['value'] as num,
    );

Map<String, dynamic> _$CustomSubNameToJson(CustomSubName instance) =>
    <String, dynamic>{
      'value': instance.value,
    };

AsCamelCase _$AsCamelCaseFromJson(Map<String, dynamic> json) => AsCamelCase(
      json['value'] as num,
    );

Map<String, dynamic> _$AsCamelCaseToJson(AsCamelCase instance) =>
    <String, dynamic>{
      'value': instance.value,
    };

ExplicitPath _$ExplicitPathFromJson(Map<String, dynamic> json) => ExplicitPath(
      json['value'] as num,
    );

Map<String, dynamic> _$ExplicitPathToJson(ExplicitPath instance) =>
    <String, dynamic>{
      'value': instance.value,
    };

ExplicitSubPath _$ExplicitSubPathFromJson(Map<String, dynamic> json) =>
    ExplicitSubPath(
      json['value'] as num,
    );

Map<String, dynamic> _$ExplicitSubPathToJson(ExplicitSubPath instance) =>
    <String, dynamic>{
      'value': instance.value,
    };
