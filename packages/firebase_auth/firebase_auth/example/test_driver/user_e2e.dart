// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './test_utils.dart';

void runUserTests() {
  group('$User', () {
    FirebaseAuth auth;

    setUp(() async {
      auth = FirebaseAuth.instance;
      if (auth.currentUser != null) {
        await auth.signOut();
      }
    });

    tearDown(() async {
      // Clean up
      await auth.currentUser?.delete();
    });

    group('getIdToken', () {
      test('should return a token', () async {
        // Setup
        User user;
        UserCredential userCredential;
        String email = generateRandomEmail();

        userCredential = await auth.createUserWithEmailAndPassword(
            email: email, password: TEST_PASSWORD);
        user = userCredential.user;

        // Test
        String token = await user.getIdToken();

        // // Assertions
        expect(token.length, greaterThan(24));
      });
    });

    group('getIdTokenResult()', () {
      test('should return a valid IdTokenResult Object', () async {
        // Setup
        User user;
        UserCredential userCredential;
        String email = generateRandomEmail();

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
        String email = generateRandomEmail();
        UserCredential linkedUserCredential = await auth.currentUser
            .linkWithCredential(
                EmailAuthProvider.credential(email, TEST_PASSWORD));

        User linkedUser = linkedUserCredential.user;
        expect(linkedUser.email, equals(email));
        expect(linkedUser.email, equals(auth.currentUser.email));
        expect(linkedUser.uid, equals(currentUID));
        expect(linkedUser.isAnonymous, isFalse);
      });

      test('should error on link anon <-> email if email already exists',
          () async {
        // Setup
        String email = generateRandomEmail();
        auth.createUserWithEmailAndPassword(
            email: email, password: TEST_PASSWORD);
        await auth.signInAnonymously();

        // Test
        try {
          await auth.currentUser
              .linkWithCredential(EmailAuthProvider.credential(
            email,
            TEST_PASSWORD,
          ));
        } on FirebaseException catch (e) {
          // Assertions
          expect(e.code, 'email-already-in-use');
          expect(e.message,
              'The email address is already in use by another account.');
          return;
        }

        fail('should have thrown an error');
      });

      // TODO(helenaford): test link phone account
      // test('should link anonymous account <-> phone account', () async {
      //   // Setup
      //   await auth.signInAnonymously();

      //   UserCredential linkedUserCredential = await auth.currentUser
      //       .linkWithCredential(PhoneAuthProvider.credential('test', 'test'));
      // });

      test(
          'should error on link anonymous account <-> phone account if invalid credentials',
          () async {
        // Setup
        await auth.signInAnonymously();

        try {
          await auth.currentUser
              .linkWithCredential(PhoneAuthProvider.credential('test', 'test'));
        } on FirebaseException catch (e) {
          expect(e.code, equals('unknown'));
          // TODO(helenaford): update expected message
          expect(e.message, isNull);
          return;
        }

        fail('should have thrown an error');
      });
    });

    group('reauthenticateWithCredential()', () {
      test('should reauthenticate correctly', () async {
        // Setup
        String email = generateRandomEmail();
        await auth.createUserWithEmailAndPassword(
            email: email, password: TEST_PASSWORD);
        User initialUser = auth.currentUser;

        // Test
        AuthCredential credential =
            EmailAuthProvider.credential(email, TEST_PASSWORD);
        await auth.currentUser.reauthenticateWithCredential(credential);

        // Assertions
        User currentUser = auth.currentUser;
        expect(currentUser.email, equals(email));
        expect(currentUser.uid, equals(initialUser.uid));
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
          fail('sendEmailVerification(actionCodeSettings) caused an error');
        }
        expect(auth.currentUser, isNotNull);
      });
    });

    group('unlink()', () {
      test('should unlink the email address', () async {
        // Setup
        await auth.signInAnonymously();

        String email = generateRandomEmail();
        AuthCredential credential =
            EmailAuthProvider.credential(email, TEST_PASSWORD);
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
        expect(unlinkedUser.email, isNull);
        expect(unlinkedUser.providerData, isA<List<UserInfo>>());
        expect(unlinkedUser.providerData.length, equals(0));
      });
    });

    group('updateEmail()', () {
      test('should update the email address', () async {
        String email = generateRandomEmail();
        String email2 = generateRandomEmail();
        // Setup
        await auth.createUserWithEmailAndPassword(
            email: email, password: TEST_PASSWORD);
        expect(auth.currentUser.email, equals(email));

        // Update user email
        await auth.currentUser.updateEmail(email2);
        expect(auth.currentUser.email, equals(email2));
      });
    });

    group('updatePassword()', () {
      test('should update the password', () async {
        String email = generateRandomEmail();
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
    });

    group('refreshToken', () {
      test('should throw an unsupported error', () async {
        // Setup
        await auth.signInAnonymously();

        // Test
        await auth.currentUser.refreshToken;

        // Assertions
        expect(auth.currentUser.refreshToken, isA<String>());
        expect(auth.currentUser.refreshToken, equals(""));
      });
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
        String email = generateRandomEmail();
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

    group('verifyBeforeUpdateEmail()', () {
      test('should not error', () async {
        String email = generateRandomEmail();

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
      });

      test('should error if email is null', () async {
        String email = generateRandomEmail();

        // Setup
        await auth.createUserWithEmailAndPassword(
            email: email, password: TEST_PASSWORD);

        // Test
        try {
          await auth.currentUser.verifyBeforeUpdateEmail(
              null, ActionCodeSettings(url: 'test.com'));
        } on AssertionError catch (_) {
          return;
        } catch (e) {
          fail('should have thrown an $AssertionError');
        }

        fail('should have thrown an error');
      });
    });
  });
}
