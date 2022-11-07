// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:mockito/mockito.dart';
import 'utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(setupEmulator);

  group('FirestoreListViewBuilder', () {
    testWidgets('Allows specifying custom error handler', (tester) async {
      final builderSpy = ListViewBuilderSpy();
      final collection = FirebaseFirestore.instance.collection('unknown');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FirestoreListView<Map>(
              query: collection,
              errorBuilder: (context, error, stack) => Text('error: $error'),
              itemBuilder: (context, snapshot) => throw UnimplementedError(),
            ),
          ),
        ),
      );

      verifyZeroInteractions(builderSpy);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(ListView), findsNothing);

      await collection.snapshots().first.then((value) {}, onError: (_) {});
      await tester.pumpAndSettle();

      expect(
        find.text(
          'error: [cloud_firestore/permission-denied] '
          'The caller does not have permission to execute the specified operation.',
        ),
        findsOneWidget,
      );
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('Allows specifying custom loading handler', (tester) async {
      final collection = await setupCollection(
        FirebaseFirestore.instance
            .collection('flutter-tests/list-view-builder/works'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FirestoreListView<Map>(
              query: collection.orderBy('value'),
              loadingBuilder: (context) => const Text('loading...'),
              itemBuilder: (context, snapshot) => throw UnimplementedError(),
            ),
          ),
        ),
      );

      expect(find.text('loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('By default, shows a progress indicator when loading',
        (tester) async {
      final collection = await setupCollection(
        FirebaseFirestore.instance
            .collection('flutter-tests/list-view-builder/works'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FirestoreListView<Map>(
              query: collection.orderBy('value'),
              itemBuilder: (context, snapshot) => throw UnimplementedError(),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('By default, ignore errors', (tester) async {
      final builderSpy = ListViewBuilderSpy();
      final collection = FirebaseFirestore.instance.collection('unknown');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FirestoreListView<Map>(
              query: collection,
              cacheExtent: 0,
              itemBuilder: (context, snapshot) => throw UnimplementedError(),
            ),
          ),
        ),
      );

      verifyZeroInteractions(builderSpy);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(ListView), findsNothing);

      await collection.snapshots().first.then((value) {}, onError: (_) {});
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('When reaching the end of the list, loads more items',
        (tester) async {
      final builderSpy = ListViewBuilderSpy();
      // show 5 items at a time
      tester.binding.window.physicalSizeTestValue = const Size(500, 500);

      final collection = await setupCollection(
        FirebaseFirestore.instance
            .collection('flutter-tests/list-view-builder/works'),
      );

      await fillCollection(collection, 25);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FirestoreListView<Map>(
              query: collection.orderBy('value'),
              cacheExtent: 0,
              itemBuilder: (context, snapshot) {
                final value = snapshot.data()['value'];
                builderSpy(context, snapshot);

                return SizedBox(
                  key: ValueKey(value.toString()),
                  height: 100,
                  child: Text(value.toString()),
                );
              },
            ),
          ),
        ),
      );

      verifyZeroInteractions(builderSpy);

      await collection.get();
      await tester.pump();

      verifyInOrder([
        for (var i = 0; i < 7; i++)
          builderSpy(
            any,
            argThat(isQueryDocumentSnapshot(data: {'value': i})),
          )
      ]);
      verifyNoMoreInteractions(builderSpy);

      await tester.drag(find.byKey(const ValueKey('5')), const Offset(0, -500));
      await tester.pump();

      verifyInOrder([
        for (var i = 7; i < 10; i++)
          builderSpy(
            any,
            argThat(isQueryDocumentSnapshot(data: {'value': i})),
          )
      ]);
      verifyNoMoreInteractions(builderSpy);

      await collection.get();

      verifyInOrder([
        for (var i = 3; i < 10; i++)
          builderSpy(
            any,
            argThat(isQueryDocumentSnapshot(data: {'value': i})),
          )
      ]);
      verifyNoMoreInteractions(builderSpy);

      await tester.pump();

      verifyInOrder([
        for (var i = 3; i < 11; i++)
          builderSpy(
            any,
            argThat(isQueryDocumentSnapshot(data: {'value': i})),
          )
      ]);
      verifyNoMoreInteractions(builderSpy);

      await tester.drag(find.byKey(const ValueKey('9')), const Offset(0, -500));
      await tester.pump();

      verifyInOrder([
        for (var i = 10; i < 15; i++)
          builderSpy(
            any,
            argThat(isQueryDocumentSnapshot(data: {'value': i})),
          )
      ]);
      verifyNoMoreInteractions(builderSpy);
    });
  });
}

class ListViewBuilderSpy<T> extends Mock {
  Widget call(
    BuildContext? context,
    T? snapshot,
  ) {
    return super.noSuchMethod(
      Invocation.method(#call, [context, snapshot]),
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
