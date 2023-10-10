// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'enums.dart';

// **************************************************************************
// CollectionGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, require_trailing_commas, prefer_single_quotes, prefer_double_quotes, use_super_parameters, duplicate_ignore

class _Sentinel {
  const _Sentinel();
}

const _sentinel = _Sentinel();

/// A collection reference object can be used for adding documents,
/// getting document references, and querying for documents
/// (using the methods inherited from Query).
abstract class EnumsCollectionReference
    implements
        EnumsQuery,
        FirestoreCollectionReference<Enums, EnumsQuerySnapshot> {
  factory EnumsCollectionReference([
    FirebaseFirestore? firestore,
  ]) = _$EnumsCollectionReference;

  static Enums fromFirestore(
    DocumentSnapshot<Map<String, Object?>> snapshot,
    SnapshotOptions? options,
  ) {
    return Enums.fromJson(snapshot.data()!);
  }

  static Map<String, Object?> toFirestore(
    Enums value,
    SetOptions? options,
  ) {
    return value.toJson();
  }

  @override
  CollectionReference<Enums> get reference;

  @override
  EnumsDocumentReference doc([String? id]);

  /// Add a new document to this collection with the specified data,
  /// assigning it a document ID automatically.
  Future<EnumsDocumentReference> add(Enums value);
}

class _$EnumsCollectionReference extends _$EnumsQuery
    implements EnumsCollectionReference {
  factory _$EnumsCollectionReference([FirebaseFirestore? firestore]) {
    firestore ??= FirebaseFirestore.instance;

    return _$EnumsCollectionReference._(
      firestore.collection('firestore-example-app').withConverter(
            fromFirestore: EnumsCollectionReference.fromFirestore,
            toFirestore: EnumsCollectionReference.toFirestore,
          ),
    );
  }

  _$EnumsCollectionReference._(
    CollectionReference<Enums> reference,
  ) : super(reference, $referenceWithoutCursor: reference);

  String get path => reference.path;

  @override
  CollectionReference<Enums> get reference =>
      super.reference as CollectionReference<Enums>;

  @override
  EnumsDocumentReference doc([String? id]) {
    assert(
      id == null || id.split('/').length == 1,
      'The document ID cannot be from a different collection',
    );
    return EnumsDocumentReference(
      reference.doc(id),
    );
  }

  @override
  Future<EnumsDocumentReference> add(Enums value) {
    return reference.add(value).then((ref) => EnumsDocumentReference(ref));
  }

  @override
  bool operator ==(Object other) {
    return other is _$EnumsCollectionReference &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

abstract class EnumsDocumentReference
    extends FirestoreDocumentReference<Enums, EnumsDocumentSnapshot> {
  factory EnumsDocumentReference(DocumentReference<Enums> reference) =
      _$EnumsDocumentReference;

  DocumentReference<Enums> get reference;

  /// A reference to the [EnumsCollectionReference] containing this document.
  EnumsCollectionReference get parent {
    return _$EnumsCollectionReference(reference.firestore);
  }

  @override
  Stream<EnumsDocumentSnapshot> snapshots();

  @override
  Future<EnumsDocumentSnapshot> get([GetOptions? options]);

  @override
  Future<void> delete();

  /// Updates data on the document. Data will be merged with any existing
  /// document data.
  ///
  /// If no document exists yet, the update will fail.
  Future<void> update({
    String id,
    FieldValue idFieldValue,
    TestEnum enumValue,
    FieldValue enumValueFieldValue,
    TestEnum? nullableEnumValue,
    FieldValue nullableEnumValueFieldValue,
    List<TestEnum> enumList,
    FieldValue enumListFieldValue,
    List<TestEnum>? nullableEnumList,
    FieldValue nullableEnumListFieldValue,
  });

  /// Updates fields in the current document using the transaction API.
  ///
  /// The update will fail if applied to a document that does not exist.
  void transactionUpdate(
    Transaction transaction, {
    String id,
    FieldValue idFieldValue,
    TestEnum enumValue,
    FieldValue enumValueFieldValue,
    TestEnum? nullableEnumValue,
    FieldValue nullableEnumValueFieldValue,
    List<TestEnum> enumList,
    FieldValue enumListFieldValue,
    List<TestEnum>? nullableEnumList,
    FieldValue nullableEnumListFieldValue,
  });
}

class _$EnumsDocumentReference
    extends FirestoreDocumentReference<Enums, EnumsDocumentSnapshot>
    implements EnumsDocumentReference {
  _$EnumsDocumentReference(this.reference);

  @override
  final DocumentReference<Enums> reference;

  /// A reference to the [EnumsCollectionReference] containing this document.
  EnumsCollectionReference get parent {
    return _$EnumsCollectionReference(reference.firestore);
  }

  @override
  Stream<EnumsDocumentSnapshot> snapshots() {
    return reference.snapshots().map(EnumsDocumentSnapshot._);
  }

  @override
  Future<EnumsDocumentSnapshot> get([GetOptions? options]) {
    return reference.get(options).then(EnumsDocumentSnapshot._);
  }

  @override
  Future<EnumsDocumentSnapshot> transactionGet(Transaction transaction) {
    return transaction.get(reference).then(EnumsDocumentSnapshot._);
  }

  Future<void> update({
    Object? id = _sentinel,
    FieldValue? idFieldValue,
    Object? enumValue = _sentinel,
    FieldValue? enumValueFieldValue,
    Object? nullableEnumValue = _sentinel,
    FieldValue? nullableEnumValueFieldValue,
    Object? enumList = _sentinel,
    FieldValue? enumListFieldValue,
    Object? nullableEnumList = _sentinel,
    FieldValue? nullableEnumListFieldValue,
  }) async {
    assert(
      id == _sentinel || idFieldValue == null,
      "Cannot specify both id and idFieldValue",
    );
    assert(
      enumValue == _sentinel || enumValueFieldValue == null,
      "Cannot specify both enumValue and enumValueFieldValue",
    );
    assert(
      nullableEnumValue == _sentinel || nullableEnumValueFieldValue == null,
      "Cannot specify both nullableEnumValue and nullableEnumValueFieldValue",
    );
    assert(
      enumList == _sentinel || enumListFieldValue == null,
      "Cannot specify both enumList and enumListFieldValue",
    );
    assert(
      nullableEnumList == _sentinel || nullableEnumListFieldValue == null,
      "Cannot specify both nullableEnumList and nullableEnumListFieldValue",
    );
    final json = {
      if (id != _sentinel)
        _$EnumsFieldMap['id']!: _$EnumsPerFieldToJson.id(id as String),
      if (idFieldValue != null) _$EnumsFieldMap['id']!: idFieldValue,
      if (enumValue != _sentinel)
        _$EnumsFieldMap['enumValue']!:
            _$EnumsPerFieldToJson.enumValue(enumValue as TestEnum),
      if (enumValueFieldValue != null)
        _$EnumsFieldMap['enumValue']!: enumValueFieldValue,
      if (nullableEnumValue != _sentinel)
        _$EnumsFieldMap['nullableEnumValue']!: _$EnumsPerFieldToJson
            .nullableEnumValue(nullableEnumValue as TestEnum?),
      if (nullableEnumValueFieldValue != null)
        _$EnumsFieldMap['nullableEnumValue']!: nullableEnumValueFieldValue,
      if (enumList != _sentinel)
        _$EnumsFieldMap['enumList']!:
            _$EnumsPerFieldToJson.enumList(enumList as List<TestEnum>),
      if (enumListFieldValue != null)
        _$EnumsFieldMap['enumList']!: enumListFieldValue,
      if (nullableEnumList != _sentinel)
        _$EnumsFieldMap['nullableEnumList']!: _$EnumsPerFieldToJson
            .nullableEnumList(nullableEnumList as List<TestEnum>?),
      if (nullableEnumListFieldValue != null)
        _$EnumsFieldMap['nullableEnumList']!: nullableEnumListFieldValue,
    };

    return reference.update(json);
  }

  void transactionUpdate(
    Transaction transaction, {
    Object? id = _sentinel,
    FieldValue? idFieldValue,
    Object? enumValue = _sentinel,
    FieldValue? enumValueFieldValue,
    Object? nullableEnumValue = _sentinel,
    FieldValue? nullableEnumValueFieldValue,
    Object? enumList = _sentinel,
    FieldValue? enumListFieldValue,
    Object? nullableEnumList = _sentinel,
    FieldValue? nullableEnumListFieldValue,
  }) {
    assert(
      id == _sentinel || idFieldValue == null,
      "Cannot specify both id and idFieldValue",
    );
    assert(
      enumValue == _sentinel || enumValueFieldValue == null,
      "Cannot specify both enumValue and enumValueFieldValue",
    );
    assert(
      nullableEnumValue == _sentinel || nullableEnumValueFieldValue == null,
      "Cannot specify both nullableEnumValue and nullableEnumValueFieldValue",
    );
    assert(
      enumList == _sentinel || enumListFieldValue == null,
      "Cannot specify both enumList and enumListFieldValue",
    );
    assert(
      nullableEnumList == _sentinel || nullableEnumListFieldValue == null,
      "Cannot specify both nullableEnumList and nullableEnumListFieldValue",
    );
    final json = {
      if (id != _sentinel)
        _$EnumsFieldMap['id']!: _$EnumsPerFieldToJson.id(id as String),
      if (idFieldValue != null) _$EnumsFieldMap['id']!: idFieldValue,
      if (enumValue != _sentinel)
        _$EnumsFieldMap['enumValue']!:
            _$EnumsPerFieldToJson.enumValue(enumValue as TestEnum),
      if (enumValueFieldValue != null)
        _$EnumsFieldMap['enumValue']!: enumValueFieldValue,
      if (nullableEnumValue != _sentinel)
        _$EnumsFieldMap['nullableEnumValue']!: _$EnumsPerFieldToJson
            .nullableEnumValue(nullableEnumValue as TestEnum?),
      if (nullableEnumValueFieldValue != null)
        _$EnumsFieldMap['nullableEnumValue']!: nullableEnumValueFieldValue,
      if (enumList != _sentinel)
        _$EnumsFieldMap['enumList']!:
            _$EnumsPerFieldToJson.enumList(enumList as List<TestEnum>),
      if (enumListFieldValue != null)
        _$EnumsFieldMap['enumList']!: enumListFieldValue,
      if (nullableEnumList != _sentinel)
        _$EnumsFieldMap['nullableEnumList']!: _$EnumsPerFieldToJson
            .nullableEnumList(nullableEnumList as List<TestEnum>?),
      if (nullableEnumListFieldValue != null)
        _$EnumsFieldMap['nullableEnumList']!: nullableEnumListFieldValue,
    };

    transaction.update(reference, json);
  }

  @override
  bool operator ==(Object other) {
    return other is EnumsDocumentReference &&
        other.runtimeType == runtimeType &&
        other.parent == parent &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, parent, id);
}

abstract class EnumsQuery implements QueryReference<Enums, EnumsQuerySnapshot> {
  @override
  EnumsQuery limit(int limit);

  @override
  EnumsQuery limitToLast(int limit);

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
  EnumsQuery orderByFieldPath(
    FieldPath fieldPath, {
    bool descending = false,
    Object? startAt,
    Object? startAfter,
    Object? endAt,
    Object? endBefore,
    EnumsDocumentSnapshot? startAtDocument,
    EnumsDocumentSnapshot? endAtDocument,
    EnumsDocumentSnapshot? endBeforeDocument,
    EnumsDocumentSnapshot? startAfterDocument,
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
  EnumsQuery whereFieldPath(
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

  EnumsQuery whereDocumentId({
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
  EnumsQuery whereId({
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
  EnumsQuery whereEnumValue({
    TestEnum? isEqualTo,
    TestEnum? isNotEqualTo,
    TestEnum? isLessThan,
    TestEnum? isLessThanOrEqualTo,
    TestEnum? isGreaterThan,
    TestEnum? isGreaterThanOrEqualTo,
    bool? isNull,
    List<TestEnum>? whereIn,
    List<TestEnum>? whereNotIn,
  });
  EnumsQuery whereNullableEnumValue({
    TestEnum? isEqualTo,
    TestEnum? isNotEqualTo,
    TestEnum? isLessThan,
    TestEnum? isLessThanOrEqualTo,
    TestEnum? isGreaterThan,
    TestEnum? isGreaterThanOrEqualTo,
    bool? isNull,
    List<TestEnum?>? whereIn,
    List<TestEnum?>? whereNotIn,
  });
  EnumsQuery whereEnumList({
    List<TestEnum>? isEqualTo,
    List<TestEnum>? isNotEqualTo,
    List<TestEnum>? isLessThan,
    List<TestEnum>? isLessThanOrEqualTo,
    List<TestEnum>? isGreaterThan,
    List<TestEnum>? isGreaterThanOrEqualTo,
    bool? isNull,
    TestEnum? arrayContains,
    List<TestEnum>? arrayContainsAny,
  });
  EnumsQuery whereNullableEnumList({
    List<TestEnum>? isEqualTo,
    List<TestEnum>? isNotEqualTo,
    List<TestEnum>? isLessThan,
    List<TestEnum>? isLessThanOrEqualTo,
    List<TestEnum>? isGreaterThan,
    List<TestEnum>? isGreaterThanOrEqualTo,
    bool? isNull,
    TestEnum? arrayContains,
    List<TestEnum>? arrayContainsAny,
  });

  EnumsQuery orderByDocumentId({
    bool descending = false,
    String startAt,
    String startAfter,
    String endAt,
    String endBefore,
    EnumsDocumentSnapshot? startAtDocument,
    EnumsDocumentSnapshot? endAtDocument,
    EnumsDocumentSnapshot? endBeforeDocument,
    EnumsDocumentSnapshot? startAfterDocument,
  });

  EnumsQuery orderById({
    bool descending = false,
    String startAt,
    String startAfter,
    String endAt,
    String endBefore,
    EnumsDocumentSnapshot? startAtDocument,
    EnumsDocumentSnapshot? endAtDocument,
    EnumsDocumentSnapshot? endBeforeDocument,
    EnumsDocumentSnapshot? startAfterDocument,
  });

  EnumsQuery orderByEnumValue({
    bool descending = false,
    TestEnum startAt,
    TestEnum startAfter,
    TestEnum endAt,
    TestEnum endBefore,
    EnumsDocumentSnapshot? startAtDocument,
    EnumsDocumentSnapshot? endAtDocument,
    EnumsDocumentSnapshot? endBeforeDocument,
    EnumsDocumentSnapshot? startAfterDocument,
  });

  EnumsQuery orderByNullableEnumValue({
    bool descending = false,
    TestEnum? startAt,
    TestEnum? startAfter,
    TestEnum? endAt,
    TestEnum? endBefore,
    EnumsDocumentSnapshot? startAtDocument,
    EnumsDocumentSnapshot? endAtDocument,
    EnumsDocumentSnapshot? endBeforeDocument,
    EnumsDocumentSnapshot? startAfterDocument,
  });

  EnumsQuery orderByEnumList({
    bool descending = false,
    List<TestEnum> startAt,
    List<TestEnum> startAfter,
    List<TestEnum> endAt,
    List<TestEnum> endBefore,
    EnumsDocumentSnapshot? startAtDocument,
    EnumsDocumentSnapshot? endAtDocument,
    EnumsDocumentSnapshot? endBeforeDocument,
    EnumsDocumentSnapshot? startAfterDocument,
  });

  EnumsQuery orderByNullableEnumList({
    bool descending = false,
    List<TestEnum>? startAt,
    List<TestEnum>? startAfter,
    List<TestEnum>? endAt,
    List<TestEnum>? endBefore,
    EnumsDocumentSnapshot? startAtDocument,
    EnumsDocumentSnapshot? endAtDocument,
    EnumsDocumentSnapshot? endBeforeDocument,
    EnumsDocumentSnapshot? startAfterDocument,
  });
}

class _$EnumsQuery extends QueryReference<Enums, EnumsQuerySnapshot>
    implements EnumsQuery {
  _$EnumsQuery(
    this._collection, {
    required Query<Enums> $referenceWithoutCursor,
    $QueryCursor $queryCursor = const $QueryCursor(),
  }) : super(
          $referenceWithoutCursor: $referenceWithoutCursor,
          $queryCursor: $queryCursor,
        );

  final CollectionReference<Object?> _collection;

  @override
  Stream<EnumsQuerySnapshot> snapshots([SnapshotOptions? options]) {
    return reference.snapshots().map(EnumsQuerySnapshot._fromQuerySnapshot);
  }

  @override
  Future<EnumsQuerySnapshot> get([GetOptions? options]) {
    return reference.get(options).then(EnumsQuerySnapshot._fromQuerySnapshot);
  }

  @override
  EnumsQuery limit(int limit) {
    return _$EnumsQuery(
      _collection,
      $referenceWithoutCursor: $referenceWithoutCursor.limit(limit),
      $queryCursor: $queryCursor,
    );
  }

  @override
  EnumsQuery limitToLast(int limit) {
    return _$EnumsQuery(
      _collection,
      $referenceWithoutCursor: $referenceWithoutCursor.limitToLast(limit),
      $queryCursor: $queryCursor,
    );
  }

  EnumsQuery orderByFieldPath(
    FieldPath fieldPath, {
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    EnumsDocumentSnapshot? startAtDocument,
    EnumsDocumentSnapshot? endAtDocument,
    EnumsDocumentSnapshot? endBeforeDocument,
    EnumsDocumentSnapshot? startAfterDocument,
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
    return _$EnumsQuery(
      _collection,
      $referenceWithoutCursor: query,
      $queryCursor: queryCursor,
    );
  }

  EnumsQuery whereFieldPath(
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
    return _$EnumsQuery(
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

  EnumsQuery whereDocumentId({
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
    return _$EnumsQuery(
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

  EnumsQuery whereId({
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
    return _$EnumsQuery(
      _collection,
      $referenceWithoutCursor: $referenceWithoutCursor.where(
        _$EnumsFieldMap['id']!,
        isEqualTo:
            isEqualTo != null ? _$EnumsPerFieldToJson.id(isEqualTo) : null,
        isNotEqualTo: isNotEqualTo != null
            ? _$EnumsPerFieldToJson.id(isNotEqualTo)
            : null,
        isLessThan:
            isLessThan != null ? _$EnumsPerFieldToJson.id(isLessThan) : null,
        isLessThanOrEqualTo: isLessThanOrEqualTo != null
            ? _$EnumsPerFieldToJson.id(isLessThanOrEqualTo)
            : null,
        isGreaterThan: isGreaterThan != null
            ? _$EnumsPerFieldToJson.id(isGreaterThan)
            : null,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo != null
            ? _$EnumsPerFieldToJson.id(isGreaterThanOrEqualTo)
            : null,
        isNull: isNull,
        whereIn: whereIn?.map((e) => _$EnumsPerFieldToJson.id(e)),
        whereNotIn: whereNotIn?.map((e) => _$EnumsPerFieldToJson.id(e)),
      ),
      $queryCursor: $queryCursor,
    );
  }

  EnumsQuery whereEnumValue({
    TestEnum? isEqualTo,
    TestEnum? isNotEqualTo,
    TestEnum? isLessThan,
    TestEnum? isLessThanOrEqualTo,
    TestEnum? isGreaterThan,
    TestEnum? isGreaterThanOrEqualTo,
    bool? isNull,
    List<TestEnum>? whereIn,
    List<TestEnum>? whereNotIn,
  }) {
    return _$EnumsQuery(
      _collection,
      $referenceWithoutCursor: $referenceWithoutCursor.where(
        _$EnumsFieldMap['enumValue']!,
        isEqualTo: isEqualTo != null
            ? _$EnumsPerFieldToJson.enumValue(isEqualTo)
            : null,
        isNotEqualTo: isNotEqualTo != null
            ? _$EnumsPerFieldToJson.enumValue(isNotEqualTo)
            : null,
        isLessThan: isLessThan != null
            ? _$EnumsPerFieldToJson.enumValue(isLessThan)
            : null,
        isLessThanOrEqualTo: isLessThanOrEqualTo != null
            ? _$EnumsPerFieldToJson.enumValue(isLessThanOrEqualTo)
            : null,
        isGreaterThan: isGreaterThan != null
            ? _$EnumsPerFieldToJson.enumValue(isGreaterThan)
            : null,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo != null
            ? _$EnumsPerFieldToJson.enumValue(isGreaterThanOrEqualTo)
            : null,
        isNull: isNull,
        whereIn: whereIn?.map((e) => _$EnumsPerFieldToJson.enumValue(e)),
        whereNotIn: whereNotIn?.map((e) => _$EnumsPerFieldToJson.enumValue(e)),
      ),
      $queryCursor: $queryCursor,
    );
  }

  EnumsQuery whereNullableEnumValue({
    TestEnum? isEqualTo,
    TestEnum? isNotEqualTo,
    TestEnum? isLessThan,
    TestEnum? isLessThanOrEqualTo,
    TestEnum? isGreaterThan,
    TestEnum? isGreaterThanOrEqualTo,
    bool? isNull,
    List<TestEnum?>? whereIn,
    List<TestEnum?>? whereNotIn,
  }) {
    return _$EnumsQuery(
      _collection,
      $referenceWithoutCursor: $referenceWithoutCursor.where(
        _$EnumsFieldMap['nullableEnumValue']!,
        isEqualTo: isEqualTo != null
            ? _$EnumsPerFieldToJson.nullableEnumValue(isEqualTo)
            : null,
        isNotEqualTo: isNotEqualTo != null
            ? _$EnumsPerFieldToJson.nullableEnumValue(isNotEqualTo)
            : null,
        isLessThan: isLessThan != null
            ? _$EnumsPerFieldToJson.nullableEnumValue(isLessThan)
            : null,
        isLessThanOrEqualTo: isLessThanOrEqualTo != null
            ? _$EnumsPerFieldToJson.nullableEnumValue(isLessThanOrEqualTo)
            : null,
        isGreaterThan: isGreaterThan != null
            ? _$EnumsPerFieldToJson.nullableEnumValue(isGreaterThan)
            : null,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo != null
            ? _$EnumsPerFieldToJson.nullableEnumValue(isGreaterThanOrEqualTo)
            : null,
        isNull: isNull,
        whereIn:
            whereIn?.map((e) => _$EnumsPerFieldToJson.nullableEnumValue(e)),
        whereNotIn:
            whereNotIn?.map((e) => _$EnumsPerFieldToJson.nullableEnumValue(e)),
      ),
      $queryCursor: $queryCursor,
    );
  }

  EnumsQuery whereEnumList({
    List<TestEnum>? isEqualTo,
    List<TestEnum>? isNotEqualTo,
    List<TestEnum>? isLessThan,
    List<TestEnum>? isLessThanOrEqualTo,
    List<TestEnum>? isGreaterThan,
    List<TestEnum>? isGreaterThanOrEqualTo,
    bool? isNull,
    TestEnum? arrayContains,
    List<TestEnum>? arrayContainsAny,
  }) {
    return _$EnumsQuery(
      _collection,
      $referenceWithoutCursor: $referenceWithoutCursor.where(
        _$EnumsFieldMap['enumList']!,
        isEqualTo: isEqualTo != null
            ? _$EnumsPerFieldToJson.enumList(isEqualTo)
            : null,
        isNotEqualTo: isNotEqualTo != null
            ? _$EnumsPerFieldToJson.enumList(isNotEqualTo)
            : null,
        isLessThan: isLessThan != null
            ? _$EnumsPerFieldToJson.enumList(isLessThan)
            : null,
        isLessThanOrEqualTo: isLessThanOrEqualTo != null
            ? _$EnumsPerFieldToJson.enumList(isLessThanOrEqualTo)
            : null,
        isGreaterThan: isGreaterThan != null
            ? _$EnumsPerFieldToJson.enumList(isGreaterThan)
            : null,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo != null
            ? _$EnumsPerFieldToJson.enumList(isGreaterThanOrEqualTo)
            : null,
        isNull: isNull,
        arrayContains: arrayContains != null
            ? (_$EnumsPerFieldToJson.enumList([arrayContains]) as List?)!.single
            : null,
        arrayContainsAny: arrayContainsAny != null
            ? _$EnumsPerFieldToJson.enumList(arrayContainsAny)
                as Iterable<Object>?
            : null,
      ),
      $queryCursor: $queryCursor,
    );
  }

  EnumsQuery whereNullableEnumList({
    List<TestEnum>? isEqualTo,
    List<TestEnum>? isNotEqualTo,
    List<TestEnum>? isLessThan,
    List<TestEnum>? isLessThanOrEqualTo,
    List<TestEnum>? isGreaterThan,
    List<TestEnum>? isGreaterThanOrEqualTo,
    bool? isNull,
    TestEnum? arrayContains,
    List<TestEnum>? arrayContainsAny,
  }) {
    return _$EnumsQuery(
      _collection,
      $referenceWithoutCursor: $referenceWithoutCursor.where(
        _$EnumsFieldMap['nullableEnumList']!,
        isEqualTo: isEqualTo != null
            ? _$EnumsPerFieldToJson.nullableEnumList(isEqualTo)
            : null,
        isNotEqualTo: isNotEqualTo != null
            ? _$EnumsPerFieldToJson.nullableEnumList(isNotEqualTo)
            : null,
        isLessThan: isLessThan != null
            ? _$EnumsPerFieldToJson.nullableEnumList(isLessThan)
            : null,
        isLessThanOrEqualTo: isLessThanOrEqualTo != null
            ? _$EnumsPerFieldToJson.nullableEnumList(isLessThanOrEqualTo)
            : null,
        isGreaterThan: isGreaterThan != null
            ? _$EnumsPerFieldToJson.nullableEnumList(isGreaterThan)
            : null,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo != null
            ? _$EnumsPerFieldToJson.nullableEnumList(isGreaterThanOrEqualTo)
            : null,
        isNull: isNull,
        arrayContains: arrayContains != null
            ? (_$EnumsPerFieldToJson.nullableEnumList([arrayContains])
                    as List?)!
                .single
            : null,
        arrayContainsAny: arrayContainsAny != null
            ? _$EnumsPerFieldToJson.nullableEnumList(arrayContainsAny)
                as Iterable<Object>?
            : null,
      ),
      $queryCursor: $queryCursor,
    );
  }

  EnumsQuery orderByDocumentId({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    EnumsDocumentSnapshot? startAtDocument,
    EnumsDocumentSnapshot? endAtDocument,
    EnumsDocumentSnapshot? endBeforeDocument,
    EnumsDocumentSnapshot? startAfterDocument,
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

    return _$EnumsQuery(
      _collection,
      $referenceWithoutCursor: query,
      $queryCursor: queryCursor,
    );
  }

  EnumsQuery orderById({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    EnumsDocumentSnapshot? startAtDocument,
    EnumsDocumentSnapshot? endAtDocument,
    EnumsDocumentSnapshot? endBeforeDocument,
    EnumsDocumentSnapshot? startAfterDocument,
  }) {
    final query = $referenceWithoutCursor.orderBy(_$EnumsFieldMap['id']!,
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

    return _$EnumsQuery(
      _collection,
      $referenceWithoutCursor: query,
      $queryCursor: queryCursor,
    );
  }

  EnumsQuery orderByEnumValue({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    EnumsDocumentSnapshot? startAtDocument,
    EnumsDocumentSnapshot? endAtDocument,
    EnumsDocumentSnapshot? endBeforeDocument,
    EnumsDocumentSnapshot? startAfterDocument,
  }) {
    final query = $referenceWithoutCursor.orderBy(_$EnumsFieldMap['enumValue']!,
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

    return _$EnumsQuery(
      _collection,
      $referenceWithoutCursor: query,
      $queryCursor: queryCursor,
    );
  }

  EnumsQuery orderByNullableEnumValue({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    EnumsDocumentSnapshot? startAtDocument,
    EnumsDocumentSnapshot? endAtDocument,
    EnumsDocumentSnapshot? endBeforeDocument,
    EnumsDocumentSnapshot? startAfterDocument,
  }) {
    final query = $referenceWithoutCursor
        .orderBy(_$EnumsFieldMap['nullableEnumValue']!, descending: descending);
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

    return _$EnumsQuery(
      _collection,
      $referenceWithoutCursor: query,
      $queryCursor: queryCursor,
    );
  }

  EnumsQuery orderByEnumList({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    EnumsDocumentSnapshot? startAtDocument,
    EnumsDocumentSnapshot? endAtDocument,
    EnumsDocumentSnapshot? endBeforeDocument,
    EnumsDocumentSnapshot? startAfterDocument,
  }) {
    final query = $referenceWithoutCursor.orderBy(_$EnumsFieldMap['enumList']!,
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

    return _$EnumsQuery(
      _collection,
      $referenceWithoutCursor: query,
      $queryCursor: queryCursor,
    );
  }

  EnumsQuery orderByNullableEnumList({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    EnumsDocumentSnapshot? startAtDocument,
    EnumsDocumentSnapshot? endAtDocument,
    EnumsDocumentSnapshot? endBeforeDocument,
    EnumsDocumentSnapshot? startAfterDocument,
  }) {
    final query = $referenceWithoutCursor
        .orderBy(_$EnumsFieldMap['nullableEnumList']!, descending: descending);
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

    return _$EnumsQuery(
      _collection,
      $referenceWithoutCursor: query,
      $queryCursor: queryCursor,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is _$EnumsQuery &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

class EnumsDocumentSnapshot extends FirestoreDocumentSnapshot<Enums> {
  EnumsDocumentSnapshot._(this.snapshot) : data = snapshot.data();

  @override
  final DocumentSnapshot<Enums> snapshot;

  @override
  EnumsDocumentReference get reference {
    return EnumsDocumentReference(
      snapshot.reference,
    );
  }

  @override
  final Enums? data;
}

class EnumsQuerySnapshot
    extends FirestoreQuerySnapshot<Enums, EnumsQueryDocumentSnapshot> {
  EnumsQuerySnapshot._(
    this.snapshot,
    this.docs,
    this.docChanges,
  );

  factory EnumsQuerySnapshot._fromQuerySnapshot(
    QuerySnapshot<Enums> snapshot,
  ) {
    final docs = snapshot.docs.map(EnumsQueryDocumentSnapshot._).toList();

    final docChanges = snapshot.docChanges.map((change) {
      return _decodeDocumentChange(
        change,
        EnumsDocumentSnapshot._,
      );
    }).toList();

    return EnumsQuerySnapshot._(
      snapshot,
      docs,
      docChanges,
    );
  }

  static FirestoreDocumentChange<EnumsDocumentSnapshot>
      _decodeDocumentChange<T>(
    DocumentChange<T> docChange,
    EnumsDocumentSnapshot Function(DocumentSnapshot<T> doc) decodeDoc,
  ) {
    return FirestoreDocumentChange<EnumsDocumentSnapshot>(
      type: docChange.type,
      oldIndex: docChange.oldIndex,
      newIndex: docChange.newIndex,
      doc: decodeDoc(docChange.doc),
    );
  }

  final QuerySnapshot<Enums> snapshot;

  @override
  final List<EnumsQueryDocumentSnapshot> docs;

  @override
  final List<FirestoreDocumentChange<EnumsDocumentSnapshot>> docChanges;
}

class EnumsQueryDocumentSnapshot extends FirestoreQueryDocumentSnapshot<Enums>
    implements EnumsDocumentSnapshot {
  EnumsQueryDocumentSnapshot._(this.snapshot) : data = snapshot.data();

  @override
  final QueryDocumentSnapshot<Enums> snapshot;

  @override
  final Enums data;

  @override
  EnumsDocumentReference get reference {
    return EnumsDocumentReference(snapshot.reference);
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Enums _$EnumsFromJson(Map<String, dynamic> json) => Enums(
      id: json['id'] as String,
      enumValue: $enumDecodeNullable(_$TestEnumEnumMap, json['enumValue']) ??
          TestEnum.one,
      nullableEnumValue:
          $enumDecodeNullable(_$TestEnumEnumMap, json['nullableEnumValue']),
      enumList: (json['enumList'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$TestEnumEnumMap, e))
              .toList() ??
          const [],
      nullableEnumList: (json['nullableEnumList'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$TestEnumEnumMap, e))
          .toList(),
    );

const _$EnumsFieldMap = <String, String>{
  'id': 'id',
  'enumValue': 'enumValue',
  'nullableEnumValue': 'nullableEnumValue',
  'enumList': 'enumList',
  'nullableEnumList': 'nullableEnumList',
};

// ignore: unused_element
abstract class _$EnumsPerFieldToJson {
  // ignore: unused_element
  static Object? id(String instance) => instance;
  // ignore: unused_element
  static Object? enumValue(TestEnum instance) => _$TestEnumEnumMap[instance]!;
  // ignore: unused_element
  static Object? nullableEnumValue(TestEnum? instance) =>
      _$TestEnumEnumMap[instance];
  // ignore: unused_element
  static Object? enumList(List<TestEnum> instance) =>
      instance.map((e) => _$TestEnumEnumMap[e]!).toList();
  // ignore: unused_element
  static Object? nullableEnumList(List<TestEnum>? instance) =>
      instance?.map((e) => _$TestEnumEnumMap[e]!).toList();
}

Map<String, dynamic> _$EnumsToJson(Enums instance) => <String, dynamic>{
      'id': instance.id,
      'enumValue': _$TestEnumEnumMap[instance.enumValue]!,
      'nullableEnumValue': _$TestEnumEnumMap[instance.nullableEnumValue],
      'enumList': instance.enumList.map((e) => _$TestEnumEnumMap[e]!).toList(),
      'nullableEnumList':
          instance.nullableEnumList?.map((e) => _$TestEnumEnumMap[e]!).toList(),
    };

const _$TestEnumEnumMap = {
  TestEnum.one: 'one',
  TestEnum.two: 'two',
  TestEnum.three: 'three',
};
