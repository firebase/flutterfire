// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../mock.dart';

void main() {
  setupFirebaseAuthMocks();

  /*late*/ TestFirebaseAuthPlatform firebaseAuthPlatform;

  /*late*/ FirebaseApp app;
  /*late*/ FirebaseApp secondaryApp;
  group('$FirebaseAuthPlatform()', () {
    setUpAll(() async {
      app = await Firebase.initializeApp();
      secondaryApp = await Firebase.initializeApp(
        name: 'testApp2',
        options: const FirebaseOptions(
          appId: '1:1234567890:ios:42424242424242',
          apiKey: '123',
          projectId: '123',
          messagingSenderId: '1234567890',
        ),
      );

      firebaseAuthPlatform = TestFirebaseAuthPlatform(
        app,
      );
      handleMethodCall((call) async {
        switch (call.method) {
          case 'Auth#registerChangeListeners':
            return {};
          default:
            return null;
        }
      });
    });

    test('Constructor', () {
      expect(firebaseAuthPlatform, isA<FirebaseAuthPlatform>());
      expect(firebaseAuthPlatform, isA<PlatformInterface>());
    });

    test('FirebaseAuthPlatform.instanceFor', () {
      final result = FirebaseAuthPlatform.instanceFor(
          app: app,
          pluginConstants: <dynamic, dynamic>{
            'APP_LANGUAGE_CODE': 'en',
            'APP_CURRENT_USER': <dynamic, dynamic>{'uid': '1234'}
          });
      expect(result, isA<FirebaseAuthPlatform>());
      expect(result.currentUser, isA<UserPlatform>());
      expect(result.currentUser.uid, '1234');
      expect(result.languageCode, equals('en'));
    });

    test('get.instance', () {
      expect(FirebaseAuthPlatform.instance, isA<FirebaseAuthPlatform>());
      expect(FirebaseAuthPlatform.instance.app.name,
          equals(defaultFirebaseAppName));
    });

    group('set.instance', () {
      test('sets the current instance', () {
        FirebaseAuthPlatform.instance = TestFirebaseAuthPlatform(secondaryApp);

        expect(FirebaseAuthPlatform.instance, isA<FirebaseAuthPlatform>());
        expect(FirebaseAuthPlatform.instance.app.name, equals('testApp2'));
      });

      test('throws an [AssertionError] if instance is null', () {
        expect(
            () => FirebaseAuthPlatform.instance = null, throwsAssertionError);
      });
    });

    test('throws if .delegateFor', () {
      try {
        firebaseAuthPlatform.testDelegateFor();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('delegateFor() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if .setInitialValues', () {
      try {
        firebaseAuthPlatform.testSetInitialValues();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('setInitialValues() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if get.currentUser', () {
      try {
        firebaseAuthPlatform.currentUser;
      } on UnimplementedError catch (e) {
        expect(e.message, equals('get.currentUser is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if set.currentUser', () {
      try {
        firebaseAuthPlatform.currentUser = null;
      } on UnimplementedError catch (e) {
        expect(e.message, equals('set.currentUser is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if languageCode', () {
      try {
        firebaseAuthPlatform.languageCode;
      } on UnimplementedError catch (e) {
        expect(e.message, equals('languageCode is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if sendAuthChangesEvent()', () {
      try {
        firebaseAuthPlatform.sendAuthChangesEvent(defaultFirebaseAppName, null);
      } on UnimplementedError catch (e) {
        expect(e.message, equals('sendAuthChangesEvent() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if applyActionCode()', () async {
      try {
        await firebaseAuthPlatform.applyActionCode('test');
      } on UnimplementedError catch (e) {
        expect(e.message, equals('applyActionCode() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if checkActionCode()', () async {
      try {
        await firebaseAuthPlatform.checkActionCode('test');
      } on UnimplementedError catch (e) {
        expect(e.message, equals('checkActionCode() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if confirmPasswordReset()', () async {
      try {
        await firebaseAuthPlatform.confirmPasswordReset('test', 'new-password');
      } on UnimplementedError catch (e) {
        expect(e.message, equals('confirmPasswordReset() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if createUserWithEmailAndPassword()', () async {
      try {
        await firebaseAuthPlatform.createUserWithEmailAndPassword(
            'test@email.com', 'password');
      } on UnimplementedError catch (e) {
        expect(e.message,
            equals('createUserWithEmailAndPassword() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if fetchSignInMethodsForEmail()', () async {
      try {
        await firebaseAuthPlatform.fetchSignInMethodsForEmail('test@email.com');
      } on UnimplementedError catch (e) {
        expect(e.message,
            equals('fetchSignInMethodsForEmail() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if getRedirectResult()', () async {
      try {
        await firebaseAuthPlatform.getRedirectResult();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('getRedirectResult() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    group('isSignInWithEmailLink()', () {
      test('returns correct result', () {
        String testEmail = 'test@email.com?';
        String mode1 = 'mode=signIn';
        String mode2 = 'mode%3DsignIn';
        String code1 = 'oobCode=';
        String code2 = 'oobCode%3D';
        List options = [
          {'email': '$testEmail', 'expected': false},
          {'email': '$testEmail$mode1', 'expected': false},
          {'email': '$testEmail$mode2', 'expected': false},
          {'email': '$testEmail$mode1&$mode2', 'expected': false},
          {'email': '$testEmail$code1', 'expected': false},
          {'email': '$testEmail$code2', 'expected': false},
          {'email': '$testEmail$code1&$code2', 'expected': false},
          {'email': '$testEmail$mode1&$code1', 'expected': true},
          {'email': '$testEmail$mode1&$code2', 'expected': true},
          {'email': '$testEmail$mode2&$code1', 'expected': true},
          {'email': '$testEmail$mode2&$code2', 'expected': true},
        ];

        options.forEach((element) {
          expect(firebaseAuthPlatform.isSignInWithEmailLink(element['email']),
              equals(element['expected']));
        });
      });
      test('throws a assertion error when email is null', () {
        expect(() => firebaseAuthPlatform.isSignInWithEmailLink(null),
            throwsAssertionError);
      });
    });

    test('throws if authStateChanges()', () {
      try {
        firebaseAuthPlatform.authStateChanges();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('authStateChanges() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if idTokenChanges()', () {
      try {
        firebaseAuthPlatform.idTokenChanges();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('idTokenChanges() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if userChanges()', () {
      try {
        firebaseAuthPlatform.userChanges();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('userChanges() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if sendPasswordResetEmail()', () async {
      try {
        await firebaseAuthPlatform.sendPasswordResetEmail('test@email.com');
      } on UnimplementedError catch (e) {
        expect(
            e.message, equals('sendPasswordResetEmail() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if sendSignInLinkToEmail()', () async {
      try {
        await firebaseAuthPlatform.sendSignInLinkToEmail(
            'test@email.com', null);
      } on UnimplementedError catch (e) {
        expect(e.message, equals('sendSignInLinkToEmail() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if setLanguageCode()', () async {
      try {
        await firebaseAuthPlatform.setLanguageCode('en');
      } on UnimplementedError catch (e) {
        expect(e.message, equals('setLanguageCode() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if setSettings()', () async {
      try {
        await firebaseAuthPlatform.setSettings();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('setSettings() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if setPersistence()', () async {
      try {
        await firebaseAuthPlatform.setPersistence(Persistence.LOCAL);
      } on UnimplementedError catch (e) {
        expect(e.message, equals('setPersistence() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if signInAnonymously()', () async {
      try {
        await firebaseAuthPlatform.signInAnonymously();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('signInAnonymously() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if signInWithCredential()', () async {
      try {
        await firebaseAuthPlatform.signInWithCredential(null);
      } on UnimplementedError catch (e) {
        expect(e.message, equals('signInWithCredential() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if signInWithEmailAndPassword()', () async {
      try {
        await firebaseAuthPlatform.signInWithEmailAndPassword(
            'test@email.com', 'password');
      } on UnimplementedError catch (e) {
        expect(e.message,
            equals('signInWithEmailAndPassword() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if signInWithEmailLink()', () async {
      try {
        await firebaseAuthPlatform.signInWithEmailLink(
            'test@email.com', 'test.com');
      } on UnimplementedError catch (e) {
        expect(e.message, equals('signInWithEmailLink() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if signInWithPhoneNumber()', () async {
      try {
        await firebaseAuthPlatform.signInWithPhoneNumber(
            TEST_PHONE_NUMBER, null);
      } on UnimplementedError catch (e) {
        expect(e.message, equals('signInWithPhoneNumber() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if signInWithPopup()', () async {
      try {
        await firebaseAuthPlatform.signInWithPopup(null);
      } on UnimplementedError catch (e) {
        expect(e.message, equals('signInWithPopup() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if signInWithRedirect()', () async {
      try {
        await firebaseAuthPlatform.signInWithRedirect(null);
      } on UnimplementedError catch (e) {
        expect(e.message, equals('signInWithRedirect() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if signOut()', () async {
      try {
        await firebaseAuthPlatform.signOut();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('signOut() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if useEmulator', () async {
      await expectLater(
        () => firebaseAuthPlatform.useEmulator('http://localhost', 9099),
        throwsUnimplementedError,
      );
    });

    test('throws if verifyPasswordResetCode()', () async {
      try {
        await firebaseAuthPlatform.verifyPasswordResetCode('test');
      } on UnimplementedError catch (e) {
        expect(
            e.message, equals('verifyPasswordResetCode() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if verifyPhoneNumber()', () async {
      try {
        await firebaseAuthPlatform.verifyPhoneNumber(
          phoneNumber: null,
          verificationCompleted: null,
          verificationFailed: null,
          codeAutoRetrievalTimeout: null,
          codeSent: null,
        );
      } on UnimplementedError catch (e) {
        expect(e.message, equals('verifyPhoneNumber() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });
  });
}

class TestFirebaseAuthPlatform extends FirebaseAuthPlatform {
  TestFirebaseAuthPlatform(FirebaseApp app) : super(appInstance: app);
  FirebaseAuthPlatform testDelegateFor({FirebaseApp app}) {
    return this.delegateFor();
  }

  FirebaseAuthPlatform testSetInitialValues() {
    return this.setInitialValues(currentUser: null, languageCode: null);
  }
}
