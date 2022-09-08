// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'freezed.dart';

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
abstract class PersonCollectionReference
    implements
        PersonQuery,
        FirestoreCollectionReference<Person, PersonQuerySnapshot> {
  factory PersonCollectionReference([
    FirebaseFirestore? firestore,
  ]) = _$PersonCollectionReference;

  static Person fromFirestore(
    DocumentSnapshot<Map<String, Object?>> snapshot,
    SnapshotOptions? options,
  ) {
    return Person.fromJson(snapshot.data()!);
  }

  static Map<String, Object?> toFirestore(
    Person value,
    SetOptions? options,
  ) {
    return value.toJson();
  }

  @override
  CollectionReference<Person> get reference;

  @override
  PersonDocumentReference doc([String? id]);

  /// Add a new document to this collection with the specified data,
  /// assigning it a document ID automatically.
  Future<PersonDocumentReference> add(Person value);
}

class _$PersonCollectionReference extends _$PersonQuery
    implements PersonCollectionReference {
  factory _$PersonCollectionReference([FirebaseFirestore? firestore]) {
    firestore ??= FirebaseFirestore.instance;

    return _$PersonCollectionReference._(
      firestore.collection('freezed-test').withConverter(
            fromFirestore: PersonCollectionReference.fromFirestore,
            toFirestore: PersonCollectionReference.toFirestore,
          ),
    );
  }

  _$PersonCollectionReference._(
    CollectionReference<Person> reference,
  ) : super(reference, reference);

  String get path => reference.path;

  @override
  CollectionReference<Person> get reference =>
      super.reference as CollectionReference<Person>;

  @override
  PersonDocumentReference doc([String? id]) {
    assert(
      id == null || id.split('/').length == 1,
      'The document ID cannot be from a different collection',
    );
    return PersonDocumentReference(
      reference.doc(id),
    );
  }

  @override
  Future<PersonDocumentReference> add(Person value) {
    return reference.add(value).then((ref) => PersonDocumentReference(ref));
  }

  @override
  bool operator ==(Object other) {
    return other is _$PersonCollectionReference &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

abstract class PersonDocumentReference
    extends FirestoreDocumentReference<Person, PersonDocumentSnapshot> {
  factory PersonDocumentReference(DocumentReference<Person> reference) =
      _$PersonDocumentReference;

  DocumentReference<Person> get reference;

  /// A reference to the [PersonCollectionReference] containing this document.
  PersonCollectionReference get parent {
    return _$PersonCollectionReference(reference.firestore);
  }

  @override
  Stream<PersonDocumentSnapshot> snapshots();

  @override
  Future<PersonDocumentSnapshot> get([GetOptions? options]);

  @override
  Future<void> delete();

  Future<void> update({
    String firstName,
    String lastName,
  });

  Future<void> set(Person value);
}

class _$PersonDocumentReference
    extends FirestoreDocumentReference<Person, PersonDocumentSnapshot>
    implements PersonDocumentReference {
  _$PersonDocumentReference(this.reference);

  @override
  final DocumentReference<Person> reference;

  /// A reference to the [PersonCollectionReference] containing this document.
  PersonCollectionReference get parent {
    return _$PersonCollectionReference(reference.firestore);
  }

  @override
  Stream<PersonDocumentSnapshot> snapshots() {
    return reference.snapshots().map((snapshot) {
      return PersonDocumentSnapshot._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<PersonDocumentSnapshot> get([GetOptions? options]) {
    return reference.get(options).then((snapshot) {
      return PersonDocumentSnapshot._(
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
    Object? firstName = _sentinel,
    Object? lastName = _sentinel,
  }) async {
    final json = {
      if (firstName != _sentinel) "firstName": firstName as String,
      if (lastName != _sentinel) "lastName": lastName as String,
    };

    return reference.update(json);
  }

  Future<void> set(Person value) {
    return reference.set(value);
  }

  @override
  bool operator ==(Object other) {
    return other is PersonDocumentReference &&
        other.runtimeType == runtimeType &&
        other.parent == parent &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, parent, id);
}

class PersonDocumentSnapshot extends FirestoreDocumentSnapshot<Person> {
  PersonDocumentSnapshot._(
    this.snapshot,
    this.data,
  );

  @override
  final DocumentSnapshot<Person> snapshot;

  @override
  PersonDocumentReference get reference {
    return PersonDocumentReference(
      snapshot.reference,
    );
  }

  @override
  final Person? data;
}

abstract class PersonQuery
    implements QueryReference<Person, PersonQuerySnapshot> {
  @override
  PersonQuery limit(int limit);

  @override
  PersonQuery limitToLast(int limit);

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
  PersonQuery orderByFieldPath(
    FieldPath fieldPath, {
    bool descending = false,
    Object? startAt,
    Object? startAfter,
    Object? endAt,
    Object? endBefore,
    PersonDocumentSnapshot? startAtDocument,
    PersonDocumentSnapshot? endAtDocument,
    PersonDocumentSnapshot? endBeforeDocument,
    PersonDocumentSnapshot? startAfterDocument,
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
  PersonQuery whereFieldPath(
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

  PersonQuery whereDocumentId({
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
  PersonQuery whereFirstName({
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
  PersonQuery whereLastName({
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

  PersonQuery orderByDocumentId({
    bool descending = false,
    String startAt,
    String startAfter,
    String endAt,
    String endBefore,
    PersonDocumentSnapshot? startAtDocument,
    PersonDocumentSnapshot? endAtDocument,
    PersonDocumentSnapshot? endBeforeDocument,
    PersonDocumentSnapshot? startAfterDocument,
  });

  PersonQuery orderByFirstName({
    bool descending = false,
    String startAt,
    String startAfter,
    String endAt,
    String endBefore,
    PersonDocumentSnapshot? startAtDocument,
    PersonDocumentSnapshot? endAtDocument,
    PersonDocumentSnapshot? endBeforeDocument,
    PersonDocumentSnapshot? startAfterDocument,
  });

  PersonQuery orderByLastName({
    bool descending = false,
    String startAt,
    String startAfter,
    String endAt,
    String endBefore,
    PersonDocumentSnapshot? startAtDocument,
    PersonDocumentSnapshot? endAtDocument,
    PersonDocumentSnapshot? endBeforeDocument,
    PersonDocumentSnapshot? startAfterDocument,
  });
}

class _$PersonQuery extends QueryReference<Person, PersonQuerySnapshot>
    implements PersonQuery {
  _$PersonQuery(
    this.reference,
    this._collection,
  );

  final CollectionReference<Object?> _collection;

  @override
  final Query<Person> reference;

  PersonQuerySnapshot _decodeSnapshot(
    QuerySnapshot<Person> snapshot,
  ) {
    final docs = snapshot.docs.map((e) {
      return PersonQueryDocumentSnapshot._(e, e.data());
    }).toList();

    final docChanges = snapshot.docChanges.map((change) {
      return FirestoreDocumentChange<PersonDocumentSnapshot>(
        type: change.type,
        oldIndex: change.oldIndex,
        newIndex: change.newIndex,
        doc: PersonDocumentSnapshot._(change.doc, change.doc.data()),
      );
    }).toList();

    return PersonQuerySnapshot._(
      snapshot,
      docs,
      docChanges,
    );
  }

  @override
  Stream<PersonQuerySnapshot> snapshots([SnapshotOptions? options]) {
    return reference.snapshots().map(_decodeSnapshot);
  }

  @override
  Future<PersonQuerySnapshot> get([GetOptions? options]) {
    return reference.get(options).then(_decodeSnapshot);
  }

  @override
  PersonQuery limit(int limit) {
    return _$PersonQuery(
      reference.limit(limit),
      _collection,
    );
  }

  @override
  PersonQuery limitToLast(int limit) {
    return _$PersonQuery(
      reference.limitToLast(limit),
      _collection,
    );
  }

  PersonQuery orderByFieldPath(
    FieldPath fieldPath, {
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    PersonDocumentSnapshot? startAtDocument,
    PersonDocumentSnapshot? endAtDocument,
    PersonDocumentSnapshot? endBeforeDocument,
    PersonDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy(fieldPath, descending: descending);

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

    return _$PersonQuery(query, _collection);
  }

  PersonQuery whereFieldPath(
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
    return _$PersonQuery(
      reference.where(
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
      _collection,
    );
  }

  PersonQuery whereDocumentId({
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
    return _$PersonQuery(
      reference.where(
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
      _collection,
    );
  }

  PersonQuery whereFirstName({
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
    return _$PersonQuery(
      reference.where(
        _$$_PersonFieldMap["firstName"]!,
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

  PersonQuery whereLastName({
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
    return _$PersonQuery(
      reference.where(
        _$$_PersonFieldMap["lastName"]!,
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

  PersonQuery orderByDocumentId({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    PersonDocumentSnapshot? startAtDocument,
    PersonDocumentSnapshot? endAtDocument,
    PersonDocumentSnapshot? endBeforeDocument,
    PersonDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy(FieldPath.documentId, descending: descending);

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

    return _$PersonQuery(query, _collection);
  }

  PersonQuery orderByFirstName({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    PersonDocumentSnapshot? startAtDocument,
    PersonDocumentSnapshot? endAtDocument,
    PersonDocumentSnapshot? endBeforeDocument,
    PersonDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy(_$$_PersonFieldMap["firstName"]!,
        descending: descending);

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

    return _$PersonQuery(query, _collection);
  }

  PersonQuery orderByLastName({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    PersonDocumentSnapshot? startAtDocument,
    PersonDocumentSnapshot? endAtDocument,
    PersonDocumentSnapshot? endBeforeDocument,
    PersonDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy(_$$_PersonFieldMap["lastName"]!,
        descending: descending);

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

    return _$PersonQuery(query, _collection);
  }

  @override
  bool operator ==(Object other) {
    return other is _$PersonQuery &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

class PersonQuerySnapshot
    extends FirestoreQuerySnapshot<Person, PersonQueryDocumentSnapshot> {
  PersonQuerySnapshot._(
    this.snapshot,
    this.docs,
    this.docChanges,
  );

  final QuerySnapshot<Person> snapshot;

  @override
  final List<PersonQueryDocumentSnapshot> docs;

  @override
  final List<FirestoreDocumentChange<PersonDocumentSnapshot>> docChanges;
}

class PersonQueryDocumentSnapshot extends FirestoreQueryDocumentSnapshot<Person>
    implements PersonDocumentSnapshot {
  PersonQueryDocumentSnapshot._(this.snapshot, this.data);

  @override
  final QueryDocumentSnapshot<Person> snapshot;

  @override
  PersonDocumentReference get reference {
    return PersonDocumentReference(snapshot.reference);
  }

  @override
  final Person data;
}

/// A collection reference object can be used for adding documents,
/// getting document references, and querying for documents
/// (using the methods inherited from Query).
abstract class PublicRedirectedCollectionReference
    implements
        PublicRedirectedQuery,
        FirestoreCollectionReference<PublicRedirected,
            PublicRedirectedQuerySnapshot> {
  factory PublicRedirectedCollectionReference([
    FirebaseFirestore? firestore,
  ]) = _$PublicRedirectedCollectionReference;

  static PublicRedirected fromFirestore(
    DocumentSnapshot<Map<String, Object?>> snapshot,
    SnapshotOptions? options,
  ) {
    return PublicRedirected.fromJson(snapshot.data()!);
  }

  static Map<String, Object?> toFirestore(
    PublicRedirected value,
    SetOptions? options,
  ) {
    return value.toJson();
  }

  @override
  CollectionReference<PublicRedirected> get reference;

  @override
  PublicRedirectedDocumentReference doc([String? id]);

  /// Add a new document to this collection with the specified data,
  /// assigning it a document ID automatically.
  Future<PublicRedirectedDocumentReference> add(PublicRedirected value);
}

class _$PublicRedirectedCollectionReference extends _$PublicRedirectedQuery
    implements PublicRedirectedCollectionReference {
  factory _$PublicRedirectedCollectionReference(
      [FirebaseFirestore? firestore]) {
    firestore ??= FirebaseFirestore.instance;

    return _$PublicRedirectedCollectionReference._(
      firestore.collection('freezed-test').withConverter(
            fromFirestore: PublicRedirectedCollectionReference.fromFirestore,
            toFirestore: PublicRedirectedCollectionReference.toFirestore,
          ),
    );
  }

  _$PublicRedirectedCollectionReference._(
    CollectionReference<PublicRedirected> reference,
  ) : super(reference, reference);

  String get path => reference.path;

  @override
  CollectionReference<PublicRedirected> get reference =>
      super.reference as CollectionReference<PublicRedirected>;

  @override
  PublicRedirectedDocumentReference doc([String? id]) {
    assert(
      id == null || id.split('/').length == 1,
      'The document ID cannot be from a different collection',
    );
    return PublicRedirectedDocumentReference(
      reference.doc(id),
    );
  }

  @override
  Future<PublicRedirectedDocumentReference> add(PublicRedirected value) {
    return reference
        .add(value)
        .then((ref) => PublicRedirectedDocumentReference(ref));
  }

  @override
  bool operator ==(Object other) {
    return other is _$PublicRedirectedCollectionReference &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

abstract class PublicRedirectedDocumentReference
    extends FirestoreDocumentReference<PublicRedirected,
        PublicRedirectedDocumentSnapshot> {
  factory PublicRedirectedDocumentReference(
          DocumentReference<PublicRedirected> reference) =
      _$PublicRedirectedDocumentReference;

  DocumentReference<PublicRedirected> get reference;

  /// A reference to the [PublicRedirectedCollectionReference] containing this document.
  PublicRedirectedCollectionReference get parent {
    return _$PublicRedirectedCollectionReference(reference.firestore);
  }

  @override
  Stream<PublicRedirectedDocumentSnapshot> snapshots();

  @override
  Future<PublicRedirectedDocumentSnapshot> get([GetOptions? options]);

  @override
  Future<void> delete();

  Future<void> update({
    String value,
  });

  Future<void> set(PublicRedirected value);
}

class _$PublicRedirectedDocumentReference extends FirestoreDocumentReference<
        PublicRedirected, PublicRedirectedDocumentSnapshot>
    implements PublicRedirectedDocumentReference {
  _$PublicRedirectedDocumentReference(this.reference);

  @override
  final DocumentReference<PublicRedirected> reference;

  /// A reference to the [PublicRedirectedCollectionReference] containing this document.
  PublicRedirectedCollectionReference get parent {
    return _$PublicRedirectedCollectionReference(reference.firestore);
  }

  @override
  Stream<PublicRedirectedDocumentSnapshot> snapshots() {
    return reference.snapshots().map((snapshot) {
      return PublicRedirectedDocumentSnapshot._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<PublicRedirectedDocumentSnapshot> get([GetOptions? options]) {
    return reference.get(options).then((snapshot) {
      return PublicRedirectedDocumentSnapshot._(
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
      if (value != _sentinel) "value": value as String,
    };

    return reference.update(json);
  }

  Future<void> set(PublicRedirected value) {
    return reference.set(value);
  }

  @override
  bool operator ==(Object other) {
    return other is PublicRedirectedDocumentReference &&
        other.runtimeType == runtimeType &&
        other.parent == parent &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, parent, id);
}

class PublicRedirectedDocumentSnapshot
    extends FirestoreDocumentSnapshot<PublicRedirected> {
  PublicRedirectedDocumentSnapshot._(
    this.snapshot,
    this.data,
  );

  @override
  final DocumentSnapshot<PublicRedirected> snapshot;

  @override
  PublicRedirectedDocumentReference get reference {
    return PublicRedirectedDocumentReference(
      snapshot.reference,
    );
  }

  @override
  final PublicRedirected? data;
}

abstract class PublicRedirectedQuery
    implements QueryReference<PublicRedirected, PublicRedirectedQuerySnapshot> {
  @override
  PublicRedirectedQuery limit(int limit);

  @override
  PublicRedirectedQuery limitToLast(int limit);

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
  PublicRedirectedQuery orderByFieldPath(
    FieldPath fieldPath, {
    bool descending = false,
    Object? startAt,
    Object? startAfter,
    Object? endAt,
    Object? endBefore,
    PublicRedirectedDocumentSnapshot? startAtDocument,
    PublicRedirectedDocumentSnapshot? endAtDocument,
    PublicRedirectedDocumentSnapshot? endBeforeDocument,
    PublicRedirectedDocumentSnapshot? startAfterDocument,
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
  PublicRedirectedQuery whereFieldPath(
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

  PublicRedirectedQuery whereDocumentId({
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
  PublicRedirectedQuery whereValue({
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

  PublicRedirectedQuery orderByDocumentId({
    bool descending = false,
    String startAt,
    String startAfter,
    String endAt,
    String endBefore,
    PublicRedirectedDocumentSnapshot? startAtDocument,
    PublicRedirectedDocumentSnapshot? endAtDocument,
    PublicRedirectedDocumentSnapshot? endBeforeDocument,
    PublicRedirectedDocumentSnapshot? startAfterDocument,
  });

  PublicRedirectedQuery orderByValue({
    bool descending = false,
    String startAt,
    String startAfter,
    String endAt,
    String endBefore,
    PublicRedirectedDocumentSnapshot? startAtDocument,
    PublicRedirectedDocumentSnapshot? endAtDocument,
    PublicRedirectedDocumentSnapshot? endBeforeDocument,
    PublicRedirectedDocumentSnapshot? startAfterDocument,
  });
}

class _$PublicRedirectedQuery
    extends QueryReference<PublicRedirected, PublicRedirectedQuerySnapshot>
    implements PublicRedirectedQuery {
  _$PublicRedirectedQuery(
    this.reference,
    this._collection,
  );

  final CollectionReference<Object?> _collection;

  @override
  final Query<PublicRedirected> reference;

  PublicRedirectedQuerySnapshot _decodeSnapshot(
    QuerySnapshot<PublicRedirected> snapshot,
  ) {
    final docs = snapshot.docs.map((e) {
      return PublicRedirectedQueryDocumentSnapshot._(e, e.data());
    }).toList();

    final docChanges = snapshot.docChanges.map((change) {
      return FirestoreDocumentChange<PublicRedirectedDocumentSnapshot>(
        type: change.type,
        oldIndex: change.oldIndex,
        newIndex: change.newIndex,
        doc: PublicRedirectedDocumentSnapshot._(change.doc, change.doc.data()),
      );
    }).toList();

    return PublicRedirectedQuerySnapshot._(
      snapshot,
      docs,
      docChanges,
    );
  }

  @override
  Stream<PublicRedirectedQuerySnapshot> snapshots([SnapshotOptions? options]) {
    return reference.snapshots().map(_decodeSnapshot);
  }

  @override
  Future<PublicRedirectedQuerySnapshot> get([GetOptions? options]) {
    return reference.get(options).then(_decodeSnapshot);
  }

  @override
  PublicRedirectedQuery limit(int limit) {
    return _$PublicRedirectedQuery(
      reference.limit(limit),
      _collection,
    );
  }

  @override
  PublicRedirectedQuery limitToLast(int limit) {
    return _$PublicRedirectedQuery(
      reference.limitToLast(limit),
      _collection,
    );
  }

  PublicRedirectedQuery orderByFieldPath(
    FieldPath fieldPath, {
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    PublicRedirectedDocumentSnapshot? startAtDocument,
    PublicRedirectedDocumentSnapshot? endAtDocument,
    PublicRedirectedDocumentSnapshot? endBeforeDocument,
    PublicRedirectedDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy(fieldPath, descending: descending);

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

    return _$PublicRedirectedQuery(query, _collection);
  }

  PublicRedirectedQuery whereFieldPath(
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
    return _$PublicRedirectedQuery(
      reference.where(
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
      _collection,
    );
  }

  PublicRedirectedQuery whereDocumentId({
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
    return _$PublicRedirectedQuery(
      reference.where(
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
      _collection,
    );
  }

  PublicRedirectedQuery whereValue({
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
    return _$PublicRedirectedQuery(
      reference.where(
        _$$PublicRedirected2FieldMap["value"]!,
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

  PublicRedirectedQuery orderByDocumentId({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    PublicRedirectedDocumentSnapshot? startAtDocument,
    PublicRedirectedDocumentSnapshot? endAtDocument,
    PublicRedirectedDocumentSnapshot? endBeforeDocument,
    PublicRedirectedDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy(FieldPath.documentId, descending: descending);

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

    return _$PublicRedirectedQuery(query, _collection);
  }

  PublicRedirectedQuery orderByValue({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    PublicRedirectedDocumentSnapshot? startAtDocument,
    PublicRedirectedDocumentSnapshot? endAtDocument,
    PublicRedirectedDocumentSnapshot? endBeforeDocument,
    PublicRedirectedDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy(_$$PublicRedirected2FieldMap["value"]!,
        descending: descending);

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

    return _$PublicRedirectedQuery(query, _collection);
  }

  @override
  bool operator ==(Object other) {
    return other is _$PublicRedirectedQuery &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

class PublicRedirectedQuerySnapshot extends FirestoreQuerySnapshot<
    PublicRedirected, PublicRedirectedQueryDocumentSnapshot> {
  PublicRedirectedQuerySnapshot._(
    this.snapshot,
    this.docs,
    this.docChanges,
  );

  final QuerySnapshot<PublicRedirected> snapshot;

  @override
  final List<PublicRedirectedQueryDocumentSnapshot> docs;

  @override
  final List<FirestoreDocumentChange<PublicRedirectedDocumentSnapshot>>
      docChanges;
}

class PublicRedirectedQueryDocumentSnapshot
    extends FirestoreQueryDocumentSnapshot<PublicRedirected>
    implements PublicRedirectedDocumentSnapshot {
  PublicRedirectedQueryDocumentSnapshot._(this.snapshot, this.data);

  @override
  final QueryDocumentSnapshot<PublicRedirected> snapshot;

  @override
  PublicRedirectedDocumentReference get reference {
    return PublicRedirectedDocumentReference(snapshot.reference);
  }

  @override
  final PublicRedirected data;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Person _$$_PersonFromJson(Map<String, dynamic> json) => _$_Person(
      firstName: json['first_name'] as String,
      lastName: json['LAST_NAME'] as String,
    );

const _$$_PersonFieldMap = <String, String>{
  'firstName': 'first_name',
  'lastName': 'LAST_NAME',
};

Map<String, dynamic> _$$_PersonToJson(_$_Person instance) => <String, dynamic>{
      'first_name': instance.firstName,
      'LAST_NAME': instance.lastName,
    };

_$PublicRedirected2 _$$PublicRedirected2FromJson(Map<String, dynamic> json) =>
    _$PublicRedirected2(
      value: json['value'] as String,
    );

const _$$PublicRedirected2FieldMap = <String, String>{
  'value': 'value',
};

Map<String, dynamic> _$$PublicRedirected2ToJson(_$PublicRedirected2 instance) =>
    <String, dynamic>{
      'value': instance.value,
    };
