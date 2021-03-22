// @dart = 2.9

// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.9

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pedantic/pedantic.dart';
import './test_utils.dart';

void runUserTests() {
  group('$User', () {
    /*late*/ FirebaseAuth auth;
    String email = generateRandomEmail();

    setUpAll(() async {
      auth = FirebaseAuth.instance;
      if (auth.currentUser != null) {
        await auth.signOut();
      }
    });

    tearDown(() async {
      await ensureSignedIn(email);
      // Clean up
      await auth.currentUser?.delete();
    });

    group('getIdToken()', () {
      test('should return a token', () async {
        // Setup
        User user;
        UserCredential userCredential;

        userCredential = await auth.createUserWithEmailAndPassword(
            email: email, password: TEST_PASSWORD);
        user = userCredential.user;

        // Test
        String token = await user.getIdToken();

        // // Assertions
        expect(token.length, greaterThan(24));
      });

      test('should catch error', () async {
        // Setup
        User user;
        UserCredential userCredential;

        userCredential = await auth.createUserWithEmailAndPassword(
            email: email, password: TEST_PASSWORD);
        user = userCredential.user;

        // needed for method to throw an error
        await auth.signOut();

        try {
          // Test
          await user.getIdToken();
        } on FirebaseAuthException catch (_) {
          return;
        } catch (e) {
          fail('should have thrown a FirebaseAuthException error');
        }
        fail('should have thrown an error');
      });
    });

    group('getIdTokenResult()', () {
      test('should return a valid IdTokenResult Object', () async {
        // Setup
        User user;
        UserCredential userCredential;

        userCredential = await auth.createUserWithEmailAndPassword(
            email: email, password: TEST_PASSWORD);
        user = userCredential.user;

        // Test
        final idTokenResult = await user.getIdTokenResult();

        // Assertions
        expect(idTokenResult.token.runtimeType, equals(String));
        expect(idTokenResult.authTime.runtimeType, equals(DateTime));
        expect(idTokenResult.issuedAtTime.runtimeType, equals(DateTime));
        expect(idTokenResult.expirationTime.runtimeType, equals(DateTime));
        expect(idTokenResult.token.length, greaterThan(24));
        expect(idTokenResult.signInProvider, equals('password'));
      });
    });

    group('linkWithCredential()', () {
      test('should link anonymous account <-> email account', () async {
        await auth.signInAnonymously();
        String currentUID = auth.currentUser.uid;

        UserCredential linkedUserCredential = await auth.currentUser
            .linkWithCredential(EmailAuthProvider.credential(
                email: email, password: TEST_PASSWORD));

        User linkedUser = linkedUserCredential.user;
        expect(linkedUser.email, equals(email));
        expect(linkedUser.email, equals(auth.currentUser.email));
        expect(linkedUser.uid, equals(currentUID));
        expect(linkedUser.isAnonymous, isFalse);
      });

      test('should error on link anon <-> email if email already exists',
          () async {
        // Setup

        await auth.createUserWithEmailAndPassword(
            email: email, password: TEST_PASSWORD);
        await auth.signInAnonymously();

        // Test
        try {
          await auth.currentUser
              .linkWithCredential(EmailAuthProvider.credential(
            email: email,
            password: TEST_PASSWORD,
          ));
        } on FirebaseAuthException catch (e) {
          // Assertions
          expect(e.code, 'email-already-in-use');
          expect(e.message,
              'The email address is already in use by another account.');

          // clean up
          await auth.currentUser.delete();
          return;
        }

        fail('should have thrown an error');
      });

      test('should link anonymous account <-> phone account', () async {
        await auth.signInAnonymously();

        Future<String> getVerificationId() {
          Completer completer = Completer<String>();

          unawaited(auth.verifyPhoneNumber(
            phoneNumber: TEST_PHONE_NUMBER,
            verificationCompleted: (PhoneAuthCredential credential) {
              fail('Should not have auto resolved');
            },
            verificationFailed: (FirebaseException e) {
              fail('Should not have errored');
            },
            codeSent: (String verificationId, int resetToken) {
              completer.complete(verificationId);
            },
            codeAutoRetrievalTimeout: (String foo) {},
          ));

          return completer.future;
        }

        String storedVerificationId = await getVerificationId();

        await auth.currentUser.linkWithCredential(PhoneAuthProvider.credential(
            verificationId: storedVerificationId, smsCode: TEST_SMS_CODE));
        expect(auth.currentUser, equals(isA<User>()));
        expect(auth.currentUser.phoneNumber, equals(TEST_PHONE_NUMBER));
        expect(auth.currentUser.providerData, equals(isA<List<UserInfo>>()));
        expect(auth.currentUser.providerData.length, equals(1));
        expect(auth.currentUser.providerData[0], equals(isA<UserInfo>()));
        expect(auth.currentUser.isAnonymous, isFalse);
        await auth.currentUser?.unlink(PhoneAuthProvider.PROVIDER_ID);
        await auth.currentUser?.delete();
      },
          skip: kIsWeb ||
              defaultTargetPlatform ==
                  TargetPlatform
                      .macOS); // verifyPhoneNumber not supported on web.

      test(
          'should error on link anonymous account <-> phone account if invalid credentials',
          () async {
        // Setup
        await auth.signInAnonymously();

        try {
          await auth.currentUser.linkWithCredential(
              PhoneAuthProvider.credential(
                  verificationId: 'test', smsCode: 'test'));
        } on FirebaseAuthException catch (e) {
          expect(e.code, equals('invalid-verification-id'));
          expect(
            e.message,
            equals(
              'The verification ID used to create the phone auth credential is invalid.',
            ),
          );
          return;
        } catch (e) {
          fail('should have thrown an FirebaseAuthException');
        }

        fail('should have thrown an error');
      }, skip: defaultTargetPlatform == TargetPlatform.macOS);
    });

    group('reauthenticateWithCredential()', () {
      test('should reauthenticate correctly', () async {
        // Setup
        await auth.createUserWithEmailAndPassword(
            email: email, password: TEST_PASSWORD);
        User initialUser = auth.currentUser;

        // Test
        AuthCredential credential =
            EmailAuthProvider.credential(email: email, password: TEST_PASSWORD);
        await auth.currentUser.reauthenticateWithCredential(credential);

        // Assertions
        User currentUser = auth.currentUser;
        expect(currentUser.email, equals(email));
        expect(currentUser.uid, equals(initialUser.uid));
      });

      test('should throw user-mismatch ', () async {
        // Setup
        String emailAlready = generateRandomEmail();

        await auth.createUserWithEmailAndPassword(
            email: email, password: TEST_PASSWORD);

        await auth.createUserWithEmailAndPassword(
            email: emailAlready, password: TEST_PASSWORD);

        try {
          // Test
          AuthCredential credential = EmailAuthProvider.credential(
              email: email, password: TEST_PASSWORD);
          await auth.currentUser.reauthenticateWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          // Assertions
          expect(e.code, equals('user-mismatch'));
          expect(
              e.message,
              equals(
                  'The supplied credentials do not correspond to the previously signed in user.'));
          await auth.currentUser.delete(); //clean up
          return;
        } catch (e) {
          fail('should have thrown an FirebaseAuthException');
        }

        fail('should have thrown an error');
      });

      test('should throw user-not-found or user-mismatch ', () async {
        // Setup
        UserCredential userCredential =
            await auth.createUserWithEmailAndPassword(
                email: email, password: TEST_PASSWORD);
        User user = userCredential.user;

        try {
          // Test
          AuthCredential credential = EmailAuthProvider.credential(
              email: 'userdoesnotexist@foobar.com', password: TEST_PASSWORD);
          await user.reauthenticateWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          // Platforms throw different errors. For now, leave them as is
          // but in future we might want to edit them before sending to user.
          if (e.code != 'user-mismatch' && e.code != 'user-not-found') {
            fail('should have thrown a valid error code (got ${e.code}');
          }

          return;
        } catch (e) {
          fail('should have thrown an FirebaseAuthException');
        }

        fail('should have thrown an error');
      });

      test('should throw invalid-email ', () async {
        // Setup
        await auth.createUserWithEmailAndPassword(
            email: email, password: TEST_PASSWORD);

        try {
          // Test
          AuthCredential credential = EmailAuthProvider.credential(
              email: 'invalid', password: TEST_PASSWORD);
          await auth.currentUser.reauthenticateWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          // Assertions
          expect(e.code, equals('invalid-email'));
          expect(e.message, equals('The email address is badly formatted.'));
          return;
        } catch (e) {
          fail('should have thrown an FirebaseAuthException');
        }

        fail('should have thrown an error');
      });

      test('should throw wrong-password ', () async {
        // Setup
        await auth.createUserWithEmailAndPassword(
            email: email, password: TEST_PASSWORD);

        try {
          // Test
          AuthCredential credential = EmailAuthProvider.credential(
              email: email, password: 'WRONG_TEST_PASSWORD');
          await auth.currentUser.reauthenticateWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          // Assertions
          expect(e.code, equals('wrong-password'));
          expect(
              e.message,
              equals(
                  'The password is invalid or the user does not have a password.'));
          return;
        } catch (e) {
          fail('should have thrown an FirebaseAuthException');
        }

        fail('should have thrown an error');
      });
    });

    group('reload()', () {
      test('should not error', () async {
        await auth.signInAnonymously();
        try {
          await auth.currentUser.reload();
          await auth.signOut();
        } catch (e) {
          fail('should not throw error');
        }
        expect(auth.currentUser, isNull);
      });
    });

    group('sendEmailVerification()', () {
      test('should not error', () async {
        await auth.createUserWithEmailAndPassword(
            email: generateRandomEmail(), password: TEST_PASSWORD);
        try {
          await auth.currentUser.sendEmailVerification();
        } catch (e) {
          fail('should not throw error');
        }
        expect(auth.currentUser, isNotNull);
      });

      test('should work with actionCodeSettings', () async {
        // Setup
        ActionCodeSettings actionCodeSettings = ActionCodeSettings(
          handleCodeInApp: true,
          url: 'https://react-native-firebase-testing.firebaseapp.com/foo',
        );
        await auth.createUserWithEmailAndPassword(
            email: generateRandomEmail(), password: TEST_PASSWORD);

        // Test
        try {
          await auth.currentUser.sendEmailVerification(actionCodeSettings);
        } catch (error) {
          fail(error);
        }
        expect(auth.currentUser, isNotNull);
      }, skip: kIsWeb);
    });

    group('unlink()', () {
      test('should unlink the email address', () async {
        // Setup
        await auth.signInAnonymously();

        AuthCredential credential =
            EmailAuthProvider.credential(email: email, password: TEST_PASSWORD);
        await auth.currentUser.linkWithCredential(credential);

        // verify user is linked
        User linkedUser = auth.currentUser;
        expect(linkedUser.email, email);
        expect(linkedUser.providerData, isA<List<UserInfo>>());
        expect(linkedUser.providerData.length, equals(1));

        // Test
        await auth.currentUser.unlink(EmailAuthProvider.PROVIDER_ID);

        // Assertions
        User unlinkedUser = auth.currentUser;
        expect(unlinkedUser.providerData, isA<List<UserInfo>>());
        expect(unlinkedUser.providerData.length, equals(0));
      });

      test('should throw error if provider id given does not exist', () async {
        // Setup
        await auth.signInAnonymously();

        AuthCredential credential =
            EmailAuthProvider.credential(email: email, password: TEST_PASSWORD);
        await auth.currentUser.linkWithCredential(credential);

        // verify user is linked
        User linkedUser = auth.currentUser;
        expect(linkedUser.email, email);

        // Test
        try {
          await auth.currentUser.unlink('invalid');
        } on FirebaseAuthException catch (e) {
          expect(e.code, 'no-such-provider');
          expect(e.message,
              'User was not linked to an account with the given provider.');
          return;
        } catch (e) {
          fail('should have thrown an FirebaseAuthException error');
        }
        fail('should have thrown an error');
      });

      test('should throw error if user does not have this provider linked',
          () async {
        // Setup
        await auth.signInAnonymously();
        // Test
        try {
          await auth.currentUser.unlink(EmailAuthProvider.PROVIDER_ID);
        } on FirebaseAuthException catch (e) {
          expect(e.code, 'no-such-provider');
          expect(e.message,
              'User was not linked to an account with the given provider.');
          return;
        } catch (e) {
          fail('should have thrown an FirebaseAuthException error');
        }
        fail('should have thrown an error');
      });
    });

    group('updateEmail()', () {
      test('should update the email address', () async {
        String emailBefore = generateRandomEmail();
        // Setup
        await auth.createUserWithEmailAndPassword(
            email: emailBefore, password: TEST_PASSWORD);
        expect(auth.currentUser.email, equals(emailBefore));

        // Update user email
        await auth.currentUser.updateEmail(email);
        expect(auth.currentUser.email, equals(email));
      });
    });

    group('updatePassword()', () {
      test('should update the password', () async {
        String pass = '${TEST_PASSWORD}1';
        String pass2 = '${TEST_PASSWORD}2';
        // Setup
        await auth.createUserWithEmailAndPassword(email: email, password: pass);

        // Update user password
        await auth.currentUser.updatePassword(pass2);

        // // Sign out
        await auth.signOut();

        // Log in with the new password
        await auth.signInWithEmailAndPassword(email: email, password: pass2);

        // Assertions
        expect(auth.currentUser, isA<Object>());
        expect(auth.currentUser.email, equals(email));
      });
      test('should throw error if password is weak', () async {
        // Setup
        await auth.createUserWithEmailAndPassword(
            email: email, password: TEST_PASSWORD);

        // Test
        try {
          // Update user password
          await auth.currentUser.updatePassword('weak');
        } on FirebaseAuthException catch (e) {
          expect(e.code, 'weak-password');
          expect(e.message, 'Password should be at least 6 characters');
          return;
        } catch (e) {
          fail('should have thrown an FirebaseAuthException error');
        }
        fail('should have thrown an error');
      });
    });

    group('refreshToken', () {
      test('should throw an unsupported error on non web platforms', () async {
        // Setup
        await auth.signInAnonymously();

        // Test
        auth.currentUser.refreshToken;

        // Assertions
        expect(auth.currentUser.refreshToken, isA<String>());
        expect(auth.currentUser.refreshToken, equals(''));
      }, skip: kIsWeb);

      test('should return a token on web', () async {
        // Setup
        await auth.signInAnonymously();

        // Test
        auth.currentUser.refreshToken;

        // Assertions
        expect(auth.currentUser.refreshToken, isA<String>());
        expect(auth.currentUser.refreshToken.isEmpty, isFalse);
      }, skip: !kIsWeb);
    });

    group('user.metadata', () {
      test(
          "should have the properties 'lastSignInTime' & 'creationTime' which are ISO strings",
          () async {
        // Setup
        await auth.createUserWithEmailAndPassword(
            email: generateRandomEmail(), password: TEST_PASSWORD);
        User user = auth.currentUser;

        // Test
        UserMetadata metadata = user.metadata;

        // Assertions
        expect(metadata.lastSignInTime, isA<DateTime>());
        expect(metadata.lastSignInTime.year, DateTime.now().year);
        expect(metadata.creationTime, isA<DateTime>());
        expect(metadata.creationTime.year, DateTime.now().year);
      });
    });

    group('updateProfile()', () {
      test('should update the profile', () async {
        String displayName = 'testName';
        String photoURL = 'http://photo.url/test.jpg';

        // Setup
        await auth.createUserWithEmailAndPassword(
            email: email, password: TEST_PASSWORD);

        // Update user profile
        await auth.currentUser.updateProfile(
          displayName: displayName,
          photoURL: photoURL,
        );

        await auth.currentUser.reload();
        User user = auth.currentUser;

        // Assertions
        expect(user, isA<Object>());
        expect(user.email, email);
        expect(user.displayName, equals(displayName));
        expect(user.photoURL, equals(photoURL));
      });
    });

    group('updatePhoneNumber()', () {
      test('should update the phone number', () async {
        // Setup
        await auth.signInAnonymously();

        String testPhoneNumber = TEST_PHONE_NUMBER;
        String testSMSCode = TEST_SMS_CODE;

        Future<String> getVerificationId() {
          Completer completer = Completer<String>();

          unawaited(auth.verifyPhoneNumber(
            phoneNumber: TEST_PHONE_NUMBER,
            verificationCompleted: (PhoneAuthCredential credential) {
              fail('Should not have auto resolved');
            },
            verificationFailed: (FirebaseException e) {
              fail('Should not have errored');
            },
            codeSent: (String verificationId, int resetToken) {
              completer.complete(verificationId);
            },
            codeAutoRetrievalTimeout: (String foo) {},
          ));

          return completer.future;
        }

        String storedVerificationId = await getVerificationId();

        // Update user profile
        await auth.currentUser.updatePhoneNumber(PhoneAuthProvider.credential(
            verificationId: storedVerificationId, smsCode: testSMSCode));

        await auth.currentUser.reload();
        User user = auth.currentUser;

        // Assertions
        expect(user, isA<Object>());
        expect(user.phoneNumber, equals(testPhoneNumber));
      }, skip: kIsWeb || defaultTargetPlatform == TargetPlatform.macOS);

      test(
          'should throw an FirebaseAuthException if verification id is invalid',
          () async {
        // Setup
        await auth.createUserWithEmailAndPassword(
            email: email, password: TEST_PASSWORD);

        try {
          // Update user profile
          await auth.currentUser.updatePhoneNumber(PhoneAuthProvider.credential(
              verificationId: 'invalid', smsCode: TEST_SMS_CODE));
        } on FirebaseAuthException catch (e) {
          expect(e.code, 'invalid-verification-id');
          expect(e.message,
              'The verification ID used to create the phone auth credential is invalid.');
          return;
        } catch (e) {
          fail('should have thrown a AssertionError error');
        }

        fail('should have thrown an error');
      }, skip: kIsWeb || defaultTargetPlatform == TargetPlatform.macOS);

      test('should throw an error when verification id is an empty string',
          () async {
        // Setup
        await auth.createUserWithEmailAndPassword(
            email: email, password: TEST_PASSWORD);

        try {
          // Test
          await auth.currentUser.updatePhoneNumber(PhoneAuthProvider.credential(
              verificationId: '', smsCode: TEST_SMS_CODE));
        } on FirebaseAuthException catch (e) {
          expect(e.code, 'invalid-verification-id');
          expect(e.message,
              'The verification ID used to create the phone auth credential is invalid.');
          return;
        } catch (e) {
          fail('should have thrown an FirebaseAuthException error');
        }

        fail('should have thrown an error');
      }, skip: kIsWeb || defaultTargetPlatform == TargetPlatform.macOS);
    });

    group('verifyBeforeUpdateEmail()', () {
      test('should not error', () async {
        // Setup
        await auth.createUserWithEmailAndPassword(
            email: email, password: TEST_PASSWORD);

        // Test
        try {
          await auth.currentUser.verifyBeforeUpdateEmail(generateRandomEmail(),
              ActionCodeSettings(url: 'http://localhost'));
        } catch (e) {
          fail('should not throw error $e');
        }

        // Assertions
        expect(auth.currentUser, isNotNull);
      },
          skip:
              true); // gets rate-limited often so should only be enabled when manual testing
    });

    group('delete()', () {
      test('should delete a user', () async {
        // Setup
        User user;
        UserCredential userCredential;

        userCredential = await auth.createUserWithEmailAndPassword(
            email: email, password: TEST_PASSWORD);
        user = userCredential.user;

        // Test
        await user.delete();

        // Assertions
        expect(auth.currentUser, equals(null));
        await auth
            .createUserWithEmailAndPassword(
                email: email, password: TEST_PASSWORD)
            .then((UserCredential userCredential) {
          expect(auth.currentUser.email, equals(email));
          return;
        }).catchError((Object error) {
          fail('Should have successfully created user after deletion');
        });
      });

      test('should throw an error on delete when no user is signed in',
          () async {
        // Setup
        User user;
        UserCredential userCredential;

        userCredential = await auth.createUserWithEmailAndPassword(
            email: email, password: TEST_PASSWORD);
        user = userCredential.user;

        await auth.signOut();

        try {
          // Test
          await user.delete();
        } on FirebaseAuthException catch (e) {
          // Assertions
          expect(e.code, 'no-current-user');
          expect(e.message, 'No user currently signed in.');

          return;
        } catch (e) {
          fail('Should have thrown an FirebaseAuthException error');
        }

        fail('Should have thrown an error');
      });
    });
  });
}
