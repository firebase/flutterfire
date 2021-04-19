// @dart = 2.9

// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.9

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedantic/pedantic.dart';
import './test_utils.dart';

void runInstanceTests() {
  group('$FirebaseAuth.instance', () {
    /*late*/ FirebaseAuth auth;

    // generate unique email address for test run
    String regularTestEmail = generateRandomEmail();

    Future<void> commonSuccessCallback(currentUserCredential) async {
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

    setUpAll(() async {
      await Firebase.initializeApp();
      await FirebaseAuth.instance
          .setSettings(appVerificationDisabledForTesting: true);
      auth = FirebaseAuth.instance;
    });

    tearDownAll(() async {
      await ensureSignedIn(regularTestEmail);
      await auth.currentUser.delete();
    });

    group('authStateChanges()', () {
      /*late*/ StreamSubscription subscription;
      StreamSubscription /*?*/ subscription2;

      tearDown(() async {
        await subscription?.cancel();
        await ensureSignedOut();

        if (subscription2 != null) {
          await Future.delayed(const Duration(seconds: 5));
          await subscription2.cancel();
        }
      });
      test('calls callback with the current user and when auth state changes',
          () async {
        await ensureSignedIn(regularTestEmail);
        String uid = auth.currentUser.uid;

        Stream<User> stream = auth.authStateChanges();
        int call = 0;

        subscription = stream.listen(expectAsync1((User user) {
          call++;
          if (call == 1) {
            expect(user.uid, isA<String>());
            expect(user.uid, equals(uid)); // initial user
          } else if (call == 2) {
            expect(user, isNull); // logged out
          } else if (call == 3) {
            expect(user.uid, isA<String>());
            expect(user.uid != uid, isTrue); // anonymous user
          } else {
            fail('Should not have been called');
          }
        }, count: 3, reason: 'Stream should only have been called 3 times'));

        // Prevent race condition where signOut is called before the stream hits
        await auth.signOut();
        await auth.signInAnonymously();
      });
    });

    group('idTokenChanges()', () {
      /*late*/ StreamSubscription subscription;
      StreamSubscription /*?*/ subscription2;

      tearDown(() async {
        await subscription?.cancel();
        await ensureSignedOut();

        if (subscription2 != null) {
          await Future.delayed(const Duration(seconds: 5));
          await subscription2.cancel();
        }
      });

      test('calls callback with the current user and when auth state changes',
          () async {
        await ensureSignedIn(regularTestEmail);
        String uid = auth.currentUser.uid;

        Stream<User> stream = auth.idTokenChanges();
        int call = 0;

        subscription = stream.listen(expectAsync1((User user) {
          call++;
          if (call == 1) {
            expect(user.uid, equals(uid)); // initial user
          } else if (call == 2) {
            expect(user, isNull); // logged out
          } else if (call == 3) {
            expect(user.uid, isA<String>());
            expect(user.uid != uid, isTrue); // anonymous user
          } else {
            fail('Should not have been called');
          }
        }, count: 3, reason: 'Stream should only have been called 3 times'));

        // Prevent race condition where signOut is called before the stream hits
        await auth.signOut();
        await auth.signInAnonymously();
      });
    });

    group('userChanges()', () {
      /*late*/ StreamSubscription subscription;
      tearDown(() async {
        await subscription.cancel();
      });
      test('calls callback with the current user and when user state changes',
          () async {
        await ensureSignedIn(regularTestEmail);

        Stream<User /*?*/ > stream = auth.userChanges();
        int call = 0;

        subscription = stream.listen(expectAsync1((User user) {
          call++;
          if (call == 1) {
            expect(user.displayName, isNull); // initial user
          } else if (call == 2) {
            expect(user.displayName, equals('updatedName')); // updated profile
          } else {
            fail('Should not have been called');
          }
        }, count: 2, reason: 'Stream should only have been called 2 times'));

        await auth.currentUser.updateProfile(displayName: 'updatedName');

        await auth.currentUser.reload();
        expect(auth.currentUser.displayName, equals('updatedName'));
      });
    });

    group('currentUser', () {
      test('should return currentUser', () async {
        await ensureSignedIn(regularTestEmail);
        var currentUser = auth.currentUser;
        expect(currentUser, isA<User>());
      });
    });

    group('applyActionCode', () {
      test('throws if invalid code', () async {
        try {
          await auth.applyActionCode('!!!!!!');
          fail('Should have thrown');
        } on FirebaseException catch (e) {
          expect(e.code, equals('invalid-action-code'));
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
          expect(e.code, equals('invalid-action-code'));
        } catch (e) {
          fail(e.toString());
        }
      });
    });

    group('confirmPasswordReset()', () {
      test('throws on invalid code', () async {
        try {
          await auth.confirmPasswordReset(
              code: '!!!!!!', newPassword: 'thingamajig');
          fail('Should have thrown');
        } on FirebaseException catch (e) {
          expect(e.code, equals('invalid-action-code'));
        } catch (e) {
          fail(e.toString());
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
                email: email, password: TEST_PASSWORD)
            .then(successCallback);
      });

      test('fails if creating a user which already exists', () async {
        await ensureSignedIn(regularTestEmail);
        try {
          await auth.createUserWithEmailAndPassword(
              email: regularTestEmail, password: '123456');
          fail('Should have thrown FirebaseAuthException');
        } on FirebaseAuthException catch (e) {
          expect(e.code, equals('email-already-in-use'));
        } catch (e) {
          fail(e.toString());
        }
      });

      test('fails if creating a user with an invalid email', () async {
        await ensureSignedIn(regularTestEmail);
        try {
          await auth.createUserWithEmailAndPassword(
              email: '!!!!!', password: '123456');
          fail('Should have thrown FirebaseAuthException');
        } on FirebaseAuthException catch (e) {
          expect(e.code, equals('invalid-email'));
        } catch (e) {
          fail(e.toString());
        }
      });

      test('fails if creating a user if providing a weak password', () async {
        await ensureSignedIn(regularTestEmail);
        try {
          await auth.createUserWithEmailAndPassword(
              email: generateRandomEmail(), password: '1');
          fail('Should have thrown FirebaseAuthException');
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
          expect(e.code, equals('invalid-email'));
        } catch (e) {
          fail(e.toString());
        }
      });
    });

    group('isSignInWithEmailLink()', () {
      test('should return true or false', () {
        const emailLink1 =
            'https://www.example.com/action?mode=signIn&oobCode=oobCode';
        const emailLink2 =
            'https://www.example.com/action?mode=verifyEmail&oobCode=oobCode';
        const emailLink3 = 'https://www.example.com/action?mode=signIn';
        const emailLink4 =
            'https://x59dg.app.goo.gl/?link=https://rnfirebase-b9ad4.firebaseapp.com/__/auth/action?apiKey%3Dfoo%26mode%3DsignIn%26oobCode%3Dbar';

        expect(auth.isSignInWithEmailLink(emailLink1), equals(true));
        expect(auth.isSignInWithEmailLink(emailLink2), equals(false));
        expect(auth.isSignInWithEmailLink(emailLink3), equals(false));
        expect(auth.isSignInWithEmailLink(emailLink4), equals(true));
      });
    });

    group('sendPasswordResetEmail()', () {
      test('should not error', () async {
        var email = generateRandomEmail();

        try {
          await auth.createUserWithEmailAndPassword(
              email: email, password: TEST_PASSWORD);

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

    group('sendSignInLinkToEmail()', () {
      test('should send email successfully', () async {
        var email = generateRandomEmail();
        await auth.createUserWithEmailAndPassword(
            email: email, password: TEST_PASSWORD);

        var settings =
            ActionCodeSettings(url: 'http://localhost', handleCodeInApp: true);
        try {
          await auth.sendSignInLinkToEmail(
              email: email, actionCodeSettings: settings);
          await auth.currentUser.delete();
        } catch (e) {
          await auth.currentUser.delete();
          fail(e.toString());
        }
      });

      test('throws if invalid continue url', () async {
        var email = generateRandomEmail();
        await auth.createUserWithEmailAndPassword(
            email: email, password: TEST_PASSWORD);

        var settings = ActionCodeSettings(url: '', handleCodeInApp: true);
        try {
          await auth.sendSignInLinkToEmail(
              email: email, actionCodeSettings: settings);
          await auth.currentUser.delete();
          fail('Should have thrown');
        } on FirebaseException catch (e) {
          await auth.currentUser.delete();
          expect(e.code, isNotNull);
          expect(e.message, isNotNull);
        } catch (e) {
          await auth.currentUser.delete();
          fail(e.toString());
        }
      });
    });

    group('languageCode', () {
      test('should change the language code', () async {
        await auth.setLanguageCode('en');

        expect(auth.languageCode, equals('en'));
      });

      test('should allow null value and default the device language code',
          () async {
        await auth.setLanguageCode(null);

        expect(auth.languageCode,
            isNotNull); // default to the device language or the Firebase projects default language
      }, skip: kIsWeb);

      test('should allow null value and set to null', () async {
        await auth.setLanguageCode(null);

        expect(auth.languageCode, null);
      }, skip: !kIsWeb);
    });

    group('setPersistence()', () {
      test('throw an unimplemented error', () async {
        try {
          await auth.setPersistence(Persistence.LOCAL);
          fail('Should have thrown');
        } catch (e) {
          expect(e, isInstanceOf<UnimplementedError>());
        }
      }, skip: kIsWeb);

      test('should set persistence', () async {
        try {
          await auth.setPersistence(Persistence.LOCAL);
        } catch (e) {
          fail('unexpected error thrown');
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
        var credential = EmailAuthProvider.credential(
            email: regularTestEmail, password: TEST_PASSWORD);
        await auth.signInWithCredential(credential).then(commonSuccessCallback);
      });

      test('throws if login user is disabled', () async {
        var credential = EmailAuthProvider.credential(
            email: 'disabled@account.com', password: 'test1234');

        try {
          await auth.signInWithCredential(credential);
          fail('Should have thrown');
        } on FirebaseException catch (e) {
          expect(e.code, equals('user-disabled'));
          expect(
              e.message,
              equals(
                  'The user account has been disabled by an administrator.'));
        } catch (e) {
          fail(e.toString());
        }
      });

      test('throws if login password is incorrect', () async {
        var credential = EmailAuthProvider.credential(
            email: regularTestEmail, password: 'sowrong');
        try {
          await auth.signInWithCredential(credential);
          fail('Should have thrown');
        } on FirebaseException catch (e) {
          expect(e.code, equals('wrong-password'));
          expect(
              e.message,
              equals(
                  'The password is invalid or the user does not have a password.'));
        } catch (e) {
          fail(e.toString());
        }
      });

      test('throws if login user is not found', () async {
        var credential = EmailAuthProvider.credential(
            email: generateRandomEmail(), password: TEST_PASSWORD);
        try {
          await auth.signInWithCredential(credential);
          fail('Should have thrown');
        } on FirebaseException catch (e) {
          expect(e.code, equals('user-not-found'));
          expect(
              e.message,
              equals(
                  'There is no user record corresponding to this identifier. The user may have been deleted.'));
        } catch (e) {
          fail(e.toString());
        }
      });
    });

    group('signInWithCustomToken()', () {
      test('signs in with custom auth token', () async {
        // need an idToken for authentication when requesting
        // a custom token
        var cred = await auth.signInAnonymously();
        var authToken = await auth.currentUser.getIdToken();
        var uid = cred.user.uid;
        var claims = {
          'roles': [
            {'role': 'member'},
            {'role': 'admin'}
          ]
        };

        var customToken = await getCustomToken(uid, claims, authToken);
        // clear anon user
        await auth.currentUser?.delete();

        var userCredential = await auth.signInWithCustomToken(customToken);

        expect(userCredential.user.uid, equals(uid));
        expect(auth.currentUser.uid, equals(uid));

        await ensureSignedOut();
      });
    });

    group('signInWithEmailAndPassword()', () {
      test('should login with email and password', () async {
        await auth
            .signInWithEmailAndPassword(
                email: regularTestEmail, password: TEST_PASSWORD)
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
          expect(e.code, equals('user-disabled'));
          expect(
              e.message,
              equals(
                  'The user account has been disabled by an administrator.'));
        } catch (e) {
          fail(e.toString());
        }
      });

      test('throws if login password is incorrect', () async {
        try {
          await auth.signInWithEmailAndPassword(
              email: regularTestEmail, password: 'sowrong');
          fail('Should have thrown');
        } on FirebaseException catch (e) {
          expect(e.code, equals('wrong-password'));
          expect(
              e.message,
              equals(
                  'The password is invalid or the user does not have a password.'));
        } catch (e) {
          fail(e.toString());
        }
      });

      test('throws if login user is not found', () async {
        try {
          await auth.signInWithEmailAndPassword(
              email: generateRandomEmail(), password: TEST_PASSWORD);
          fail('Should have thrown');
        } on FirebaseException catch (e) {
          expect(e.code, equals('user-not-found'));
          expect(
              e.message,
              equals(
                  'There is no user record corresponding to this identifier. The user may have been deleted.'));
        } catch (e) {
          fail(e.toString());
        }
      });
    });

    // For manual testing only
    // group('signInWithEmailLink()', () {
    // see: signInWithEmailLink test below
    // to ensure an email is successfully sent using
    // automated testing. Enable this manual test to
    // ensure the link in the test email actually works
    // and signs a user in.
    // test('should sign in user using link', () async {
    //  const email = 'MANUAL TEST EMAIL HERE';
    //     const emailLink = 'MANUAL TEST CODE HERE';

    //   var userCredential =
    //       await auth.signInWithEmailLink(email: email, emailLink: emailLink);

    //   expect(userCredential.user.email, equals(email));
    //   // clean up
    //   ensureSignedOut();
    // });

    // test('should throw argument-error', () async {
    //   const email = 'test@email.com';
    //   const emailLink = 'https://invalid.com';
    //   try {
    //     await auth.signInWithEmailLink(email: email, emailLink: emailLink);
    //   } on FirebaseAuthException catch (e) {
    //     expect(e.code, 'argument-error');
    //     expect(e.message, 'Invalid email link!');
    //   }
    // });
    // });

    group('signOut()', () {
      test('should sign out', () async {
        await ensureSignedIn(regularTestEmail);
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
          expect(e.code, equals('invalid-action-code'));
        } catch (e) {
          fail(e.toString());
        }
      });
    });

    group('verifyPhoneNumber()', () {
      test('should fail with an invalid phone number', () async {
        Future<Exception> getError() async {
          Completer completer = Completer<FirebaseAuthException>();

          unawaited(auth.verifyPhoneNumber(
              phoneNumber: 'foo',
              verificationCompleted: (PhoneAuthCredential credential) {
                return completer
                    .completeError(Exception('Should not have been called'));
              },
              verificationFailed: (FirebaseAuthException e) {
                completer.complete(e);
              },
              codeSent: (String verificationId, int resetToken) {
                return completer
                    .completeError(Exception('Should not have been called'));
              },
              codeAutoRetrievalTimeout: (String foo) {
                return completer
                    .completeError(Exception('Should not have been called'));
              }));

          return completer.future;
        }

        Exception e = await getError();
        expect(e, isA<FirebaseAuthException>());
        FirebaseAuthException exception = e as FirebaseAuthException;
        expect(exception.code, equals('invalid-phone-number'));
      });

      test('should auto verify phone number', () async {
        String testPhoneNumber = '+447444555666';
        String testSmsCode = '123456';
        await auth.signInAnonymously();

        Future<PhoneAuthCredential> getCredential() async {
          Completer completer = Completer<PhoneAuthCredential>();

          unawaited(auth.verifyPhoneNumber(
              phoneNumber: testPhoneNumber,
              // ignore: invalid_use_of_visible_for_testing_member
              autoRetrievedSmsCodeForTesting: testSmsCode,
              verificationCompleted: (PhoneAuthCredential credential) {
                if (credential.smsCode != testSmsCode) {
                  return completer
                      .completeError(Exception('SMS code did not match'));
                }

                completer.complete(credential);
              },
              verificationFailed: (FirebaseException e) {
                return completer
                    .completeError(Exception('Should not have been called'));
              },
              codeSent: (String verificationId, int resetToken) {
                return completer
                    .completeError(Exception('Should not have been called'));
              },
              codeAutoRetrievalTimeout: (String foo) {
                return completer
                    .completeError(Exception('Should not have been called'));
              }));

          return completer.future;
        }

        PhoneAuthCredential credential = await getCredential();
        expect(credential, isA<PhoneAuthCredential>());
      }, skip: kIsWeb || defaultTargetPlatform != TargetPlatform.android);
    }, skip: defaultTargetPlatform == TargetPlatform.macOS || kIsWeb);
  });
}
