@TestOn('vm')
import 'package:firebase/firebase_io.dart';
import 'package:firebase/src/consts.dart';
import 'package:test/test.dart';

import 'test_shared.dart';

Uri getTestUrl(int count, {DateTime timeKey}) => getTestUrlBase(
    <String>['test', testKey(timeKey), count.toString() + '.json']);

//TODO: add tests that validate security by having secured and insecure sections
void main() {
  int count = 0;
  group('get, put and post', () {
    test('without security', () async {
      var baseUri = getTestUrl(count++);

      var fbClient = new FirebaseClient.anonymous();

      var rootValue = await fbClient.get(baseUri);

      expect(rootValue, isNull);

      var putContent = {"name": "Alan Turing", "birthday": "June 23, 1912"};

      rootValue = await fbClient.put(baseUri, putContent);

      expect(rootValue, putContent);

      rootValue = await fbClient.get(baseUri);

      expect(rootValue, putContent);

      // TODO: Consider improving how we construct this new path.
      var postUri = Uri
          .parse('${baseUri.toString().split('.json').first}/interests.json');

      var interests = [
        {'name': 'Encryption', 'love-level': 10},
        {'name': 'Computer Science', 'love-level': 7}
      ];

      for (var interest in interests) {
        rootValue = await fbClient.post(postUri, interest);

        expect(rootValue, isMap);

        expect(rootValue['name'], isNotNull);
      }
    });

    test('with an admin secret', () async {
      var baseUri = getTestUrl(count++);

      var fbClient = new FirebaseClient(AUTH_TOKEN);

      var rootValue = await fbClient.get(baseUri);

      expect(rootValue, isNull);

      var putContent = {"name": "Alan Turing", "birthday": "June 23, 1912"};

      rootValue = await fbClient.put(baseUri, putContent);

      expect(rootValue, putContent);

      rootValue = await fbClient.get(baseUri);

      expect(rootValue, putContent);

      // TODO: Consider improving how we construct this new path.
      var postUri = Uri
          .parse('${baseUri.toString().split('.json').first}/interests.json');

      var interests = [
        {'name': 'Encryption', 'love-level': 10},
        {'name': 'Computer Science', 'love-level': 7}
      ];

      for (var interest in interests) {
        rootValue = await fbClient.post(postUri, interest);

        expect(rootValue, isMap);

        expect(rootValue['name'], isNotNull);
      }
    });

    test('with a token', () async {
      var baseUri = getTestUrl(count++);

      var firebaseToken = createFirebaseJwtToken(AUTH_TOKEN, admin: true);

      var fbClient = new FirebaseClient(firebaseToken);

      var rootValue = await fbClient.get(baseUri);

      expect(rootValue, isNull);

      var putContent = {"name": "Alan Turing", "birthday": "June 23, 1912"};

      rootValue = await fbClient.put(baseUri, putContent);

      expect(rootValue, putContent);

      rootValue = await fbClient.get(baseUri);

      expect(rootValue, putContent);

      // TODO: Consider improving how we construct this new path.
      var postUri = Uri
          .parse('${baseUri.toString().split('.json').first}/interests.json');

      var interests = [
        {'name': 'Encryption', 'love-level': 10},
        {'name': 'Computer Science', 'love-level': 7}
      ];

      for (var interest in interests) {
        rootValue = await fbClient.post(postUri, interest);

        expect(rootValue, isMap);

        expect(rootValue['name'], isNotNull);
      }
    });
  });

  test('delete', () async {
    var fbClient = new FirebaseClient(AUTH_TOKEN);

    var oldDate = new DateTime.now().subtract(const Duration(days: 2));
    var reallyOldDate = oldDate.subtract(const Duration(days: 2));

    var outdatedUri = getTestUrl(2, timeKey: reallyOldDate);

    await fbClient.put(outdatedUri, {'a': 'a'});

    var allTestOutput =
        await fbClient.get(getTestUrlBase(['test.json'])) as Map;

    expect(allTestOutput.length, greaterThanOrEqualTo(1));

    var deleteCount = 0;
    for (var item in allTestOutput.keys) {
      var date = parseTestKey(item);

      if (date.isBefore(oldDate)) {
        var url = getTestUrlBase(<String>['test', testKey(date) + '.json']);
        await fbClient.delete(url);
        deleteCount++;
      }
    }

    expect(deleteCount, greaterThanOrEqualTo(1));
  });

  group('invalid key chars', () {
    for (var char in invalidFirebaseKeyCharsAndStar) {
      test('validate encoding for invalid key char "$char"', () async {
        var baseUri = getTestUrl(count++);

        var fbClient = new FirebaseClient(AUTH_TOKEN);

        var rootValue = await fbClient.get(baseUri);

        expect(rootValue, isNull);

        var unencodedKey = 'key with $char';

        var putContent = {unencodedKey: "Alan Turing"};

        try {
          await fbClient.put(baseUri, putContent);
          fail('key with invalid char shoul fail');
        } catch (e) {
          // TODO: some verification
        }

        var encoded = encodeKey(unencodedKey);
        putContent = {encoded: "Alan Turing"};

        rootValue = await fbClient.put(baseUri, putContent);

        expect(rootValue, putContent);
      });
    }

    test('all invalid chars', () async {
      var baseUri = getTestUrl(count++);

      var encoded = encodeKey(invalidKeyString);

      var fbClient = new FirebaseClient(AUTH_TOKEN);

      var rootValue = await fbClient.get(baseUri);

      expect(rootValue, isNull);

      var putContent = {encoded: "Alan Turing"};

      rootValue = await fbClient.put(baseUri, putContent);

      expect(rootValue, putContent);

      rootValue = await fbClient.get(baseUri);

      expect(rootValue, putContent);

      var decoded = decodeKey(encoded);

      expect(decoded, invalidKeyString);
    });
  });
}
