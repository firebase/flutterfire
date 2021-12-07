// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie.dart';

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
abstract class MovieCollectionReference
    implements MovieQuery, FirestoreCollectionReference<MovieQuerySnapshot> {
  factory MovieCollectionReference([
    FirebaseFirestore? firestore,
  ]) = _$MovieCollectionReference;

  static Movie fromFirestore(
    DocumentSnapshot<Map<String, Object?>> snapshot,
    SnapshotOptions? options,
  ) {
    return _$MovieFromJson(snapshot.data()!);
  }

  static Map<String, Object?> toFirestore(
    Movie value,
    SetOptions? options,
  ) {
    return _$MovieToJson(value);
  }

  @override
  MovieDocumentReference doc([String? id]);

  /// Add a new document to this collection with the specified data,
  /// assigning it a document ID automatically.
  Future<MovieDocumentReference> add(Movie value);
}

class _$MovieCollectionReference extends _$MovieQuery
    implements MovieCollectionReference {
  factory _$MovieCollectionReference([FirebaseFirestore? firestore]) {
    firestore ??= FirebaseFirestore.instance;

    return _$MovieCollectionReference._(
      firestore.collection('firestore-example-app').withConverter(
            fromFirestore: MovieCollectionReference.fromFirestore,
            toFirestore: MovieCollectionReference.toFirestore,
          ),
    );
  }

  _$MovieCollectionReference._(
    CollectionReference<Movie> reference,
  ) : super(reference, reference);

  String get path => reference.path;

  @override
  CollectionReference<Movie> get reference =>
      super.reference as CollectionReference<Movie>;

  @override
  MovieDocumentReference doc([String? id]) {
    return MovieDocumentReference(
      reference.doc(id),
    );
  }

  @override
  Future<MovieDocumentReference> add(Movie value) {
    return reference.add(value).then((ref) => MovieDocumentReference(ref));
  }

  @override
  bool operator ==(Object other) {
    return other is _$MovieCollectionReference &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

abstract class MovieDocumentReference
    extends FirestoreDocumentReference<MovieDocumentSnapshot> {
  factory MovieDocumentReference(DocumentReference<Movie> reference) =
      _$MovieDocumentReference;

  DocumentReference<Movie> get reference;

  /// A reference to the [MovieCollectionReference] containing this document.
  MovieCollectionReference get parent {
    return _$MovieCollectionReference(reference.firestore);
  }

  late final CommentCollectionReference comments = _$CommentCollectionReference(
    reference,
  );

  @override
  Stream<MovieDocumentSnapshot> snapshots();

  @override
  Future<MovieDocumentSnapshot> get([GetOptions? options]);

  @override
  Future<void> delete();

  Future<void> update({
    String poster,
    int likes,
    String title,
    int year,
    String runtime,
    String rated,
    List<String>? genre,
  });

  Future<void> set(Movie value);
}

class _$MovieDocumentReference
    extends FirestoreDocumentReference<MovieDocumentSnapshot>
    implements MovieDocumentReference {
  _$MovieDocumentReference(this.reference);

  @override
  final DocumentReference<Movie> reference;

  /// A reference to the [MovieCollectionReference] containing this document.
  MovieCollectionReference get parent {
    return _$MovieCollectionReference(reference.firestore);
  }

  late final CommentCollectionReference comments = _$CommentCollectionReference(
    reference,
  );

  @override
  Stream<MovieDocumentSnapshot> snapshots() {
    return reference.snapshots().map((snapshot) {
      return MovieDocumentSnapshot._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<MovieDocumentSnapshot> get([GetOptions? options]) {
    return reference.get(options).then((snapshot) {
      return MovieDocumentSnapshot._(
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
    Object? poster = _sentinel,
    Object? likes = _sentinel,
    Object? title = _sentinel,
    Object? year = _sentinel,
    Object? runtime = _sentinel,
    Object? rated = _sentinel,
    Object? genre = _sentinel,
  }) async {
    final json = {
      if (poster != _sentinel) "poster": poster as String,
      if (likes != _sentinel) "likes": likes as int,
      if (title != _sentinel) "title": title as String,
      if (year != _sentinel) "year": year as int,
      if (runtime != _sentinel) "runtime": runtime as String,
      if (rated != _sentinel) "rated": rated as String,
      if (genre != _sentinel) "genre": genre as List<String>?,
    };

    return reference.update(json);
  }

  Future<void> set(Movie value) {
    return reference.set(value);
  }

  @override
  bool operator ==(Object other) {
    return other is MovieDocumentReference &&
        other.runtimeType == runtimeType &&
        other.parent == parent &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, parent, id);
}

class MovieDocumentSnapshot extends FirestoreDocumentSnapshot {
  MovieDocumentSnapshot._(
    this.snapshot,
    this.data,
  );

  @override
  final DocumentSnapshot<Movie> snapshot;

  @override
  MovieDocumentReference get reference {
    return MovieDocumentReference(
      snapshot.reference,
    );
  }

  @override
  final Movie? data;
}

abstract class MovieQuery implements QueryReference<MovieQuerySnapshot> {
  @override
  MovieQuery limit(int limit);

  @override
  MovieQuery limitToLast(int limit);

  MovieQuery wherePoster({
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
  MovieQuery whereLikes({
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
  MovieQuery whereTitle({
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
  MovieQuery whereYear({
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
  MovieQuery whereRuntime({
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
  MovieQuery whereRated({
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
  MovieQuery whereGenre({
    List<String>? isEqualTo,
    List<String>? isNotEqualTo,
    List<String>? isLessThan,
    List<String>? isLessThanOrEqualTo,
    List<String>? isGreaterThan,
    List<String>? isGreaterThanOrEqualTo,
    bool? isNull,
    List<String>? arrayContainsAny,
  });

  MovieQuery orderByPoster({
    bool descending = false,
    String startAt,
    String startAfter,
    String endAt,
    String endBefore,
    MovieDocumentSnapshot? startAtDocument,
    MovieDocumentSnapshot? endAtDocument,
    MovieDocumentSnapshot? endBeforeDocument,
    MovieDocumentSnapshot? startAfterDocument,
  });

  MovieQuery orderByLikes({
    bool descending = false,
    int startAt,
    int startAfter,
    int endAt,
    int endBefore,
    MovieDocumentSnapshot? startAtDocument,
    MovieDocumentSnapshot? endAtDocument,
    MovieDocumentSnapshot? endBeforeDocument,
    MovieDocumentSnapshot? startAfterDocument,
  });

  MovieQuery orderByTitle({
    bool descending = false,
    String startAt,
    String startAfter,
    String endAt,
    String endBefore,
    MovieDocumentSnapshot? startAtDocument,
    MovieDocumentSnapshot? endAtDocument,
    MovieDocumentSnapshot? endBeforeDocument,
    MovieDocumentSnapshot? startAfterDocument,
  });

  MovieQuery orderByYear({
    bool descending = false,
    int startAt,
    int startAfter,
    int endAt,
    int endBefore,
    MovieDocumentSnapshot? startAtDocument,
    MovieDocumentSnapshot? endAtDocument,
    MovieDocumentSnapshot? endBeforeDocument,
    MovieDocumentSnapshot? startAfterDocument,
  });

  MovieQuery orderByRuntime({
    bool descending = false,
    String startAt,
    String startAfter,
    String endAt,
    String endBefore,
    MovieDocumentSnapshot? startAtDocument,
    MovieDocumentSnapshot? endAtDocument,
    MovieDocumentSnapshot? endBeforeDocument,
    MovieDocumentSnapshot? startAfterDocument,
  });

  MovieQuery orderByRated({
    bool descending = false,
    String startAt,
    String startAfter,
    String endAt,
    String endBefore,
    MovieDocumentSnapshot? startAtDocument,
    MovieDocumentSnapshot? endAtDocument,
    MovieDocumentSnapshot? endBeforeDocument,
    MovieDocumentSnapshot? startAfterDocument,
  });

  MovieQuery orderByGenre({
    bool descending = false,
    List<String>? startAt,
    List<String>? startAfter,
    List<String>? endAt,
    List<String>? endBefore,
    MovieDocumentSnapshot? startAtDocument,
    MovieDocumentSnapshot? endAtDocument,
    MovieDocumentSnapshot? endBeforeDocument,
    MovieDocumentSnapshot? startAfterDocument,
  });
}

class _$MovieQuery extends QueryReference<MovieQuerySnapshot>
    implements MovieQuery {
  _$MovieQuery(
    this.reference,
    this._collection,
  );

  final CollectionReference<Object?> _collection;

  @override
  final Query<Movie> reference;

  MovieQuerySnapshot _decodeSnapshot(
    QuerySnapshot<Movie> snapshot,
  ) {
    final docs = snapshot.docs.map((e) {
      return MovieQueryDocumentSnapshot._(e, e.data());
    }).toList();

    final docChanges = snapshot.docChanges.map((change) {
      return FirestoreDocumentChange<MovieDocumentSnapshot>(
        type: change.type,
        oldIndex: change.oldIndex,
        newIndex: change.newIndex,
        doc: MovieDocumentSnapshot._(change.doc, change.doc.data()),
      );
    }).toList();

    return MovieQuerySnapshot._(
      snapshot,
      docs,
      docChanges,
    );
  }

  @override
  Stream<MovieQuerySnapshot> snapshots([SnapshotOptions? options]) {
    return reference.snapshots().map(_decodeSnapshot);
  }

  @override
  Future<MovieQuerySnapshot> get([GetOptions? options]) {
    return reference.get(options).then(_decodeSnapshot);
  }

  @override
  MovieQuery limit(int limit) {
    return _$MovieQuery(
      reference.limit(limit),
      _collection,
    );
  }

  @override
  MovieQuery limitToLast(int limit) {
    return _$MovieQuery(
      reference.limitToLast(limit),
      _collection,
    );
  }

  MovieQuery wherePoster({
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
    return _$MovieQuery(
      reference.where(
        'poster',
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

  MovieQuery whereLikes({
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
    return _$MovieQuery(
      reference.where(
        'likes',
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

  MovieQuery whereTitle({
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
    return _$MovieQuery(
      reference.where(
        'title',
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

  MovieQuery whereYear({
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
    return _$MovieQuery(
      reference.where(
        'year',
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

  MovieQuery whereRuntime({
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
    return _$MovieQuery(
      reference.where(
        'runtime',
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

  MovieQuery whereRated({
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
    return _$MovieQuery(
      reference.where(
        'rated',
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

  MovieQuery whereGenre({
    List<String>? isEqualTo,
    List<String>? isNotEqualTo,
    List<String>? isLessThan,
    List<String>? isLessThanOrEqualTo,
    List<String>? isGreaterThan,
    List<String>? isGreaterThanOrEqualTo,
    bool? isNull,
    List<String>? arrayContainsAny,
  }) {
    return _$MovieQuery(
      reference.where(
        'genre',
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        isNull: isNull,
        arrayContainsAny: arrayContainsAny,
      ),
      _collection,
    );
  }

  MovieQuery orderByPoster({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    MovieDocumentSnapshot? startAtDocument,
    MovieDocumentSnapshot? endAtDocument,
    MovieDocumentSnapshot? endBeforeDocument,
    MovieDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy('poster', descending: false);

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

    return _$MovieQuery(query, _collection);
  }

  MovieQuery orderByLikes({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    MovieDocumentSnapshot? startAtDocument,
    MovieDocumentSnapshot? endAtDocument,
    MovieDocumentSnapshot? endBeforeDocument,
    MovieDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy('likes', descending: false);

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

    return _$MovieQuery(query, _collection);
  }

  MovieQuery orderByTitle({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    MovieDocumentSnapshot? startAtDocument,
    MovieDocumentSnapshot? endAtDocument,
    MovieDocumentSnapshot? endBeforeDocument,
    MovieDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy('title', descending: false);

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

    return _$MovieQuery(query, _collection);
  }

  MovieQuery orderByYear({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    MovieDocumentSnapshot? startAtDocument,
    MovieDocumentSnapshot? endAtDocument,
    MovieDocumentSnapshot? endBeforeDocument,
    MovieDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy('year', descending: false);

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

    return _$MovieQuery(query, _collection);
  }

  MovieQuery orderByRuntime({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    MovieDocumentSnapshot? startAtDocument,
    MovieDocumentSnapshot? endAtDocument,
    MovieDocumentSnapshot? endBeforeDocument,
    MovieDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy('runtime', descending: false);

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

    return _$MovieQuery(query, _collection);
  }

  MovieQuery orderByRated({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    MovieDocumentSnapshot? startAtDocument,
    MovieDocumentSnapshot? endAtDocument,
    MovieDocumentSnapshot? endBeforeDocument,
    MovieDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy('rated', descending: false);

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

    return _$MovieQuery(query, _collection);
  }

  MovieQuery orderByGenre({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    MovieDocumentSnapshot? startAtDocument,
    MovieDocumentSnapshot? endAtDocument,
    MovieDocumentSnapshot? endBeforeDocument,
    MovieDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy('genre', descending: false);

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

    return _$MovieQuery(query, _collection);
  }

  @override
  bool operator ==(Object other) {
    return other is _$MovieQuery &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

class MovieQuerySnapshot
    extends FirestoreQuerySnapshot<MovieQueryDocumentSnapshot> {
  MovieQuerySnapshot._(
    this.snapshot,
    this.docs,
    this.docChanges,
  );

  final QuerySnapshot<Movie> snapshot;

  @override
  final List<MovieQueryDocumentSnapshot> docs;

  @override
  final List<FirestoreDocumentChange<MovieDocumentSnapshot>> docChanges;
}

class MovieQueryDocumentSnapshot extends FirestoreQueryDocumentSnapshot
    implements MovieDocumentSnapshot {
  MovieQueryDocumentSnapshot._(this.snapshot, this.data);

  @override
  final QueryDocumentSnapshot<Movie> snapshot;

  @override
  MovieDocumentReference get reference {
    return MovieDocumentReference(snapshot.reference);
  }

  @override
  final Movie data;
}

/// A collection reference object can be used for adding documents,
/// getting document references, and querying for documents
/// (using the methods inherited from Query).
abstract class CommentCollectionReference
    implements
        CommentQuery,
        FirestoreCollectionReference<CommentQuerySnapshot> {
  factory CommentCollectionReference(
    DocumentReference<Movie> parent,
  ) = _$CommentCollectionReference;

  static Comment fromFirestore(
    DocumentSnapshot<Map<String, Object?>> snapshot,
    SnapshotOptions? options,
  ) {
    return _$CommentFromJson(snapshot.data()!);
  }

  static Map<String, Object?> toFirestore(
    Comment value,
    SetOptions? options,
  ) {
    return _$CommentToJson(value);
  }

  /// A reference to the containing [MovieDocumentReference] if this is a subcollection.
  MovieDocumentReference get parent;

  @override
  CommentDocumentReference doc([String? id]);

  /// Add a new document to this collection with the specified data,
  /// assigning it a document ID automatically.
  Future<CommentDocumentReference> add(Comment value);
}

class _$CommentCollectionReference extends _$CommentQuery
    implements CommentCollectionReference {
  factory _$CommentCollectionReference(
    DocumentReference<Movie> parent,
  ) {
    return _$CommentCollectionReference._(
      MovieDocumentReference(parent),
      parent.collection('comments').withConverter(
            fromFirestore: CommentCollectionReference.fromFirestore,
            toFirestore: CommentCollectionReference.toFirestore,
          ),
    );
  }

  _$CommentCollectionReference._(
    this.parent,
    CollectionReference<Comment> reference,
  ) : super(reference, reference);

  @override
  final MovieDocumentReference parent;

  String get path => reference.path;

  @override
  CollectionReference<Comment> get reference =>
      super.reference as CollectionReference<Comment>;

  @override
  CommentDocumentReference doc([String? id]) {
    return CommentDocumentReference(
      reference.doc(id),
    );
  }

  @override
  Future<CommentDocumentReference> add(Comment value) {
    return reference.add(value).then((ref) => CommentDocumentReference(ref));
  }

  @override
  bool operator ==(Object other) {
    return other is _$CommentCollectionReference &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

abstract class CommentDocumentReference
    extends FirestoreDocumentReference<CommentDocumentSnapshot> {
  factory CommentDocumentReference(DocumentReference<Comment> reference) =
      _$CommentDocumentReference;

  DocumentReference<Comment> get reference;

  /// A reference to the [CommentCollectionReference] containing this document.
  CommentCollectionReference get parent {
    return _$CommentCollectionReference(
      reference.parent.parent!.withConverter<Movie>(
        fromFirestore: MovieCollectionReference.fromFirestore,
        toFirestore: MovieCollectionReference.toFirestore,
      ),
    );
  }

  @override
  Stream<CommentDocumentSnapshot> snapshots();

  @override
  Future<CommentDocumentSnapshot> get([GetOptions? options]);

  @override
  Future<void> delete();

  Future<void> update({
    String authorName,
    String message,
  });

  Future<void> set(Comment value);
}

class _$CommentDocumentReference
    extends FirestoreDocumentReference<CommentDocumentSnapshot>
    implements CommentDocumentReference {
  _$CommentDocumentReference(this.reference);

  @override
  final DocumentReference<Comment> reference;

  /// A reference to the [CommentCollectionReference] containing this document.
  CommentCollectionReference get parent {
    return _$CommentCollectionReference(
      reference.parent.parent!.withConverter<Movie>(
        fromFirestore: MovieCollectionReference.fromFirestore,
        toFirestore: MovieCollectionReference.toFirestore,
      ),
    );
  }

  @override
  Stream<CommentDocumentSnapshot> snapshots() {
    return reference.snapshots().map((snapshot) {
      return CommentDocumentSnapshot._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<CommentDocumentSnapshot> get([GetOptions? options]) {
    return reference.get(options).then((snapshot) {
      return CommentDocumentSnapshot._(
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
    Object? authorName = _sentinel,
    Object? message = _sentinel,
  }) async {
    final json = {
      if (authorName != _sentinel) "authorName": authorName as String,
      if (message != _sentinel) "message": message as String,
    };

    return reference.update(json);
  }

  Future<void> set(Comment value) {
    return reference.set(value);
  }

  @override
  bool operator ==(Object other) {
    return other is CommentDocumentReference &&
        other.runtimeType == runtimeType &&
        other.parent == parent &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, parent, id);
}

class CommentDocumentSnapshot extends FirestoreDocumentSnapshot {
  CommentDocumentSnapshot._(
    this.snapshot,
    this.data,
  );

  @override
  final DocumentSnapshot<Comment> snapshot;

  @override
  CommentDocumentReference get reference {
    return CommentDocumentReference(
      snapshot.reference,
    );
  }

  @override
  final Comment? data;
}

abstract class CommentQuery implements QueryReference<CommentQuerySnapshot> {
  @override
  CommentQuery limit(int limit);

  @override
  CommentQuery limitToLast(int limit);

  CommentQuery whereAuthorName({
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
  CommentQuery whereMessage({
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

  CommentQuery orderByAuthorName({
    bool descending = false,
    String startAt,
    String startAfter,
    String endAt,
    String endBefore,
    CommentDocumentSnapshot? startAtDocument,
    CommentDocumentSnapshot? endAtDocument,
    CommentDocumentSnapshot? endBeforeDocument,
    CommentDocumentSnapshot? startAfterDocument,
  });

  CommentQuery orderByMessage({
    bool descending = false,
    String startAt,
    String startAfter,
    String endAt,
    String endBefore,
    CommentDocumentSnapshot? startAtDocument,
    CommentDocumentSnapshot? endAtDocument,
    CommentDocumentSnapshot? endBeforeDocument,
    CommentDocumentSnapshot? startAfterDocument,
  });
}

class _$CommentQuery extends QueryReference<CommentQuerySnapshot>
    implements CommentQuery {
  _$CommentQuery(
    this.reference,
    this._collection,
  );

  final CollectionReference<Object?> _collection;

  @override
  final Query<Comment> reference;

  CommentQuerySnapshot _decodeSnapshot(
    QuerySnapshot<Comment> snapshot,
  ) {
    final docs = snapshot.docs.map((e) {
      return CommentQueryDocumentSnapshot._(e, e.data());
    }).toList();

    final docChanges = snapshot.docChanges.map((change) {
      return FirestoreDocumentChange<CommentDocumentSnapshot>(
        type: change.type,
        oldIndex: change.oldIndex,
        newIndex: change.newIndex,
        doc: CommentDocumentSnapshot._(change.doc, change.doc.data()),
      );
    }).toList();

    return CommentQuerySnapshot._(
      snapshot,
      docs,
      docChanges,
    );
  }

  @override
  Stream<CommentQuerySnapshot> snapshots([SnapshotOptions? options]) {
    return reference.snapshots().map(_decodeSnapshot);
  }

  @override
  Future<CommentQuerySnapshot> get([GetOptions? options]) {
    return reference.get(options).then(_decodeSnapshot);
  }

  @override
  CommentQuery limit(int limit) {
    return _$CommentQuery(
      reference.limit(limit),
      _collection,
    );
  }

  @override
  CommentQuery limitToLast(int limit) {
    return _$CommentQuery(
      reference.limitToLast(limit),
      _collection,
    );
  }

  CommentQuery whereAuthorName({
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
    return _$CommentQuery(
      reference.where(
        'authorName',
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

  CommentQuery whereMessage({
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
    return _$CommentQuery(
      reference.where(
        'message',
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

  CommentQuery orderByAuthorName({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    CommentDocumentSnapshot? startAtDocument,
    CommentDocumentSnapshot? endAtDocument,
    CommentDocumentSnapshot? endBeforeDocument,
    CommentDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy('authorName', descending: false);

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

    return _$CommentQuery(query, _collection);
  }

  CommentQuery orderByMessage({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    CommentDocumentSnapshot? startAtDocument,
    CommentDocumentSnapshot? endAtDocument,
    CommentDocumentSnapshot? endBeforeDocument,
    CommentDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy('message', descending: false);

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

    return _$CommentQuery(query, _collection);
  }

  @override
  bool operator ==(Object other) {
    return other is _$CommentQuery &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

class CommentQuerySnapshot
    extends FirestoreQuerySnapshot<CommentQueryDocumentSnapshot> {
  CommentQuerySnapshot._(
    this.snapshot,
    this.docs,
    this.docChanges,
  );

  final QuerySnapshot<Comment> snapshot;

  @override
  final List<CommentQueryDocumentSnapshot> docs;

  @override
  final List<FirestoreDocumentChange<CommentDocumentSnapshot>> docChanges;
}

class CommentQueryDocumentSnapshot extends FirestoreQueryDocumentSnapshot
    implements CommentDocumentSnapshot {
  CommentQueryDocumentSnapshot._(this.snapshot, this.data);

  @override
  final QueryDocumentSnapshot<Comment> snapshot;

  @override
  CommentDocumentReference get reference {
    return CommentDocumentReference(snapshot.reference);
  }

  @override
  final Comment data;
}

// **************************************************************************
// ValidatorGenerator
// **************************************************************************

_$assertMovie(Movie instance) {
  const Min(0).validate(instance.likes, "likes");
  const Min(0).validate(instance.year, "year");
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Movie _$MovieFromJson(Map<String, dynamic> json) => Movie(
      genre:
          (json['genre'] as List<dynamic>?)?.map((e) => e as String).toList(),
      likes: json['likes'] as int,
      poster: json['poster'] as String,
      rated: json['rated'] as String,
      runtime: json['runtime'] as String,
      title: json['title'] as String,
      year: json['year'] as int,
    );

Map<String, dynamic> _$MovieToJson(Movie instance) => <String, dynamic>{
      'poster': instance.poster,
      'likes': instance.likes,
      'title': instance.title,
      'year': instance.year,
      'runtime': instance.runtime,
      'rated': instance.rated,
      'genre': instance.genre,
    };

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      authorName: json['authorName'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'authorName': instance.authorName,
      'message': instance.message,
    };
