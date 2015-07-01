@TestOn("browser")
library firebase.test;

import 'dart:async';

import 'package:firebase/firebase.dart';
import 'package:test/test.dart';

const TEST_URL = 'https://boiling-fire-3310.firebaseio.com/test/';

// Update TEST_URL to a valid URL and update AUTH_TOKEN to a corresponding
// authentication token to test authentication.
const AUTH_TOKEN = '5KxwqxGbNU0Mrje2NGnSFJZsd3KaTVeUtcVhorMl';
const INVALID_AUTH_TOKEN = 'xbKOOdkZDBExtKM3sZw6gWtFpGgqMkMidXCiAFjm';

// Update CREDENTIALS_EMAIL to an email address to test
// auth using email/password credentials.
// Unfortunately, createUser does not work with the firebaseio demo test URL,
// if you want to enable this, you will likely need to change TEST_URL to your own.
const CREDENTIALS_EMAIL = null;
const CREDENTIALS_PASSWORD = 'right';
const CREDENTIALS_WRONG_PASSWORD = 'wrong';

const OAUTH_PROVIDER = null;
const OAUTH_TOKEN = null;

final _dateKey = new DateTime.now().toUtc().toIso8601String();
final _testKey = '$_dateKey'.replaceAll(new RegExp(r'[\.\:]'), '_');

String getTestUrl(int count) => new Uri(
    scheme: 'https',
    host: 'boiling-fire-3310.firebaseio.com',
    pathSegments: ['test', _testKey, count.toString()]).toString();

int _count = 0;

void main() {
  Firebase f;
  String testUrl;

  setUp(() {
    _count++;
    testUrl = getTestUrl(_count);
    f = new Firebase(testUrl);
  });

  tearDown(() {
    if (f != null) {
      f.unauth();
      f = null;
    }
  });

  if (AUTH_TOKEN != null) {
    group('authWithCustomToken', () {
      test('bad auth token should fail', () {
        expect(f.authWithCustomToken(INVALID_AUTH_TOKEN), throwsA((error) {
          expect(error['code'], 'INVALID_TOKEN');
          return true;
        }));
      });

      test('good auth token', () async {
        // per https://www.firebase.com/docs/web/api/firebase/authwithcustomtoken.html
        // should just succeed – nothing of interest in the return value
        await f.authWithCustomToken(AUTH_TOKEN);
      });
    });
  }

  group('authAnonymously', () {
    test('good auth', () {
      return f.authAnonymously().then((response) {
        expect(response['uid'], isNotNull);
        expect(response['expires'], isNotNull);
        expect(response['auth']['uid'], isNotNull);
        expect(response['auth']['provider'], 'anonymous');
        expect(response['token'], isNotNull);
        expect(response['provider'], 'anonymous');
        expect(response['anonymous'], {});
      });
    });

    test('good auth with custom remember', () {
      return f.authAnonymously(remember: "sessionOnly").then((response) {
        expect(response['uid'], isNotNull);
        expect(response['expires'], isNotNull);
        expect(response['auth']['uid'], isNotNull);
        expect(response['auth']['provider'], 'anonymous');
        expect(response['token'], isNotNull);
        expect(response['provider'], 'anonymous');
        expect(response['anonymous'], {});
      });
    });
  });

  if (CREDENTIALS_EMAIL != null) {
    group('auth-credentials', () {
      test('auth-credentials - good password', () {
        var credentials = {
          'email': CREDENTIALS_EMAIL,
          'password': CREDENTIALS_PASSWORD
        };
        return f.createUser(credentials).then((res) {
          expect(res, isNotNull);
          return f.authWithPassword(credentials).then((authResponse) {
            expect(authResponse['uid'], isNotNull);
            expect(authResponse['expires'], isNotNull);
            expect(authResponse['auth']['uid'], isNotNull);
            expect(authResponse['auth']['provider'], 'password');
            expect(authResponse['token'], isNotNull);
            expect(authResponse['provider'], 'password');
            expect(authResponse['password']['email'], CREDENTIALS_EMAIL);
            expect(authResponse['password']['isTemporaryPassword'], false);

            f.removeUser(credentials).then((err) {
              expect(err, null);
            });
          });
        });
      });

      test('auth-credentials - bad password', () {
        var credentials = {
          'email': 'badCredentialTest@example.com',
          'password': 'RIGHT'
        };
        var badCredentials = {
          'email': 'badCredentialTest@example.com',
          'password': 'WRONG'
        };
        return f.createUser(credentials).then((res) {
          expect(res, isNotNull);

          expect(f.authWithPassword(badCredentials), throwsA((error) {
            expect(error['code'], 'INVALID_PASSWORD');
            f.removeUser(credentials).then((err) {
              expect(err, null);
            });
            return true;
          }));
        });
      });
    });

    group('createUser', () {
      test('createUser returns user data on success', () {
        var credentials = {
          'email': 'createUserTest@example.com',
          'password': 'pswd'
        };
        return f.createUser(credentials).then((result) {
          expect(result['uid'], isNotNull);
          f.removeUser(credentials);
        });
      });

      test('createUser throws error', () {
        var credentials = {'email': 'badEmailAddress', 'password': 'pswd'};
        expect(f.createUser(credentials), throwsA((error) {
          expect(error['code'], 'INVALID_EMAIL');
          return true;
        }));
      });
    });

    group('changeEmail', () {
      var password = 'pswd';

      test('changeEmail returns null on success', () {
        var email = 'changeEmailTest@example.com';
        var newEmail = 'updatedEmailTest@example.com';
        var changeCredentials = {
          'oldEmail': email,
          'newEmail': newEmail,
          'password': password,
        };
        return f
            .createUser({'email': email, 'password': password})
            .then((result) {
          f.changeEmail(changeCredentials).then((result) {
            expect(result, null);
            f.removeUser({'email': newEmail, 'password': password});
          });
        });
      });

      test('changeEmail throws error', () {
        var email = 'changePasswordErrorTests@example.com';
        var badCredentials = {
          'oldEmail': email,
          'newEmail': 'invalid_email',
          'password': password,
        };

        return f
            .createUser({'email': email, 'password': password})
            .then((result) {
          expect(f.changeEmail(badCredentials), throwsA((error) {
            expect(error['code'], "INVALID_EMAIL");
            f.removeUser({'email': email, 'password': password});
            return true;
          }));
        });
      });
    });

    group('changePassword', () {
      var oldPassword = 'pswd';
      var newPassword = 'updatedPswd';

      test('changePassword returns null on success', () {
        var email = 'changePasswordTest@example.com';
        var changeCredentials = {
          'email': email,
          'oldPassword': oldPassword,
          'newPassword': newPassword
        };
        return f
            .createUser({'email': email, 'password': oldPassword})
            .then((result) {
          f.changePassword(changeCredentials).then((result) {
            expect(result, null);
            f.removeUser({'email': email, 'password': newPassword});
          });
        });
      });

      test('changePassword throws error', () {
        var email = 'changePasswordErrorTests@example.com';
        var badCredentials = {
          'email': email,
          'oldPassword': 'wrong',
          'newPassword': 'updated_password'
        };

        return f
            .createUser({'email': email, 'password': oldPassword})
            .then((result) {
          expect(f.changePassword(badCredentials), throwsA((error) {
            expect(error['code'], "INVALID_PASSWORD");
            f.removeUser({'email': email, 'password': oldPassword});
            return true;
          }));
        });
      });
    });

    group('removeUser', () {
      test('removeUser returns null on success', () {
        var credentials = {
          'email': 'removeUserTest@example.com',
          'password': 'pswd'
        };
        return f.createUser(credentials).then((result) {
          f.removeUser(credentials).then((result) {
            expect(result, null);
          });
        });
      });

      test('removeUser returns error', () {
        var credentials = {
          'email': 'removeUserNotExistsTest@example.com',
          'password': 'pswd'
        };
        expect(f.removeUser(credentials), throwsA((error) {
          expect(error['code'], 'INVALID_USER');
          return true;
        }));
      });
    });

    group('resetPassword', () {
      test('resetPassword returns null on success', () {
        var password = 'pswd';
        var email = 'resetPasswordTest@example.com';

        var credentials = {'email': email, 'password': password};
        return f.createUser(credentials).then((result) {
          f.resetPassword({'email': email}).then((result) {
            expect(result, null);
            f.removeUser(credentials);
          });
        });
      });

      test('resetPassword throws error', () {
        var email = 'resetEmailNotFound@example.com';
        expect(f.resetPassword({'email': email}), throwsA((error) {
          expect(error['code'], "INVALID_USER");
          return true;
        }));
      });
    });
  }

  if (OAUTH_PROVIDER != null && OAUTH_TOKEN != null) {
    group('authWithOAuthToken', () {
      test('good OAuth token', () {
        return f
            .authWithOAuthToken(OAUTH_PROVIDER, OAUTH_TOKEN)
            .then((authResponse) {
          expect(authResponse['uid'], isNotNull);
          expect(authResponse['expires'], isNotNull);
          expect(authResponse['auth']['uid'], isNotNull);
          expect(authResponse['auth']['provider'], OAUTH_PROVIDER);
          expect(authResponse['token'], isNotNull);
          expect(authResponse['provider'], OAUTH_PROVIDER);
          expect(authResponse[OAUTH_PROVIDER], isNotNull);
        });
      });

      test('bad OAuth token', () {
        expect(f.authWithOAuthToken(OAUTH_PROVIDER, 'bad-auth-token'),
            throwsA((error) {
          expect(error['code'], 'INVALID_CREDENTIALS');
          return true;
        }));
      });
    });
  }

  group('getAuth', () {
    test('getAuth when not authenticated', () {
      var response = f.getAuth();
      expect(response, isNull);
    });

    test('getAuth when authenticated', () {
      return f.authAnonymously().then((_) {
        var response = f.getAuth();
        expect(response['uid'], isNotNull);
        expect(response['expires'], isNotNull);
        expect(response['auth']['uid'], isNotNull);
        expect(response['auth']['provider'], 'anonymous');
        expect(response['token'], isNotNull);
        expect(response['provider'], 'anonymous');
        expect(response['anonymous'], {});
      });
    });
  });

  group('non-auth', () {
    test('child', () {
      var child = f.child('trad');
      expect(child.key, 'trad');

      var parent = child.parent();
      expect(parent.key, _count.toString());

      var root = child.root();
      expect(root.key, isNull);
    });

    test('key returns last item name', () {
      expect(f.key, _count.toString());
    });

    test('key returns null on root location', () {
      expect(f.root().key, isNull);
    });

    test('toString returns the absolute url to ref location', () {
      expect(f.toString(), testUrl);
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

  group('data-snapshot', () {
    test('exists returns true when data exists', () {
      f.child('ds-exists').set({'thing': 'one'});
      return f.child('ds-exists').once('value').then((snapshot) {
        expect(snapshot.exists, true);
      });
    });

    test('exists returns false when data doesnt exist', () {
      return f.child('ds-no-exists').once("value").then((snapshot) {
        expect(snapshot.exists, false);
      });
    });

    test('val() returns dart representation', () {
      var expected = {'test_data': 'good'};
      f.child('ds-val').set(expected);
      return f.child('ds-val').once("value").then((snapshot) {
        expect(snapshot.val(), expected);
      });
    });

    test('snapshot returns child', () {
      var expected = {'test_data': 'good'};
      f.child('ds-child/my-child').set(expected);
      return f.child('ds-child').once("value").then((snapshot) {
        expect(snapshot.child('my-child').val(), expected);
      });
    });

    test('snapshot forEach on children', () {
      f.child('ds-forEach/thing-one').setWithPriority({'thing': 'one'}, 1);
      f.child('ds-forEach/thing-two').setWithPriority({'thing': 'two'}, 2);
      f.child('ds-forEach/cat-hat').setWithPriority({'cat': 'hat'}, 3);
      return f.child('ds-forEach').once("value").then((snapshot) {
        var items = [];
        snapshot.forEach((snapshot) {
          items.add(snapshot.key);
        });
        expect(items, ['thing-one', 'thing-two', 'cat-hat']);
      });
    });

    test('hasChild returns true when child exists', () {
      f.child('ds-hasChild/thing-one').set({'thing': 'one'});
      return f.child('ds-hasChild').once("value").then((snapshot) {
        expect(snapshot.hasChild("thing-one"), true);
      });
    });

    test('hasChild returns false when child doesnt exists', () {
      return f.child('ds-no-hasChild').once("value").then((snapshot) {
        expect(snapshot.hasChild("thing-one"), false);
      });
    });

    test('hasChildren returns true when has any children', () {
      f.child('ds-hasChildren/thing-one').set({'thing': 'one'});
      return f.child('ds-hasChildren').once("value").then((snapshot) {
        expect(snapshot.hasChildren, true);
      });
    });

    test('hasChildren returns false when has no children', () {
      return f.child('ds-no-hasChildren').once("value").then((snapshot) {
        expect(snapshot.hasChildren, false);
      });
    });

    test('key returns the key location', () {
      return f.child('ds-key').once("value").then((snapshot) {
        expect(snapshot.key, 'ds-key');
      });
    });

    test('numChildren returns the number of children', () {
      f.child('ds-numChildren/one').set("one");
      f.child('ds-numChildren/two').set("two");
      f.child('ds-numChildren/three').set("three");
      return f.child('ds-numChildren').once("value").then((snapshot) {
        expect(snapshot.numChildren, 3);
      });
    });

    test('ref returns firebase reference for this snapshot', () {
      Firebase expected = f.child('ds-ref');

      return expected.once('value').then((snapshot) {
        var ref = snapshot.ref();
        expect(ref.key, expected.key);
        expect(ref, new isInstanceOf<Firebase>());
      });
    });

    test('getPriority returns priority', () {
      f.child('ds-priority').setWithPriority("thing", 4);
      return f.child('ds-priority').once('value').then((snapshot) {
        expect(snapshot.getPriority(), 4);
      });
    });

    test('exportVal returns full data with priority', () {
      f.child('ds-exportVal').setWithPriority("thing2", 500);
      return f.child('ds-exportVal').once('value').then((snapshot) {
        expect(snapshot.exportVal(), {'.value': 'thing2', '.priority': 500});
      });
    });
  });

  group('query', () {
    test('orderByChild', () {
      f.child('order-by-child/one/animal').set('aligator');
      f.child('order-by-child/two/animal').set('zebra');
      f.child('order-by-child/three/animal').set('monkey');

      return f
          .child('order-by-child')
          .orderByChild('animal')
          .once('value')
          .then((snapshot) {
        var items = [];
        snapshot.forEach((snapshot) {
          items.add(snapshot.val());
        });
        expect(items, [
          {'animal': 'aligator'},
          {'animal': 'monkey'},
          {'animal': 'zebra'},
        ]);
      });
    });

    test('orderByKey', () {
      f.child('order-by-key/zebra').set('three');
      f.child('order-by-key/elephant').set('one');
      f.child('order-by-key/monkey').set('two');

      return f
          .child('order-by-key')
          .orderByKey()
          .once('value')
          .then((snapshot) {
        var items = [];
        snapshot.forEach((snapshot) {
          items.add(snapshot.val());
        });
        expect(items, ['one', 'two', 'three']);
      });
    });

    test('orderByValue', () {
      f.child('order-by-value/football').set(20);
      f.child('order-by-value/basketball').set(10);
      f.child('order-by-value/baseball').set(15);

      return f
          .child('order-by-value')
          .orderByValue()
          .once('value')
          .then((snapshot) {
        var items = [];
        snapshot.forEach((snapshot) {
          items.add(snapshot.val());
        });
        expect(items, [10, 15, 20]);
      });
    });

    test('orderByPriority', () {
      f.child('order-by-priority/football').setWithPriority('twenty', 20);
      f.child('order-by-priority/basketball').setWithPriority('ten', 10);
      f.child('order-by-priority/baseball').setWithPriority('fifteen', 15);

      return f
          .child('order-by-priority')
          .orderByPriority()
          .once('value')
          .then((snapshot) {
        var items = [];
        snapshot.forEach((snapshot) {
          items.add(snapshot.val());
        });
        expect(items, ['ten', 'fifteen', 'twenty']);
      });
    });

    test('equalTo', () {
      f.child('equalTo/football').set(20);
      f.child('equalTo/basketball').set(10);
      f.child('equalTo/soccer').set(15);
      f.child('equalTo/baseball').set(15);

      return f
          .child('equalTo')
          .orderByValue()
          .equalTo(15)
          .once('value')
          .then((snapshot) {
        var val = snapshot.val();
        expect(val, {'soccer': 15, 'baseball': 15});
      });
    });

    test('equalTo with Key', () {
      f.child('equalTo/football').set(20);
      f.child('equalTo/basketball').set(10);
      f.child('equalTo/soccer').set(15);
      f.child('equalTo/baseball').set(15);

      return f
          .child('equalTo')
          .orderByValue()
          .equalTo(15, 'soccer')
          .once('value')
          .then((snapshot) {
        var val = snapshot.val();
        expect(val, {'soccer': 15});
      });
    });

    group('startAt', () {
      test('startAt starts at beginning when not specified', () async {
        var child = f.child('startAt 1');

        var count = 0;
        await Future.doWhile(() {
          count++;
          return child.push().set(count).then((_) {
            return count < 10;
          });
        });

        var snapshot = await child.startAt().once('value');

        var val = snapshot.val();
        expect(val, hasLength(10));
      });

      test('startAt returns items from starting point when ordering by value',
          () {
        var child = f.child('startAt 2');
        child.push().set(1);
        child.push().set(2);
        child.push().set(3);
        child.push().set(4);

        return child
            .startAt(value: 2)
            .orderByValue()
            .limitToFirst(2)
            .once('value')
            .then((snapshot) {
          var val = snapshot.val() as Map;
          expect(val.values, [2, 3]);
        });
      });

      test('startAt returns items when ordering by child', () {
        f.child('startAt/A/thing').set('1');
        f.child('startAt/B/thing').set('2');
        f.child('startAt/C/thing').set('3');
        f.child('startAt/D/thing').set('4');

        return f
            .child('startAt')
            .startAt(value: '3')
            .orderByChild('thing')
            .once('value')
            .then((snapshot) {
          var val = snapshot.val() as Map;
          expect(val.values, [{'thing': '3'}, {'thing': '4'}]);
        });
      });

      test('startAt returns items when ordering by key', () {
        f.child('startAt/key/A').set('1');
        f.child('startAt/key/B').set('2');
        f.child('startAt/key/C').set('3');
        f.child('startAt/key/D').set('4');
        f.child('startAt/key/E').set('5');

        return f
            .child('startAt/key')
            .startAt(value: 'C')
            .orderByKey()
            .limitToFirst(3)
            .once('value')
            .then((snapshot) {
          var val = snapshot.val() as Map;
          expect(val.values, ['3', '4', '5']);
        });
      });

      test('startAt returns items from key when ordering by priority', () {
        f.child('startAt/priority/A').setWithPriority('one', 100);
        f.child('startAt/priority/B').setWithPriority('two', 100);
        f.child('startAt/priority/C').setWithPriority('three', 100);
        f.child('startAt/priority/D').setWithPriority('four', 100);
        f.child('startAt/priority/E').setWithPriority('one - A', 90);

        return f
            .child('startAt/priority')
            .startAt(value: 100, key: 'C')
            .orderByPriority()
            .limitToFirst(3)
            .once('value')
            .then((snapshot) {
          var val = snapshot.val() as Map;
          expect(val.values, ['three', 'four']);
        });
      });
    });

    group('endAt', () {
      test('endAt ends at end when not specified', () async {
        var child = f.child('endAt 1');

        var count = 0;
        await Future.doWhile(() {
          count++;
          return child.push().set(count).then((_) {
            return count < 10;
          });
        });

        var snapshot = await child.endAt().once('value');
        var val = snapshot.val();
        expect(val, hasLength(10));
      });

      test('endAt returns items from end point when ordering by value', () {
        var child = f.child('endAt 2');
        child.push().set(1);
        child.push().set(2);
        child.push().set(3);
        child.push().set(4);

        return child
            .endAt(value: 2)
            .orderByValue()
            .limitToFirst(2)
            .once('value')
            .then((snapshot) {
          var val = snapshot.val() as Map;
          expect(val.values, [1, 2]);
        });
      });

      test('endAt returns items when ordering by child', () {
        f.child('endAt/A/thing').set('1');
        f.child('endAt/B/thing').set('2');
        f.child('endAt/C/thing').set('3');
        f.child('endAt/D/thing').set('4');

        return f
            .child('endAt')
            .endAt(value: '3')
            .orderByChild('thing')
            .once('value')
            .then((snapshot) {
          var val = snapshot.val() as Map;
          expect(val.values, [{'thing': '1'}, {'thing': '2'}, {'thing': '3'}]);
        });
      });

      test('endAt returns items when ordering by key', () {
        f.child('endAt/key/A').set('1');
        f.child('endAt/key/B').set('2');
        f.child('endAt/key/C').set('3');
        f.child('endAt/key/D').set('4');
        f.child('endAt/key/E').set('5');

        return f
            .child('endAt/key')
            .endAt(value: 'C')
            .orderByKey()
            .limitToFirst(3)
            .once('value')
            .then((snapshot) {
          var val = snapshot.val() as Map;
          expect(val.values, ['1', '2', '3']);
        });
      });

      test('endAt returns items from key when ordering by priority', () {
        f.child('endAt/priority/A').setWithPriority('one', 100);
        f.child('endAt/priority/B').setWithPriority('two', 100);
        f.child('endAt/priority/C').setWithPriority('three', 100);
        f.child('endAt/priority/D').setWithPriority('four', 100);
        f.child('endAt/priority/E').setWithPriority('one - A', 120);

        return f
            .child('endAt/priority')
            .endAt(value: 100, key: 'C')
            .orderByPriority()
            .once('value')
            .then((snapshot) {
          var val = snapshot.val() as Map;
          expect(val.values, ['one', 'two', 'three']);
        });
      });
    });

    test('limitToFirst', () {
      f.child('limitToFirst-test/one').setWithPriority('one', 1);
      f.child('limitToFirst-test/two').setWithPriority('two', 2);
      f.child('limitToFirst-test/three').setWithPriority('three', 3);

      return f
          .child('limitToFirst-test')
          .limitToFirst(2)
          .once('value')
          .then((snapshot) {
        var val = snapshot.val() as Map;
        expect(val.values, ['one', 'two']);
      });
    });

    test('limitToLast', () {
      f.child('limitToLast-test/one').setWithPriority('one', 1);
      f.child('limitToLast-test/two').setWithPriority('two', 2);
      f.child('limitToLast-test/three').setWithPriority('three', 3);

      return f
          .child('limitToLast-test')
          .limitToLast(2)
          .once('value')
          .then((snapshot) {
        var val = snapshot.val() as Map;
        expect(val.values, ['two', 'three']);
      });
    });
  });

  group('on & off', () {
    List<String> addedKeys = [];
    test('onChildAdded', () async {
      Firebase testRef;
      StreamSubscription<Event> subscription;
      var eventCount = 0;

      testRef = f.child('onChildAdded');
      subscription = testRef.onChildAdded.listen((event) {
        var ss = event.snapshot;
        addedKeys.add(ss.key);
        expect(++eventCount, lessThan(3));
        expect(ss.val(), eventCount);
      });

      await testRef.push(value: 1);

      await testRef.push(value: 2);

      await subscription.cancel();
      await testRef.push(value: 3);
    });

    test('onChildChanged', () async {
      Firebase testRef;
      StreamSubscription<Event> subscription;
      var eventCount = 0;

      testRef = f.child('onChildChanged');
      subscription = testRef.onChildChanged.listen((event) {
        var ss = event.snapshot;
        expect(ss.key, 'key');
        eventCount++;
        expect(ss.val(), eventCount);
      });

      await testRef.set({'key': 0});

      await testRef.set({'key': 1});

      await testRef.set({'key': 2});

      await subscription.cancel();
      await testRef.set({'key': 3});

      expect(eventCount, 2);
    });

    test('onChildRemoved', () async {
      Firebase testRef;
      StreamSubscription<Event> onChildRemovedSubscription;
      int childRemovedCount = 0;

      testRef = f.child('onChildAdded');
      onChildRemovedSubscription = testRef.onChildRemoved.listen((event) {
        var ss = event.snapshot;
        expect(++childRemovedCount, 1);
        expect(ss.key, addedKeys[0]);
      });

      await testRef.child(addedKeys[0]).remove();

      await onChildRemovedSubscription.cancel();
      await testRef.child(addedKeys[1]).remove();
    });

    test('onValue', () async {
      Firebase testRef;
      StreamSubscription<Event> onValueSubscription;
      int valueCount = 0;

      testRef = f.child('onValue');
      onValueSubscription = testRef.onValue.listen((event) {
        var ss = event.snapshot;
        expect(ss.key, 'onValue');
        expect(ss.val(), {'key': ++valueCount});
        expect(valueCount, lessThan(3));
      });
      await testRef.set({'key': 1});

      await testRef.update({'key': 2});

      await onValueSubscription.cancel();
      await testRef.update({'key': 3});
    });

    test('value events triggered last', () {
      int numAdded = 0;
      var value = {'a': 'b', 'c': 'd', 'e': 'f'};
      Firebase testRef = f.child("things");
      testRef.onValue.listen((Event event) {
        var ss = event.snapshot;
        expect(numAdded, 3);
        expect(ss.val(), value);
      });
      testRef.onChildAdded.listen((Event event) {
        numAdded++;
      });
      testRef.set(value);
    });
  });

  group('once', () {
    test('set a value and get', () {
      var testRef = f.child('once');

      testRef.once('child_added').then(expectAsync((value) {
        var ds = value as DataSnapshot;
        expect(ds.hasChildren, false);
        expect(ds.numChildren, 0);
        expect(ds.key, 'a');
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

    test('simple value, existing value', () async {
      var testRef = f.child('tx3');
      await testRef.set(42);

      var retryCount = 0;
      var result = await testRef.transaction((curVal) {
        // Not sure why we have to retry at all - hmm...
        expect(retryCount, lessThanOrEqualTo(1),
            reason: 'Should not have to retry more than once');

        if (curVal != 42) {
          retryCount++;
          return null;
        }

        return 43;
      });

      expect(result.committed, isTrue);
      expect(result.error, isNull);

      var snapshot = result.snapshot;
      expect(snapshot.hasChildren, false);
      expect(snapshot.numChildren, 0);
      expect(snapshot.val(), 43);
    });
  });

  group('onDisconnect', () {
    test('set', () {
      var value = {'onDisconnect set': 1};
      return f.onDisconnect.set(value).then((v) {
        // Unable to check value (value set upon disconnect.)
      });
    });

    test('setWithPriority', () {
      var priority = 1;
      var value = {'onDisconnect setWithPriority': 2};
      return f.onDisconnect.setWithPriority(value, priority).then((v) {
        // Unable to check value (value set upon disconnect.)
      });
    });

    test('update', () {
      var value = {'onDisconnect update': 3};
      return f.onDisconnect.update(value).then((v) {
        // Unable to check value (value updated upon disconnect.)
      });
    });

    test('remove', () {
      return f.onDisconnect.remove().then((v) {
        // Unable to check value (value removed upon disconnect.)
      });
    });

    test('cancel', () {
      return f.onDisconnect.cancel().then((v) {
        // TODO: confirm that queued set/update events are cancelled.
      });
    });
  });
}
