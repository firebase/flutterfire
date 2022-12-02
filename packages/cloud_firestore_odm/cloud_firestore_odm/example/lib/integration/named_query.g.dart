// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'named_query.dart';

// **************************************************************************
// CollectionGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, require_trailing_commas, prefer_single_quotes, prefer_double_quotes, use_super_parameters

class _Sentinel {
  const _Sentinel();
}

const _sentinel = _Sentinel();

/// Adds [namedBundleTest4Get] to [FirebaseFirestore].
extension NamedBundleTest4Extrension on FirebaseFirestore {
  /// Performs [FirebaseFirestore.namedQueryGet] and decode the result into
  /// a [Conflict] snashot.
  Future<ConflictQuerySnapshot> namedBundleTest4Get({
    GetOptions options = const GetOptions(),
  }) async {
    final snapshot = await namedQueryWithConverterGet(
      r'named-bundle-test-4',
      fromFirestore: ConflictCollectionReference.fromFirestore,
      toFirestore: ConflictCollectionReference.toFirestore,
      options: options,
    );
    return ConflictQuerySnapshot._fromQuerySnapshot(snapshot);
  }
}

/// A collection reference object can be used for adding documents,
/// getting document references, and querying for documents
/// (using the methods inherited from Query).
abstract class ConflictCollectionReference
    implements
        ConflictQuery,
        FirestoreCollectionReference<Conflict, ConflictQuerySnapshot> {
  factory ConflictCollectionReference([
    FirebaseFirestore? firestore,
  ]) = _$ConflictCollectionReference;

  static Conflict fromFirestore(
    DocumentSnapshot<Map<String, Object?>> snapshot,
    SnapshotOptions? options,
  ) {
    return _$ConflictFromJson(snapshot.data()!);
  }

  static Map<String, Object?> toFirestore(
    Conflict value,
    SetOptions? options,
  ) {
    return _$ConflictToJson(value);
  }

  @override
  CollectionReference<Conflict> get reference;

  @override
  ConflictDocumentReference doc([String? id]);

  /// Add a new document to this collection with the specified data,
  /// assigning it a document ID automatically.
  Future<ConflictDocumentReference> add(Conflict value);
}

class _$ConflictCollectionReference extends _$ConflictQuery
    implements ConflictCollectionReference {
  factory _$ConflictCollectionReference([FirebaseFirestore? firestore]) {
    firestore ??= FirebaseFirestore.instance;

    return _$ConflictCollectionReference._(
      firestore
          .collection('firestore-example-app/42/named-query-conflict')
          .withConverter(
            fromFirestore: ConflictCollectionReference.fromFirestore,
            toFirestore: ConflictCollectionReference.toFirestore,
          ),
    );
  }

  _$ConflictCollectionReference._(
    CollectionReference<Conflict> reference,
  ) : super(reference, $referenceWithoutCursor: reference);

  String get path => reference.path;

  @override
  CollectionReference<Conflict> get reference =>
      super.reference as CollectionReference<Conflict>;

  @override
  ConflictDocumentReference doc([String? id]) {
    assert(
      id == null || id.split('/').length == 1,
      'The document ID cannot be from a different collection',
    );
    return ConflictDocumentReference(
      reference.doc(id),
    );
  }

  @override
  Future<ConflictDocumentReference> add(Conflict value) {
    return reference.add(value).then((ref) => ConflictDocumentReference(ref));
  }

  @override
  bool operator ==(Object other) {
    return other is _$ConflictCollectionReference &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

abstract class ConflictDocumentReference
    extends FirestoreDocumentReference<Conflict, ConflictDocumentSnapshot> {
  factory ConflictDocumentReference(DocumentReference<Conflict> reference) =
      _$ConflictDocumentReference;

  DocumentReference<Conflict> get reference;

  /// A reference to the [ConflictCollectionReference] containing this document.
  ConflictCollectionReference get parent {
    return _$ConflictCollectionReference(reference.firestore);
  }

  @override
  Stream<ConflictDocumentSnapshot> snapshots();

  @override
  Future<ConflictDocumentSnapshot> get([GetOptions? options]);

  @override
  Future<void> delete();

  /// Updates data on the document. Data will be merged with any existing
  /// document data.
  ///
  /// If no document exists yet, the update will fail.
  Future<void> update({
    num number,
    FieldValue numberFieldValue,
  });

  /// Updates fields in the current document using the transaction API.
  ///
  /// The update will fail if applied to a document that does not exist.
  void transactionUpdate(
    Transaction transaction, {
    num number,
    FieldValue numberFieldValue,
  });
}

class _$ConflictDocumentReference
    extends FirestoreDocumentReference<Conflict, ConflictDocumentSnapshot>
    implements ConflictDocumentReference {
  _$ConflictDocumentReference(this.reference);

  @override
  final DocumentReference<Conflict> reference;

  /// A reference to the [ConflictCollectionReference] containing this document.
  ConflictCollectionReference get parent {
    return _$ConflictCollectionReference(reference.firestore);
  }

  @override
  Stream<ConflictDocumentSnapshot> snapshots() {
    return reference.snapshots().map(ConflictDocumentSnapshot._);
  }

  @override
  Future<ConflictDocumentSnapshot> get([GetOptions? options]) {
    return reference.get(options).then(ConflictDocumentSnapshot._);
  }

  @override
  Future<ConflictDocumentSnapshot> transactionGet(Transaction transaction) {
    return transaction.get(reference).then(ConflictDocumentSnapshot._);
  }

  Future<void> update({
    Object? number = _sentinel,
    FieldValue? numberFieldValue,
  }) async {
    assert(
      number == _sentinel || numberFieldValue == null,
      "Cannot specify both number and numberFieldValue",
    );
    final json = {
      if (number != _sentinel) _$ConflictFieldMap['number']!: number as num,
      if (numberFieldValue != null)
        _$ConflictFieldMap['number']!: numberFieldValue,
    };

    return reference.update(json);
  }

  void transactionUpdate(
    Transaction transaction, {
    Object? number = _sentinel,
    FieldValue? numberFieldValue,
  }) {
    assert(
      number == _sentinel || numberFieldValue == null,
      "Cannot specify both number and numberFieldValue",
    );
    final json = {
      if (number != _sentinel) _$ConflictFieldMap['number']!: number as num,
      if (numberFieldValue != null)
        _$ConflictFieldMap['number']!: numberFieldValue,
    };

    transaction.update(reference, json);
  }

  @override
  bool operator ==(Object other) {
    return other is ConflictDocumentReference &&
        other.runtimeType == runtimeType &&
        other.parent == parent &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, parent, id);
}

abstract class ConflictQuery
    implements QueryReference<Conflict, ConflictQuerySnapshot> {
  @override
  ConflictQuery limit(int limit);

  @override
  ConflictQuery limitToLast(int limit);

  /// Perform an order query based on a [FieldPath].
  ///
  /// This method is considered unsafe as it does check that the field path
  /// maps to a valid property or that parameters such as [isEqualTo] receive
  /// a value of the correct type.
  ///
  /// If possible, instead use the more explicit variant of order queries:
  ///
  /// **AVOID**:
  /// ```dart
  /// collection.orderByFieldPath(
  ///   FieldPath.fromString('title'),
  ///   startAt: 'title',
  /// );
  /// ```
  ///
  /// **PREFER**:
  /// ```dart
  /// collection.orderByTitle(startAt: 'title');
  /// ```
  ConflictQuery orderByFieldPath(
    FieldPath fieldPath, {
    bool descending = false,
    Object? startAt,
    Object? startAfter,
    Object? endAt,
    Object? endBefore,
    ConflictDocumentSnapshot? startAtDocument,
    ConflictDocumentSnapshot? endAtDocument,
    ConflictDocumentSnapshot? endBeforeDocument,
    ConflictDocumentSnapshot? startAfterDocument,
  });

  /// Perform a where query based on a [FieldPath].
  ///
  /// This method is considered unsafe as it does check that the field path
  /// maps to a valid property or that parameters such as [isEqualTo] receive
  /// a value of the correct type.
  ///
  /// If possible, instead use the more explicit variant of where queries:
  ///
  /// **AVOID**:
  /// ```dart
  /// collection.whereFieldPath(FieldPath.fromString('title'), isEqualTo: 'title');
  /// ```
  ///
  /// **PREFER**:
  /// ```dart
  /// collection.whereTitle(isEqualTo: 'title');
  /// ```
  ConflictQuery whereFieldPath(
    FieldPath fieldPath, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    List<Object?>? arrayContainsAny,
    List<Object?>? whereIn,
    List<Object?>? whereNotIn,
    bool? isNull,
  });

  ConflictQuery whereDocumentId({
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
  ConflictQuery whereNumber({
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

  ConflictQuery orderByDocumentId({
    bool descending = false,
    String startAt,
    String startAfter,
    String endAt,
    String endBefore,
    ConflictDocumentSnapshot? startAtDocument,
    ConflictDocumentSnapshot? endAtDocument,
    ConflictDocumentSnapshot? endBeforeDocument,
    ConflictDocumentSnapshot? startAfterDocument,
  });

  ConflictQuery orderByNumber({
    bool descending = false,
    num startAt,
    num startAfter,
    num endAt,
    num endBefore,
    ConflictDocumentSnapshot? startAtDocument,
    ConflictDocumentSnapshot? endAtDocument,
    ConflictDocumentSnapshot? endBeforeDocument,
    ConflictDocumentSnapshot? startAfterDocument,
  });
}

class _$ConflictQuery extends QueryReference<Conflict, ConflictQuerySnapshot>
    implements ConflictQuery {
  _$ConflictQuery(
    this._collection, {
    required Query<Conflict> $referenceWithoutCursor,
    $QueryCursor $queryCursor = const $QueryCursor(),
  }) : super(
          $referenceWithoutCursor: $referenceWithoutCursor,
          $queryCursor: $queryCursor,
        );

  final CollectionReference<Object?> _collection;

  @override
  Stream<ConflictQuerySnapshot> snapshots([SnapshotOptions? options]) {
    return reference.snapshots().map(ConflictQuerySnapshot._fromQuerySnapshot);
  }

  @override
  Future<ConflictQuerySnapshot> get([GetOptions? options]) {
    return reference
        .get(options)
        .then(ConflictQuerySnapshot._fromQuerySnapshot);
  }

  @override
  ConflictQuery limit(int limit) {
    return _$ConflictQuery(
      _collection,
      $referenceWithoutCursor: $referenceWithoutCursor.limit(limit),
      $queryCursor: $queryCursor,
    );
  }

  @override
  ConflictQuery limitToLast(int limit) {
    return _$ConflictQuery(
      _collection,
      $referenceWithoutCursor: $referenceWithoutCursor.limitToLast(limit),
      $queryCursor: $queryCursor,
    );
  }

  ConflictQuery orderByFieldPath(
    FieldPath fieldPath, {
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    ConflictDocumentSnapshot? startAtDocument,
    ConflictDocumentSnapshot? endAtDocument,
    ConflictDocumentSnapshot? endBeforeDocument,
    ConflictDocumentSnapshot? startAfterDocument,
  }) {
    final query =
        $referenceWithoutCursor.orderBy(fieldPath, descending: descending);
    var queryCursor = $queryCursor;

    if (startAtDocument != null) {
      queryCursor = queryCursor.copyWith(
        startAt: const [],
        startAtDocumentSnapshot: startAtDocument.snapshot,
      );
    }
    if (startAfterDocument != null) {
      queryCursor = queryCursor.copyWith(
        startAfter: const [],
        startAfterDocumentSnapshot: startAfterDocument.snapshot,
      );
    }
    if (endAtDocument != null) {
      queryCursor = queryCursor.copyWith(
        endAt: const [],
        endAtDocumentSnapshot: endAtDocument.snapshot,
      );
    }
    if (endBeforeDocument != null) {
      queryCursor = queryCursor.copyWith(
        endBefore: const [],
        endBeforeDocumentSnapshot: endBeforeDocument.snapshot,
      );
    }

    if (startAt != _sentinel) {
      queryCursor = queryCursor.copyWith(
        startAt: [...queryCursor.startAt, startAt],
        startAtDocumentSnapshot: null,
      );
    }
    if (startAfter != _sentinel) {
      queryCursor = queryCursor.copyWith(
        startAfter: [...queryCursor.startAfter, startAfter],
        startAfterDocumentSnapshot: null,
      );
    }
    if (endAt != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endAt: [...queryCursor.endAt, endAt],
        endAtDocumentSnapshot: null,
      );
    }
    if (endBefore != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endBefore: [...queryCursor.endBefore, endBefore],
        endBeforeDocumentSnapshot: null,
      );
    }
    return _$ConflictQuery(
      _collection,
      $referenceWithoutCursor: query,
      $queryCursor: queryCursor,
    );
  }

  ConflictQuery whereFieldPath(
    FieldPath fieldPath, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    List<Object?>? arrayContainsAny,
    List<Object?>? whereIn,
    List<Object?>? whereNotIn,
    bool? isNull,
  }) {
    return _$ConflictQuery(
      _collection,
      $referenceWithoutCursor: $referenceWithoutCursor.where(
        fieldPath,
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        arrayContains: arrayContains,
        arrayContainsAny: arrayContainsAny,
        whereIn: whereIn,
        whereNotIn: whereNotIn,
        isNull: isNull,
      ),
      $queryCursor: $queryCursor,
    );
  }

  ConflictQuery whereDocumentId({
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
    return _$ConflictQuery(
      _collection,
      $referenceWithoutCursor: $referenceWithoutCursor.where(
        FieldPath.documentId,
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
      $queryCursor: $queryCursor,
    );
  }

  ConflictQuery whereNumber({
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
    return _$ConflictQuery(
      _collection,
      $referenceWithoutCursor: $referenceWithoutCursor.where(
        _$ConflictFieldMap['number']!,
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
      $queryCursor: $queryCursor,
    );
  }

  ConflictQuery orderByDocumentId({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    ConflictDocumentSnapshot? startAtDocument,
    ConflictDocumentSnapshot? endAtDocument,
    ConflictDocumentSnapshot? endBeforeDocument,
    ConflictDocumentSnapshot? startAfterDocument,
  }) {
    final query = $referenceWithoutCursor.orderBy(FieldPath.documentId,
        descending: descending);
    var queryCursor = $queryCursor;

    if (startAtDocument != null) {
      queryCursor = queryCursor.copyWith(
        startAt: const [],
        startAtDocumentSnapshot: startAtDocument.snapshot,
      );
    }
    if (startAfterDocument != null) {
      queryCursor = queryCursor.copyWith(
        startAfter: const [],
        startAfterDocumentSnapshot: startAfterDocument.snapshot,
      );
    }
    if (endAtDocument != null) {
      queryCursor = queryCursor.copyWith(
        endAt: const [],
        endAtDocumentSnapshot: endAtDocument.snapshot,
      );
    }
    if (endBeforeDocument != null) {
      queryCursor = queryCursor.copyWith(
        endBefore: const [],
        endBeforeDocumentSnapshot: endBeforeDocument.snapshot,
      );
    }

    if (startAt != _sentinel) {
      queryCursor = queryCursor.copyWith(
        startAt: [...queryCursor.startAt, startAt],
        startAtDocumentSnapshot: null,
      );
    }
    if (startAfter != _sentinel) {
      queryCursor = queryCursor.copyWith(
        startAfter: [...queryCursor.startAfter, startAfter],
        startAfterDocumentSnapshot: null,
      );
    }
    if (endAt != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endAt: [...queryCursor.endAt, endAt],
        endAtDocumentSnapshot: null,
      );
    }
    if (endBefore != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endBefore: [...queryCursor.endBefore, endBefore],
        endBeforeDocumentSnapshot: null,
      );
    }

    return _$ConflictQuery(
      _collection,
      $referenceWithoutCursor: query,
      $queryCursor: queryCursor,
    );
  }

  ConflictQuery orderByNumber({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    ConflictDocumentSnapshot? startAtDocument,
    ConflictDocumentSnapshot? endAtDocument,
    ConflictDocumentSnapshot? endBeforeDocument,
    ConflictDocumentSnapshot? startAfterDocument,
  }) {
    final query = $referenceWithoutCursor.orderBy(_$ConflictFieldMap['number']!,
        descending: descending);
    var queryCursor = $queryCursor;

    if (startAtDocument != null) {
      queryCursor = queryCursor.copyWith(
        startAt: const [],
        startAtDocumentSnapshot: startAtDocument.snapshot,
      );
    }
    if (startAfterDocument != null) {
      queryCursor = queryCursor.copyWith(
        startAfter: const [],
        startAfterDocumentSnapshot: startAfterDocument.snapshot,
      );
    }
    if (endAtDocument != null) {
      queryCursor = queryCursor.copyWith(
        endAt: const [],
        endAtDocumentSnapshot: endAtDocument.snapshot,
      );
    }
    if (endBeforeDocument != null) {
      queryCursor = queryCursor.copyWith(
        endBefore: const [],
        endBeforeDocumentSnapshot: endBeforeDocument.snapshot,
      );
    }

    if (startAt != _sentinel) {
      queryCursor = queryCursor.copyWith(
        startAt: [...queryCursor.startAt, startAt],
        startAtDocumentSnapshot: null,
      );
    }
    if (startAfter != _sentinel) {
      queryCursor = queryCursor.copyWith(
        startAfter: [...queryCursor.startAfter, startAfter],
        startAfterDocumentSnapshot: null,
      );
    }
    if (endAt != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endAt: [...queryCursor.endAt, endAt],
        endAtDocumentSnapshot: null,
      );
    }
    if (endBefore != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endBefore: [...queryCursor.endBefore, endBefore],
        endBeforeDocumentSnapshot: null,
      );
    }

    return _$ConflictQuery(
      _collection,
      $referenceWithoutCursor: query,
      $queryCursor: queryCursor,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is _$ConflictQuery &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

class ConflictDocumentSnapshot extends FirestoreDocumentSnapshot<Conflict> {
  ConflictDocumentSnapshot._(this.snapshot) : data = snapshot.data();

  @override
  final DocumentSnapshot<Conflict> snapshot;

  @override
  ConflictDocumentReference get reference {
    return ConflictDocumentReference(
      snapshot.reference,
    );
  }

  @override
  final Conflict? data;
}

class ConflictQuerySnapshot
    extends FirestoreQuerySnapshot<Conflict, ConflictQueryDocumentSnapshot> {
  ConflictQuerySnapshot._(
    this.snapshot,
    this.docs,
    this.docChanges,
  );

  factory ConflictQuerySnapshot._fromQuerySnapshot(
    QuerySnapshot<Conflict> snapshot,
  ) {
    final docs = snapshot.docs.map(ConflictQueryDocumentSnapshot._).toList();

    final docChanges = snapshot.docChanges.map((change) {
      return _decodeDocumentChange(
        change,
        ConflictDocumentSnapshot._,
      );
    }).toList();

    return ConflictQuerySnapshot._(
      snapshot,
      docs,
      docChanges,
    );
  }

  static FirestoreDocumentChange<ConflictDocumentSnapshot>
      _decodeDocumentChange<T>(
    DocumentChange<T> docChange,
    ConflictDocumentSnapshot Function(DocumentSnapshot<T> doc) decodeDoc,
  ) {
    return FirestoreDocumentChange<ConflictDocumentSnapshot>(
      type: docChange.type,
      oldIndex: docChange.oldIndex,
      newIndex: docChange.newIndex,
      doc: decodeDoc(docChange.doc),
    );
  }

  final QuerySnapshot<Conflict> snapshot;

  @override
  final List<ConflictQueryDocumentSnapshot> docs;

  @override
  final List<FirestoreDocumentChange<ConflictDocumentSnapshot>> docChanges;
}

class ConflictQueryDocumentSnapshot
    extends FirestoreQueryDocumentSnapshot<Conflict>
    implements ConflictDocumentSnapshot {
  ConflictQueryDocumentSnapshot._(this.snapshot) : data = snapshot.data();

  @override
  final QueryDocumentSnapshot<Conflict> snapshot;

  @override
  final Conflict data;

  @override
  ConflictDocumentReference get reference {
    return ConflictDocumentReference(snapshot.reference);
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Conflict _$ConflictFromJson(Map<String, dynamic> json) => Conflict(
      json['number'] as num,
    );

const _$ConflictFieldMap = <String, String>{
  'number': 'number',
};

Map<String, dynamic> _$ConflictToJson(Conflict instance) => <String, dynamic>{
      'number': instance.number,
    };
