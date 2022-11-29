// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'movie.dart';

// **************************************************************************
// CollectionGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, require_trailing_commas, prefer_single_quotes, prefer_double_quotes, use_super_parameters

class _Sentinel {
  const _Sentinel();
}

const _sentinel = _Sentinel();

/// A collection reference object can be used for adding documents,
/// getting document references, and querying for documents
/// (using the methods inherited from Query).
abstract class MovieCollectionReference
    implements
        MovieQuery,
        FirestoreCollectionReference<Movie, MovieQuerySnapshot> {
  factory MovieCollectionReference([
    FirebaseFirestore? firestore,
  ]) = _$MovieCollectionReference;

  static Movie fromFirestore(
    DocumentSnapshot<Map<String, Object?>> snapshot,
    SnapshotOptions? options,
  ) {
    return _$MovieFromJson({'id': snapshot.id, ...?snapshot.data()});
  }

  static Map<String, Object?> toFirestore(
    Movie value,
    SetOptions? options,
  ) {
    return {..._$MovieToJson(value)}..remove('id');
  }

  @override
  CollectionReference<Movie> get reference;

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
  ) : super(reference, $referenceWithoutCursor: reference);

  String get path => reference.path;

  @override
  CollectionReference<Movie> get reference =>
      super.reference as CollectionReference<Movie>;

  @override
  MovieDocumentReference doc([String? id]) {
    assert(
      id == null || id.split('/').length == 1,
      'The document ID cannot be from a different collection',
    );
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
    extends FirestoreDocumentReference<Movie, MovieDocumentSnapshot> {
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

  /// Updates data on the document. Data will be merged with any existing
  /// document data.
  ///
  /// If no document exists yet, the update will fail.
  Future<void> update({
    String poster,
    FieldValue posterFieldValue,
    int likes,
    FieldValue likesFieldValue,
    String title,
    FieldValue titleFieldValue,
    int year,
    FieldValue yearFieldValue,
    String runtime,
    FieldValue runtimeFieldValue,
    String rated,
    FieldValue ratedFieldValue,
    List<String>? genre,
    FieldValue genreFieldValue,
    List<LanguageType>? language,
    FieldValue languageFieldValue,
    CertificationType certification,
    FieldValue certificationFieldValue,
    List<Map<CastType, String>> cast,
    FieldValue castFieldValue,
    Map<CastType, String> majorCast,
    FieldValue majorCastFieldValue,
  });

  /// Updates fields in the current document using the transaction API.
  ///
  /// The update will fail if applied to a document that does not exist.
  void transactionUpdate(
    Transaction transaction, {
    String poster,
    FieldValue posterFieldValue,
    int likes,
    FieldValue likesFieldValue,
    String title,
    FieldValue titleFieldValue,
    int year,
    FieldValue yearFieldValue,
    String runtime,
    FieldValue runtimeFieldValue,
    String rated,
    FieldValue ratedFieldValue,
    List<String>? genre,
    FieldValue genreFieldValue,
    List<LanguageType>? language,
    FieldValue languageFieldValue,
    CertificationType certification,
    FieldValue certificationFieldValue,
    List<Map<CastType, String>> cast,
    FieldValue castFieldValue,
    Map<CastType, String> majorCast,
    FieldValue majorCastFieldValue,
  });
}

class _$MovieDocumentReference
    extends FirestoreDocumentReference<Movie, MovieDocumentSnapshot>
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
    return reference.snapshots().map(MovieDocumentSnapshot._);
  }

  @override
  Future<MovieDocumentSnapshot> get([GetOptions? options]) {
    return reference.get(options).then(MovieDocumentSnapshot._);
  }

  @override
  Future<MovieDocumentSnapshot> transactionGet(Transaction transaction) {
    return transaction.get(reference).then(MovieDocumentSnapshot._);
  }

  Future<void> update({
    Object? poster = _sentinel,
    FieldValue? posterFieldValue,
    Object? likes = _sentinel,
    FieldValue? likesFieldValue,
    Object? title = _sentinel,
    FieldValue? titleFieldValue,
    Object? year = _sentinel,
    FieldValue? yearFieldValue,
    Object? runtime = _sentinel,
    FieldValue? runtimeFieldValue,
    Object? rated = _sentinel,
    FieldValue? ratedFieldValue,
    Object? genre = _sentinel,
    FieldValue? genreFieldValue,
    Object? language = _sentinel,
    FieldValue? languageFieldValue,
    Object? certification = _sentinel,
    FieldValue? certificationFieldValue,
    Object? cast = _sentinel,
    FieldValue? castFieldValue,
    Object? majorCast = _sentinel,
    FieldValue? majorCastFieldValue,
  }) async {
    assert(
      poster == _sentinel || posterFieldValue == null,
      "Cannot specify both poster and posterFieldValue",
    );
    assert(
      likes == _sentinel || likesFieldValue == null,
      "Cannot specify both likes and likesFieldValue",
    );
    assert(
      title == _sentinel || titleFieldValue == null,
      "Cannot specify both title and titleFieldValue",
    );
    assert(
      year == _sentinel || yearFieldValue == null,
      "Cannot specify both year and yearFieldValue",
    );
    assert(
      runtime == _sentinel || runtimeFieldValue == null,
      "Cannot specify both runtime and runtimeFieldValue",
    );
    assert(
      rated == _sentinel || ratedFieldValue == null,
      "Cannot specify both rated and ratedFieldValue",
    );
    assert(
      genre == _sentinel || genreFieldValue == null,
      "Cannot specify both genre and genreFieldValue",
    );
    assert(
      language == _sentinel || languageFieldValue == null,
      "Cannot specify both language and languageFieldValue",
    );
    assert(
      certification == _sentinel || certificationFieldValue == null,
      "Cannot specify both certification and certificationFieldValue",
    );
    assert(
      cast == _sentinel || castFieldValue == null,
      "Cannot specify both cast and castFieldValue",
    );
    assert(
      majorCast == _sentinel || majorCastFieldValue == null,
      "Cannot specify both majorCast and majorCastFieldValue",
    );
    final json = {
      if (poster != _sentinel)
        _$MovieFieldMap['poster']!:
            _$MoviePerFieldToJson.poster(poster as String),
      if (posterFieldValue != null)
        _$MovieFieldMap['poster']!: posterFieldValue,
      if (likes != _sentinel)
        _$MovieFieldMap['likes']!: _$MoviePerFieldToJson.likes(likes as int),
      if (likesFieldValue != null) _$MovieFieldMap['likes']!: likesFieldValue,
      if (title != _sentinel)
        _$MovieFieldMap['title']!: _$MoviePerFieldToJson.title(title as String),
      if (titleFieldValue != null) _$MovieFieldMap['title']!: titleFieldValue,
      if (year != _sentinel)
        _$MovieFieldMap['year']!: _$MoviePerFieldToJson.year(year as int),
      if (yearFieldValue != null) _$MovieFieldMap['year']!: yearFieldValue,
      if (runtime != _sentinel)
        _$MovieFieldMap['runtime']!:
            _$MoviePerFieldToJson.runtime(runtime as String),
      if (runtimeFieldValue != null)
        _$MovieFieldMap['runtime']!: runtimeFieldValue,
      if (rated != _sentinel)
        _$MovieFieldMap['rated']!: _$MoviePerFieldToJson.rated(rated as String),
      if (ratedFieldValue != null) _$MovieFieldMap['rated']!: ratedFieldValue,
      if (genre != _sentinel)
        _$MovieFieldMap['genre']!:
            _$MoviePerFieldToJson.genre(genre as List<String>?),
      if (genreFieldValue != null) _$MovieFieldMap['genre']!: genreFieldValue,
      if (language != _sentinel)
        _$MovieFieldMap['language']!:
            _$MoviePerFieldToJson.language(language as List<LanguageType>?),
      if (languageFieldValue != null)
        _$MovieFieldMap['language']!: languageFieldValue,
      if (certification != _sentinel)
        _$MovieFieldMap['certification']!: _$MoviePerFieldToJson
            .certification(certification as CertificationType),
      if (certificationFieldValue != null)
        _$MovieFieldMap['certification']!: certificationFieldValue,
      if (cast != _sentinel)
        _$MovieFieldMap['cast']!:
            _$MoviePerFieldToJson.cast(cast as List<Map<CastType, String>>),
      if (castFieldValue != null) _$MovieFieldMap['cast']!: castFieldValue,
      if (majorCast != _sentinel)
        _$MovieFieldMap['majorCast']!:
            _$MoviePerFieldToJson.majorCast(majorCast as Map<CastType, String>),
      if (majorCastFieldValue != null)
        _$MovieFieldMap['majorCast']!: majorCastFieldValue,
    };

    return reference.update(json);
  }

  void transactionUpdate(
    Transaction transaction, {
    Object? poster = _sentinel,
    FieldValue? posterFieldValue,
    Object? likes = _sentinel,
    FieldValue? likesFieldValue,
    Object? title = _sentinel,
    FieldValue? titleFieldValue,
    Object? year = _sentinel,
    FieldValue? yearFieldValue,
    Object? runtime = _sentinel,
    FieldValue? runtimeFieldValue,
    Object? rated = _sentinel,
    FieldValue? ratedFieldValue,
    Object? genre = _sentinel,
    FieldValue? genreFieldValue,
    Object? language = _sentinel,
    FieldValue? languageFieldValue,
    Object? certification = _sentinel,
    FieldValue? certificationFieldValue,
    Object? cast = _sentinel,
    FieldValue? castFieldValue,
    Object? majorCast = _sentinel,
    FieldValue? majorCastFieldValue,
  }) {
    assert(
      poster == _sentinel || posterFieldValue == null,
      "Cannot specify both poster and posterFieldValue",
    );
    assert(
      likes == _sentinel || likesFieldValue == null,
      "Cannot specify both likes and likesFieldValue",
    );
    assert(
      title == _sentinel || titleFieldValue == null,
      "Cannot specify both title and titleFieldValue",
    );
    assert(
      year == _sentinel || yearFieldValue == null,
      "Cannot specify both year and yearFieldValue",
    );
    assert(
      runtime == _sentinel || runtimeFieldValue == null,
      "Cannot specify both runtime and runtimeFieldValue",
    );
    assert(
      rated == _sentinel || ratedFieldValue == null,
      "Cannot specify both rated and ratedFieldValue",
    );
    assert(
      genre == _sentinel || genreFieldValue == null,
      "Cannot specify both genre and genreFieldValue",
    );
    assert(
      language == _sentinel || languageFieldValue == null,
      "Cannot specify both language and languageFieldValue",
    );
    assert(
      certification == _sentinel || certificationFieldValue == null,
      "Cannot specify both certification and certificationFieldValue",
    );
    assert(
      cast == _sentinel || castFieldValue == null,
      "Cannot specify both cast and castFieldValue",
    );
    assert(
      majorCast == _sentinel || majorCastFieldValue == null,
      "Cannot specify both majorCast and majorCastFieldValue",
    );
    final json = {
      if (poster != _sentinel)
        _$MovieFieldMap['poster']!:
            _$MoviePerFieldToJson.poster(poster as String),
      if (posterFieldValue != null)
        _$MovieFieldMap['poster']!: posterFieldValue,
      if (likes != _sentinel)
        _$MovieFieldMap['likes']!: _$MoviePerFieldToJson.likes(likes as int),
      if (likesFieldValue != null) _$MovieFieldMap['likes']!: likesFieldValue,
      if (title != _sentinel)
        _$MovieFieldMap['title']!: _$MoviePerFieldToJson.title(title as String),
      if (titleFieldValue != null) _$MovieFieldMap['title']!: titleFieldValue,
      if (year != _sentinel)
        _$MovieFieldMap['year']!: _$MoviePerFieldToJson.year(year as int),
      if (yearFieldValue != null) _$MovieFieldMap['year']!: yearFieldValue,
      if (runtime != _sentinel)
        _$MovieFieldMap['runtime']!:
            _$MoviePerFieldToJson.runtime(runtime as String),
      if (runtimeFieldValue != null)
        _$MovieFieldMap['runtime']!: runtimeFieldValue,
      if (rated != _sentinel)
        _$MovieFieldMap['rated']!: _$MoviePerFieldToJson.rated(rated as String),
      if (ratedFieldValue != null) _$MovieFieldMap['rated']!: ratedFieldValue,
      if (genre != _sentinel)
        _$MovieFieldMap['genre']!:
            _$MoviePerFieldToJson.genre(genre as List<String>?),
      if (genreFieldValue != null) _$MovieFieldMap['genre']!: genreFieldValue,
      if (language != _sentinel)
        _$MovieFieldMap['language']!:
            _$MoviePerFieldToJson.language(language as List<LanguageType>?),
      if (languageFieldValue != null)
        _$MovieFieldMap['language']!: languageFieldValue,
      if (certification != _sentinel)
        _$MovieFieldMap['certification']!: _$MoviePerFieldToJson
            .certification(certification as CertificationType),
      if (certificationFieldValue != null)
        _$MovieFieldMap['certification']!: certificationFieldValue,
      if (cast != _sentinel)
        _$MovieFieldMap['cast']!:
            _$MoviePerFieldToJson.cast(cast as List<Map<CastType, String>>),
      if (castFieldValue != null) _$MovieFieldMap['cast']!: castFieldValue,
      if (majorCast != _sentinel)
        _$MovieFieldMap['majorCast']!:
            _$MoviePerFieldToJson.majorCast(majorCast as Map<CastType, String>),
      if (majorCastFieldValue != null)
        _$MovieFieldMap['majorCast']!: majorCastFieldValue,
    };

    transaction.update(reference, json);
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

abstract class MovieQuery implements QueryReference<Movie, MovieQuerySnapshot> {
  @override
  MovieQuery limit(int limit);

  @override
  MovieQuery limitToLast(int limit);

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
  MovieQuery orderByFieldPath(
    FieldPath fieldPath, {
    bool descending = false,
    Object? startAt,
    Object? startAfter,
    Object? endAt,
    Object? endBefore,
    MovieDocumentSnapshot? startAtDocument,
    MovieDocumentSnapshot? endAtDocument,
    MovieDocumentSnapshot? endBeforeDocument,
    MovieDocumentSnapshot? startAfterDocument,
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
  MovieQuery whereFieldPath(
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

  MovieQuery whereDocumentId({
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
    String? arrayContains,
    List<String>? arrayContainsAny,
  });
  MovieQuery whereLanguage({
    List<LanguageType>? isEqualTo,
    List<LanguageType>? isNotEqualTo,
    List<LanguageType>? isLessThan,
    List<LanguageType>? isLessThanOrEqualTo,
    List<LanguageType>? isGreaterThan,
    List<LanguageType>? isGreaterThanOrEqualTo,
    bool? isNull,
    LanguageType? arrayContains,
    List<LanguageType>? arrayContainsAny,
  });
  MovieQuery whereCertification({
    CertificationType? isEqualTo,
    CertificationType? isNotEqualTo,
    CertificationType? isLessThan,
    CertificationType? isLessThanOrEqualTo,
    CertificationType? isGreaterThan,
    CertificationType? isGreaterThanOrEqualTo,
    bool? isNull,
    List<CertificationType>? whereIn,
    List<CertificationType>? whereNotIn,
  });
  MovieQuery whereCast({
    List<Map<CastType, String>>? isEqualTo,
    List<Map<CastType, String>>? isNotEqualTo,
    List<Map<CastType, String>>? isLessThan,
    List<Map<CastType, String>>? isLessThanOrEqualTo,
    List<Map<CastType, String>>? isGreaterThan,
    List<Map<CastType, String>>? isGreaterThanOrEqualTo,
    bool? isNull,
    Map<CastType, String>? arrayContains,
    List<Map<CastType, String>>? arrayContainsAny,
  });
  MovieQuery whereMajorCast({
    Map<CastType, String>? isEqualTo,
    Map<CastType, String>? isNotEqualTo,
    Map<CastType, String>? isLessThan,
    Map<CastType, String>? isLessThanOrEqualTo,
    Map<CastType, String>? isGreaterThan,
    Map<CastType, String>? isGreaterThanOrEqualTo,
    bool? isNull,
    List<Map<CastType, String>>? whereIn,
    List<Map<CastType, String>>? whereNotIn,
  });

  MovieQuery orderByDocumentId({
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

  MovieQuery orderByLanguage({
    bool descending = false,
    List<LanguageType>? startAt,
    List<LanguageType>? startAfter,
    List<LanguageType>? endAt,
    List<LanguageType>? endBefore,
    MovieDocumentSnapshot? startAtDocument,
    MovieDocumentSnapshot? endAtDocument,
    MovieDocumentSnapshot? endBeforeDocument,
    MovieDocumentSnapshot? startAfterDocument,
  });

  MovieQuery orderByCertification({
    bool descending = false,
    CertificationType startAt,
    CertificationType startAfter,
    CertificationType endAt,
    CertificationType endBefore,
    MovieDocumentSnapshot? startAtDocument,
    MovieDocumentSnapshot? endAtDocument,
    MovieDocumentSnapshot? endBeforeDocument,
    MovieDocumentSnapshot? startAfterDocument,
  });

  MovieQuery orderByCast({
    bool descending = false,
    List<Map<CastType, String>> startAt,
    List<Map<CastType, String>> startAfter,
    List<Map<CastType, String>> endAt,
    List<Map<CastType, String>> endBefore,
    MovieDocumentSnapshot? startAtDocument,
    MovieDocumentSnapshot? endAtDocument,
    MovieDocumentSnapshot? endBeforeDocument,
    MovieDocumentSnapshot? startAfterDocument,
  });

  MovieQuery orderByMajorCast({
    bool descending = false,
    Map<CastType, String> startAt,
    Map<CastType, String> startAfter,
    Map<CastType, String> endAt,
    Map<CastType, String> endBefore,
    MovieDocumentSnapshot? startAtDocument,
    MovieDocumentSnapshot? endAtDocument,
    MovieDocumentSnapshot? endBeforeDocument,
    MovieDocumentSnapshot? startAfterDocument,
  });
}

class _$MovieQuery extends QueryReference<Movie, MovieQuerySnapshot>
    implements MovieQuery {
  _$MovieQuery(
    this._collection, {
    required Query<Movie> $referenceWithoutCursor,
    $QueryCursor $queryCursor = const $QueryCursor(),
  }) : super(
          $referenceWithoutCursor: $referenceWithoutCursor,
          $queryCursor: $queryCursor,
        );

  final CollectionReference<Object?> _collection;

  @override
  Stream<MovieQuerySnapshot> snapshots([SnapshotOptions? options]) {
    return reference.snapshots().map(MovieQuerySnapshot._fromQuerySnapshot);
  }

  @override
  Future<MovieQuerySnapshot> get([GetOptions? options]) {
    return reference.get(options).then(MovieQuerySnapshot._fromQuerySnapshot);
  }

  @override
  MovieQuery limit(int limit) {
    return _$MovieQuery(
      _collection,
      $referenceWithoutCursor: $referenceWithoutCursor.limit(limit),
      $queryCursor: $queryCursor,
    );
  }

  @override
  MovieQuery limitToLast(int limit) {
    return _$MovieQuery(
      _collection,
      $referenceWithoutCursor: $referenceWithoutCursor.limitToLast(limit),
      $queryCursor: $queryCursor,
    );
  }

  MovieQuery orderByFieldPath(
    FieldPath fieldPath, {
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
    return _$MovieQuery(
      _collection,
      $referenceWithoutCursor: query,
      $queryCursor: queryCursor,
    );
  }

  MovieQuery whereFieldPath(
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
    return _$MovieQuery(
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

  MovieQuery whereDocumentId({
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
      _collection,
      $referenceWithoutCursor: $referenceWithoutCursor.where(
        _$MovieFieldMap['poster']!,
        isEqualTo: _$MoviePerFieldToJson.poster(isEqualTo),
        isNotEqualTo: _$MoviePerFieldToJson.poster(isNotEqualTo),
        isLessThan: _$MoviePerFieldToJson.poster(isLessThan),
        isLessThanOrEqualTo: _$MoviePerFieldToJson.poster(isLessThanOrEqualTo),
        isGreaterThan: _$MoviePerFieldToJson.poster(isGreaterThan),
        isGreaterThanOrEqualTo:
            _$MoviePerFieldToJson.poster(isGreaterThanOrEqualTo),
        isNull: isNull,
        whereIn: whereIn?.map((e) => _$MoviePerFieldToJson.poster(e)).toList(),
        whereNotIn:
            whereNotIn?.map((e) => _$MoviePerFieldToJson.poster(e)).toList(),
      ),
      $queryCursor: $queryCursor,
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
      _collection,
      $referenceWithoutCursor: $referenceWithoutCursor.where(
        _$MovieFieldMap['likes']!,
        isEqualTo: _$MoviePerFieldToJson.likes(isEqualTo),
        isNotEqualTo: _$MoviePerFieldToJson.likes(isNotEqualTo),
        isLessThan: _$MoviePerFieldToJson.likes(isLessThan),
        isLessThanOrEqualTo: _$MoviePerFieldToJson.likes(isLessThanOrEqualTo),
        isGreaterThan: _$MoviePerFieldToJson.likes(isGreaterThan),
        isGreaterThanOrEqualTo:
            _$MoviePerFieldToJson.likes(isGreaterThanOrEqualTo),
        isNull: isNull,
        whereIn: whereIn?.map((e) => _$MoviePerFieldToJson.likes(e)).toList(),
        whereNotIn:
            whereNotIn?.map((e) => _$MoviePerFieldToJson.likes(e)).toList(),
      ),
      $queryCursor: $queryCursor,
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
      _collection,
      $referenceWithoutCursor: $referenceWithoutCursor.where(
        _$MovieFieldMap['title']!,
        isEqualTo: _$MoviePerFieldToJson.title(isEqualTo),
        isNotEqualTo: _$MoviePerFieldToJson.title(isNotEqualTo),
        isLessThan: _$MoviePerFieldToJson.title(isLessThan),
        isLessThanOrEqualTo: _$MoviePerFieldToJson.title(isLessThanOrEqualTo),
        isGreaterThan: _$MoviePerFieldToJson.title(isGreaterThan),
        isGreaterThanOrEqualTo:
            _$MoviePerFieldToJson.title(isGreaterThanOrEqualTo),
        isNull: isNull,
        whereIn: whereIn?.map((e) => _$MoviePerFieldToJson.title(e)).toList(),
        whereNotIn:
            whereNotIn?.map((e) => _$MoviePerFieldToJson.title(e)).toList(),
      ),
      $queryCursor: $queryCursor,
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
      _collection,
      $referenceWithoutCursor: $referenceWithoutCursor.where(
        _$MovieFieldMap['year']!,
        isEqualTo: _$MoviePerFieldToJson.year(isEqualTo),
        isNotEqualTo: _$MoviePerFieldToJson.year(isNotEqualTo),
        isLessThan: _$MoviePerFieldToJson.year(isLessThan),
        isLessThanOrEqualTo: _$MoviePerFieldToJson.year(isLessThanOrEqualTo),
        isGreaterThan: _$MoviePerFieldToJson.year(isGreaterThan),
        isGreaterThanOrEqualTo:
            _$MoviePerFieldToJson.year(isGreaterThanOrEqualTo),
        isNull: isNull,
        whereIn: whereIn?.map((e) => _$MoviePerFieldToJson.year(e)).toList(),
        whereNotIn:
            whereNotIn?.map((e) => _$MoviePerFieldToJson.year(e)).toList(),
      ),
      $queryCursor: $queryCursor,
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
      _collection,
      $referenceWithoutCursor: $referenceWithoutCursor.where(
        _$MovieFieldMap['runtime']!,
        isEqualTo: _$MoviePerFieldToJson.runtime(isEqualTo),
        isNotEqualTo: _$MoviePerFieldToJson.runtime(isNotEqualTo),
        isLessThan: _$MoviePerFieldToJson.runtime(isLessThan),
        isLessThanOrEqualTo: _$MoviePerFieldToJson.runtime(isLessThanOrEqualTo),
        isGreaterThan: _$MoviePerFieldToJson.runtime(isGreaterThan),
        isGreaterThanOrEqualTo:
            _$MoviePerFieldToJson.runtime(isGreaterThanOrEqualTo),
        isNull: isNull,
        whereIn: whereIn?.map((e) => _$MoviePerFieldToJson.runtime(e)).toList(),
        whereNotIn:
            whereNotIn?.map((e) => _$MoviePerFieldToJson.runtime(e)).toList(),
      ),
      $queryCursor: $queryCursor,
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
      _collection,
      $referenceWithoutCursor: $referenceWithoutCursor.where(
        _$MovieFieldMap['rated']!,
        isEqualTo: _$MoviePerFieldToJson.rated(isEqualTo),
        isNotEqualTo: _$MoviePerFieldToJson.rated(isNotEqualTo),
        isLessThan: _$MoviePerFieldToJson.rated(isLessThan),
        isLessThanOrEqualTo: _$MoviePerFieldToJson.rated(isLessThanOrEqualTo),
        isGreaterThan: _$MoviePerFieldToJson.rated(isGreaterThan),
        isGreaterThanOrEqualTo:
            _$MoviePerFieldToJson.rated(isGreaterThanOrEqualTo),
        isNull: isNull,
        whereIn: whereIn?.map((e) => _$MoviePerFieldToJson.rated(e)).toList(),
        whereNotIn:
            whereNotIn?.map((e) => _$MoviePerFieldToJson.rated(e)).toList(),
      ),
      $queryCursor: $queryCursor,
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
    String? arrayContains,
    List<String>? arrayContainsAny,
  }) {
    return _$MovieQuery(
      _collection,
      $referenceWithoutCursor: $referenceWithoutCursor.where(
        _$MovieFieldMap['genre']!,
        isEqualTo: _$MoviePerFieldToJson.genre(isEqualTo),
        isNotEqualTo: _$MoviePerFieldToJson.genre(isNotEqualTo),
        isLessThan: _$MoviePerFieldToJson.genre(isLessThan),
        isLessThanOrEqualTo: _$MoviePerFieldToJson.genre(isLessThanOrEqualTo),
        isGreaterThan: _$MoviePerFieldToJson.genre(isGreaterThan),
        isGreaterThanOrEqualTo:
            _$MoviePerFieldToJson.genre(isGreaterThanOrEqualTo),
        isNull: isNull,
        arrayContains: arrayContains,
        arrayContainsAny: _$MoviePerFieldToJson.genre(arrayContainsAny),
      ),
      $queryCursor: $queryCursor,
    );
  }

  MovieQuery whereLanguage({
    List<LanguageType>? isEqualTo,
    List<LanguageType>? isNotEqualTo,
    List<LanguageType>? isLessThan,
    List<LanguageType>? isLessThanOrEqualTo,
    List<LanguageType>? isGreaterThan,
    List<LanguageType>? isGreaterThanOrEqualTo,
    bool? isNull,
    LanguageType? arrayContains,
    List<LanguageType>? arrayContainsAny,
  }) {
    return _$MovieQuery(
      _collection,
      $referenceWithoutCursor: $referenceWithoutCursor.where(
        _$MovieFieldMap['language']!,
        isEqualTo: _$MoviePerFieldToJson.language(isEqualTo),
        isNotEqualTo: _$MoviePerFieldToJson.language(isNotEqualTo),
        isLessThan: _$MoviePerFieldToJson.language(isLessThan),
        isLessThanOrEqualTo:
            _$MoviePerFieldToJson.language(isLessThanOrEqualTo),
        isGreaterThan: _$MoviePerFieldToJson.language(isGreaterThan),
        isGreaterThanOrEqualTo:
            _$MoviePerFieldToJson.language(isGreaterThanOrEqualTo),
        isNull: isNull,
        arrayContains: arrayContains,
        arrayContainsAny: _$MoviePerFieldToJson.language(arrayContainsAny),
      ),
      $queryCursor: $queryCursor,
    );
  }

  MovieQuery whereCertification({
    CertificationType? isEqualTo,
    CertificationType? isNotEqualTo,
    CertificationType? isLessThan,
    CertificationType? isLessThanOrEqualTo,
    CertificationType? isGreaterThan,
    CertificationType? isGreaterThanOrEqualTo,
    bool? isNull,
    List<CertificationType>? whereIn,
    List<CertificationType>? whereNotIn,
  }) {
    return _$MovieQuery(
      _collection,
      $referenceWithoutCursor: $referenceWithoutCursor.where(
        _$MovieFieldMap['certification']!,
        isEqualTo: _$MoviePerFieldToJson.certification(isEqualTo),
        isNotEqualTo: _$MoviePerFieldToJson.certification(isNotEqualTo),
        isLessThan: _$MoviePerFieldToJson.certification(isLessThan),
        isLessThanOrEqualTo:
            _$MoviePerFieldToJson.certification(isLessThanOrEqualTo),
        isGreaterThan: _$MoviePerFieldToJson.certification(isGreaterThan),
        isGreaterThanOrEqualTo:
            _$MoviePerFieldToJson.certification(isGreaterThanOrEqualTo),
        isNull: isNull,
        whereIn: whereIn
            ?.map((e) => _$MoviePerFieldToJson.certification(e))
            .toList(),
        whereNotIn: whereNotIn
            ?.map((e) => _$MoviePerFieldToJson.certification(e))
            .toList(),
      ),
      $queryCursor: $queryCursor,
    );
  }

  MovieQuery whereCast({
    List<Map<CastType, String>>? isEqualTo,
    List<Map<CastType, String>>? isNotEqualTo,
    List<Map<CastType, String>>? isLessThan,
    List<Map<CastType, String>>? isLessThanOrEqualTo,
    List<Map<CastType, String>>? isGreaterThan,
    List<Map<CastType, String>>? isGreaterThanOrEqualTo,
    bool? isNull,
    Map<CastType, String>? arrayContains,
    List<Map<CastType, String>>? arrayContainsAny,
  }) {
    return _$MovieQuery(
      _collection,
      $referenceWithoutCursor: $referenceWithoutCursor.where(
        _$MovieFieldMap['cast']!,
        isEqualTo: _$MoviePerFieldToJson.cast(isEqualTo),
        isNotEqualTo: _$MoviePerFieldToJson.cast(isNotEqualTo),
        isLessThan: _$MoviePerFieldToJson.cast(isLessThan),
        isLessThanOrEqualTo: _$MoviePerFieldToJson.cast(isLessThanOrEqualTo),
        isGreaterThan: _$MoviePerFieldToJson.cast(isGreaterThan),
        isGreaterThanOrEqualTo:
            _$MoviePerFieldToJson.cast(isGreaterThanOrEqualTo),
        isNull: isNull,
        arrayContains: arrayContains,
        arrayContainsAny: _$MoviePerFieldToJson.cast(arrayContainsAny),
      ),
      $queryCursor: $queryCursor,
    );
  }

  MovieQuery whereMajorCast({
    Map<CastType, String>? isEqualTo,
    Map<CastType, String>? isNotEqualTo,
    Map<CastType, String>? isLessThan,
    Map<CastType, String>? isLessThanOrEqualTo,
    Map<CastType, String>? isGreaterThan,
    Map<CastType, String>? isGreaterThanOrEqualTo,
    bool? isNull,
    List<Map<CastType, String>>? whereIn,
    List<Map<CastType, String>>? whereNotIn,
  }) {
    return _$MovieQuery(
      _collection,
      $referenceWithoutCursor: $referenceWithoutCursor.where(
        _$MovieFieldMap['majorCast']!,
        isEqualTo: _$MoviePerFieldToJson.majorCast(isEqualTo),
        isNotEqualTo: _$MoviePerFieldToJson.majorCast(isNotEqualTo),
        isLessThan: _$MoviePerFieldToJson.majorCast(isLessThan),
        isLessThanOrEqualTo:
            _$MoviePerFieldToJson.majorCast(isLessThanOrEqualTo),
        isGreaterThan: _$MoviePerFieldToJson.majorCast(isGreaterThan),
        isGreaterThanOrEqualTo:
            _$MoviePerFieldToJson.majorCast(isGreaterThanOrEqualTo),
        isNull: isNull,
        whereIn:
            whereIn?.map((e) => _$MoviePerFieldToJson.majorCast(e)).toList(),
        whereNotIn:
            whereNotIn?.map((e) => _$MoviePerFieldToJson.majorCast(e)).toList(),
      ),
      $queryCursor: $queryCursor,
    );
  }

  MovieQuery orderByDocumentId({
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

    return _$MovieQuery(
      _collection,
      $referenceWithoutCursor: query,
      $queryCursor: queryCursor,
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
    final query = $referenceWithoutCursor.orderBy(_$MovieFieldMap['poster']!,
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
        startAt: [
          ...queryCursor.startAt,
          _$MoviePerFieldToJson.poster(startAt as String)
        ],
        startAtDocumentSnapshot: null,
      );
    }
    if (startAfter != _sentinel) {
      queryCursor = queryCursor.copyWith(
        startAfter: [
          ...queryCursor.startAfter,
          _$MoviePerFieldToJson.poster(startAfter as String)
        ],
        startAfterDocumentSnapshot: null,
      );
    }
    if (endAt != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endAt: [
          ...queryCursor.endAt,
          _$MoviePerFieldToJson.poster(endAt as String)
        ],
        endAtDocumentSnapshot: null,
      );
    }
    if (endBefore != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endBefore: [
          ...queryCursor.endBefore,
          _$MoviePerFieldToJson.poster(endBefore as String)
        ],
        endBeforeDocumentSnapshot: null,
      );
    }

    return _$MovieQuery(
      _collection,
      $referenceWithoutCursor: query,
      $queryCursor: queryCursor,
    );
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
    final query = $referenceWithoutCursor.orderBy(_$MovieFieldMap['likes']!,
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
        startAt: [
          ...queryCursor.startAt,
          _$MoviePerFieldToJson.likes(startAt as int)
        ],
        startAtDocumentSnapshot: null,
      );
    }
    if (startAfter != _sentinel) {
      queryCursor = queryCursor.copyWith(
        startAfter: [
          ...queryCursor.startAfter,
          _$MoviePerFieldToJson.likes(startAfter as int)
        ],
        startAfterDocumentSnapshot: null,
      );
    }
    if (endAt != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endAt: [
          ...queryCursor.endAt,
          _$MoviePerFieldToJson.likes(endAt as int)
        ],
        endAtDocumentSnapshot: null,
      );
    }
    if (endBefore != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endBefore: [
          ...queryCursor.endBefore,
          _$MoviePerFieldToJson.likes(endBefore as int)
        ],
        endBeforeDocumentSnapshot: null,
      );
    }

    return _$MovieQuery(
      _collection,
      $referenceWithoutCursor: query,
      $queryCursor: queryCursor,
    );
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
    final query = $referenceWithoutCursor.orderBy(_$MovieFieldMap['title']!,
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
        startAt: [
          ...queryCursor.startAt,
          _$MoviePerFieldToJson.title(startAt as String)
        ],
        startAtDocumentSnapshot: null,
      );
    }
    if (startAfter != _sentinel) {
      queryCursor = queryCursor.copyWith(
        startAfter: [
          ...queryCursor.startAfter,
          _$MoviePerFieldToJson.title(startAfter as String)
        ],
        startAfterDocumentSnapshot: null,
      );
    }
    if (endAt != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endAt: [
          ...queryCursor.endAt,
          _$MoviePerFieldToJson.title(endAt as String)
        ],
        endAtDocumentSnapshot: null,
      );
    }
    if (endBefore != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endBefore: [
          ...queryCursor.endBefore,
          _$MoviePerFieldToJson.title(endBefore as String)
        ],
        endBeforeDocumentSnapshot: null,
      );
    }

    return _$MovieQuery(
      _collection,
      $referenceWithoutCursor: query,
      $queryCursor: queryCursor,
    );
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
    final query = $referenceWithoutCursor.orderBy(_$MovieFieldMap['year']!,
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
        startAt: [
          ...queryCursor.startAt,
          _$MoviePerFieldToJson.year(startAt as int)
        ],
        startAtDocumentSnapshot: null,
      );
    }
    if (startAfter != _sentinel) {
      queryCursor = queryCursor.copyWith(
        startAfter: [
          ...queryCursor.startAfter,
          _$MoviePerFieldToJson.year(startAfter as int)
        ],
        startAfterDocumentSnapshot: null,
      );
    }
    if (endAt != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endAt: [...queryCursor.endAt, _$MoviePerFieldToJson.year(endAt as int)],
        endAtDocumentSnapshot: null,
      );
    }
    if (endBefore != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endBefore: [
          ...queryCursor.endBefore,
          _$MoviePerFieldToJson.year(endBefore as int)
        ],
        endBeforeDocumentSnapshot: null,
      );
    }

    return _$MovieQuery(
      _collection,
      $referenceWithoutCursor: query,
      $queryCursor: queryCursor,
    );
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
    final query = $referenceWithoutCursor.orderBy(_$MovieFieldMap['runtime']!,
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
        startAt: [
          ...queryCursor.startAt,
          _$MoviePerFieldToJson.runtime(startAt as String)
        ],
        startAtDocumentSnapshot: null,
      );
    }
    if (startAfter != _sentinel) {
      queryCursor = queryCursor.copyWith(
        startAfter: [
          ...queryCursor.startAfter,
          _$MoviePerFieldToJson.runtime(startAfter as String)
        ],
        startAfterDocumentSnapshot: null,
      );
    }
    if (endAt != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endAt: [
          ...queryCursor.endAt,
          _$MoviePerFieldToJson.runtime(endAt as String)
        ],
        endAtDocumentSnapshot: null,
      );
    }
    if (endBefore != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endBefore: [
          ...queryCursor.endBefore,
          _$MoviePerFieldToJson.runtime(endBefore as String)
        ],
        endBeforeDocumentSnapshot: null,
      );
    }

    return _$MovieQuery(
      _collection,
      $referenceWithoutCursor: query,
      $queryCursor: queryCursor,
    );
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
    final query = $referenceWithoutCursor.orderBy(_$MovieFieldMap['rated']!,
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
        startAt: [
          ...queryCursor.startAt,
          _$MoviePerFieldToJson.rated(startAt as String)
        ],
        startAtDocumentSnapshot: null,
      );
    }
    if (startAfter != _sentinel) {
      queryCursor = queryCursor.copyWith(
        startAfter: [
          ...queryCursor.startAfter,
          _$MoviePerFieldToJson.rated(startAfter as String)
        ],
        startAfterDocumentSnapshot: null,
      );
    }
    if (endAt != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endAt: [
          ...queryCursor.endAt,
          _$MoviePerFieldToJson.rated(endAt as String)
        ],
        endAtDocumentSnapshot: null,
      );
    }
    if (endBefore != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endBefore: [
          ...queryCursor.endBefore,
          _$MoviePerFieldToJson.rated(endBefore as String)
        ],
        endBeforeDocumentSnapshot: null,
      );
    }

    return _$MovieQuery(
      _collection,
      $referenceWithoutCursor: query,
      $queryCursor: queryCursor,
    );
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
    final query = $referenceWithoutCursor.orderBy(_$MovieFieldMap['genre']!,
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
        startAt: [
          ...queryCursor.startAt,
          _$MoviePerFieldToJson.genre(startAt as List<String>?)
        ],
        startAtDocumentSnapshot: null,
      );
    }
    if (startAfter != _sentinel) {
      queryCursor = queryCursor.copyWith(
        startAfter: [
          ...queryCursor.startAfter,
          _$MoviePerFieldToJson.genre(startAfter as List<String>?)
        ],
        startAfterDocumentSnapshot: null,
      );
    }
    if (endAt != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endAt: [
          ...queryCursor.endAt,
          _$MoviePerFieldToJson.genre(endAt as List<String>?)
        ],
        endAtDocumentSnapshot: null,
      );
    }
    if (endBefore != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endBefore: [
          ...queryCursor.endBefore,
          _$MoviePerFieldToJson.genre(endBefore as List<String>?)
        ],
        endBeforeDocumentSnapshot: null,
      );
    }

    return _$MovieQuery(
      _collection,
      $referenceWithoutCursor: query,
      $queryCursor: queryCursor,
    );
  }

  MovieQuery orderByLanguage({
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
    final query = $referenceWithoutCursor.orderBy(_$MovieFieldMap['language']!,
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
        startAt: [
          ...queryCursor.startAt,
          _$MoviePerFieldToJson.language(startAt as List<LanguageType>?)
        ],
        startAtDocumentSnapshot: null,
      );
    }
    if (startAfter != _sentinel) {
      queryCursor = queryCursor.copyWith(
        startAfter: [
          ...queryCursor.startAfter,
          _$MoviePerFieldToJson.language(startAfter as List<LanguageType>?)
        ],
        startAfterDocumentSnapshot: null,
      );
    }
    if (endAt != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endAt: [
          ...queryCursor.endAt,
          _$MoviePerFieldToJson.language(endAt as List<LanguageType>?)
        ],
        endAtDocumentSnapshot: null,
      );
    }
    if (endBefore != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endBefore: [
          ...queryCursor.endBefore,
          _$MoviePerFieldToJson.language(endBefore as List<LanguageType>?)
        ],
        endBeforeDocumentSnapshot: null,
      );
    }

    return _$MovieQuery(
      _collection,
      $referenceWithoutCursor: query,
      $queryCursor: queryCursor,
    );
  }

  MovieQuery orderByCertification({
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
    final query = $referenceWithoutCursor
        .orderBy(_$MovieFieldMap['certification']!, descending: descending);
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
        startAt: [
          ...queryCursor.startAt,
          _$MoviePerFieldToJson.certification(startAt as CertificationType)
        ],
        startAtDocumentSnapshot: null,
      );
    }
    if (startAfter != _sentinel) {
      queryCursor = queryCursor.copyWith(
        startAfter: [
          ...queryCursor.startAfter,
          _$MoviePerFieldToJson.certification(startAfter as CertificationType)
        ],
        startAfterDocumentSnapshot: null,
      );
    }
    if (endAt != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endAt: [
          ...queryCursor.endAt,
          _$MoviePerFieldToJson.certification(endAt as CertificationType)
        ],
        endAtDocumentSnapshot: null,
      );
    }
    if (endBefore != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endBefore: [
          ...queryCursor.endBefore,
          _$MoviePerFieldToJson.certification(endBefore as CertificationType)
        ],
        endBeforeDocumentSnapshot: null,
      );
    }

    return _$MovieQuery(
      _collection,
      $referenceWithoutCursor: query,
      $queryCursor: queryCursor,
    );
  }

  MovieQuery orderByCast({
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
    final query = $referenceWithoutCursor.orderBy(_$MovieFieldMap['cast']!,
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
        startAt: [
          ...queryCursor.startAt,
          _$MoviePerFieldToJson.cast(startAt as List<Map<CastType, String>>)
        ],
        startAtDocumentSnapshot: null,
      );
    }
    if (startAfter != _sentinel) {
      queryCursor = queryCursor.copyWith(
        startAfter: [
          ...queryCursor.startAfter,
          _$MoviePerFieldToJson.cast(startAfter as List<Map<CastType, String>>)
        ],
        startAfterDocumentSnapshot: null,
      );
    }
    if (endAt != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endAt: [
          ...queryCursor.endAt,
          _$MoviePerFieldToJson.cast(endAt as List<Map<CastType, String>>)
        ],
        endAtDocumentSnapshot: null,
      );
    }
    if (endBefore != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endBefore: [
          ...queryCursor.endBefore,
          _$MoviePerFieldToJson.cast(endBefore as List<Map<CastType, String>>)
        ],
        endBeforeDocumentSnapshot: null,
      );
    }

    return _$MovieQuery(
      _collection,
      $referenceWithoutCursor: query,
      $queryCursor: queryCursor,
    );
  }

  MovieQuery orderByMajorCast({
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
    final query = $referenceWithoutCursor.orderBy(_$MovieFieldMap['majorCast']!,
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
        startAt: [
          ...queryCursor.startAt,
          _$MoviePerFieldToJson.majorCast(startAt as Map<CastType, String>)
        ],
        startAtDocumentSnapshot: null,
      );
    }
    if (startAfter != _sentinel) {
      queryCursor = queryCursor.copyWith(
        startAfter: [
          ...queryCursor.startAfter,
          _$MoviePerFieldToJson.majorCast(startAfter as Map<CastType, String>)
        ],
        startAfterDocumentSnapshot: null,
      );
    }
    if (endAt != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endAt: [
          ...queryCursor.endAt,
          _$MoviePerFieldToJson.majorCast(endAt as Map<CastType, String>)
        ],
        endAtDocumentSnapshot: null,
      );
    }
    if (endBefore != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endBefore: [
          ...queryCursor.endBefore,
          _$MoviePerFieldToJson.majorCast(endBefore as Map<CastType, String>)
        ],
        endBeforeDocumentSnapshot: null,
      );
    }

    return _$MovieQuery(
      _collection,
      $referenceWithoutCursor: query,
      $queryCursor: queryCursor,
    );
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

class MovieDocumentSnapshot extends FirestoreDocumentSnapshot<Movie> {
  MovieDocumentSnapshot._(this.snapshot) : data = snapshot.data();

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

class MovieQuerySnapshot
    extends FirestoreQuerySnapshot<Movie, MovieQueryDocumentSnapshot> {
  MovieQuerySnapshot._(
    this.snapshot,
    this.docs,
    this.docChanges,
  );

  factory MovieQuerySnapshot._fromQuerySnapshot(
    QuerySnapshot<Movie> snapshot,
  ) {
    final docs = snapshot.docs.map(MovieQueryDocumentSnapshot._).toList();

    final docChanges = snapshot.docChanges.map((change) {
      return _decodeDocumentChange(
        change,
        MovieDocumentSnapshot._,
      );
    }).toList();

    return MovieQuerySnapshot._(
      snapshot,
      docs,
      docChanges,
    );
  }

  static FirestoreDocumentChange<MovieDocumentSnapshot>
      _decodeDocumentChange<T>(
    DocumentChange<T> docChange,
    MovieDocumentSnapshot Function(DocumentSnapshot<T> doc) decodeDoc,
  ) {
    return FirestoreDocumentChange<MovieDocumentSnapshot>(
      type: docChange.type,
      oldIndex: docChange.oldIndex,
      newIndex: docChange.newIndex,
      doc: decodeDoc(docChange.doc),
    );
  }

  final QuerySnapshot<Movie> snapshot;

  @override
  final List<MovieQueryDocumentSnapshot> docs;

  @override
  final List<FirestoreDocumentChange<MovieDocumentSnapshot>> docChanges;
}

class MovieQueryDocumentSnapshot extends FirestoreQueryDocumentSnapshot<Movie>
    implements MovieDocumentSnapshot {
  MovieQueryDocumentSnapshot._(this.snapshot) : data = snapshot.data();

  @override
  final QueryDocumentSnapshot<Movie> snapshot;

  @override
  final Movie data;

  @override
  MovieDocumentReference get reference {
    return MovieDocumentReference(snapshot.reference);
  }
}

/// A collection reference object can be used for adding documents,
/// getting document references, and querying for documents
/// (using the methods inherited from Query).
abstract class CommentCollectionReference
    implements
        CommentQuery,
        FirestoreCollectionReference<Comment, CommentQuerySnapshot> {
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

  @override
  CollectionReference<Comment> get reference;

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
  ) : super(reference, $referenceWithoutCursor: reference);

  @override
  final MovieDocumentReference parent;

  String get path => reference.path;

  @override
  CollectionReference<Comment> get reference =>
      super.reference as CollectionReference<Comment>;

  @override
  CommentDocumentReference doc([String? id]) {
    assert(
      id == null || id.split('/').length == 1,
      'The document ID cannot be from a different collection',
    );
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
    extends FirestoreDocumentReference<Comment, CommentDocumentSnapshot> {
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

  /// Updates data on the document. Data will be merged with any existing
  /// document data.
  ///
  /// If no document exists yet, the update will fail.
  Future<void> update({
    String authorName,
    FieldValue authorNameFieldValue,
    String message,
    FieldValue messageFieldValue,
  });

  /// Updates fields in the current document using the transaction API.
  ///
  /// The update will fail if applied to a document that does not exist.
  void transactionUpdate(
    Transaction transaction, {
    String authorName,
    FieldValue authorNameFieldValue,
    String message,
    FieldValue messageFieldValue,
  });
}

class _$CommentDocumentReference
    extends FirestoreDocumentReference<Comment, CommentDocumentSnapshot>
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
    return reference.snapshots().map(CommentDocumentSnapshot._);
  }

  @override
  Future<CommentDocumentSnapshot> get([GetOptions? options]) {
    return reference.get(options).then(CommentDocumentSnapshot._);
  }

  @override
  Future<CommentDocumentSnapshot> transactionGet(Transaction transaction) {
    return transaction.get(reference).then(CommentDocumentSnapshot._);
  }

  Future<void> update({
    Object? authorName = _sentinel,
    FieldValue? authorNameFieldValue,
    Object? message = _sentinel,
    FieldValue? messageFieldValue,
  }) async {
    assert(
      authorName == _sentinel || authorNameFieldValue == null,
      "Cannot specify both authorName and authorNameFieldValue",
    );
    assert(
      message == _sentinel || messageFieldValue == null,
      "Cannot specify both message and messageFieldValue",
    );
    final json = {
      if (authorName != _sentinel)
        _$CommentFieldMap['authorName']!:
            _$CommentPerFieldToJson.authorName(authorName as String),
      if (authorNameFieldValue != null)
        _$CommentFieldMap['authorName']!: authorNameFieldValue,
      if (message != _sentinel)
        _$CommentFieldMap['message']!:
            _$CommentPerFieldToJson.message(message as String),
      if (messageFieldValue != null)
        _$CommentFieldMap['message']!: messageFieldValue,
    };

    return reference.update(json);
  }

  void transactionUpdate(
    Transaction transaction, {
    Object? authorName = _sentinel,
    FieldValue? authorNameFieldValue,
    Object? message = _sentinel,
    FieldValue? messageFieldValue,
  }) {
    assert(
      authorName == _sentinel || authorNameFieldValue == null,
      "Cannot specify both authorName and authorNameFieldValue",
    );
    assert(
      message == _sentinel || messageFieldValue == null,
      "Cannot specify both message and messageFieldValue",
    );
    final json = {
      if (authorName != _sentinel)
        _$CommentFieldMap['authorName']!:
            _$CommentPerFieldToJson.authorName(authorName as String),
      if (authorNameFieldValue != null)
        _$CommentFieldMap['authorName']!: authorNameFieldValue,
      if (message != _sentinel)
        _$CommentFieldMap['message']!:
            _$CommentPerFieldToJson.message(message as String),
      if (messageFieldValue != null)
        _$CommentFieldMap['message']!: messageFieldValue,
    };

    transaction.update(reference, json);
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

abstract class CommentQuery
    implements QueryReference<Comment, CommentQuerySnapshot> {
  @override
  CommentQuery limit(int limit);

  @override
  CommentQuery limitToLast(int limit);

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
  CommentQuery orderByFieldPath(
    FieldPath fieldPath, {
    bool descending = false,
    Object? startAt,
    Object? startAfter,
    Object? endAt,
    Object? endBefore,
    CommentDocumentSnapshot? startAtDocument,
    CommentDocumentSnapshot? endAtDocument,
    CommentDocumentSnapshot? endBeforeDocument,
    CommentDocumentSnapshot? startAfterDocument,
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
  CommentQuery whereFieldPath(
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

  CommentQuery whereDocumentId({
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

  CommentQuery orderByDocumentId({
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

class _$CommentQuery extends QueryReference<Comment, CommentQuerySnapshot>
    implements CommentQuery {
  _$CommentQuery(
    this._collection, {
    required Query<Comment> $referenceWithoutCursor,
    $QueryCursor $queryCursor = const $QueryCursor(),
  }) : super(
          $referenceWithoutCursor: $referenceWithoutCursor,
          $queryCursor: $queryCursor,
        );

  final CollectionReference<Object?> _collection;

  @override
  Stream<CommentQuerySnapshot> snapshots([SnapshotOptions? options]) {
    return reference.snapshots().map(CommentQuerySnapshot._fromQuerySnapshot);
  }

  @override
  Future<CommentQuerySnapshot> get([GetOptions? options]) {
    return reference.get(options).then(CommentQuerySnapshot._fromQuerySnapshot);
  }

  @override
  CommentQuery limit(int limit) {
    return _$CommentQuery(
      _collection,
      $referenceWithoutCursor: $referenceWithoutCursor.limit(limit),
      $queryCursor: $queryCursor,
    );
  }

  @override
  CommentQuery limitToLast(int limit) {
    return _$CommentQuery(
      _collection,
      $referenceWithoutCursor: $referenceWithoutCursor.limitToLast(limit),
      $queryCursor: $queryCursor,
    );
  }

  CommentQuery orderByFieldPath(
    FieldPath fieldPath, {
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
    return _$CommentQuery(
      _collection,
      $referenceWithoutCursor: query,
      $queryCursor: queryCursor,
    );
  }

  CommentQuery whereFieldPath(
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
    return _$CommentQuery(
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

  CommentQuery whereDocumentId({
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
      _collection,
      $referenceWithoutCursor: $referenceWithoutCursor.where(
        _$CommentFieldMap['authorName']!,
        isEqualTo: _$CommentPerFieldToJson.authorName(isEqualTo),
        isNotEqualTo: _$CommentPerFieldToJson.authorName(isNotEqualTo),
        isLessThan: _$CommentPerFieldToJson.authorName(isLessThan),
        isLessThanOrEqualTo:
            _$CommentPerFieldToJson.authorName(isLessThanOrEqualTo),
        isGreaterThan: _$CommentPerFieldToJson.authorName(isGreaterThan),
        isGreaterThanOrEqualTo:
            _$CommentPerFieldToJson.authorName(isGreaterThanOrEqualTo),
        isNull: isNull,
        whereIn:
            whereIn?.map((e) => _$CommentPerFieldToJson.authorName(e)).toList(),
        whereNotIn: whereNotIn
            ?.map((e) => _$CommentPerFieldToJson.authorName(e))
            .toList(),
      ),
      $queryCursor: $queryCursor,
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
      _collection,
      $referenceWithoutCursor: $referenceWithoutCursor.where(
        _$CommentFieldMap['message']!,
        isEqualTo: _$CommentPerFieldToJson.message(isEqualTo),
        isNotEqualTo: _$CommentPerFieldToJson.message(isNotEqualTo),
        isLessThan: _$CommentPerFieldToJson.message(isLessThan),
        isLessThanOrEqualTo:
            _$CommentPerFieldToJson.message(isLessThanOrEqualTo),
        isGreaterThan: _$CommentPerFieldToJson.message(isGreaterThan),
        isGreaterThanOrEqualTo:
            _$CommentPerFieldToJson.message(isGreaterThanOrEqualTo),
        isNull: isNull,
        whereIn:
            whereIn?.map((e) => _$CommentPerFieldToJson.message(e)).toList(),
        whereNotIn:
            whereNotIn?.map((e) => _$CommentPerFieldToJson.message(e)).toList(),
      ),
      $queryCursor: $queryCursor,
    );
  }

  CommentQuery orderByDocumentId({
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

    return _$CommentQuery(
      _collection,
      $referenceWithoutCursor: query,
      $queryCursor: queryCursor,
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
    final query = $referenceWithoutCursor
        .orderBy(_$CommentFieldMap['authorName']!, descending: descending);
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
        startAt: [
          ...queryCursor.startAt,
          _$CommentPerFieldToJson.authorName(startAt as String)
        ],
        startAtDocumentSnapshot: null,
      );
    }
    if (startAfter != _sentinel) {
      queryCursor = queryCursor.copyWith(
        startAfter: [
          ...queryCursor.startAfter,
          _$CommentPerFieldToJson.authorName(startAfter as String)
        ],
        startAfterDocumentSnapshot: null,
      );
    }
    if (endAt != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endAt: [
          ...queryCursor.endAt,
          _$CommentPerFieldToJson.authorName(endAt as String)
        ],
        endAtDocumentSnapshot: null,
      );
    }
    if (endBefore != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endBefore: [
          ...queryCursor.endBefore,
          _$CommentPerFieldToJson.authorName(endBefore as String)
        ],
        endBeforeDocumentSnapshot: null,
      );
    }

    return _$CommentQuery(
      _collection,
      $referenceWithoutCursor: query,
      $queryCursor: queryCursor,
    );
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
    final query = $referenceWithoutCursor.orderBy(_$CommentFieldMap['message']!,
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
        startAt: [
          ...queryCursor.startAt,
          _$CommentPerFieldToJson.message(startAt as String)
        ],
        startAtDocumentSnapshot: null,
      );
    }
    if (startAfter != _sentinel) {
      queryCursor = queryCursor.copyWith(
        startAfter: [
          ...queryCursor.startAfter,
          _$CommentPerFieldToJson.message(startAfter as String)
        ],
        startAfterDocumentSnapshot: null,
      );
    }
    if (endAt != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endAt: [
          ...queryCursor.endAt,
          _$CommentPerFieldToJson.message(endAt as String)
        ],
        endAtDocumentSnapshot: null,
      );
    }
    if (endBefore != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endBefore: [
          ...queryCursor.endBefore,
          _$CommentPerFieldToJson.message(endBefore as String)
        ],
        endBeforeDocumentSnapshot: null,
      );
    }

    return _$CommentQuery(
      _collection,
      $referenceWithoutCursor: query,
      $queryCursor: queryCursor,
    );
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

class CommentDocumentSnapshot extends FirestoreDocumentSnapshot<Comment> {
  CommentDocumentSnapshot._(this.snapshot) : data = snapshot.data();

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

class CommentQuerySnapshot
    extends FirestoreQuerySnapshot<Comment, CommentQueryDocumentSnapshot> {
  CommentQuerySnapshot._(
    this.snapshot,
    this.docs,
    this.docChanges,
  );

  factory CommentQuerySnapshot._fromQuerySnapshot(
    QuerySnapshot<Comment> snapshot,
  ) {
    final docs = snapshot.docs.map(CommentQueryDocumentSnapshot._).toList();

    final docChanges = snapshot.docChanges.map((change) {
      return _decodeDocumentChange(
        change,
        CommentDocumentSnapshot._,
      );
    }).toList();

    return CommentQuerySnapshot._(
      snapshot,
      docs,
      docChanges,
    );
  }

  static FirestoreDocumentChange<CommentDocumentSnapshot>
      _decodeDocumentChange<T>(
    DocumentChange<T> docChange,
    CommentDocumentSnapshot Function(DocumentSnapshot<T> doc) decodeDoc,
  ) {
    return FirestoreDocumentChange<CommentDocumentSnapshot>(
      type: docChange.type,
      oldIndex: docChange.oldIndex,
      newIndex: docChange.newIndex,
      doc: decodeDoc(docChange.doc),
    );
  }

  final QuerySnapshot<Comment> snapshot;

  @override
  final List<CommentQueryDocumentSnapshot> docs;

  @override
  final List<FirestoreDocumentChange<CommentDocumentSnapshot>> docChanges;
}

class CommentQueryDocumentSnapshot
    extends FirestoreQueryDocumentSnapshot<Comment>
    implements CommentDocumentSnapshot {
  CommentQueryDocumentSnapshot._(this.snapshot) : data = snapshot.data();

  @override
  final QueryDocumentSnapshot<Comment> snapshot;

  @override
  final Comment data;

  @override
  CommentDocumentReference get reference {
    return CommentDocumentReference(snapshot.reference);
  }
}

// **************************************************************************
// ValidatorGenerator
// **************************************************************************

void _$assertMovie(Movie instance) {
  const Min(0).validate(instance.likes, 'likes');
  const Min(0).validate(instance.year, 'year');
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
      id: json['id'] as String,
      language: (json['language'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$LanguageTypeEnumMap, e))
          .toList(),
      certification:
          $enumDecode(_$CertificationTypeEnumMap, json['certification']),
      cast: (json['cast'] as List<dynamic>)
          .map((e) => (e as Map<String, dynamic>).map(
                (k, e) =>
                    MapEntry($enumDecode(_$CastTypeEnumMap, k), e as String),
              ))
          .toList(),
      majorCast: (json['majorCast'] as Map<String, dynamic>).map(
        (k, e) => MapEntry($enumDecode(_$CastTypeEnumMap, k), e as String),
      ),
    );

const _$MovieFieldMap = <String, String>{
  'id': 'id',
  'poster': 'poster',
  'likes': 'likes',
  'title': 'title',
  'year': 'year',
  'runtime': 'runtime',
  'rated': 'rated',
  'genre': 'genre',
  'language': 'language',
  'certification': 'certification',
  'cast': 'cast',
  'majorCast': 'majorCast',
};

// ignore: unused_element
abstract class _$MoviePerFieldToJson {
  // ignore: unused_element
  static Object? id(String instance) => instance;
  // ignore: unused_element
  static Object? poster(String instance) => instance;
  // ignore: unused_element
  static Object? likes(int instance) => instance;
  // ignore: unused_element
  static Object? title(String instance) => instance;
  // ignore: unused_element
  static Object? year(int instance) => instance;
  // ignore: unused_element
  static Object? runtime(String instance) => instance;
  // ignore: unused_element
  static Object? rated(String instance) => instance;
  // ignore: unused_element
  static Object? genre(List<String>? instance) => instance;
  // ignore: unused_element
  static Object? language(List<LanguageType>? instance) =>
      instance?.map((e) => _$LanguageTypeEnumMap[e]!).toList();
  // ignore: unused_element
  static Object? certification(CertificationType instance) =>
      _$CertificationTypeEnumMap[instance]!;
  // ignore: unused_element
  static Object? cast(List<Map<CastType, String>> instance) => instance
      .map((e) => e.map((k, e) => MapEntry(_$CastTypeEnumMap[k]!, e)))
      .toList();
  // ignore: unused_element
  static Object? majorCast(Map<CastType, String> instance) =>
      instance.map((k, e) => MapEntry(_$CastTypeEnumMap[k]!, e));
}

Map<String, dynamic> _$MovieToJson(Movie instance) => <String, dynamic>{
      'id': instance.id,
      'poster': instance.poster,
      'likes': instance.likes,
      'title': instance.title,
      'year': instance.year,
      'runtime': instance.runtime,
      'rated': instance.rated,
      'genre': instance.genre,
      'language':
          instance.language?.map((e) => _$LanguageTypeEnumMap[e]!).toList(),
      'certification': _$CertificationTypeEnumMap[instance.certification]!,
      'cast': instance.cast
          .map((e) => e.map((k, e) => MapEntry(_$CastTypeEnumMap[k]!, e)))
          .toList(),
      'majorCast':
          instance.majorCast.map((k, e) => MapEntry(_$CastTypeEnumMap[k]!, e)),
    };

const _$LanguageTypeEnumMap = {
  LanguageType.english: 'english',
  LanguageType.french: 'french',
  LanguageType.spanish: 'spanish',
  LanguageType.chinese: 'chinese',
  LanguageType.korean: 'korean',
};

const _$CertificationTypeEnumMap = {
  CertificationType.none: 'none',
  CertificationType.g: 'g',
  CertificationType.pg: 'pg',
  CertificationType.pg13: 'pg13',
  CertificationType.R: 'R',
  CertificationType.tvpg: 'tvpg',
  CertificationType.tvma: 'tvma',
};

const _$CastTypeEnumMap = {
  CastType.background: 'background',
  CastType.cameo: 'cameo',
  CastType.recurring: 'recurring',
  CastType.side: 'side',
  CastType.star: 'star',
  CastType.coStar: 'coStar',
  CastType.guestStar: 'guestStar',
};

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      authorName: json['authorName'] as String,
      message: json['message'] as String,
    );

const _$CommentFieldMap = <String, String>{
  'authorName': 'authorName',
  'message': 'message',
};

// ignore: unused_element
abstract class _$CommentPerFieldToJson {
  // ignore: unused_element
  static Object? authorName(String instance) => instance;
  // ignore: unused_element
  static Object? message(String instance) => instance;
}

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'authorName': instance.authorName,
      'message': instance.message,
    };
