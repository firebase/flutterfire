// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// iOS and macOS abort on this exception. Android catches it, then reports
/// code `unknown` because `IllegalArgumentException` is not a Firestore
/// exception. The group asserts `invalid-argument`, which is the Windows
/// contract.
String? _invalidFieldNameSkipReason() {
  if (kIsWeb) {
    return null;
  }
  if (defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    return 'iOS and macOS do not catch FIRInvalidArgumentException';
  }
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'Android reports IllegalArgumentException as unknown, not invalid-argument';
  }
  return null;
}

void runInvalidFieldNameTests() {
  group('invalid document field names', () {
    late FirebaseFirestore firestore;

    setUpAll(() async {
      firestore = FirebaseFirestore.instance;
    });

    Matcher throwsInvalidField(String messageFragment) {
      return throwsA(
        isA<FirebaseException>()
            .having((error) => error.plugin, 'plugin', 'cloud_firestore')
            .having((error) => error.code, 'code', 'invalid-argument')
            .having(
              (error) => error.message,
              'message',
              contains(messageFragment),
            ),
      );
    }

    DocumentReference<Map<String, dynamic>> document(String name) {
      return firestore.doc('flutter-tests/$name');
    }

    test('set() rejects an empty field name', () async {
      final reference = document('invalid-field-set-empty');
      await reference.delete();

      await expectLater(
        reference.set(<String, dynamic>{'': 1}),
        throwsInvalidField('must not be empty'),
      );

      final snapshot = await reference.get();
      expect(snapshot.exists, isFalse);
    });

    test('set() rejects an empty field name nested in a map', () async {
      final reference = document('invalid-field-set-nested-empty');
      await reference.delete();

      await expectLater(
        reference.set(<String, dynamic>{
          'row': <String, dynamic>{'': 1},
        }),
        throwsInvalidField('must not be empty'),
      );

      final snapshot = await reference.get();
      expect(snapshot.exists, isFalse);
    });

    test('set() rejects a reserved field name', () async {
      final reference = document('invalid-field-set-reserved');
      await reference.delete();

      await expectLater(
        reference.set(<String, dynamic>{'__x__': 1}),
        throwsInvalidField('begin and end'),
      );

      final snapshot = await reference.get();
      expect(snapshot.exists, isFalse);
    });

    test(
      'set() rejects a field named __',
      () async {
        final reference = document('invalid-field-set-double-underscore');
        await reference.delete();

        await expectLater(
          reference.set(<String, dynamic>{'__': 1}),
          throwsInvalidField('begin and end'),
        );

        final snapshot = await reference.get();
        expect(snapshot.exists, isFalse);
      },
      skip: kIsWeb
          ? 'The JS SDK does not treat __ as a reserved field name'
          : null,
    );

    test('set() with merge rejects an empty field name', () async {
      final reference = document('invalid-field-set-merge-empty');
      await reference.set(<String, dynamic>{'ok': 1});

      await expectLater(
        reference.set(<String, dynamic>{'': 2}, SetOptions(merge: true)),
        throwsInvalidField('must not be empty'),
      );

      final snapshot = await reference.get();
      expect(snapshot.data(), <String, dynamic>{'ok': 1});
    });

    test('update() rejects a reserved field name', () async {
      final reference = document('invalid-field-update-reserved');
      await reference.set(<String, dynamic>{'ok': 1});

      await expectLater(
        reference.update(<String, dynamic>{'__x__': 2}),
        throwsInvalidField('begin and end'),
      );

      final snapshot = await reference.get();
      expect(snapshot.data(), <String, dynamic>{'ok': 1});
    });

    test(
      'batch.set() rejects an empty field name',
      () async {
        final reference = document('invalid-field-batch-set-empty');
        await reference.delete();

        await expectLater(() async {
          final batch = firestore.batch();
          batch.set(reference, <String, dynamic>{'': 1});
          await batch.commit();
        }(), throwsInvalidField('must not be empty'));

        final snapshot = await reference.get();
        expect(snapshot.exists, isFalse);
      },
      skip: kIsWeb
          ? 'The JS SDK throws from batch.set before commit, and that call is not converted to FirebaseException'
          : null,
    );

    test(
      'runTransaction set() rejects an empty field name',
      () async {
        final reference = document('invalid-field-transaction-set-empty');
        await reference.set(<String, dynamic>{'ok': 1});
        var attempts = 0;

        await expectLater(
          firestore.runTransaction((transaction) async {
            attempts += 1;
            transaction.set(reference, <String, dynamic>{'': 1});
          }, maxAttempts: 2),
          throwsInvalidField('must not be empty'),
        );
        expect(attempts, 1);

        final snapshot = await reference.get();
        expect(snapshot.data(), <String, dynamic>{'ok': 1});
      },
      skip: kIsWeb
          ? 'A JS error inside the transaction handler is rewrapped as a plain Error'
          : null,
    );

    test(
      'runTransaction update() rejects a reserved field name',
      () async {
        final reference = document('invalid-field-transaction-update-reserved');
        await reference.set(<String, dynamic>{'ok': 1});
        var attempts = 0;

        await expectLater(
          firestore.runTransaction((transaction) async {
            attempts += 1;
            transaction.update(reference, <String, dynamic>{'__x__': 2});
          }, maxAttempts: 2),
          throwsInvalidField('begin and end'),
        );
        expect(attempts, 1);

        final snapshot = await reference.get();
        expect(snapshot.data(), <String, dynamic>{'ok': 1});
      },
      skip: kIsWeb
          ? 'A JS error inside the transaction handler is rewrapped as a plain Error'
          : null,
    );

    test('a query value may use a reserved field name', () async {
      final query = firestore
          .collection('flutter-tests-invalid-field-query')
          .where('m', isEqualTo: <String, dynamic>{'__x__': 1});

      // Web accepts this value. The Windows client forwards it, and the
      // emulator rejects the reserved key. The plugin does not validate it.
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
        await expectLater(
          query.get(),
          throwsA(
            isA<FirebaseException>()
                .having((error) => error.plugin, 'plugin', 'cloud_firestore')
                .having((error) => error.code, 'code', 'invalid-argument')
                .having(
                  (error) => error.message,
                  'message',
                  contains('is reserved'),
                ),
          ),
        );
        return;
      }

      final snapshot = await query.get();
      expect(snapshot.docs, isEmpty);
    });
  }, skip: _invalidFieldNameSkipReason() ?? false);
}
