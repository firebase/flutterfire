@TestOn("browser")
library firebase.test;

import 'dart:async';

import 'package:firebase/firebase.dart';
import 'package:test/test.dart';

import 'test_shared.dart';

// Update CREDENTIALS_EMAIL to an email address to test
// auth using email/password credentials.
// Unfortunately, createUser does not work with the firebaseio demo test URL,
// if you want to enable this, you will likely need to change TEST_URL to your own.
const CREDENTIALS_EMAIL = null;
const CREDENTIALS_PASSWORD = 'right';
const CREDENTIALS_WRONG_PASSWORD = 'wrong';

const OAUTH_PROVIDER = null;
const OAUTH_TOKEN = null;

int _count = 0;

String getTestUrl(int count) =>
    getTestUrlBase(<String>['test', testKey(), count.toString()]).toString();

void main() {
  Firebase fbClient;
  String testUrl;

  setUp(() {
    _count++;
    testUrl = getTestUrl(_count);
    fbClient = new Firebase(testUrl);
  });

  tearDown(() {
    if (fbClient != null) {
      fbClient.unauth();
      fbClient = null;
    }
  });

  if (AUTH_TOKEN != null) {
    group('authWithCustomToken', () {
      test('bad auth token should fail', () {
        expect(fbClient.authWithCustomToken(INVALID_AUTH_TOKEN),
            throwsA((error) {
          expect(error['code'], 'INVALID_TOKEN');
          return true;
        }));
      });

      test('good auth token', () async {
        // per https://www.firebase.com/docs/web/api/firebase/authwithcustomtoken.html
        // should just succeed – nothing of interest in the return value
        await fbClient.authWithCustomToken(AUTH_TOKEN);
      });
    });
  }

  group('authAnonymously', () {
    void validateAuthResponse(Map response) {
      expect(response['uid'], isNotNull);
      expect(response['expires'], isNotNull);
      expect(response['auth']['uid'], isNotNull);
      expect(response['auth']['provider'], 'anonymous');
      expect(response['token'], isNotNull);
      expect(response['provider'], 'anonymous');
      expect(response['anonymous'], {});
    }

    test('good auth', () async {
      var response = await fbClient.authAnonymously();

      validateAuthResponse(response);
    });

    test('onAuth stream', () async {
      var onAuthStream = fbClient.onAuth();

      await fbClient.authAnonymously();

      var value = await onAuthStream.first;

      validateAuthResponse(value);
    });

    test('good auth with custom remember', () async {
      var response = await fbClient.authAnonymously(remember: 'sessionOnly');

      validateAuthResponse(response);
    });
  });

  if (CREDENTIALS_EMAIL != null) {
    group('auth-credentials', () {
      test('auth-credentials - good password', () {
        var credentials = {
          'email': CREDENTIALS_EMAIL,
          'password': CREDENTIALS_PASSWORD
        };
        return fbClient.createUser(credentials).then((res) {
          expect(res, isNotNull);
          return fbClient.authWithPassword(credentials).then((authResponse) {
            expect(authResponse['uid'], isNotNull);
            expect(authResponse['expires'], isNotNull);
            expect(authResponse['auth']['uid'], isNotNull);
            expect(authResponse['auth']['provider'], 'password');
            expect(authResponse['token'], isNotNull);
            expect(authResponse['provider'], 'password');
            expect(authResponse['password']['email'], CREDENTIALS_EMAIL);
            expect(authResponse['password']['isTemporaryPassword'], false);

            fbClient.removeUser(credentials).then((err) {
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
        return fbClient.createUser(credentials).then((res) {
          expect(res, isNotNull);

          expect(fbClient.authWithPassword(badCredentials), throwsA((error) {
            expect(error['code'], 'INVALID_PASSWORD');
            fbClient.removeUser(credentials).then((err) {
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
        return fbClient.createUser(credentials).then((result) {
          expect(result['uid'], isNotNull);
          fbClient.removeUser(credentials);
        });
      });

      test('createUser throws error', () {
        var credentials = {'email': 'badEmailAddress', 'password': 'pswd'};
        expect(fbClient.createUser(credentials), throwsA((error) {
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
        return fbClient
            .createUser({'email': email, 'password': password})
            .then((result) {
          fbClient.changeEmail(changeCredentials).then((result) {
            expect(result, null);
            fbClient.removeUser({'email': newEmail, 'password': password});
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

        return fbClient
            .createUser({'email': email, 'password': password})
            .then((result) {
          expect(fbClient.changeEmail(badCredentials), throwsA((error) {
            expect(error['code'], "INVALID_EMAIL");
            fbClient.removeUser({'email': email, 'password': password});
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
        return fbClient
            .createUser({'email': email, 'password': oldPassword})
            .then((result) {
          fbClient.changePassword(changeCredentials).then((result) {
            expect(result, null);
            fbClient.removeUser({'email': email, 'password': newPassword});
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

        return fbClient
            .createUser({'email': email, 'password': oldPassword})
            .then((result) {
          expect(fbClient.changePassword(badCredentials), throwsA((error) {
            expect(error['code'], "INVALID_PASSWORD");
            fbClient.removeUser({'email': email, 'password': oldPassword});
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
        return fbClient.createUser(credentials).then((result) {
          fbClient.removeUser(credentials).then((result) {
            expect(result, null);
          });
        });
      });

      test('removeUser returns error', () {
        var credentials = {
          'email': 'removeUserNotExistsTest@example.com',
          'password': 'pswd'
        };
        expect(fbClient.removeUser(credentials), throwsA((error) {
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
        return fbClient.createUser(credentials).then((result) {
          fbClient.resetPassword({'email': email}).then((result) {
            expect(result, null);
            fbClient.removeUser(credentials);
          });
        });
      });

      test('resetPassword throws error', () {
        var email = 'resetEmailNotFound@example.com';
        expect(fbClient.resetPassword({'email': email}), throwsA((error) {
          expect(error['code'], "INVALID_USER");
          return true;
        }));
      });
    });
  }

  if (OAUTH_PROVIDER != null && OAUTH_TOKEN != null) {
    group('authWithOAuthToken', () {
      test('good OAuth token', () {
        return fbClient
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
        expect(fbClient.authWithOAuthToken(OAUTH_PROVIDER, 'bad-auth-token'),
            throwsA((error) {
          expect(error['code'], 'INVALID_CREDENTIALS');
          return true;
        }));
      });
    });
  }

  group('getAuth', () {
    test('getAuth when not authenticated', () {
      var response = fbClient.getAuth();
      expect(response, isNull);
    });

    test('getAuth when authenticated', () {
      return fbClient.authAnonymously().then((_) {
        var response = fbClient.getAuth();
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
      var child = fbClient.child('trad');
      expect(child.key, 'trad');

      var parent = child.parent();
      expect(parent.key, _count.toString());

      var root = child.root();
      expect(root.key, isNull);
    });

    test('key returns last item name', () {
      expect(fbClient.key, _count.toString());
    });

    test('key returns null on root location', () {
      expect(fbClient.root().key, isNull);
    });

    test('toString returns the absolute url to ref location', () {
      // the firebase URI has ':' escaped – so reverse that
      expect(fbClient.toString().replaceAll('%3A', ':'), testUrl);
    });

    test('set', () {
      var value = {'number value': 42};
      return fbClient.set(value).then((v) {
        // TODO: check the value?
      });
    });

    test('set string', () {
      var child = fbClient.child('bar');
      return child.set('foo').then((foo) {
        // TODO: actually test result
      });
    });

    test('update', () {
      // TODO: not sure why this works and the string case does not
      return fbClient.update({'update_works': 'oof'}).then((foo) {
        // TODO: actually test the result
      });
    });

    test('push', () {
      // TODO: actually validate the result
      var pushRef = fbClient.push();
      return pushRef.set('HAHA');
    });

    test('push map', () async {
      var childAddedFuture = fbClient.onValue.first;

      var pushRef = fbClient.push(value: {'key': 'value'});

      await childAddedFuture;

      var snapshot = await pushRef.once('value');
      expect(snapshot.val()['key'], 'value');
    });

    test('push callback', () async {
      var completer = new Completer();
      fbClient.push(value: 4, onComplete: (error) => completer.complete(error));
      var result = await completer.future;
      expect(result, isNull);
    });

    test('priorities', () {
      // TODO: actually validate the result
      var testRef = fbClient.child('ZZZ');
      return testRef.setWithPriority(1, 1).then((foo) {
        return testRef.setPriority(100);
      });
    });

    test('value', () {
      return fbClient.onValue.first.then((Event e) {
        //TODO actually test the result
      });
    });
  });

  group('data-snapshot', () {
    test('exists returns true when data exists', () {
      fbClient.child('ds-exists').set({'thing': 'one'});
      return fbClient.child('ds-exists').once('value').then((snapshot) {
        expect(snapshot.exists, true);
      });
    });

    test('exists returns false when data doesnt exist', () {
      return fbClient.child('ds-no-exists').once("value").then((snapshot) {
        expect(snapshot.exists, false);
      });
    });

    test('val() returns dart representation', () {
      var expected = {'test_data': 'good'};
      fbClient.child('ds-val').set(expected);
      return fbClient.child('ds-val').once("value").then((snapshot) {
        expect(snapshot.val(), expected);
      });
    });

    test('snapshot returns child', () {
      var expected = {'test_data': 'good'};
      fbClient.child('ds-child/my-child').set(expected);
      return fbClient.child('ds-child').once("value").then((snapshot) {
        expect(snapshot.child('my-child').val(), expected);
      });
    });

    test('snapshot forEach on children', () {
      fbClient.child('ds-forEach/thing-one').setWithPriority(
          {'thing': 'one'}, 1);
      fbClient.child('ds-forEach/thing-two').setWithPriority(
          {'thing': 'two'}, 2);
      fbClient.child('ds-forEach/cat-hat').setWithPriority({'cat': 'hat'}, 3);
      return fbClient.child('ds-forEach').once("value").then((snapshot) {
        var items = [];
        snapshot.forEach((snapshot) {
          items.add(snapshot.key);
        });
        expect(items, ['thing-one', 'thing-two', 'cat-hat']);
      });
    });

    test('hasChild returns true when child exists', () {
      fbClient.child('ds-hasChild/thing-one').set({'thing': 'one'});
      return fbClient.child('ds-hasChild').once("value").then((snapshot) {
        expect(snapshot.hasChild("thing-one"), true);
      });
    });

    test('hasChild returns false when child doesnt exists', () {
      return fbClient.child('ds-no-hasChild').once("value").then((snapshot) {
        expect(snapshot.hasChild("thing-one"), false);
      });
    });

    test('hasChildren returns true when has any children', () {
      fbClient.child('ds-hasChildren/thing-one').set({'thing': 'one'});
      return fbClient.child('ds-hasChildren').once("value").then((snapshot) {
        expect(snapshot.hasChildren, true);
      });
    });

    test('hasChildren returns false when has no children', () {
      return fbClient.child('ds-no-hasChildren').once("value").then((snapshot) {
        expect(snapshot.hasChildren, false);
      });
    });

    test('key returns the key location', () {
      return fbClient.child('ds-key').once("value").then((snapshot) {
        expect(snapshot.key, 'ds-key');
      });
    });

    test('numChildren returns the number of children', () {
      fbClient.child('ds-numChildren/one').set("one");
      fbClient.child('ds-numChildren/two').set("two");
      fbClient.child('ds-numChildren/three').set("three");
      return fbClient.child('ds-numChildren').once("value").then((snapshot) {
        expect(snapshot.numChildren, 3);
      });
    });

    test('ref returns firebase reference for this snapshot', () {
      Firebase expected = fbClient.child('ds-ref');

      return expected.once('value').then((snapshot) {
        var ref = snapshot.ref();
        expect(ref.key, expected.key);
        expect(ref, new isInstanceOf<Firebase>());
      });
    });

    test('getPriority returns priority', () {
      fbClient.child('ds-priority').setWithPriority("thing", 4);
      return fbClient.child('ds-priority').once('value').then((snapshot) {
        expect(snapshot.getPriority(), 4);
      });
    });

    test('exportVal returns full data with priority', () {
      fbClient.child('ds-exportVal').setWithPriority("thing2", 500);
      return fbClient.child('ds-exportVal').once('value').then((snapshot) {
        expect(snapshot.exportVal(), {'.value': 'thing2', '.priority': 500});
      });
    });
  });

  group('query', () {
    test('orderByChild', () {
      fbClient.child('order-by-child/one/animal').set('aligator');
      fbClient.child('order-by-child/two/animal').set('zebra');
      fbClient.child('order-by-child/three/animal').set('monkey');

      return fbClient
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
      fbClient.child('order-by-key/zebra').set('three');
      fbClient.child('order-by-key/elephant').set('one');
      fbClient.child('order-by-key/monkey').set('two');

      return fbClient
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
      fbClient.child('order-by-value/football').set(20);
      fbClient.child('order-by-value/basketball').set(10);
      fbClient.child('order-by-value/baseball').set(15);

      return fbClient
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
      fbClient.child('order-by-priority/football').setWithPriority(
          'twenty', 20);
      fbClient.child('order-by-priority/basketball').setWithPriority('ten', 10);
      fbClient.child('order-by-priority/baseball').setWithPriority(
          'fifteen', 15);

      return fbClient
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
      fbClient.child('equalTo/football').set(20);
      fbClient.child('equalTo/basketball').set(10);
      fbClient.child('equalTo/soccer').set(15);
      fbClient.child('equalTo/baseball').set(15);

      return fbClient
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
      fbClient.child('equalTo/football').set(20);
      fbClient.child('equalTo/basketball').set(10);
      fbClient.child('equalTo/soccer').set(15);
      fbClient.child('equalTo/baseball').set(15);

      return fbClient
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
        var child = fbClient.child('startAt 1');

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
        var child = fbClient.child('startAt 2');
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
        fbClient.child('startAt/A/thing').set('1');
        fbClient.child('startAt/B/thing').set('2');
        fbClient.child('startAt/C/thing').set('3');
        fbClient.child('startAt/D/thing').set('4');

        return fbClient
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
        fbClient.child('startAt/key/A').set('1');
        fbClient.child('startAt/key/B').set('2');
        fbClient.child('startAt/key/C').set('3');
        fbClient.child('startAt/key/D').set('4');
        fbClient.child('startAt/key/E').set('5');

        return fbClient
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
        fbClient.child('startAt/priority/A').setWithPriority('one', 100);
        fbClient.child('startAt/priority/B').setWithPriority('two', 100);
        fbClient.child('startAt/priority/C').setWithPriority('three', 100);
        fbClient.child('startAt/priority/D').setWithPriority('four', 100);
        fbClient.child('startAt/priority/E').setWithPriority('one - A', 90);

        return fbClient
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
        var child = fbClient.child('endAt 1');

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
        var child = fbClient.child('endAt 2');
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
        fbClient.child('endAt/A/thing').set('1');
        fbClient.child('endAt/B/thing').set('2');
        fbClient.child('endAt/C/thing').set('3');
        fbClient.child('endAt/D/thing').set('4');

        return fbClient
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
        fbClient.child('endAt/key/A').set('1');
        fbClient.child('endAt/key/B').set('2');
        fbClient.child('endAt/key/C').set('3');
        fbClient.child('endAt/key/D').set('4');
        fbClient.child('endAt/key/E').set('5');

        return fbClient
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
        fbClient.child('endAt/priority/A').setWithPriority('one', 100);
        fbClient.child('endAt/priority/B').setWithPriority('two', 100);
        fbClient.child('endAt/priority/C').setWithPriority('three', 100);
        fbClient.child('endAt/priority/D').setWithPriority('four', 100);
        fbClient.child('endAt/priority/E').setWithPriority('one - A', 120);

        return fbClient
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
      fbClient.child('limitToFirst-test/one').setWithPriority('one', 1);
      fbClient.child('limitToFirst-test/two').setWithPriority('two', 2);
      fbClient.child('limitToFirst-test/three').setWithPriority('three', 3);

      return fbClient
          .child('limitToFirst-test')
          .limitToFirst(2)
          .once('value')
          .then((snapshot) {
        var val = snapshot.val() as Map;
        expect(val.values, ['one', 'two']);
      });
    });

    test('limitToLast', () {
      fbClient.child('limitToLast-test/one').setWithPriority('one', 1);
      fbClient.child('limitToLast-test/two').setWithPriority('two', 2);
      fbClient.child('limitToLast-test/three').setWithPriority('three', 3);

      return fbClient
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

      testRef = fbClient.child('onChildAdded');
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

      testRef = fbClient.child('onChildChanged');
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

      testRef = fbClient.child('onChildAdded');
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

      testRef = fbClient.child('onValue');
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
      Firebase testRef = fbClient.child("things");
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
      var testRef = fbClient.child('once');

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
      var testRef = fbClient.child('tx1');
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
      var testRef = fbClient.child('tx2');
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
      var testRef = fbClient.child('tx3');
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
    }, skip: 'The transaction does not complete when compiled to JS. '
        'https://github.com/firebase/firebase-dart/issues/52');
  });

  group('onDisconnect', () {
    test('set', () {
      var value = {'onDisconnect set': 1};
      return fbClient.onDisconnect.set(value).then((v) {
        // Unable to check value (value set upon disconnect.)
      });
    });

    test('setWithPriority', () {
      var priority = 1;
      var value = {'onDisconnect setWithPriority': 2};
      return fbClient.onDisconnect.setWithPriority(value, priority).then((v) {
        // Unable to check value (value set upon disconnect.)
      });
    });

    test('update', () {
      var value = {'onDisconnect update': 3};
      return fbClient.onDisconnect.update(value).then((v) {
        // Unable to check value (value updated upon disconnect.)
      });
    });

    test('remove', () {
      return fbClient.onDisconnect.remove().then((v) {
        // Unable to check value (value removed upon disconnect.)
      });
    });

    test('cancel', () {
      return fbClient.onDisconnect.cancel().then((v) {
        // TODO: confirm that queued set/update events are cancelled.
      });
    });
  });
}
