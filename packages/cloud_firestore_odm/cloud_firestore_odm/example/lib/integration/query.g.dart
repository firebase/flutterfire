// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'query.dart';

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
abstract class DateTimeQueryCollectionReference
    implements
        DateTimeQueryQuery,
        FirestoreCollectionReference<DateTimeQueryQuerySnapshot> {
  factory DateTimeQueryCollectionReference([
    FirebaseFirestore? firestore,
  ]) = _$DateTimeQueryCollectionReference;

  static DateTimeQuery fromFirestore(
    DocumentSnapshot<Map<String, Object?>> snapshot,
    SnapshotOptions? options,
  ) {
    return _$DateTimeQueryFromJson(snapshot.data()!);
  }

  static Map<String, Object?> toFirestore(
    DateTimeQuery value,
    SetOptions? options,
  ) {
    return _$DateTimeQueryToJson(value);
  }

  @override
  DateTimeQueryDocumentReference doc([String? id]);

  /// Add a new document to this collection with the specified data,
  /// assigning it a document ID automatically.
  Future<DateTimeQueryDocumentReference> add(DateTimeQuery value);
}

class _$DateTimeQueryCollectionReference extends _$DateTimeQueryQuery
    implements DateTimeQueryCollectionReference {
  factory _$DateTimeQueryCollectionReference([FirebaseFirestore? firestore]) {
    firestore ??= FirebaseFirestore.instance;

    return _$DateTimeQueryCollectionReference._(
      firestore.collection('firestore-example-app/42/date-time').withConverter(
            fromFirestore: DateTimeQueryCollectionReference.fromFirestore,
            toFirestore: DateTimeQueryCollectionReference.toFirestore,
          ),
    );
  }

  _$DateTimeQueryCollectionReference._(
    CollectionReference<DateTimeQuery> reference,
  ) : super(reference, reference);

  String get path => reference.path;

  @override
  CollectionReference<DateTimeQuery> get reference =>
      super.reference as CollectionReference<DateTimeQuery>;

  @override
  DateTimeQueryDocumentReference doc([String? id]) {
    return DateTimeQueryDocumentReference(
      reference.doc(id),
    );
  }

  @override
  Future<DateTimeQueryDocumentReference> add(DateTimeQuery value) {
    return reference
        .add(value)
        .then((ref) => DateTimeQueryDocumentReference(ref));
  }

  @override
  bool operator ==(Object other) {
    return other is _$DateTimeQueryCollectionReference &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

abstract class DateTimeQueryDocumentReference
    extends FirestoreDocumentReference<DateTimeQueryDocumentSnapshot> {
  factory DateTimeQueryDocumentReference(
          DocumentReference<DateTimeQuery> reference) =
      _$DateTimeQueryDocumentReference;

  DocumentReference<DateTimeQuery> get reference;

  /// A reference to the [DateTimeQueryCollectionReference] containing this document.
  DateTimeQueryCollectionReference get parent {
    return _$DateTimeQueryCollectionReference(reference.firestore);
  }

  @override
  Stream<DateTimeQueryDocumentSnapshot> snapshots();

  @override
  Future<DateTimeQueryDocumentSnapshot> get([GetOptions? options]);

  @override
  Future<void> delete();

  Future<void> update({
    DateTime time,
  });

  Future<void> set(DateTimeQuery value);
}

class _$DateTimeQueryDocumentReference
    extends FirestoreDocumentReference<DateTimeQueryDocumentSnapshot>
    implements DateTimeQueryDocumentReference {
  _$DateTimeQueryDocumentReference(this.reference);

  @override
  final DocumentReference<DateTimeQuery> reference;

  /// A reference to the [DateTimeQueryCollectionReference] containing this document.
  DateTimeQueryCollectionReference get parent {
    return _$DateTimeQueryCollectionReference(reference.firestore);
  }

  @override
  Stream<DateTimeQueryDocumentSnapshot> snapshots() {
    return reference.snapshots().map((snapshot) {
      return DateTimeQueryDocumentSnapshot._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<DateTimeQueryDocumentSnapshot> get([GetOptions? options]) {
    return reference.get(options).then((snapshot) {
      return DateTimeQueryDocumentSnapshot._(
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
    Object? time = _sentinel,
  }) async {
    final json = {
      if (time != _sentinel) "time": time as DateTime,
    };

    return reference.update(json);
  }

  Future<void> set(DateTimeQuery value) {
    return reference.set(value);
  }

  @override
  bool operator ==(Object other) {
    return other is DateTimeQueryDocumentReference &&
        other.runtimeType == runtimeType &&
        other.parent == parent &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, parent, id);
}

class DateTimeQueryDocumentSnapshot extends FirestoreDocumentSnapshot {
  DateTimeQueryDocumentSnapshot._(
    this.snapshot,
    this.data,
  );

  @override
  final DocumentSnapshot<DateTimeQuery> snapshot;

  @override
  DateTimeQueryDocumentReference get reference {
    return DateTimeQueryDocumentReference(
      snapshot.reference,
    );
  }

  @override
  final DateTimeQuery? data;
}

abstract class DateTimeQueryQuery
    implements QueryReference<DateTimeQueryQuerySnapshot> {
  @override
  DateTimeQueryQuery limit(int limit);

  @override
  DateTimeQueryQuery limitToLast(int limit);

  DateTimeQueryQuery whereTime({
    DateTime? isEqualTo,
    DateTime? isNotEqualTo,
    DateTime? isLessThan,
    DateTime? isLessThanOrEqualTo,
    DateTime? isGreaterThan,
    DateTime? isGreaterThanOrEqualTo,
    bool? isNull,
    List<DateTime>? whereIn,
    List<DateTime>? whereNotIn,
  });

  DateTimeQueryQuery orderByTime({
    bool descending = false,
    DateTime startAt,
    DateTime startAfter,
    DateTime endAt,
    DateTime endBefore,
    DateTimeQueryDocumentSnapshot? startAtDocument,
    DateTimeQueryDocumentSnapshot? endAtDocument,
    DateTimeQueryDocumentSnapshot? endBeforeDocument,
    DateTimeQueryDocumentSnapshot? startAfterDocument,
  });
}

class _$DateTimeQueryQuery extends QueryReference<DateTimeQueryQuerySnapshot>
    implements DateTimeQueryQuery {
  _$DateTimeQueryQuery(
    this.reference,
    this._collection,
  );

  final CollectionReference<Object?> _collection;

  @override
  final Query<DateTimeQuery> reference;

  DateTimeQueryQuerySnapshot _decodeSnapshot(
    QuerySnapshot<DateTimeQuery> snapshot,
  ) {
    final docs = snapshot.docs.map((e) {
      return DateTimeQueryQueryDocumentSnapshot._(e, e.data());
    }).toList();

    final docChanges = snapshot.docChanges.map((change) {
      return FirestoreDocumentChange<DateTimeQueryDocumentSnapshot>(
        type: change.type,
        oldIndex: change.oldIndex,
        newIndex: change.newIndex,
        doc: DateTimeQueryDocumentSnapshot._(change.doc, change.doc.data()),
      );
    }).toList();

    return DateTimeQueryQuerySnapshot._(
      snapshot,
      docs,
      docChanges,
    );
  }

  @override
  Stream<DateTimeQueryQuerySnapshot> snapshots([SnapshotOptions? options]) {
    return reference.snapshots().map(_decodeSnapshot);
  }

  @override
  Future<DateTimeQueryQuerySnapshot> get([GetOptions? options]) {
    return reference.get(options).then(_decodeSnapshot);
  }

  @override
  DateTimeQueryQuery limit(int limit) {
    return _$DateTimeQueryQuery(
      reference.limit(limit),
      _collection,
    );
  }

  @override
  DateTimeQueryQuery limitToLast(int limit) {
    return _$DateTimeQueryQuery(
      reference.limitToLast(limit),
      _collection,
    );
  }

  DateTimeQueryQuery whereTime({
    DateTime? isEqualTo,
    DateTime? isNotEqualTo,
    DateTime? isLessThan,
    DateTime? isLessThanOrEqualTo,
    DateTime? isGreaterThan,
    DateTime? isGreaterThanOrEqualTo,
    bool? isNull,
    List<DateTime>? whereIn,
    List<DateTime>? whereNotIn,
  }) {
    return _$DateTimeQueryQuery(
      reference.where(
        'time',
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

  DateTimeQueryQuery orderByTime({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    DateTimeQueryDocumentSnapshot? startAtDocument,
    DateTimeQueryDocumentSnapshot? endAtDocument,
    DateTimeQueryDocumentSnapshot? endBeforeDocument,
    DateTimeQueryDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy('time', descending: descending);

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

    return _$DateTimeQueryQuery(query, _collection);
  }

  @override
  bool operator ==(Object other) {
    return other is _$DateTimeQueryQuery &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

class DateTimeQueryQuerySnapshot
    extends FirestoreQuerySnapshot<DateTimeQueryQueryDocumentSnapshot> {
  DateTimeQueryQuerySnapshot._(
    this.snapshot,
    this.docs,
    this.docChanges,
  );

  final QuerySnapshot<DateTimeQuery> snapshot;

  @override
  final List<DateTimeQueryQueryDocumentSnapshot> docs;

  @override
  final List<FirestoreDocumentChange<DateTimeQueryDocumentSnapshot>> docChanges;
}

class DateTimeQueryQueryDocumentSnapshot extends FirestoreQueryDocumentSnapshot
    implements DateTimeQueryDocumentSnapshot {
  DateTimeQueryQueryDocumentSnapshot._(this.snapshot, this.data);

  @override
  final QueryDocumentSnapshot<DateTimeQuery> snapshot;

  @override
  DateTimeQueryDocumentReference get reference {
    return DateTimeQueryDocumentReference(snapshot.reference);
  }

  @override
  final DateTimeQuery data;
}

/// A collection reference object can be used for adding documents,
/// getting document references, and querying for documents
/// (using the methods inherited from Query).
abstract class TimestampQueryCollectionReference
    implements
        TimestampQueryQuery,
        FirestoreCollectionReference<TimestampQueryQuerySnapshot> {
  factory TimestampQueryCollectionReference([
    FirebaseFirestore? firestore,
  ]) = _$TimestampQueryCollectionReference;

  static TimestampQuery fromFirestore(
    DocumentSnapshot<Map<String, Object?>> snapshot,
    SnapshotOptions? options,
  ) {
    return _$TimestampQueryFromJson(snapshot.data()!);
  }

  static Map<String, Object?> toFirestore(
    TimestampQuery value,
    SetOptions? options,
  ) {
    return _$TimestampQueryToJson(value);
  }

  @override
  TimestampQueryDocumentReference doc([String? id]);

  /// Add a new document to this collection with the specified data,
  /// assigning it a document ID automatically.
  Future<TimestampQueryDocumentReference> add(TimestampQuery value);
}

class _$TimestampQueryCollectionReference extends _$TimestampQueryQuery
    implements TimestampQueryCollectionReference {
  factory _$TimestampQueryCollectionReference([FirebaseFirestore? firestore]) {
    firestore ??= FirebaseFirestore.instance;

    return _$TimestampQueryCollectionReference._(
      firestore
          .collection('firestore-example-app/42/timestamp-time')
          .withConverter(
            fromFirestore: TimestampQueryCollectionReference.fromFirestore,
            toFirestore: TimestampQueryCollectionReference.toFirestore,
          ),
    );
  }

  _$TimestampQueryCollectionReference._(
    CollectionReference<TimestampQuery> reference,
  ) : super(reference, reference);

  String get path => reference.path;

  @override
  CollectionReference<TimestampQuery> get reference =>
      super.reference as CollectionReference<TimestampQuery>;

  @override
  TimestampQueryDocumentReference doc([String? id]) {
    return TimestampQueryDocumentReference(
      reference.doc(id),
    );
  }

  @override
  Future<TimestampQueryDocumentReference> add(TimestampQuery value) {
    return reference
        .add(value)
        .then((ref) => TimestampQueryDocumentReference(ref));
  }

  @override
  bool operator ==(Object other) {
    return other is _$TimestampQueryCollectionReference &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

abstract class TimestampQueryDocumentReference
    extends FirestoreDocumentReference<TimestampQueryDocumentSnapshot> {
  factory TimestampQueryDocumentReference(
          DocumentReference<TimestampQuery> reference) =
      _$TimestampQueryDocumentReference;

  DocumentReference<TimestampQuery> get reference;

  /// A reference to the [TimestampQueryCollectionReference] containing this document.
  TimestampQueryCollectionReference get parent {
    return _$TimestampQueryCollectionReference(reference.firestore);
  }

  @override
  Stream<TimestampQueryDocumentSnapshot> snapshots();

  @override
  Future<TimestampQueryDocumentSnapshot> get([GetOptions? options]);

  @override
  Future<void> delete();

  Future<void> update({
    Timestamp time,
  });

  Future<void> set(TimestampQuery value);
}

class _$TimestampQueryDocumentReference
    extends FirestoreDocumentReference<TimestampQueryDocumentSnapshot>
    implements TimestampQueryDocumentReference {
  _$TimestampQueryDocumentReference(this.reference);

  @override
  final DocumentReference<TimestampQuery> reference;

  /// A reference to the [TimestampQueryCollectionReference] containing this document.
  TimestampQueryCollectionReference get parent {
    return _$TimestampQueryCollectionReference(reference.firestore);
  }

  @override
  Stream<TimestampQueryDocumentSnapshot> snapshots() {
    return reference.snapshots().map((snapshot) {
      return TimestampQueryDocumentSnapshot._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<TimestampQueryDocumentSnapshot> get([GetOptions? options]) {
    return reference.get(options).then((snapshot) {
      return TimestampQueryDocumentSnapshot._(
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
    Object? time = _sentinel,
  }) async {
    final json = {
      if (time != _sentinel) "time": time as Timestamp,
    };

    return reference.update(json);
  }

  Future<void> set(TimestampQuery value) {
    return reference.set(value);
  }

  @override
  bool operator ==(Object other) {
    return other is TimestampQueryDocumentReference &&
        other.runtimeType == runtimeType &&
        other.parent == parent &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, parent, id);
}

class TimestampQueryDocumentSnapshot extends FirestoreDocumentSnapshot {
  TimestampQueryDocumentSnapshot._(
    this.snapshot,
    this.data,
  );

  @override
  final DocumentSnapshot<TimestampQuery> snapshot;

  @override
  TimestampQueryDocumentReference get reference {
    return TimestampQueryDocumentReference(
      snapshot.reference,
    );
  }

  @override
  final TimestampQuery? data;
}

abstract class TimestampQueryQuery
    implements QueryReference<TimestampQueryQuerySnapshot> {
  @override
  TimestampQueryQuery limit(int limit);

  @override
  TimestampQueryQuery limitToLast(int limit);

  TimestampQueryQuery whereTime({
    Timestamp? isEqualTo,
    Timestamp? isNotEqualTo,
    Timestamp? isLessThan,
    Timestamp? isLessThanOrEqualTo,
    Timestamp? isGreaterThan,
    Timestamp? isGreaterThanOrEqualTo,
    bool? isNull,
    List<Timestamp>? whereIn,
    List<Timestamp>? whereNotIn,
  });

  TimestampQueryQuery orderByTime({
    bool descending = false,
    Timestamp startAt,
    Timestamp startAfter,
    Timestamp endAt,
    Timestamp endBefore,
    TimestampQueryDocumentSnapshot? startAtDocument,
    TimestampQueryDocumentSnapshot? endAtDocument,
    TimestampQueryDocumentSnapshot? endBeforeDocument,
    TimestampQueryDocumentSnapshot? startAfterDocument,
  });
}

class _$TimestampQueryQuery extends QueryReference<TimestampQueryQuerySnapshot>
    implements TimestampQueryQuery {
  _$TimestampQueryQuery(
    this.reference,
    this._collection,
  );

  final CollectionReference<Object?> _collection;

  @override
  final Query<TimestampQuery> reference;

  TimestampQueryQuerySnapshot _decodeSnapshot(
    QuerySnapshot<TimestampQuery> snapshot,
  ) {
    final docs = snapshot.docs.map((e) {
      return TimestampQueryQueryDocumentSnapshot._(e, e.data());
    }).toList();

    final docChanges = snapshot.docChanges.map((change) {
      return FirestoreDocumentChange<TimestampQueryDocumentSnapshot>(
        type: change.type,
        oldIndex: change.oldIndex,
        newIndex: change.newIndex,
        doc: TimestampQueryDocumentSnapshot._(change.doc, change.doc.data()),
      );
    }).toList();

    return TimestampQueryQuerySnapshot._(
      snapshot,
      docs,
      docChanges,
    );
  }

  @override
  Stream<TimestampQueryQuerySnapshot> snapshots([SnapshotOptions? options]) {
    return reference.snapshots().map(_decodeSnapshot);
  }

  @override
  Future<TimestampQueryQuerySnapshot> get([GetOptions? options]) {
    return reference.get(options).then(_decodeSnapshot);
  }

  @override
  TimestampQueryQuery limit(int limit) {
    return _$TimestampQueryQuery(
      reference.limit(limit),
      _collection,
    );
  }

  @override
  TimestampQueryQuery limitToLast(int limit) {
    return _$TimestampQueryQuery(
      reference.limitToLast(limit),
      _collection,
    );
  }

  TimestampQueryQuery whereTime({
    Timestamp? isEqualTo,
    Timestamp? isNotEqualTo,
    Timestamp? isLessThan,
    Timestamp? isLessThanOrEqualTo,
    Timestamp? isGreaterThan,
    Timestamp? isGreaterThanOrEqualTo,
    bool? isNull,
    List<Timestamp>? whereIn,
    List<Timestamp>? whereNotIn,
  }) {
    return _$TimestampQueryQuery(
      reference.where(
        'time',
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

  TimestampQueryQuery orderByTime({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    TimestampQueryDocumentSnapshot? startAtDocument,
    TimestampQueryDocumentSnapshot? endAtDocument,
    TimestampQueryDocumentSnapshot? endBeforeDocument,
    TimestampQueryDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy('time', descending: descending);

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

    return _$TimestampQueryQuery(query, _collection);
  }

  @override
  bool operator ==(Object other) {
    return other is _$TimestampQueryQuery &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

class TimestampQueryQuerySnapshot
    extends FirestoreQuerySnapshot<TimestampQueryQueryDocumentSnapshot> {
  TimestampQueryQuerySnapshot._(
    this.snapshot,
    this.docs,
    this.docChanges,
  );

  final QuerySnapshot<TimestampQuery> snapshot;

  @override
  final List<TimestampQueryQueryDocumentSnapshot> docs;

  @override
  final List<FirestoreDocumentChange<TimestampQueryDocumentSnapshot>>
      docChanges;
}

class TimestampQueryQueryDocumentSnapshot extends FirestoreQueryDocumentSnapshot
    implements TimestampQueryDocumentSnapshot {
  TimestampQueryQueryDocumentSnapshot._(this.snapshot, this.data);

  @override
  final QueryDocumentSnapshot<TimestampQuery> snapshot;

  @override
  TimestampQueryDocumentReference get reference {
    return TimestampQueryDocumentReference(snapshot.reference);
  }

  @override
  final TimestampQuery data;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DateTimeQuery _$DateTimeQueryFromJson(Map<String, dynamic> json) =>
    DateTimeQuery(
      const FirestoreDateTimeConverter().fromJson(json['time'] as Timestamp),
    );

Map<String, dynamic> _$DateTimeQueryToJson(DateTimeQuery instance) =>
    <String, dynamic>{
      'time': const FirestoreDateTimeConverter().toJson(instance.time),
    };

TimestampQuery _$TimestampQueryFromJson(Map<String, dynamic> json) =>
    TimestampQuery(
      const FirestoreTimestampConverter().fromJson(json['time'] as Timestamp),
    );

Map<String, dynamic> _$TimestampQueryToJson(TimestampQuery instance) =>
    <String, dynamic>{
      'time': const FirestoreTimestampConverter().toJson(instance.time),
    };
