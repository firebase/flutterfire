import 'dart:async';
import 'dart:js';

import 'package:firebase/firebase.dart';
import 'package:scheduled_test/scheduled_test.dart';
import 'package:unittest/html_config.dart';

const TEST_URL = 'https://dart-test.firebaseio-demo.com/test/';

// Update TEST_URL to a valid URL and update AUTH_TOKEN to a corresponding
// authentication token to test authentication.
const AUTH_TOKEN = null;
const INVALID_AUTH_TOKEN = 'xbKOOdkZDBExtKM3sZw6gWtFpGgqMkMidXCiAFjm';

// Update CREDENTIALS_EMAIL to an email address to test
// auth using email/password credentials.
// Unfortunately, createUser does not work with the firebaseio demo test URL,
// if you want to enable this, you will likely need to change TEST_URL to your own.
const CREDENTIALS_EMAIL = null;
const CREDENTIALS_PASSWORD = 'right';
const CREDENTIALS_WRONG_PASSWORD = 'wrong';

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

  if (AUTH_TOKEN != null) {
    group('authWithCustomToken', () {
      test('bad auth token should fail', () {
        expect(f.authWithCustomToken(INVALID_AUTH_TOKEN), throwsA((error) {
          expect(error['code'], 'INVALID_TOKEN');
          return true;
        }));
      });

      test('good auth token', () {
        return f.authWithCustomToken(AUTH_TOKEN);
      });
    });
  }

  group('authAnonymously', () {
    test('good auth', () {
      return f.authAnonymously().then((response) {
        expect(response.auth, isNotNull);
      });
    });

    test('good auth with custom remember', () {
      return f.authAnonymously(remember: "sessionOnly").then((response) {
        expect(response.auth, isNotNull);
      });
    });
  });
  
  if (CREDENTIALS_EMAIL != null) {
    group('auth-credentials', () {
      var credentials = {'email':CREDENTIALS_EMAIL,
        'password':CREDENTIALS_PASSWORD};
      var badCredentials = {'email':CREDENTIALS_EMAIL,
        'password':CREDENTIALS_WRONG_PASSWORD};

      test('auth-credentials', () {
        schedule(() {
          return f.createUser(credentials).then((err) {
            expect(err, null);
            f.authWithPassword(credentials).then((authResponse) {
              expect(authResponse.auth, isNotNull);
              expect(f.authWithPassword(badCredentials), throwsA((error) {
                expect(error['code'], 'INVALID_PASSWORD');
                f.removeUser(credentials).then((err) { expect(err, null); });
                return true;
              }));
            });
          });
        });
      });
    });

    group('createUser', () {
      test('createUser returns null on success', () {
        schedule(() {
          var credentials = {'email': 'createUserTest@example.com',
              'password': 'pswd'};
          return f.createUser(credentials).then((result) {
            expect(result, null);
            f.removeUser(credentials);
          });
        });
      });

      test('createUser throws error', () {
        schedule(() {
          var credentials = {'email': 'badEmailAddress',
              'password': 'pswd'};
          expect(f.createUser(credentials), throwsA((error) {
            expect(error['code'], 'INVALID_EMAIL');
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
        schedule(() {
          return f.createUser({'email': email, 'password': oldPassword}).then((result) {
            f.changePassword(changeCredentials).then((result) {
              expect(result, null);
              f.removeUser({'email': email, 'password': newPassword});
            });
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

        schedule(() {
          return f.createUser({'email': email, 'password': oldPassword}).then((result) {
            expect(f.changePassword(badCredentials), throwsA((error) {
              expect(error['code'], "INVALID_PASSWORD");
              f.removeUser({'email': email, 'password': oldPassword});
              return true;
            }));
          });
        });
      });
    });

    group('removeUser', () {
      test('removeUser returns null on success', () {
        var credentials = {'email': 'removeUserTest@example.com',
            'password': 'pswd'};
        schedule(() {
          return f.createUser(credentials).then((result) {
            f.removeUser(credentials).then((result) {
              expect(result, null);
            });
          });
        });
      });

      test('removeUser returns error', () {
        var credentials = {'email': 'removeUserNotExistsTest@example.com',
            'password': 'pswd'};
        schedule(() {
          expect(f.removeUser(credentials), throwsA((error) {
            expect(error['code'], 'INVALID_USER');
            return true;
          }));
        });
      });
    });

    group('resetPassword', () {
      test('resetPassword returns null on success', () {
        var password = 'pswd';
        var email = 'resetPasswordTest@example.com';

        schedule(() {
          var credentials = {'email': email, 'password': password};
          return f.createUser(credentials).then((result) {
            f.resetPassword({'email': email}).then((result) {
              expect(result, null);
              f.removeUser(credentials);
            });
          });
        });
      });

      test('resetPassword throws error', () {
        var email = 'resetEmailNotFound@example.com';
        schedule(() {
          expect(f.resetPassword({'email': email}), throwsA((error) {
            expect(error['code'], "INVALID_USER");
            return true;
          }));
        });
      });
    });

    group('getAuth', () {
      var credentials = {'email':CREDENTIALS_EMAIL,
          'password':CREDENTIALS_PASSWORD};

      test('getAuth when not authenticated', () {
        var response = f.getAuth();
        expect(response, isNull);
      });

      test('getAuth when authenticated', () {
        schedule(() {
          var credentials = {
              'email': 'getAuthUserTest@example.com',
              'password': 'pswd'
          };
          return f.createUser(credentials).then((_) {
            f.authWithPassword(credentials).then((_) {
              var response = f.getAuth();
              expect(response.auth, isNotNull);
              f.removeUser(credentials);
            });
          });
        });
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

  group('query', () {
    test('startAt', () {
      var child = f.child('query');

      schedule(() {
        var count = 0;
        return Future.doWhile(() {
          count++;
          return child.push().set(count).then((_) {
            return count < 10;
          });
        });
      });

      schedule(() {
        return child.startAt().once('value').then((snapshot) {
          var val = snapshot.val();
          expect(val, hasLength(10));
        });
      });

      schedule(() {
        return child.startAt().limit(5).once('value').then((snapshot) {
          var val = snapshot.val() as Map;
          expect(val.values, [1, 2, 3, 4, 5]);

          var lastKey = val.keys.last;

          return child.startAt(name: lastKey).limit(2).once('value');
        }).then((snapshot) {
          var val = snapshot.val() as Map;
          expect(val.values, [5, 6]);

          var lastKey = val.keys.last;

          return child.startAt(name: lastKey).once('value');
        }).then((snapshot) {
          var val = snapshot.val() as Map;
          expect(val.values, [6, 7, 8, 9, 10]);

          var lastKey = val.keys.last;
          expect(val[lastKey], 10);

          return child.startAt(name: lastKey).once('value');
        }).then((snapshot) {
          var val = snapshot.val() as Map;
          expect(val.values, [10]);
        });
      });
    });
  });

  group('on & off', () {

    List<String> addedKeys = [];
    test('onChildAdded', () {
      Firebase testRef;
      StreamSubscription<Event> subscription;
      var eventCount = 0;

      schedule(() {
        testRef = f.child('onChildAdded');
        subscription = testRef.onChildAdded.listen((event) {
          var ss = event.snapshot;
          addedKeys.add(ss.name);
          expect(++eventCount, lessThan(3));
          expect(ss.val(), eventCount);
        });

        return testRef.push(value: 1);
      });

      schedule(() {
        return testRef.push(value: 2);
      });

      schedule(() {
        Future waitFuture = subscription.cancel();
        if (waitFuture == null) {
          return testRef.push(value: 3);
        }
        else waitFuture.then((_) {
          return testRef.push(value: 3);
        });
      });
    });

    test('onChildChanged', () {
      Firebase testRef;
      StreamSubscription<Event> subscription;
      var eventCount = 0;

      schedule(() {
        testRef = f.child('onChildChanged');
        subscription = testRef.onChildChanged.listen((event) {
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
        Future waitFuture = subscription.cancel();
        if (waitFuture == null) {
          return testRef.set({'key': 3});
        }
        else waitFuture.then((_) {
          return testRef.set({'key': 3});
        });
      });

      schedule(() {
        expect(eventCount, 2);
      });
    });

    test('onChildRemoved', () {
      Firebase testRef;
      StreamSubscription<Event> onChildRemovedSubscription;
      int childRemovedCount = 0;

      schedule(() {
        testRef = f.child('onChildAdded');
        onChildRemovedSubscription = testRef.onChildRemoved.listen((event) {
          var ss = event.snapshot;
          expect(++childRemovedCount, 1);
          expect(ss.name, addedKeys[0]);
        });

        return testRef.child(addedKeys[0]).remove();
      });

      schedule(() {
        Future waitFuture = onChildRemovedSubscription.cancel();
        if (waitFuture == null) {
          return testRef.child(addedKeys[1]).remove();
        }
        else waitFuture.then((_) {
          return testRef.child(addedKeys[1]).remove();
        });
      });
    });

    test('onValue', () {
      Firebase testRef;
      StreamSubscription<Event> onValueSubscription;
      int valueCount = 0;

      schedule(() {
        testRef = f.child('onValue');
        onValueSubscription = testRef.onValue.listen((event) {
          var ss = event.snapshot;
          expect(ss.name, 'onValue');
          expect(ss.val(), {'key': ++valueCount});
          expect(valueCount, lessThan(3));
        });
        return testRef.set({'key': 1});
      });

      schedule(() {
        return testRef.update({'key': 2});
      });

      schedule(() {
        Future waitFuture = onValueSubscription.cancel();
        if (waitFuture == null) {
          return testRef.update({'key': 3});
        }
        else waitFuture.then((_) {
          return testRef.update({'key': 3});
        });
      });
    });

    test('value events triggered last', () {
      schedule(() {
        int numAdded = 0;
        var value = {
            'a':'b', 'c':'d', 'e':'f'
        };
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
