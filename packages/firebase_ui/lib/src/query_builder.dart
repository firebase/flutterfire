import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreQueryBuilder<Document> extends StatefulWidget {
  const FirestoreQueryBuilder({
    Key? key,
    required this.query,
    required this.builder,
    this.pageSize = 10,
    this.child,
  })  : assert(pageSize > 1, 'Cannot have a pageSize lower than 1'),
        super(key: key);

  final Query<Document> query;

  final int pageSize;

  final Widget Function(
    BuildContext context,
    QueryBuilderSnapshot<Document> snapshot,
    Widget? child,
  ) builder;

  final Widget? child;

  @override
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
    isFetchingNextPage: false,
    stackTrace: null,
    fetchNextPage: _fetchNextPage,
  );

  void _fetchNextPage() {
    if (_snapshot.isFetchingNextPage) return;

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
      _snapshot = _snapshot.copyWith(isFetchingNextPage: true);
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
            _snapshot = _snapshot.copyWith(isFetchingNextPage: false);
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
            _snapshot = _snapshot.copyWith(isFetchingNextPage: false);
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

abstract class QueryBuilderSnapshot<Document> {
  bool get isFetching;
  bool get isFetchingNextPage;
  bool get hasError;
  bool get hasData;
  bool get hasNextPage;

  Object? get error;
  StackTrace? get stackTrace;

  List<QueryDocumentSnapshot<Document>> get docs;

  void fetchNextPage();
}

class _QueryBuilderSnapshot<Document>
    implements QueryBuilderSnapshot<Document> {
  _QueryBuilderSnapshot._({
    required this.docs,
    required this.error,
    required this.hasData,
    required this.hasError,
    required this.isFetching,
    required this.isFetchingNextPage,
    required this.stackTrace,
    required this.hasNextPage,
    required VoidCallback fetchNextPage,
  }) : _fetchNextPage = fetchNextPage;

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
  final bool isFetchingNextPage;

  @override
  final StackTrace? stackTrace;

  final VoidCallback _fetchNextPage;

  @override
  void fetchNextPage() => _fetchNextPage();

  _QueryBuilderSnapshot<Document> copyWith({
    Object? docs = const _Sentinel(),
    Object? error = const _Sentinel(),
    Object? hasData = const _Sentinel(),
    Object? hasError = const _Sentinel(),
    Object? hasNextPage = const _Sentinel(),
    Object? isFetching = const _Sentinel(),
    Object? isFetchingNextPage = const _Sentinel(),
    Object? stackTrace = const _Sentinel(),
    Object? fetchNextPage = const _Sentinel(),
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
      isFetchingNextPage: valueAs(isFetchingNextPage, this.isFetchingNextPage),
      stackTrace: valueAs(stackTrace, this.stackTrace),
      fetchNextPage: valueAs(fetchNextPage, this.fetchNextPage),
    );
  }
}

class _Sentinel {
  const _Sentinel();
}
