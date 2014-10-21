import 'dart:async';

import 'package:firebase/firebase.dart';
import 'package:scheduled_test/scheduled_test.dart';
import 'package:unittest/html_config.dart';

const TEST_URL = 'https://dart-test.firebaseio-demo.com/test/';

// Update TEST_URL to a valid URL and update AUTH_KEY to a corresponding
// key to test authentication.
const AUTH_KEY = null;

const INVALID_TOKEN = 'xbKOOdkZDBExtKM3sZw6gWtFpGgqMkMidXCiAFjm';

final _dateKey = new DateTime.now().toUtc().toIso8601String();
final _testKey = '$_dateKey'.replaceAll(new RegExp(r'[\.]'), '_');

final _testUrl = TEST_URL + _testKey + '/';

void main() {
  useHtmlConfiguration();
  groupSep = ' - ';

  Firebase f;

  setUp(() {
    f = new Firebase(_testUrl);

    currentSchedule.onComplete.schedule(() {
      if (f != null) {
        f.unauth();
        f = null;
      }
    });
  });

  if (AUTH_KEY != null) {
    group('auth', () {
      test('bad auth should fail', () {
        expect(f.auth(INVALID_TOKEN), throwsA((error) {
          expect(error['code'], 'INVALID_TOKEN');
          return true;
        }));
      });

      test('good auth key', () {
        return f.auth(AUTH_KEY);
      });
    });
  }

  group('non-auth', () {
    test('child', () {
      var child = f.child('trad');
      expect(child.name, 'trad');

      var parent = child.parent();
      expect(parent.name, _testKey);

      var root = child.root();
      expect(root.name, isNull);
    });

    test('set', () {
      var value = {'number value': 42};
      return f.set(value).then((v) {
        // TODO: check the value?
      });
    });

    test('set string', () {
      var child = f.child('bar');
      return child.set('foo').then((foo) {
        // TODO: actually test result
      });
    });

    test('update', () {
      // TODO: not sure why this works and the string case does not
      return f.update({'update_works': 'oof'}).then((foo) {
        // TODO: actually test the result
      });
    });

    test('push', () {
      // TODO: actually validate the result
      var pushRef = f.push();
      return pushRef.set('HAHA');
    });

    test('priorities', () {
      // TODO: actually validate the result
      var testRef = f.child('ZZZ');
      return testRef.setWithPriority(1, 1).then((foo) {
        return testRef.setPriority(100);
      });
    });

    test('value', () {
      return f.onValue.first.then((Event e) {
        //TODO actually test the result
      });
    });
  });

  group('on', () {
    test('onChildChanged', () {
      Firebase testRef;
      var eventCount = 0;
      bool isDone = false;

      schedule(() {
        testRef = f.child('onChildChanged');
        testRef.onChildChanged.listen((event) {
          var ss = event.snapshot;
          expect(ss.name, 'key');

          eventCount++;

          expect(ss.val(), eventCount);
        });

        return testRef.set({'key': 0});
      });

      schedule(() {
        return testRef.set({'key': 1});
      });

      schedule(() {
        return testRef.set({'key': 2});
      });

      schedule(() {
        return testRef.set({'key': 3});
      });

      schedule(() {
        expect(eventCount, 3);
      });
    });
  });

  group('once', () {
    test('set a value and get', () {
      var testRef = f.child('once');

      testRef.once('child_added').then(expectAsync((value) {
        var ds = value as DataSnapshot;
        expect(ds.hasChildren, false);
        expect(ds.numChildren, 0);
        expect(ds.name, 'a');
        expect(ds.val(), 'b');
      }));

      return testRef.set({'a': 'b'});
    });
  });

  group('transaction', () {
    test('simple value, nothing exists', () {
      var testRef = f.child('tx1');
      return testRef.transaction((curVal) {
        expect(curVal, isNull);
        return 42;
      }).then((result) {
        expect(result.committed, isTrue);
        expect(result.error, isNull);

        var snapshot = result.snapshot;
        expect(snapshot.hasChildren, false);
        expect(snapshot.numChildren, 0);
        expect(snapshot.val(), 42);
      });
    });

    test('complex value, nothing exists', () {
      var value = const {'int': 42, 'bool': true, 'str': 'string'};
      var testRef = f.child('tx2');
      return testRef.transaction((curVal) {
        expect(curVal, isNull);
        return value;
      }).then((result) {
        expect(result.committed, isTrue);
        expect(result.error, isNull);

        var snapshot = result.snapshot;
        expect(snapshot.hasChildren, true);
        expect(snapshot.numChildren, 3);
        expect(snapshot.val(), value);
      });
    });

    test('simple value, existing value', () {
      var testRef = f.child('tx3');
      return testRef.set(42).then((_) {
        return testRef.transaction((curVal) {
          expect(curVal == null || curVal == 42, isTrue);
          return 43;
        });
      }).then((result) {
        expect(result.committed, isTrue);
        expect(result.error, isNull);

        var snapshot = result.snapshot;
        expect(snapshot.hasChildren, false);
        expect(snapshot.numChildren, 0);
        expect(snapshot.val(), 43);
      });
    });
  });
}
