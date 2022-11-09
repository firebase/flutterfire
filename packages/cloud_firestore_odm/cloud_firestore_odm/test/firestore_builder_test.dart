// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'common.dart';

void main() {
  group('FirestoreBuilder', () {
    testWidgets('supports collection selectors', (tester) async {
      final notifier = ValueNotifier([0]);
      final ref = FakeCollectionReference(notifier);
      var buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: FirestoreBuilder<int>(
            ref: ref.select((snapshot) => snapshot.docs.length),
            builder: (context, snapshot, child) {
              buildCount++;
              if (!snapshot.hasData) return const Text('loading');
              return Text('length: ${snapshot.data}');
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('length: 1'), findsOneWidget);
      expect(buildCount, 2);

      notifier.value = [1];
      await tester.pump();

      expect(buildCount, 2);
      expect(find.text('length: 1'), findsOneWidget);

      notifier.value = [0, 1, 2];
      await tester.pump();

      expect(find.text('length: 3'), findsOneWidget);
      expect(buildCount, 3);
    });

    testWidgets('supports document selectors', (tester) async {
      final notifier = ValueNotifier(0);
      final ref = FakeDocumentReference(notifier);
      var buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: FirestoreBuilder<bool>(
            ref: ref.select((snapshot) => snapshot.data.isEven),
            builder: (context, snapshot, child) {
              buildCount++;
              if (!snapshot.hasData) return const Text('loading');
              return Text('${snapshot.data}');
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('true'), findsOneWidget);
      expect(buildCount, 2);

      notifier.value = 42;
      await tester.pump();

      expect(buildCount, 2);
      expect(find.text('true'), findsOneWidget);

      notifier.value = 41;
      await tester.pump();

      expect(find.text('false'), findsOneWidget);
      expect(buildCount, 3);
    });

    testWidgets(
        'rebuilding with a different selector on the same reference immediately has access to the data',
        (tester) async {
      final notifier = ValueNotifier(0);
      final ref = FakeDocumentReference(notifier);

      await tester.pumpWidget(
        MaterialApp(
          home: FirestoreBuilder<bool>(
            ref: ref.select((snapshot) => snapshot.data.isEven),
            builder: (context, snapshot, child) {
              if (!snapshot.hasData) return const Text('loading');
              return Text('${snapshot.data}');
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('true'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: FirestoreBuilder<bool>(
            ref: ref.select((snapshot) => snapshot.data.isOdd),
            builder: (context, snapshot, child) {
              if (!snapshot.hasData) return const Text('loading');
              return Text('${snapshot.data}');
            },
          ),
        ),
      );

      expect(find.text('false'), findsOneWidget);
    });

    testWidgets('if selector throws, emits AsyncSnapshot.withError',
        (tester) async {
      final notifier = ValueNotifier(0);
      final ref = FakeDocumentReference(notifier);
      Object? error;

      await tester.pumpWidget(
        MaterialApp(
          home: FirestoreBuilder<bool>(
            ref: ref.select((snapshot) => throw UnimplementedError()),
            builder: (context, snapshot, child) {
              if (snapshot.hasError) {
                error = snapshot.error;
                return const Text('error');
              }
              if (!snapshot.hasData) return const Text('loading');
              return Text('${snapshot.data}');
            },
          ),
        ),
      );

      expect(find.text('loading'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('error'), findsOneWidget);
      expect(error, isUnimplementedError);
    });

    group('connectionState', () {
      group('no selectors', () {
        testWidgets('is "waiting" on initial build and "active" on data',
            (tester) async {
          final notifier = ValueNotifier(0);
          final ref = FakeDocumentReference(notifier);
          ConnectionState? connectionState;

          await tester.pumpWidget(
            MaterialApp(
              home: FirestoreBuilder<FakeDocumentSnapshot<int>>(
                ref: ref,
                builder: (context, snapshot, child) {
                  connectionState = snapshot.connectionState;
                  if (snapshot.hasError) return const Text('error');
                  if (!snapshot.hasData) return const Text('loading');
                  return Text('${snapshot.data?.data}');
                },
              ),
            ),
          );

          expect(connectionState, ConnectionState.waiting);
          expect(find.text('loading'), findsOneWidget);

          await tester.pumpAndSettle();

          expect(connectionState, ConnectionState.active);
          expect(find.text('0'), findsOneWidget);
        });

        testWidgets('is "waiting" on rebuild and "active" after new event',
            (tester) async {
          final notifier = ValueNotifier(0);
          final ref = FakeDocumentReference(notifier);
          final notifier2 = ValueNotifier(42);
          final ref2 = FakeDocumentReference(notifier2);
          ConnectionState? connectionState;

          await tester.pumpWidget(
            MaterialApp(
              home: FirestoreBuilder<FakeDocumentSnapshot<int>>(
                ref: ref,
                builder: (context, snapshot, child) {
                  connectionState = snapshot.connectionState;
                  if (snapshot.hasError) return const Text('error');
                  if (!snapshot.hasData) return const Text('loading');
                  return Text('${snapshot.data?.data}');
                },
              ),
            ),
          );

          await tester.pumpAndSettle();

          expect(connectionState, ConnectionState.active);
          expect(find.text('error'), findsNothing);
          expect(find.text('loading'), findsNothing);
          expect(find.text('0'), findsOneWidget);

          await tester.pumpWidget(
            MaterialApp(
              home: FirestoreBuilder<FakeDocumentSnapshot<int>>(
                ref: ref2,
                builder: (context, snapshot, child) {
                  connectionState = snapshot.connectionState;
                  if (snapshot.hasError) return const Text('error');
                  if (!snapshot.hasData) return const Text('loading');
                  return Text('${snapshot.data?.data}');
                },
              ),
            ),
          );

          expect(find.text('0'), findsOneWidget);
          expect(connectionState, ConnectionState.waiting);

          await tester.pumpAndSettle();

          expect(connectionState, ConnectionState.active);
          expect(find.text('42'), findsOneWidget);
        });

        testWidgets('is "active" on error', (tester) async {
          final error = ValueNotifier<Object>(0);
          final ref = FakeDocumentReference(
            ValueNotifier(0),
            errorListenable: error,
            emitCurrentValue: false,
          );
          ConnectionState? connectionState;

          await tester.pumpWidget(
            MaterialApp(
              home: FirestoreBuilder<FakeDocumentSnapshot<int>>(
                ref: ref,
                builder: (context, snapshot, child) {
                  connectionState = snapshot.connectionState;
                  if (snapshot.hasError) return const Text('error');
                  if (!snapshot.hasData) return const Text('loading');
                  return Text('${snapshot.data?.data}');
                },
              ),
            ),
          );

          error.notifyListeners();
          await tester.pumpAndSettle();

          expect(connectionState, ConnectionState.active);
          expect(find.text('error'), findsOneWidget);
        });
      });

      group('with selectors', () {
        testWidgets('is "waiting" on initial build and "active" on data',
            (tester) async {
          final notifier = ValueNotifier(0);
          final ref = FakeDocumentReference(notifier);
          ConnectionState? connectionState;

          await tester.pumpWidget(
            MaterialApp(
              home: FirestoreBuilder<bool>(
                ref: ref.select((snapshot) => snapshot.data.isEven),
                builder: (context, snapshot, child) {
                  connectionState = snapshot.connectionState;
                  if (snapshot.hasError) return const Text('error');
                  if (!snapshot.hasData) return const Text('loading');
                  return Text('${snapshot.data}');
                },
              ),
            ),
          );

          expect(connectionState, ConnectionState.waiting);
          expect(find.text('loading'), findsOneWidget);

          await tester.pumpAndSettle();

          expect(connectionState, ConnectionState.active);
          expect(find.text('true'), findsOneWidget);
        });

        testWidgets('is "waiting" on rebuild and "active" after new event',
            (tester) async {
          final notifier = ValueNotifier(0);
          final ref = FakeDocumentReference(notifier);
          final notifier2 = ValueNotifier(42);
          final ref2 = FakeDocumentReference(notifier2);
          ConnectionState? connectionState;

          await tester.pumpWidget(
            MaterialApp(
              home: FirestoreBuilder<bool>(
                ref: ref.select((s) => s.data.isEven),
                builder: (context, snapshot, child) {
                  connectionState = snapshot.connectionState;
                  if (snapshot.hasError) return const Text('error');
                  if (!snapshot.hasData) return const Text('loading');
                  return Text('${snapshot.data}');
                },
              ),
            ),
          );

          await tester.pumpAndSettle();

          expect(connectionState, ConnectionState.active);
          expect(find.text('error'), findsNothing);
          expect(find.text('loading'), findsNothing);
          expect(find.text('true'), findsOneWidget);

          await tester.pumpWidget(
            MaterialApp(
              home: FirestoreBuilder<bool>(
                ref: ref2.select((s) => s.data.isEven),
                builder: (context, snapshot, child) {
                  connectionState = snapshot.connectionState;
                  if (snapshot.hasError) return const Text('error');
                  if (!snapshot.hasData) return const Text('loading');
                  return Text('${snapshot.data}');
                },
              ),
            ),
          );

          expect(find.text('true'), findsOneWidget);
          expect(connectionState, ConnectionState.waiting);

          await tester.pumpAndSettle();

          expect(connectionState, ConnectionState.active);
          expect(find.text('true'), findsOneWidget);
        });

        testWidgets('is "active" on error', (tester) async {
          final error = ValueNotifier<Object>(0);
          final ref = FakeDocumentReference(
            ValueNotifier(0),
            errorListenable: error,
            emitCurrentValue: false,
          );
          ConnectionState? connectionState;

          await tester.pumpWidget(
            MaterialApp(
              home: FirestoreBuilder<bool>(
                ref: ref.select((s) => s.data.isEven),
                builder: (context, snapshot, child) {
                  connectionState = snapshot.connectionState;
                  if (snapshot.hasError) return const Text('error');
                  if (!snapshot.hasData) return const Text('loading');
                  return Text('${snapshot.data}');
                },
              ),
            ),
          );

          error.notifyListeners();
          await tester.pumpAndSettle();

          expect(connectionState, ConnectionState.active);
          expect(find.text('error'), findsOneWidget);
        });
      });
    });

    testWidgets('on error, selectors always rebuild', (tester) async {
      final notifier = ValueNotifier(0);
      final onError = ValueNotifier<Object>(42);
      final ref = FakeDocumentReference(notifier, errorListenable: onError);
      final error = UnimplementedError();
      var buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: FirestoreBuilder<bool>(
            ref: ref.select((snapshot) => snapshot.data.isEven),
            builder: (context, snapshot, child) {
              buildCount++;
              if (snapshot.hasError) return const Text('error');
              if (!snapshot.hasData) return const Text('loading');
              return Text('${snapshot.data}');
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(buildCount, 2);
      expect(find.text('true'), findsOneWidget);

      onError.value = error;
      await tester.pump();

      expect(buildCount, 3);
      expect(find.text('error'), findsOneWidget);

      onError.notifyListeners();
      await tester.pump();

      // rebuild even though the error didn't change
      expect(buildCount, 4);
      expect(find.text('error'), findsOneWidget);
    });

    testWidgets('after an error, selectors always rebuild', (tester) async {
      final notifier = ValueNotifier(0);
      final onError = ValueNotifier<Object>(42);
      final ref = FakeDocumentReference(notifier, errorListenable: onError);
      Object? error;
      var buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: FirestoreBuilder<bool>(
            ref: ref.select((snapshot) => snapshot.data.isEven),
            builder: (context, snapshot, child) {
              buildCount++;
              error = snapshot.error;
              if (snapshot.hasError) return const Text('error');
              if (!snapshot.hasData) return const Text('loading');
              return Text('${snapshot.data}');
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(buildCount, 2);
      expect(find.text('true'), findsOneWidget);

      onError.value = UnimplementedError();
      await tester.pump();

      expect(buildCount, 3);
      expect(find.text('error'), findsOneWidget);
      expect(error, isUnimplementedError);

      notifier.value = 2;
      await tester.pump();

      // rebild even though the last "data" was an even number too, because
      // we had an error in between
      expect(buildCount, 4);
      expect(find.text('true'), findsOneWidget);
    });

    testWidgets('supports document references', (tester) async {
      final notifier = ValueNotifier(0);
      final ref = FakeDocumentReference(notifier);

      await tester.pumpWidget(
        MaterialApp(
          home: FirestoreBuilder<FakeDocumentSnapshot<int>>(
            ref: ref,
            builder: (context, snapshot, child) {
              if (!snapshot.hasData) return const Text('loading');
              return Text('${snapshot.data!.data}');
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('0'), findsOneWidget);

      notifier.value = 42;

      await tester.pump();

      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('supports collection references', (tester) async {
      final notifier = ValueNotifier([0]);
      final ref = FakeCollectionReference(notifier);

      await tester.pumpWidget(
        MaterialApp(
          home: FirestoreBuilder<FakeQuerySnapshot<int>>(
            ref: ref,
            builder: (context, snapshot, child) {
              if (!snapshot.hasData) return const Text('loading');
              return ListView(
                children: [
                  for (final doc in snapshot.data!.docs)
                    Text(doc.data.toString()),
                ],
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('0'), findsOneWidget);

      notifier.value = [1, 42];

      await tester.pump();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });
  });
}
