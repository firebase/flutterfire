// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A function that builds a widget from a [FirestoreQueryBuilderSnapshot]
///
/// See also [FirebaseDatabaseQueryBuilder].
typedef FirestoreQueryBuilderSnapshotBuilder<T> = Widget Function(
  BuildContext context,
  FirestoreQueryBuilderSnapshot<T> snapshot,
  Widget? child,
);

/// {@template firebase_ui.firestore_query_builder}
/// Listens to a query and paginates the result in a way that is compatible with
/// infinite scroll views, such as [ListView] or [GridView].
///
/// [FirestoreQueryBuilder] will subscribe to the query and obtain the first
/// [pageSize] items (10 by default). Then as the UI needs to render more items,
/// it is possible to call [FirestoreQueryBuilderSnapshot.fetchMore] to obtain more items.
///
/// [FirestoreQueryBuilder] is independent from how the query will be rendered
/// and as such can be used with any existing widget for rendering list of items.
///
/// An example of how to combine [FirestoreQueryBuilder] with [ListView] would be:
///
/// ```dart
/// FirestoreQueryBuilder<Movie>(
///   query: moviesCollection.orderBy('title'),
///   builder: (context, snapshot, _) {
///     if (snapshot.isFetching) {
///       return const CircularProgressIndicator();
///     }
///     if (snapshot.hasError) {
///       return Text('error ${snapshot.error}');
///     }
///
///     return ListView.builder(
///       itemCount: snapshot.docs.length,
///       itemBuilder: (context, index) {
///         // if we reached the end of the currently obtained items, we try to
///         // obtain more items
///         if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
///           // Tell FirestoreQueryBuilder to try to obtain more items.
///           // It is safe to call this function from within the build method.
///           snapshot.fetchMore();
///         }
///
///         final movie = snapshot.docs[index];
///         return Text(movie.title);
///       },
///     );
///   },
/// )
/// ```
/// {@endtemplate}
/// {@subCategory service:firestore}
/// {@subCategory type:widget}
/// {@subCategory description:A widget that listens to a query.}
/// {@subCategory img:https://place-hold.it/400x150}
class FirestoreQueryBuilder<Document> extends StatefulWidget {
  /// {@macro firebase_ui.firestore_query_builder}
  const FirestoreQueryBuilder({
    Key? key,
    required this.query,
    required this.builder,
    this.pageSize = 10,
    this.child,
  })  : assert(pageSize > 1, 'Cannot have a pageSize lower than 1'),
        super(key: key);

  /// The query that will be paginated.
  ///
  /// When the query changes, the pagination will restart from first page.
  final Query<Document> query;

  /// The number of items that will be fetched at a time.
  ///
  /// When it changes, the current progress will be preserved.
  final int pageSize;

  final FirestoreQueryBuilderSnapshotBuilder<Document> builder;

  /// A widget that will be passed to [builder] for optimizations purpose.
  ///
  /// Since this widget is not created within [builder], it won't rebuild
  /// when the query emits an update.
  final Widget? child;

  @override
  // ignore: library_private_types_in_public_api
  _FirestoreQueryBuilderState<Document> createState() =>
      _FirestoreQueryBuilderState<Document>();
}

class _FirestoreQueryBuilderState<Document>
    extends State<FirestoreQueryBuilder<Document>> {
  StreamSubscription? _querySubscription;

  var _pageCount = 0;

  late var _snapshot = _QueryBuilderSnapshot<Document>._(
    docs: [],
    error: null,
    hasData: false,
    hasError: false,
    hasMore: false,
    isFetching: false,
    isFetchingMore: false,
    stackTrace: null,
    fetchMore: _fetchNextPage,
  );

  void _fetchNextPage() {
    if (_snapshot.isFetching ||
        !_snapshot.hasMore ||
        _snapshot.isFetchingMore) {
      return;
    }

    _pageCount++;
    _listenQuery(nextPage: true);
  }

  @override
  void initState() {
    super.initState();
    _listenQuery();
  }

  @override
  void didUpdateWidget(FirestoreQueryBuilder<Document> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _pageCount = 0;
      _listenQuery();
    } else if (oldWidget.pageSize != widget.pageSize) {
      // The page size changes, so we re-fetch items, making sure we're
      // preserving the current progress.
      final previousItemCount = (oldWidget.pageSize + 1) * _pageCount;
      _pageCount = (previousItemCount / widget.pageSize).ceil();
      _listenQuery();
    }
  }

  void _listenQuery({bool nextPage = false}) {
    _querySubscription?.cancel();

    if (nextPage) {
      _snapshot = _snapshot.copyWith(isFetchingMore: true);
    } else {
      _snapshot = _snapshot.copyWith(isFetching: true);
    }

    // Delaying the setState so that fetchNextpage can be used within a child's
    // "build" – most commonly ListView's itemBuilder
    Future.microtask(() => setState(() {}));

    final expectedDocsCount = (_pageCount + 1) * widget.pageSize

        /// The "+1" is used to voluntarily fetch one extra item,
        /// used to determine whether there is a next page or not.
        /// This extra item will not be rendered.
        +
        1;

    final query = widget.query.limit(expectedDocsCount);

    _querySubscription = query.snapshots().listen(
      (event) {
        setState(() {
          if (nextPage) {
            _snapshot = _snapshot.copyWith(isFetchingMore: false);
          } else {
            _snapshot = _snapshot.copyWith(isFetching: false);
          }

          _snapshot = _snapshot.copyWith(
            hasData: true,
            docs: event.size < expectedDocsCount
                ? event.docs
                : event.docs.take(expectedDocsCount - 1).toList(),
            error: null,
            hasMore: event.size == expectedDocsCount,
            stackTrace: null,
            hasError: false,
          );
        });
      },
      onError: (Object error, StackTrace stackTrace) {
        setState(() {
          if (nextPage) {
            _snapshot = _snapshot.copyWith(isFetchingMore: false);
          } else {
            _snapshot = _snapshot.copyWith(isFetching: false);
          }

          _snapshot = _snapshot.copyWith(
            error: error,
            stackTrace: stackTrace,
            hasError: true,
            hasMore: false,
          );
        });
      },
    );
  }

  @override
  void dispose() {
    _querySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _snapshot, widget.child);
  }
}

/// The result of a paginated query.
abstract class FirestoreQueryBuilderSnapshot<Document> {
  /// Whether the first page of the query is currently being fetched.
  ///
  /// [isFetching] will reset to `true` when the query changes, in which case
  /// a widget can have both [isFetching] as `true` and [hasData]/[hasError] as
  /// `true.
  bool get isFetching;

  /// Whether a new page is being fetched.
  ///
  /// See also [fetchMore].
  bool get isFetchingMore;

  /// Whether a page was not obtained.
  ///
  /// On error, [docs] will still be available if a valid result was emitted
  /// previously.
  bool get hasError;

  /// Whether at least one page was obtained.
  ///
  /// It is possible for [hasData] to be `true` and [hasError]/[isFetching]
  /// to also be true. That is because [docs] will still be available even
  /// when the query changed or an error was emitted.
  bool get hasData;

  /// Whether there is an extra page to fetch
  ///
  /// See also [fetchMore].
  bool get hasMore;

  /// The error emitted, if any.
  Object? get error;

  /// If an error was emitted, the stackTrace associated to this error.
  StackTrace? get stackTrace;

  /// All the items obtained.
  List<QueryDocumentSnapshot<Document>> get docs;

  /// Try to obtain more items from the collection.
  ///
  /// It is safe to call this method multiple times at once or to call it
  /// within the `build` method of a widget.
  void fetchMore();
}

class _QueryBuilderSnapshot<Document>
    implements FirestoreQueryBuilderSnapshot<Document> {
  _QueryBuilderSnapshot._({
    required this.docs,
    required this.error,
    required this.hasData,
    required this.hasError,
    required this.isFetching,
    required this.isFetchingMore,
    required this.stackTrace,
    required this.hasMore,
    required VoidCallback fetchMore,
  }) : _fetchNextPage = fetchMore;

  @override
  final List<QueryDocumentSnapshot<Document>> docs;

  @override
  final Object? error;

  @override
  final bool hasData;

  @override
  final bool hasError;

  @override
  final bool hasMore;

  @override
  final bool isFetching;

  @override
  final bool isFetchingMore;

  @override
  final StackTrace? stackTrace;

  final VoidCallback _fetchNextPage;

  @override
  void fetchMore() => _fetchNextPage();

  _QueryBuilderSnapshot<Document> copyWith({
    Object? docs = const _Sentinel(),
    Object? error = const _Sentinel(),
    Object? hasData = const _Sentinel(),
    Object? hasError = const _Sentinel(),
    Object? hasMore = const _Sentinel(),
    Object? isFetching = const _Sentinel(),
    Object? isFetchingMore = const _Sentinel(),
    Object? stackTrace = const _Sentinel(),
  }) {
    T valueAs<T>(Object? maybeNewValue, T previousValue) {
      if (maybeNewValue == const _Sentinel()) {
        return previousValue;
      }
      return maybeNewValue as T;
    }

    return _QueryBuilderSnapshot._(
      docs: valueAs(docs, this.docs),
      error: valueAs(error, this.error),
      hasData: valueAs(hasData, this.hasData),
      hasMore: valueAs(hasMore, this.hasMore),
      hasError: valueAs(hasError, this.hasError),
      isFetching: valueAs(isFetching, this.isFetching),
      isFetchingMore: valueAs(isFetchingMore, this.isFetchingMore),
      stackTrace: valueAs(stackTrace, this.stackTrace),
      fetchMore: fetchMore,
    );
  }
}

class _Sentinel {
  const _Sentinel();
}

/// A type representing the function passed to [FirestoreListView] for its `itemBuilder`.
typedef FirestoreItemBuilder<Document> = Widget Function(
  BuildContext context,
  QueryDocumentSnapshot<Document> doc,
);

/// A type representing the function passed to [FirestoreListView] for its `loadingBuilder`.
typedef FirestoreLoadingBuilder = Widget Function(BuildContext context);

/// A type representing the function passed to [FirestoreListView] for its `errorBuilder`.
typedef FirestoreErrorBuilder = Widget Function(
  BuildContext context,
  Object error,
  StackTrace stackTrace,
);

/// A type representing the function passed to [FirestoreListView] for its `emptyBuilder`.
typedef FirestoreEmptyBuilder = Widget Function(BuildContext context);

/// {@template firebase_ui.firestorelistview}
/// A [ListView.builder] that obtains its items from a Firestore query.
///
/// As an example, consider the following collection:
///
/// ```dart
/// class Movie {
///   Movie({required this.title, required this.genre});
///
///   Movie.fromJson(Map<String, Object?> json)
///     : this(
///         title: json['title']! as String,
///         genre: json['genre']! as String,
///       );
///
///   final String title;
///   final String genre;
///
///   Map<String, Object?> toJson() {
///     return {
///       'title': title,
///       'genre': genre,
///     };
///   }
/// }
///
/// final moviesCollection = FirebaseFirestore.instance.collection('movies').withConverter<Movie>(
///      fromFirestore: (snapshot, _) => Movie.fromJson(snapshot.data()!),
///      toFirestore: (movie, _) => movie.toJson(),
///    );
/// ```
///
///
/// Using [FirestoreListView], we can now show the list of movies by writing:
///
/// ```dart
/// FirestoreListView<Movie>(
///   query: moviesCollection.orderBy('title'),
///   itemBuilder: (context, snapshot) {
///     Movie movie = snapshot.data();
///     return Text(movie.title);
///   },
/// )
/// ```
///
/// For advanced UI use-cases, consider switching to [FirestoreQueryBuilder].
/// {@endtemplate}
/// {@subCategory service:firestore}
/// {@subCategory type:widget}
/// {@subCategory description:A widget that listens to a query and display the items using a ListView}
/// {@subCategory img:https://place-hold.it/400x150}
class FirestoreListView<Document> extends FirestoreQueryBuilder<Document> {
  /// {@macro firebase_ui.firestorelistview}
  FirestoreListView({
    Key? key,
    required Query<Document> query,
    required FirestoreItemBuilder<Document> itemBuilder,
    int pageSize = 10,
    FirestoreLoadingBuilder? loadingBuilder,
    FirestoreErrorBuilder? errorBuilder,
    FirestoreEmptyBuilder? emptyBuilder,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollController? controller,
    bool? primary,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
    double? itemExtent,
    Widget? prototypeItem,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    double? cacheExtent,
    int? semanticChildCount,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.manual,
    String? restorationId,
    Clip clipBehavior = Clip.hardEdge,
  }) : super(
          key: key,
          query: query,
          pageSize: pageSize,
          builder: (context, snapshot, _) {
            if (snapshot.isFetching) {
              return loadingBuilder?.call(context) ??
                  const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError && errorBuilder != null) {
              return errorBuilder(
                context,
                snapshot.error!,
                snapshot.stackTrace!,
              );
            }

            if (snapshot.docs.isEmpty && emptyBuilder != null) {
              return emptyBuilder(context);
            }

            return ListView.builder(
              itemCount: snapshot.docs.length,
              itemBuilder: (context, index) {
                final isLastItem = index + 1 == snapshot.docs.length;
                if (isLastItem && snapshot.hasMore) snapshot.fetchMore();

                final doc = snapshot.docs[index];
                return itemBuilder(context, doc);
              },
              scrollDirection: scrollDirection,
              reverse: reverse,
              controller: controller,
              primary: primary,
              physics: physics,
              shrinkWrap: shrinkWrap,
              padding: padding,
              itemExtent: itemExtent,
              prototypeItem: prototypeItem,
              addAutomaticKeepAlives: addAutomaticKeepAlives,
              addRepaintBoundaries: addRepaintBoundaries,
              addSemanticIndexes: addSemanticIndexes,
              cacheExtent: cacheExtent,
              semanticChildCount: semanticChildCount,
              dragStartBehavior: dragStartBehavior,
              keyboardDismissBehavior: keyboardDismissBehavior,
              restorationId: restorationId,
              clipBehavior: clipBehavior,
            );
          },
        );
}

/// Listens to an aggregate query and passes the [AsyncSnapshot] to the builder.
class AggregateQueryBuilder extends StatefulWidget {
  /// A query to listen to
  final AggregateQuery query;

  /// A builder that is called whenever the query is updated.
  final Widget Function(
    BuildContext context,
    AsyncSnapshot<AggregateQuerySnapshot> snapshot,
  ) builder;

  const AggregateQueryBuilder({
    super.key,
    required this.query,
    required this.builder,
  });

  @override
  State<AggregateQueryBuilder> createState() => _AggregateQueryBuilderState();
}

class _AggregateQueryBuilderState extends State<AggregateQueryBuilder> {
  late var queryFuture = widget.query.get();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AggregateQuerySnapshot>(
      future: queryFuture,
      builder: (context, snapshot) {
        return widget.builder(context, snapshot);
      },
    );
  }

  @override
  void didUpdateWidget(covariant AggregateQueryBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != oldWidget.query) {
      queryFuture = widget.query.get();
    }
  }
}
