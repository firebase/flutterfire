import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreQueryBuilder<Document> extends StatefulWidget {
  const FirestoreQueryBuilder({
    Key? key,
    required this.query,
    required this.builder,
    this.limit = 10,
    this.child,
  }) : super(key: key);

  final Query<Document> query;

  final int limit;

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
    extends State<FirestoreQueryBuilder<Document>>
    implements QueryBuilderSnapshot<Document> {
  StreamSubscription? _querySubscription;

  var pageCount = 0;

  @override
  Document? data;

  @override
  Object? error;

  @override
  bool hasData = false;

  @override
  bool hasError = false;

  @override
  bool isFetching = false;

  @override
  bool isFetchingNextPage = false;

  @override
  StackTrace? stackTrace;

  @override
  void fetchNextPage() {
    if (isFetchingNextPage) return;

    pageCount++;

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
      setState(() {
        isFetching = true;
      });
      _listenQuery();
    }
  }

  void _listenQuery({bool nextPage = false}) {
    _querySubscription?.cancel();

    setState(() {
      if (nextPage)
        isFetchingNextPage = true;
      else
        isFetching = true;
    });

    final query = widget.query.limit((pageCount + 1) * widget.limit);

    _querySubscription = widget.query.snapshots().listen(
      (event) {
        setState(() {
          if (nextPage)
            isFetchingNextPage = false;
          else
            isFetching = false;
          hasData = true;
          error = null;
          stackTrace = null;
          hasError = false;
        });
      },
      onError: (Object error, StackTrace stackTrace) {
        setState(() {
          if (nextPage)
            isFetchingNextPage = false;
          else
            isFetching = false;
          this.error = error;
          this.stackTrace = stackTrace;
          hasError = true;
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
    return widget.builder(context, this, widget.child);
  }
}

abstract class QueryBuilderSnapshot<Document> {
  bool get isFetching;
  bool get isFetchingNextPage;
  bool get hasError;
  bool get hasData;

  Object? get error;
  StackTrace? get stackTrace;

  Document? get data;

  void fetchNextPage();
}
