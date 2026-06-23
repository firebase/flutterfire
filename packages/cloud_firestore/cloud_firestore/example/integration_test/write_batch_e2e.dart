// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void runWriteBatchTests() {
  group('$WriteBatch', () {
    late FirebaseFirestore firestore;

    setUpAll(() async {
      firestore = FirebaseFirestore.instance;
    });

    Future<CollectionReference<Map<String, dynamic>>> initializeTest(
      String id,
    ) async {
      CollectionReference<Map<String, dynamic>> collection =
          firestore.collection('flutter-tests/$id/query-tests');
      QuerySnapshot<Map<String, dynamic>> snapshot = await collection.get();

      await Future.forEach(snapshot.docs, (
        DocumentSnapshot<Map<String, dynamic>> documentSnapshot,
      ) {
        return documentSnapshot.reference.delete();
      });
      return collection;
    }

    test('works with withConverter', () async {
      CollectionReference<Map<String, dynamic>> collection =
          await initializeTest('with-converter-batch');
      WriteBatch batch = firestore.batch();

      DocumentReference<int> doc = collection.doc('doc1').withConverter(
            fromFirestore: (snapshot, options) {
              return snapshot.data()!['value'] as int;
            },
            toFirestore: (value, options) => {'value': value},
          );

      var snapshot = await doc.get();

      expect(snapshot.exists, false);

      batch.set<int>(doc, 42);

      await batch.commit();
      snapshot = await doc.get();

      expect(snapshot.exists, true);
      expect(snapshot.data(), 42);

      batch = firestore.batch();
      batch.update(doc, {'value': 21});

      await batch.commit();
      snapshot = await doc.get();

      expect(snapshot.exists, true);
      expect(snapshot.data(), 21);

      batch = firestore.batch();
      batch.delete(doc);

      await batch.commit();
      snapshot = await doc.get();

      expect(snapshot.exists, false);
    });

    test('updates with typed data through withConverter', () async {
      CollectionReference<Map<String, dynamic>> collection =
          await initializeTest('with-converter-batch-update');
      WriteBatch batch = firestore.batch();

      DocumentReference<int> doc = collection.doc('doc1').withConverter(
            fromFirestore: (snapshot, options) {
              return snapshot.data()!['value'] as int;
            },
            toFirestore: (value, options) => {'value': value},
          );

      await doc.set(42);

      batch.update<int>(doc, 21);

      await batch.commit();

      DocumentSnapshot<int> snapshot = await doc.get();
      expect(snapshot.exists, isTrue);
      expect(snapshot.data(), 21);
    });

    test('updates complex typed data through withConverter', () async {
      CollectionReference<Map<String, dynamic>> collection =
          await initializeTest('with-converter-complex-batch-update');
      DocumentReference<Map<String, dynamic>> rawDoc = collection.doc('doc1');
      DocumentReference<_WriteBatchProfile> doc = rawDoc.withConverter(
        fromFirestore: (snapshot, options) {
          return _WriteBatchProfile.fromFirestore(snapshot.data()!);
        },
        toFirestore: (value, options) => value.toFirestore(),
      );

      await rawDoc.set({
        'existing': 'preserved',
        'name': 'before',
      });

      WriteBatch batch = firestore.batch();
      batch.update<_WriteBatchProfile>(
        doc,
        _WriteBatchProfile(
          name: 'Ada',
          score: 42,
          address: _WriteBatchAddress(city: 'London', postcode: 'NW1'),
          tags: ['admin', 'tester'],
          preferences: {
            'email': true,
            'theme': 'dark',
          },
          nickname: null,
        ),
      );

      await batch.commit();

      DocumentSnapshot<Map<String, dynamic>> rawSnapshot = await rawDoc.get();
      expect(rawSnapshot.data(), {
        'existing': 'preserved',
        'name': 'Ada',
        'score': 42,
        'address': {
          'city': 'London',
          'postcode': 'NW1',
        },
        'tags': ['admin', 'tester'],
        'preferences': {
          'email': true,
          'theme': 'dark',
        },
        'nickname': null,
      });

      DocumentSnapshot<_WriteBatchProfile> snapshot = await doc.get();
      _WriteBatchProfile profile = snapshot.data()!;
      expect(profile.name, 'Ada');
      expect(profile.score, 42);
      expect(profile.address.city, 'London');
      expect(profile.address.postcode, 'NW1');
      expect(profile.tags, ['admin', 'tester']);
      expect(profile.preferences, {
        'email': true,
        'theme': 'dark',
      });
      expect(profile.nickname, isNull);
    });

    test('should update a document using FieldPath keys', () async {
      CollectionReference<Map<String, dynamic>> collection =
          await initializeTest('write-batch-field-path');
      DocumentReference<Map<String, dynamic>> doc = collection.doc('doc1');

      await doc.set({
        'nested': {'field': 'old_value'},
        'top': 'value',
      });

      WriteBatch batch = firestore.batch();
      batch.update(doc, {
        FieldPath(const ['nested', 'field']): 'new_value',
      });
      await batch.commit();

      DocumentSnapshot<Map<String, dynamic>> snapshot = await doc.get();
      expect(snapshot.exists, isTrue);
      expect(snapshot.data()!['nested']['field'], equals('new_value'));
      expect(snapshot.data()!['top'], equals('value'));
    });

    test('performs batch operations', () async {
      CollectionReference<Map<String, dynamic>> collection =
          await initializeTest('write-batch-ops');
      WriteBatch batch = firestore.batch();

      DocumentReference<Map<String, dynamic>> doc1 =
          collection.doc('doc1'); // delete
      DocumentReference<Map<String, dynamic>> doc2 =
          collection.doc('doc2'); // set
      DocumentReference<Map<String, dynamic>> doc3 =
          collection.doc('doc3'); // update
      DocumentReference<Map<String, dynamic>> doc4 =
          collection.doc('doc4'); // update w/ merge
      DocumentReference<Map<String, dynamic>> doc5 =
          collection.doc('doc5'); // update w/ mergeFields

      await Future.wait([
        doc1.set({'foo': 'bar'}),
        doc2.set({'foo': 'bar'}),
        doc3.set({'foo': 'bar', 'bar': 'baz'}),
        doc4.set({'foo': 'bar'}),
        doc5.set({'foo': 'bar', 'bar': 'baz'}),
      ]);

      batch.delete(doc1);
      batch.set(doc2, <String, dynamic>{'bar': 'baz'});
      batch.update(doc3, <String, dynamic>{'bar': 'ben'});
      batch.set(doc4, <String, dynamic>{'bar': 'ben'}, SetOptions(merge: true));

      batch.set(
        doc5,
        <String, dynamic>{'bar': 'ben'},
        SetOptions(mergeFields: ['bar']),
      );

      await batch.commit();

      QuerySnapshot<Map<String, dynamic>> snapshot = await collection.get();

      expect(snapshot.docs.length, equals(4));
      expect(snapshot.docs.where((doc) => doc.id == 'doc1').isEmpty, isTrue);
      expect(
        snapshot.docs.firstWhere((doc) => doc.id == 'doc2').data(),
        equals(<String, dynamic>{'bar': 'baz'}),
      );
      expect(
        snapshot.docs.firstWhere((doc) => doc.id == 'doc3').data(),
        equals(<String, dynamic>{'foo': 'bar', 'bar': 'ben'}),
      );
      expect(
        snapshot.docs.firstWhere((doc) => doc.id == 'doc4').data(),
        equals(<String, dynamic>{'foo': 'bar', 'bar': 'ben'}),
      );

      expect(
        snapshot.docs.firstWhere((doc) => doc.id == 'doc5').data(),
        equals(<String, dynamic>{'foo': 'bar', 'bar': 'ben'}),
      );
    });
  });
}

class _WriteBatchProfile {
  _WriteBatchProfile({
    required this.name,
    required this.score,
    required this.address,
    required this.tags,
    required this.preferences,
    required this.nickname,
  });

  factory _WriteBatchProfile.fromFirestore(Map<String, dynamic> data) {
    return _WriteBatchProfile(
      name: data['name'] as String,
      score: data['score'] as int,
      address: _WriteBatchAddress.fromFirestore(
        data['address'] as Map<String, dynamic>,
      ),
      tags: (data['tags'] as List<dynamic>).cast<String>(),
      preferences: Map<String, Object?>.from(data['preferences'] as Map),
      nickname: data['nickname'] as String?,
    );
  }

  final String name;
  final int score;
  final _WriteBatchAddress address;
  final List<String> tags;
  final Map<String, Object?> preferences;
  final String? nickname;

  Map<String, Object?> toFirestore() {
    return {
      'name': name,
      'score': score,
      'address': address.toFirestore(),
      'tags': tags,
      'preferences': preferences,
      'nickname': nickname,
    };
  }
}

class _WriteBatchAddress {
  _WriteBatchAddress({
    required this.city,
    required this.postcode,
  });

  factory _WriteBatchAddress.fromFirestore(Map<String, dynamic> data) {
    return _WriteBatchAddress(
      city: data['city'] as String,
      postcode: data['postcode'] as String,
    );
  }

  final String city;
  final String postcode;

  Map<String, Object?> toFirestore() {
    return {
      'city': city,
      'postcode': postcode,
    };
  }
}
