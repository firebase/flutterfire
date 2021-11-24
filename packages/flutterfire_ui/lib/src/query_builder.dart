import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// {@template firebase_ui.firestore_query_builder}
/// {@endtemplate}
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

  final Widget Function(
    BuildContext context,
    QueryBuilderSnapshot<Document> snapshot,
    Widget? child,
  ) builder;

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
    hasNextPage: false,
    isFetching: false,
    isFetchingMore: false,
    stackTrace: null,
    fetchMore: _fetchNextPage,
  );

  void _fetchNextPage() {
    if (_snapshot.isFetchingMore) return;

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
            hasNextPage: event.size == expectedDocsCount,
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
            hasNextPage: false,
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
abstract class QueryBuilderSnapshot<Document> {
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
  bool get hasNextPage;

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
    implements QueryBuilderSnapshot<Document> {
  _QueryBuilderSnapshot._({
    required this.docs,
    required this.error,
    required this.hasData,
    required this.hasError,
    required this.isFetching,
    required this.isFetchingMore,
    required this.stackTrace,
    required this.hasNextPage,
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
  final bool hasNextPage;

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
    Object? hasNextPage = const _Sentinel(),
    Object? isFetching = const _Sentinel(),
    Object? isFetchingMore = const _Sentinel(),
    Object? stackTrace = const _Sentinel(),
    Object? fetchMore = const _Sentinel(),
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
      hasNextPage: valueAs(hasNextPage, this.hasNextPage),
      hasError: valueAs(hasError, this.hasError),
      isFetching: valueAs(isFetching, this.isFetching),
      isFetchingMore: valueAs(isFetchingMore, this.isFetchingMore),
      stackTrace: valueAs(stackTrace, this.stackTrace),
      fetchMore: valueAs(fetchMore, this.fetchMore),
    );
  }
}

class _Sentinel {
  const _Sentinel();
}
