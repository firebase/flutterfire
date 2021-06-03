import 'package:drive/drive.dart' as drive;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';

final List<Map<String, Object>> testDocuments = [
  {'ref': 'one', 'value': 23},
  {'ref': 'two', 'value': 56},
  {'ref': 'three', 'value': 9},
  {'ref': 'four', 'value': 40}
];

void testsMain() {
  group('FirebaseDatabase', () {
    setUp(() async {
      await Firebase.initializeApp();
    });

    setUpAll(() async {
      final FirebaseDatabase database = FirebaseDatabase.instance;

      const String orderTestPath = 'ordered/';

      await Future.wait(testDocuments.map((map) {
        String child = map['ref']! as String;
        return database.reference().child('$orderTestPath/$child').set(map);
      }));
    });

    test('correct order returned from query', () async {
      Event event = await FirebaseDatabase.instance
          .reference()
          .child('ordered')
          .orderByChild('value')
          .onValue
          .first;

      final ordered = testDocuments.map((doc) => doc['value']! as int).toList();
      ordered.sort();

      final documents = event.snapshot.value.values
          .map((doc) => doc['value'] as int)
          .toList();

      expect(documents[0], ordered[0]);
      expect(documents[1], ordered[1]);
      expect(documents[2], ordered[2]);
      expect(documents[3], ordered[3]);
    });

    test('runTransaction', () async {
      final FirebaseDatabase database = FirebaseDatabase.instance;
      final DatabaseReference ref = database.reference().child('counter');

      await ref.set(0);

      final DataSnapshot snapshot = await ref.once();
      final int value = snapshot.value ?? 0;
      final TransactionResult transactionResult =
          await ref.runTransaction((MutableData mutableData) async {
        mutableData.value = (mutableData.value ?? 0) + 1;
        return mutableData;
      });

      expect(transactionResult.committed, true);
      expect(transactionResult.dataSnapshot!.value > value, true);
    });

    test('DataSnapshot supports null childKeys for maps', () async {
      // Regression test for https://github.com/FirebaseExtended/flutterfire/issues/6002

      final ref = FirebaseDatabase.instance.reference().child('counter');

      final transactionResult = await ref.runTransaction((mutableData) async {
        mutableData.value = {'v': 'vala'};
        return mutableData;
      });

      expect(transactionResult.committed, true);
      expect(
        transactionResult.dataSnapshot!.value,
        {'v': 'vala'},
      );
    });

    test('setPersistenceCacheSizeBytes Integer', () async {
      final FirebaseDatabase database = FirebaseDatabase.instance;

      await database.setPersistenceCacheSizeBytes(2147483647);
    });

    test('setPersistenceCacheSizeBytes Long', () async {
      final FirebaseDatabase database = FirebaseDatabase.instance;
      await database.setPersistenceCacheSizeBytes(2147483648);
    });

    test('get snapshot', () async {
      final dataSnapshot = await FirebaseDatabase.instance
          .reference()
          .child('ordered/one')
          .get();
      expect(dataSnapshot, isNot(null));
      expect(dataSnapshot!.key, 'one');
      expect(dataSnapshot.value['ref'], 'one');
      expect(dataSnapshot.value['value'], 23);
    });
  });
}

void main() => drive.main(testsMain);
