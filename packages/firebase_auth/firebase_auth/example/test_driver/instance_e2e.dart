// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'test_utils.dart';

void runInstanceTests() {
  group('$FirebaseAuth.instance', () {
    FirebaseAuth auth;

    // generate unique email address for test run
    String regularTestEmail = generateRandomEmail();
    String testPassword = TEST_PASSWORD;

    void commonSuccessCallback(currentUserCredential) async {
      var currentUser = currentUserCredential.user;

      expect(currentUser, isInstanceOf<Object>());
      expect(currentUser.uid, isInstanceOf<String>());
      expect(currentUser.email, equals(regularTestEmail));
      expect(currentUser.isAnonymous, isFalse);
      expect(currentUser.uid, equals(auth.currentUser.uid));

      var additionalUserInfo = currentUserCredential.additionalUserInfo;
      expect(additionalUserInfo, isInstanceOf<Object>());
      expect(additionalUserInfo.isNewUser, isFalse);

      await auth.signOut();
    }

    void ensureSignedIn() async {
      if (auth.currentUser == null) {
        try {
          await auth.createUserWithEmailAndPassword(
              email: regularTestEmail, password: testPassword);
        } catch (e) {
          if (e.code == 'email-already-in-use') {
            await auth.signInWithEmailAndPassword(
                email: regularTestEmail, password: testPassword);
          }
        }
      }
    }

    void ensureSignedOut() async {
      if (auth.currentUser != null) {
        await auth.signOut();
      }
    }

    setUpAll(() async {
      await Firebase.initializeApp();
      auth = FirebaseAuth.instance;
    });

    tearDownAll(() async {
      await ensureSignedIn();
      await auth.currentUser.delete();
    });

    group('authStateChanges()', () {
      test('calls callback with the current user and when auth state changes',
          () async {
        await ensureSignedIn();
        String uid = auth.currentUser.uid;

        Stream<User> stream = auth.authStateChanges();
        int call = 0;

        StreamSubscription subscription =
            stream.listen(expectAsync1((User user) {
          call++;
          if (call == 1) {
            expect(user.uid, equals(uid)); // initial user
          } else if (call == 2) {
            expect(user, isNull); // logged out
          } else if (call == 3) {
            expect(user.uid, isA<String>());
            expect(user.uid != uid, isTrue); // annonymous user
          } else {
            fail("Should not have been called");
          }
        }, count: 3, reason: "Stream should only have been called 3 times"));

        // Prevent race condition where signOut is called before the stream hits
        await auth.signOut();
        await auth.signInAnonymously();
        await subscription.cancel();
        await ensureSignedOut();
      });

      test('handles multiple subscribers', () async {
        await ensureSignedOut();

        Stream<User> stream = auth.authStateChanges();
        Stream<User> stream2 = auth.authStateChanges();

        StreamSubscription subscription =
            stream.listen(expectAsync1((User user) {}, count: 2));

        StreamSubscription subscription2 =
            stream2.listen(expectAsync1((User user) {}, count: 3));

        await ensureSignedIn();
        await subscription.cancel();
        await ensureSignedOut();
        await subscription2.cancel();
      });
    });

    group('idTokenChanges()', () {
      test('calls callback with the current user and when auth state changes',
          () async {
        await ensureSignedIn();
        String uid = auth.currentUser.uid;

        Stream<User> stream = auth.idTokenChanges();
        int call = 0;

        StreamSubscription subscription =
            stream.listen(expectAsync1((User user) {
          call++;
          if (call == 1) {
            expect(user.uid, equals(uid)); // initial user
          } else if (call == 2) {
            expect(user, isNull); // logged out
          } else if (call == 3) {
            expect(user.uid, isA<String>());
            expect(user.uid != uid, isTrue); // annonymous user
          } else {
            fail("Should not have been called");
          }
        }, count: 3, reason: "Stream should only have been called 3 times"));

        // Prevent race condition where signOut is called before the stream hits
        await auth.signOut();
        await auth.signInAnonymously();
        await subscription.cancel();
        await ensureSignedOut();
      });

      test('handles multiple subscribers', () async {
        await ensureSignedOut();

        Stream<User> stream = auth.idTokenChanges();
        Stream<User> stream2 = auth.idTokenChanges();

        StreamSubscription subscription =
            stream.listen(expectAsync1((User user) {}, count: 2));

        StreamSubscription subscription2 =
            stream2.listen(expectAsync1((User user) {}, count: 3));

        await ensureSignedIn();
        await subscription.cancel();
        await ensureSignedOut();
        await subscription2.cancel();
      });
    });

    group('currentUser', () {
      test('should return currentUser', () async {
        await ensureSignedIn();
        var currentUser = auth.currentUser;
        expect(currentUser, isA<User>());
      });
    });

    group('applyActionCode', () {
      test('throws if invalid code', () async {
        try {
          await auth.applyActionCode('!!!!!!');
          fail("Should have thrown");
        } on FirebaseException catch (e) {
          expect(e.code, equals("invalid-action-code"));
        } catch (e) {
          fail(e.toString());
        }
      });
    });

    group('checkActionCode()', () {
      test('throws on invalid code', () async {
        try {
          await auth.checkActionCode('!!!!!!');
          fail('Should have thrown');
        } on FirebaseException catch (e) {
          expect(e.code, equals("invalid-action-code"));
        } catch (e) {
          fail(e.toString());
        }
      });
    });

    group('confirmPasswordReset()', () {
      // How to test a valid code?

      test('throws on invalid code', () async {
        try {
          await auth.confirmPasswordReset(
              code: '!!!!!!', newPassword: 'thingamajig');
          fail('Should have thrown');
        } on FirebaseException catch (e) {
          expect(e.code, equals("invalid-action-code"));
        } catch (e) {
          fail((e.toString()));
        }
      });
    });

    group('createUserWithEmailAndPassword', () {
      test('should create a user with an email and password', () async {
        var email = generateRandomEmail();

        Function successCallback = (UserCredential newUserCredential) async {
          expect(newUserCredential.user, isA<User>());
          User newUser = newUserCredential.user;

          expect(newUser.uid, isA<String>());
          expect(newUser.email, equals(email));
          expect(newUser.emailVerified, isFalse);
          expect(newUser.isAnonymous, isFalse);
          expect(newUser.uid, equals(auth.currentUser.uid));

          var additionalUserInfo = newUserCredential.additionalUserInfo;
          expect(additionalUserInfo, isA<AdditionalUserInfo>());
          expect(additionalUserInfo.isNewUser, isTrue);

          await auth.currentUser?.delete();
        };

        await auth
            .createUserWithEmailAndPassword(
                email: email, password: testPassword)
            .then(successCallback);
      });

      test('fails if creating a user which already exists', () async {
        await ensureSignedIn();
        try {
          await auth.createUserWithEmailAndPassword(
              email: regularTestEmail, password: '123456');
          fail("Should have thrown FirebaseAuthException");
        } on FirebaseAuthException catch (e) {
          expect(e.code, equals('email-already-in-use'));
        } catch (e) {
          fail(e.toString());
        }
      });

      test('fails if creating a user with an invalid email', () async {
        await ensureSignedIn();
        try {
          await auth.createUserWithEmailAndPassword(
              email: '!!!!!', password: '123456');
          fail("Should have thrown FirebaseAuthException");
        } on FirebaseAuthException catch (e) {
          expect(e.code, equals('invalid-email'));
        } catch (e) {
          fail(e.toString());
        }
      });

      test('fails if creating a user if providing a weak password', () async {
        await ensureSignedIn();
        try {
          await auth.createUserWithEmailAndPassword(
              email: generateRandomEmail(), password: '1');
          fail("Should have thrown FirebaseAuthException");
        } on FirebaseAuthException catch (e) {
          expect(e.code, equals('weak-password'));
        } catch (e) {
          fail(e.toString());
        }
      });
    });

    group('fetchSignInMethodsForEmail()', () {
      test('should return password provider for an email address', () async {
        var providers = await auth.fetchSignInMethodsForEmail(regularTestEmail);
        print('PROVIDERS $providers');
        expect(providers, isList);
        expect(providers.contains('password'), isTrue);
      });

      test('should return empty array for a not found email', () async {
        var providers =
            await auth.fetchSignInMethodsForEmail(generateRandomEmail());

        expect(providers, isList);
        expect(providers, isEmpty);
      });

      test('throws for a bad email address', () async {
        try {
          await auth.fetchSignInMethodsForEmail('foobar');
          fail('Should have thrown');
        } on FirebaseAuthException catch (e) {
          expect(e.code, equals("invalid-email"));
        } catch (e) {
          fail(e.toString());
        }
      });
    });

    group('getRedirectResult()', () {
      test('throw an unimplemented error', () async {
        try {
          await auth.getRedirectResult();
          fail('Should have thrown');
        } catch (e) {
          expect(e, isInstanceOf<UnimplementedError>());
        }
      });
    }, skip: !kIsWeb);

    group('isSignInWithEmailLink()', () {
      test('throws if email link is null', () {
        expect(() => auth.isSignInWithEmailLink(null), throwsAssertionError);
      });
    });

    group('sendPasswordResetEmail()', () {
      test('should not error', () async {
        var email = generateRandomEmail();

        try {
          await auth.createUserWithEmailAndPassword(
              email: email, password: testPassword);

          await auth.sendPasswordResetEmail(email: email);
          await auth.currentUser.delete();
        } catch (e) {
          await auth.currentUser.delete();
          fail(e.toString());
        }
      });

      test('fails if the user could not be found', () async {
        try {
          await auth.sendPasswordResetEmail(email: 'does-not-exist@bar.com');
          fail('Should have thrown');
        } on FirebaseAuthException catch (e) {
          expect(e.code, equals('user-not-found'));
        } catch (e) {
          fail(e.toString());
        }
      });
    });

    group('sendSignInWithEmailLink()', () {
      test('should not error', () async {
        var email = generateRandomEmail();
        await auth.createUserWithEmailAndPassword(
            email: email, password: testPassword);

        var settings = ActionCodeSettings(url: 'http://localhost');
        try {
          await auth.sendSignInWithEmailLink(
              email: email, actionCodeSettings: settings);
          await auth.currentUser.delete();
        } catch (e) {
          await auth.currentUser.delete();
          fail(e.toString());
        }
      });

      //   test('throws if invalid continue url', () async {
      //     var email = generateRandomEmail();
      //     await auth.createUserWithEmailAndPassword(
      //         email: email, password: testPassword);

      //     var settings = ActionCodeSettings(url: '');
      //     try {
      //       await auth.sendSignInWithEmailLink(
      //           email: email, actionCodeSettings: settings);
      //       await auth.currentUser.delete();
      //       fail('Should have thrown');
      //     } on FirebaseException catch (e) {
      //       await auth.currentUser.delete();
      //       expect(e.code, isNotNull);
      //       expect(e.message, isNotNull);
      //     } catch (e) {
      //       await auth.currentUser.delete();
      //       fail(e.toString());
      //     }
      //   });
    });

    group('languageCode', () {
      test('should change the language code', () async {
        await auth.setLanguageCode('en');

        expect(auth.languageCode, equals('en'));
      });
    });

    group('setPersistence()', () {
      test('throw an unimplemented error', () async {
        try {
          await auth.setPersistence(Persistence.LOCAL);
          fail('Should have thrown');
        } catch (e) {
          expect(e, isInstanceOf<UnimplementedError>());
        }
      }, skip: !kIsWeb);
    });

    group('signInAnonymously()', () {
      test('should sign in anonymously', () async {
        Function successCallback =
            (UserCredential currentUserCredential) async {
          var currentUser = currentUserCredential.user;

          expect(currentUser, isA<User>());
          expect(currentUser.uid, isA<String>());
          expect(currentUser.email, isNull);
          expect(currentUser.isAnonymous, isTrue);
          expect(currentUser.uid, equals(auth.currentUser.uid));

          var additionalUserInfo = currentUserCredential.additionalUserInfo;
          expect(additionalUserInfo, isInstanceOf<Object>());

          await auth.signOut();
        };

        await auth.signInAnonymously().then(successCallback);
      });
    });

    group('signInWithCredential()', () {
      test('should login with email and password', () async {
        var credential =
            EmailAuthProvider.credential(regularTestEmail, testPassword);
        await auth.signInWithCredential(credential).then(commonSuccessCallback);
      });

      test('throws if login user is disabled', () async {
        var credential =
            EmailAuthProvider.credential('disabled@account.com', 'test1234');

        try {
          await auth.signInWithCredential(credential);
          fail('Should have thrown');
        } on FirebaseException catch (e) {
          expect(e.code, equals("user-disabled"));
          expect(
              e.message,
              equals(
                  "The user account has been disabled by an administrator."));
        } catch (e) {
          fail((e.toString()));
        }
      });

      test('throws if login password is incorrect', () async {
        var credential =
            EmailAuthProvider.credential(regularTestEmail, 'sowrong');
        try {
          await auth.signInWithCredential(credential);
          fail('Should have thrown');
        } on FirebaseException catch (e) {
          expect(e.code, equals("wrong-password"));
          expect(
              e.message,
              equals(
                  "The password is invalid or the user does not have a password."));
        } catch (e) {
          fail((e.toString()));
        }
      });

      test('throws if login user is not found', () async {
        var credential =
            EmailAuthProvider.credential(generateRandomEmail(), testPassword);
        try {
          await auth.signInWithCredential(credential);
          fail('Should have thrown');
        } on FirebaseException catch (e) {
          expect(e.code, equals("user-not-found"));
          expect(
              e.message,
              equals(
                  "There is no user record corresponding to this identifier. The user may have been deleted."));
        } catch (e) {
          fail((e.toString()));
        }
      });
    });

    // group('signInWithCustomToken()', () {
    //   test('signs in with custom auth token', () async {
    //     var customUID = 'zdwHCjbpzraRoNK7d64FYWv5AH02';
    //     // TODO: create custom token
    //     var claims = {
    //       'roles': [
    //         {'role': 'member'},
    //         {'role': 'admin'}
    //       ]
    //     };
    //     var token = 'foo.bar.baz';
    //     var userCredential = await auth.signInWithCustomToken(token);

    //     expect(userCredential.user.uid, equals(customUID));
    //     expect(auth.currentUser.uid, equals(customUID));

    //     var idTokenResult = await auth.currentUser.getIdTokenResult(true);
    //     expect(idTokenResult.claims['roles'], isList);

    //     await auth.signOut();
    //   });
    // });

    group('signInWithEmailAndPassword()', () {
      test('should login with email and password', () async {
        await auth
            .signInWithEmailAndPassword(
                email: regularTestEmail, password: testPassword)
            .then(commonSuccessCallback);
      });

      test('throws if login user is disabled', () async {
        var email = 'disabled@account.com';
        var password = 'test1234';

        try {
          await auth.signInWithEmailAndPassword(
              email: email, password: password);
          fail('Should have thrown');
        } on FirebaseException catch (e) {
          expect(e.code, equals("user-disabled"));
          expect(
              e.message,
              equals(
                  "The user account has been disabled by an administrator."));
        } catch (e) {
          fail((e.toString()));
        }
      });

      test('throws if login password is incorrect', () async {
        try {
          await auth.signInWithEmailAndPassword(
              email: regularTestEmail, password: 'sowrong');
          fail('Should have thrown');
        } on FirebaseException catch (e) {
          expect(e.code, equals("wrong-password"));
          expect(
              e.message,
              equals(
                  "The password is invalid or the user does not have a password."));
        } catch (e) {
          fail((e.toString()));
        }
      });

      test('throws if login user is not found', () async {
        try {
          await auth.signInWithEmailAndPassword(
              email: generateRandomEmail(), password: testPassword);
          fail('Should have thrown');
        } on FirebaseException catch (e) {
          expect(e.code, equals("user-not-found"));
          expect(
              e.message,
              equals(
                  "There is no user record corresponding to this identifier. The user may have been deleted."));
        } catch (e) {
          fail((e.toString()));
        }
      });
    });

    // group('signInWithEmailAndLink()', () {
    //   // TODO: tests
    // });

    group('signInWithPopup()', () {
      test('throws an unimplemented error', () async {
        try {
          FacebookAuthProvider facebookProvider = FacebookAuthProvider();
          facebookProvider.addScope('user_birthday');
          facebookProvider.setCustomParameters({
            'display': 'popup',
          });

          await auth.signInWithPopup(facebookProvider);
        } catch (e) {
          expect(e, isInstanceOf<UnimplementedError>());
        }
      }, skip: !kIsWeb);
    });

    group('signInWithRedirect()', () {
      test('throws an unimplemented error', () async {
        try {
          FacebookAuthProvider facebookProvider = FacebookAuthProvider();
          facebookProvider.addScope('user_birthday');
          facebookProvider.setCustomParameters({
            'display': 'popup',
          });

          await auth.signInWithRedirect(facebookProvider);
        } catch (e) {
          expect(e, isInstanceOf<UnimplementedError>());
        }
      }, skip: !kIsWeb);
    });

    group('signOut()', () {
      test('should sign out', () async {
        await ensureSignedIn();
        expect(auth.currentUser, isA<User>());
        await auth.signOut();
        expect(auth.currentUser, isNull);
      });
    });

    group('verifyPasswordResetCode()', () {
      test('throws on invalid code', () async {
        try {
          await auth.verifyPasswordResetCode('!!!!!!');
          fail('Should have thrown');
        } on FirebaseException catch (e) {
          expect(e.code, equals("invalid-action-code"));
        } catch (e) {
          fail(e.toString());
        }
      });
    });

    // group('verifyPhoneNumber()', () {
    //   // TODO: tests
    // });
  });
}
