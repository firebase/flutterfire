// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:mockito/mockito.dart';
import 'utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(prepare);

  group('FirestoreQueryBuilder', () {
    testWidgets('fetches initial page', (tester) async {
      final builderSpy = QueryBuilderSpy();
      final collection = await setupCollection(
        FirebaseFirestore.instance
            .collection('flutter-tests/query-builder/works'),
      );

      await collection.add({'value': 21});

      await tester.pumpWidget(
        FirestoreQueryBuilder<Map>(
          query: collection.orderBy('value'),
          builder: builderSpy,
        ),
      );

      verify(
        builderSpy(
          any,
          argThat(
            isQueryBuilderSnapshot(
              isFetching: true,
              hasData: false,
              hasMore: false,
              docs: [],
              error: null,
              stackTrace: null,
              isFetchingNextPage: false,
              hasError: false,
            ),
          ),
          null,
        ),
      ).called(1);
      verifyNoMoreInteractions(builderSpy);

      await collection.get();
      await tester.pump();

      verify(
        builderSpy(
          any,
          argThat(
            isQueryBuilderSnapshot(
              isFetching: false,
              hasData: true,
              hasMore: false,
              docs: [
                isQueryDocumentSnapshot(data: {'value': 21}),
              ],
              error: null,
              stackTrace: null,
              isFetchingNextPage: false,
            ),
          ),
          null,
        ),
      ).called(1);
      verifyNoMoreInteractions(builderSpy);

      await collection.add({'value': 42});
      await tester.pump();

      verify(
        builderSpy(
          any,
          argThat(
            isQueryBuilderSnapshot(
              isFetching: false,
              hasMore: false,
              hasData: true,
              docs: [
                isQueryDocumentSnapshot(data: {'value': 21}),
                isQueryDocumentSnapshot(data: {'value': 42}),
              ],
              error: null,
              stackTrace: null,
              isFetchingNextPage: false,
            ),
          ),
          null,
        ),
      ).called(1);
      verifyNoMoreInteractions(builderSpy);
    });

    testWidgets('defaults to fetching 10 by 10', (tester) async {
      final builderSpy = QueryBuilderSpy();
      final collection = await setupCollection(
        FirebaseFirestore.instance
            .collection('flutter-tests/query-builder/works'),
      );

      await fillCollection(collection, 25);

      await tester.pumpWidget(
        FirestoreQueryBuilder<Map>(
          query: collection.orderBy('value'),
          builder: builderSpy,
        ),
      );

      clearInteractions(builderSpy);

      await collection.get();
      await tester.pump();

      verify(
        builderSpy(
          any,
          captureThat(
            isQueryBuilderSnapshot(
              isFetching: false,
              hasData: true,
              hasMore: true,
              docs: [
                for (var i = 0; i < 10; i++)
                  isQueryDocumentSnapshot(data: {'value': i}),
              ],
              error: null,
              stackTrace: null,
              isFetchingNextPage: false,
            ),
          ),
          null,
        ),
      );
      verifyNoMoreInteractions(builderSpy);

      builderSpy.lastSnapshot!.fetchMore();
      await tester.pump();

      verify(
        builderSpy(
          any,
          captureThat(
            isQueryBuilderSnapshot(
              isFetching: false,
              isFetchingNextPage: true,
              hasData: true,
              hasMore: true,
              docs: [
                for (var i = 0; i < 10; i++)
                  isQueryDocumentSnapshot(data: {'value': i}),
              ],
              error: null,
              stackTrace: null,
            ),
          ),
          null,
        ),
      );

      await collection.get();
      await tester.pump();

      verify(
        builderSpy(
          any,
          captureThat(
            isQueryBuilderSnapshot(
              isFetching: false,
              isFetchingNextPage: false,
              hasData: true,
              hasMore: true,
              docs: [
                for (var i = 0; i < 20; i++)
                  isQueryDocumentSnapshot(data: {'value': i}),
              ],
              error: null,
              stackTrace: null,
            ),
          ),
          null,
        ),
      );

      builderSpy.lastSnapshot!.fetchMore();
      await tester.pump();

      verify(
        builderSpy(
          any,
          captureThat(
            isQueryBuilderSnapshot(
              isFetching: false,
              isFetchingNextPage: true,
              hasData: true,
              hasMore: true,
              docs: [
                for (var i = 0; i < 20; i++)
                  isQueryDocumentSnapshot(data: {'value': i}),
              ],
              error: null,
              stackTrace: null,
            ),
          ),
          null,
        ),
      );

      await collection.get();
      await tester.pump();

      verify(
        builderSpy(
          any,
          captureThat(
            isQueryBuilderSnapshot(
              isFetching: false,
              isFetchingNextPage: false,
              hasData: true,
              hasMore: false,
              docs: [
                for (var i = 0; i < 25; i++)
                  isQueryDocumentSnapshot(data: {'value': i}),
              ],
              error: null,
              stackTrace: null,
            ),
          ),
          null,
        ),
      );

      await collection.add({'value': 25});
      await tester.pump();

      verify(
        builderSpy(
          any,
          captureThat(
            isQueryBuilderSnapshot(
              isFetching: false,
              isFetchingNextPage: false,
              hasData: true,
              hasMore: false,
              docs: [
                for (var i = 0; i < 26; i++)
                  isQueryDocumentSnapshot(data: {'value': i}),
              ],
              error: null,
              stackTrace: null,
            ),
          ),
          null,
        ),
      );
    });

    testWidgets('when the query changes, re-fetches from first page',
        (tester) async {
      final builderSpy = QueryBuilderSpy();
      final collection = await setupCollection(
        FirebaseFirestore.instance
            .collection('flutter-tests/query-builder/works'),
      );

      await fillCollection(collection, 25);

      await tester.pumpWidget(
        FirestoreQueryBuilder<Map>(
          query: collection.orderBy('value'),
          builder: builderSpy,
        ),
      );

      clearInteractions(builderSpy);

      await collection.get();
      await tester.pump();

      verify(
        builderSpy(
          any,
          captureThat(
            isQueryBuilderSnapshot(
              isFetching: false,
              hasData: true,
              hasMore: true,
              docs: [
                for (var i = 0; i < 10; i++)
                  isQueryDocumentSnapshot(data: {'value': i}),
              ],
              error: null,
              stackTrace: null,
              isFetchingNextPage: false,
            ),
          ),
          null,
        ),
      );
      verifyNoMoreInteractions(builderSpy);

      builderSpy.lastSnapshot!.fetchMore();
      await tester.pump();

      verify(
        builderSpy(
          any,
          captureThat(
            isQueryBuilderSnapshot(isFetchingNextPage: true),
          ),
          null,
        ),
      );
      verifyNoMoreInteractions(builderSpy);

      await collection.get();
      await tester.pump();

      verify(
        builderSpy(
          any,
          captureThat(
            isQueryBuilderSnapshot(
              isFetching: false,
              hasData: true,
              hasMore: true,
              docs: [
                for (var i = 0; i < 20; i++)
                  isQueryDocumentSnapshot(data: {'value': i}),
              ],
              error: null,
              stackTrace: null,
              isFetchingNextPage: false,
            ),
          ),
          null,
        ),
      );
      verifyNoMoreInteractions(builderSpy);

      await tester.pumpWidget(
        FirestoreQueryBuilder<Map>(
          query: collection.orderBy('value', descending: true),
          builder: builderSpy,
        ),
      );

      verify(
        builderSpy(
          any,
          captureThat(
            isQueryBuilderSnapshot(
              isFetching: true,
              hasData: true,
              hasMore: true,
              docs: [
                for (var i = 0; i < 20; i++)
                  isQueryDocumentSnapshot(data: {'value': i}),
              ],
              error: null,
              stackTrace: null,
              isFetchingNextPage: false,
            ),
          ),
          null,
        ),
      );
      verifyNoMoreInteractions(builderSpy);

      await collection.get();
      await tester.pump();

      verify(
        builderSpy(
          any,
          captureThat(
            isQueryBuilderSnapshot(
              isFetching: false,
              hasData: true,
              hasMore: true,
              docs: [
                for (var i = 0; i < 10; i++)
                  isQueryDocumentSnapshot(data: {'value': 24 - i}),
              ],
              error: null,
              stackTrace: null,
              isFetchingNextPage: false,
            ),
          ),
          null,
        ),
      );
      verifyNoMoreInteractions(builderSpy);
    });

    testWidgets('when the page size changes, re-fetches but preserve progress',
        (tester) async {
      final builderSpy = QueryBuilderSpy();
      final collection = await setupCollection(
        FirebaseFirestore.instance
            .collection('flutter-tests/query-builder/works'),
      );

      await fillCollection(collection, 25);

      await tester.pumpWidget(
        FirestoreQueryBuilder<Map>(
          query: collection.orderBy('value'),
          builder: builderSpy,
        ),
      );

      clearInteractions(builderSpy);

      await collection.get();
      await tester.pump();

      verify(
        builderSpy(
          any,
          captureThat(
            isQueryBuilderSnapshot(
              isFetching: false,
              hasData: true,
              hasMore: true,
              docs: [
                for (var i = 0; i < 10; i++)
                  isQueryDocumentSnapshot(data: {'value': i}),
              ],
              error: null,
              stackTrace: null,
              isFetchingNextPage: false,
            ),
          ),
          null,
        ),
      );
      verifyNoMoreInteractions(builderSpy);

      builderSpy.lastSnapshot!.fetchMore();
      await tester.pump();

      verify(
        builderSpy(
          any,
          captureThat(
            isQueryBuilderSnapshot(isFetchingNextPage: true),
          ),
          null,
        ),
      );
      verifyNoMoreInteractions(builderSpy);

      await collection.get();
      await tester.pump();

      verify(
        builderSpy(
          any,
          captureThat(
            isQueryBuilderSnapshot(
              isFetching: false,
              hasData: true,
              hasMore: true,
              docs: [
                for (var i = 0; i < 20; i++)
                  isQueryDocumentSnapshot(data: {'value': i}),
              ],
              error: null,
              stackTrace: null,
              isFetchingNextPage: false,
            ),
          ),
          null,
        ),
      );
      verifyNoMoreInteractions(builderSpy);

      await tester.pumpWidget(
        FirestoreQueryBuilder<Map>(
          pageSize: 11,
          query: collection.orderBy('value'),
          builder: builderSpy,
        ),
      );

      verify(
        builderSpy(
          any,
          captureThat(
            isQueryBuilderSnapshot(
              isFetching: true,
              hasData: true,
              hasMore: true,
              docs: [
                for (var i = 0; i < 20; i++)
                  isQueryDocumentSnapshot(data: {'value': i}),
              ],
              error: null,
              stackTrace: null,
              isFetchingNextPage: false,
            ),
          ),
          null,
        ),
      );
      verifyNoMoreInteractions(builderSpy);

      await collection.get();
      await tester.pump();

      verify(
        builderSpy(
          any,
          captureThat(
            isQueryBuilderSnapshot(
              isFetching: false,
              hasData: true,
              hasMore: true,
              docs: [
                for (var i = 0; i < 22; i++)
                  isQueryDocumentSnapshot(data: {'value': i}),
              ],
              error: null,
              stackTrace: null,
              isFetchingNextPage: false,
            ),
          ),
          null,
        ),
      );
      verifyNoMoreInteractions(builderSpy);
    });

    testWidgets('calling fetchNextPage twice is no-op', (tester) async {
      final builderSpy = QueryBuilderSpy();
      final collection = await setupCollection(
        FirebaseFirestore.instance
            .collection('flutter-tests/query-builder/works'),
      );

      await fillCollection(collection, 25);

      await tester.pumpWidget(
        FirestoreQueryBuilder<Map>(
          query: collection.orderBy('value'),
          builder: builderSpy,
        ),
      );

      clearInteractions(builderSpy);

      await collection.get();
      await tester.pump();

      verify(
        builderSpy(
          any,
          captureThat(
            isQueryBuilderSnapshot(
              isFetching: false,
              hasData: true,
              hasMore: true,
              docs: [
                for (var i = 0; i < 10; i++)
                  isQueryDocumentSnapshot(data: {'value': i}),
              ],
              error: null,
              stackTrace: null,
              isFetchingNextPage: false,
            ),
          ),
          null,
        ),
      );
      verifyNoMoreInteractions(builderSpy);

      builderSpy.lastSnapshot!
        ..fetchMore()
        ..fetchMore();

      await tester.pump();

      verify(
        builderSpy(
          any,
          captureThat(
            isQueryBuilderSnapshot(
              isFetching: false,
              isFetchingNextPage: true,
              hasData: true,
              hasMore: true,
              docs: [
                for (var i = 0; i < 10; i++)
                  isQueryDocumentSnapshot(data: {'value': i}),
              ],
              error: null,
              stackTrace: null,
            ),
          ),
          null,
        ),
      );

      await collection.get();
      await tester.pump();

      verify(
        builderSpy(
          any,
          captureThat(
            isQueryBuilderSnapshot(
              isFetching: false,
              isFetchingNextPage: false,
              hasData: true,
              hasMore: true,
              docs: [
                for (var i = 0; i < 20; i++)
                  isQueryDocumentSnapshot(data: {'value': i}),
              ],
              error: null,
              stackTrace: null,
            ),
          ),
          null,
        ),
      );
    });

    testWidgets('error after data preserves the data', (tester) async {
      final builderSpy = QueryBuilderSpy();
      final validCollection = await setupCollection(
        FirebaseFirestore.instance
            .collection('flutter-tests/query-builder/works'),
      );
      final unknownCollection =
          FirebaseFirestore.instance.collection('unknown');

      await fillCollection(validCollection, 25);

      await tester.pumpWidget(
        FirestoreQueryBuilder<Map>(
          query: validCollection.orderBy('value'),
          builder: builderSpy,
        ),
      );

      clearInteractions(builderSpy);

      await validCollection.get();
      await tester.pump();

      verify(
        builderSpy(
          any,
          captureThat(
            isQueryBuilderSnapshot(
              isFetching: false,
              hasData: true,
              hasMore: true,
              docs: [
                for (var i = 0; i < 10; i++)
                  isQueryDocumentSnapshot(data: {'value': i}),
              ],
              error: null,
              stackTrace: null,
              isFetchingNextPage: false,
            ),
          ),
          null,
        ),
      );
      verifyNoMoreInteractions(builderSpy);

      await tester.pumpWidget(
        FirestoreQueryBuilder<Map>(
          query: unknownCollection,
          builder: builderSpy,
        ),
      );

      verify(
        builderSpy(
          any,
          captureThat(
            isQueryBuilderSnapshot(
              isFetching: true,
              hasData: true,
              hasMore: true,
              hasError: false,
              docs: [
                for (var i = 0; i < 10; i++)
                  isQueryDocumentSnapshot(data: {'value': i}),
              ],
              error: null,
              stackTrace: null,
              isFetchingNextPage: false,
            ),
          ),
          null,
        ),
      );
      verifyNoMoreInteractions(builderSpy);

      await unknownCollection.snapshots().first.then((_) {}, onError: (_) {});
      await tester.pump();

      verify(
        builderSpy(
          any,
          captureThat(
            isQueryBuilderSnapshot(
              isFetching: false,
              hasData: true,
              hasMore: false,
              hasError: true,
              docs: [
                for (var i = 0; i < 10; i++)
                  isQueryDocumentSnapshot(data: {'value': i}),
              ],
              error: isA<FirebaseException>(),
              stackTrace: isNotNull,
              isFetchingNextPage: false,
            ),
          ),
          null,
        ),
      );
      verifyNoMoreInteractions(builderSpy);
    });

    testWidgets(
      'data after error resets hasError/error/stackTrace',
      (tester) async {
        final builderSpy = QueryBuilderSpy();
        final validCollection = await setupCollection(
          FirebaseFirestore.instance
              .collection('flutter-tests/query-builder/works'),
        );
        final unknownCollection =
            FirebaseFirestore.instance.collection('unknown');

        await fillCollection(validCollection, 25);

        await tester.pumpWidget(
          FirestoreQueryBuilder<Map>(
            query: unknownCollection,
            builder: builderSpy,
          ),
        );

        verify(
          builderSpy(
            any,
            captureThat(
              isQueryBuilderSnapshot(
                isFetching: true,
                hasData: false,
                hasMore: false,
                hasError: false,
                docs: [],
                error: null,
                stackTrace: null,
                isFetchingNextPage: false,
              ),
            ),
            null,
          ),
        );
        verifyNoMoreInteractions(builderSpy);

        await unknownCollection.snapshots().first.then((_) {}, onError: (_) {});
        await tester.pump();

        verify(
          builderSpy(
            any,
            captureThat(
              isQueryBuilderSnapshot(
                isFetching: false,
                isFetchingNextPage: false,
                hasData: false,
                hasMore: false,
                docs: [],
                hasError: true,
                error: isA<FirebaseException>(),
                stackTrace: isNotNull,
              ),
            ),
            null,
          ),
        );
        verifyNoMoreInteractions(builderSpy);

        await tester.pumpWidget(
          FirestoreQueryBuilder<Map>(
            query: validCollection.orderBy('value'),
            builder: builderSpy,
          ),
        );

        verify(
          builderSpy(
            any,
            captureThat(
              isQueryBuilderSnapshot(
                isFetching: true,
                isFetchingNextPage: false,
                hasData: false,
                hasMore: false,
                docs: [],
                hasError: true,
                error: isA<FirebaseException>(),
                stackTrace: isNotNull,
              ),
            ),
            null,
          ),
        );
        verifyNoMoreInteractions(builderSpy);

        await validCollection.get();
        await tester.pump();

        verify(
          builderSpy(
            any,
            captureThat(
              isQueryBuilderSnapshot(
                isFetching: false,
                hasData: true,
                hasMore: true,
                docs: [
                  for (var i = 0; i < 10; i++)
                    isQueryDocumentSnapshot(data: {'value': i}),
                ],
                hasError: false,
                error: null,
                stackTrace: null,
                isFetchingNextPage: false,
              ),
            ),
            null,
          ),
        );
        verifyNoMoreInteractions(builderSpy);
      },
    );
  });
}

class QueryBuilderSpy<T> extends Mock {
  QueryBuilderSpy([this._builder]) {
    if (_builder != null) {
      when(call(any, any, any)).thenAnswer((realInvocation) {
        return _builder!(
          realInvocation.positionalArguments[0] as BuildContext,
          realInvocation.positionalArguments[1]
              as FirestoreQueryBuilderSnapshot<T>,
          realInvocation.positionalArguments[2] as Widget?,
        );
      });
    }
  }

  final Widget Function(
    BuildContext context,
    FirestoreQueryBuilderSnapshot<T> snapshot,
    Widget? child,
  )? _builder;

  FirestoreQueryBuilderSnapshot<T>? lastSnapshot;

  Widget call(
    BuildContext? context,
    FirestoreQueryBuilderSnapshot<T>? snapshot,
    Widget? child,
  ) {
    if (snapshot != null) lastSnapshot = snapshot;

    return super.noSuchMethod(
      Invocation.method(#call, [context, snapshot, child]),
      returnValueForMissingStub: Container(),
      returnValue: Container(),
    );
  }
}

Future<void> fillCollection(CollectionReference ref, int length) {
  return Future.wait([
    for (var i = 0; i < length; i++) ref.add({'value': i}),
  ]);
}
