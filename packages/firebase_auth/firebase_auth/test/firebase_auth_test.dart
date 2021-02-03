// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:async/async.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_platform_interface/src/method_channel/method_channel_firebase_auth.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import './mock.dart';

import 'package:mockito/mockito.dart';

MockFirebaseAuth mockAuthPlatform = MockFirebaseAuth();

void main() {
  setupFirebaseAuthMocks();

  /*late*/ FirebaseAuth auth;

  const String kMockActionCode = '12345';
  const String kMockEmail = 'test@example.com';
  const String kMockPassword = 'passw0rd';
  const String kMockIdToken = '12345';
  const String kMockAccessToken = '67890';
  const String kMockGithubToken = 'github';
  const String kMockCustomToken = '12345';
  const String kMockPhoneNumber = '5555555555';
  const String kMockVerificationId = '12345';
  const String kMockSmsCode = '123456';
  const String kMockLanguage = 'en';
  const String kMockOobCode = 'oobcode';
  const String kMockURL = 'http://www.example.com';
  const String kMockHost = 'www.example.com';
  const int kMockPort = 31337;

  final ActionCodeSettings kMockActionCodeSettings =
      ActionCodeSettings(url: kMockURL);
  final TestAuthProvider testAuthProvider = TestAuthProvider();
  final int kMockCreationTimestamp =
      DateTime.now().subtract(const Duration(days: 2)).millisecondsSinceEpoch;
  final int kMockLastSignInTimestamp =
      DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch;

  Map<String, dynamic> kMockUser = <String, dynamic>{
    'isAnonymous': true,
    'emailVerified': false,
    'displayName': 'displayName',
    'metadata': <String, int>{
      'creationTime': kMockCreationTimestamp,
      'lastSignInTime': kMockLastSignInTimestamp,
    },
    'providerData': <Map<String, String>>[
      <String, String>{
        'providerId': 'firebase',
        'uid': '12345',
        'displayName': 'Flutter Test User',
        'photoURL': 'http://www.example.com/',
        'email': 'test@example.com',
      },
    ],
  };

  /*late*/ MockUserPlatform mockUserPlatform;
  /*late*/ MockUserCredentialPlatform mockUserCredPlatform;
  /*late*/ MockConfirmationResultPlatform mockConfirmationResultPlatform;
  /*late*/ MockRecaptchaVerifier mockVerifier;
  /*late*/ AdditionalUserInfo mockAdditionalUserInfo;
  /*late*/ EmailAuthCredential mockCredential;

  group("$FirebaseAuth", () {
    Map<String, dynamic> user;
    FirebaseAuthPlatform.instance = mockAuthPlatform;

    setUpAll(() async {
      await Firebase.initializeApp();

      auth = FirebaseAuth.instance;
      user = kMockUser;

      mockUserPlatform = MockUserPlatform(mockAuthPlatform, user);
      mockConfirmationResultPlatform = MockConfirmationResultPlatform();
      mockUserCredPlatform = MockUserCredentialPlatform(
          FirebaseAuthPlatform.instance,
          mockAdditionalUserInfo,
          mockCredential,
          mockUserPlatform);
      mockVerifier = MockRecaptchaVerifier();
      mockAdditionalUserInfo = AdditionalUserInfo(
        isNewUser: false,
        username: 'flutterUser',
        providerId: 'testProvider',
        profile: <String, dynamic>{'foo': 'bar'},
      );
      mockCredential =
          EmailAuthProvider.credential(email: 'test', password: 'test');

      when(mockAuthPlatform.signInAnonymously()).thenAnswer(
          (_) => Future<UserCredentialPlatform>.value(mockUserCredPlatform));

      when(mockAuthPlatform.signInWithCredential(any)).thenAnswer(
          (_) => Future<UserCredentialPlatform>.value(mockUserCredPlatform));

      when(mockAuthPlatform.currentUser).thenReturn(mockUserPlatform);

      when(mockAuthPlatform.instanceFor(
              app: anyNamed("app"),
              pluginConstants: anyNamed("pluginConstants")))
          .thenAnswer((_) => mockUserPlatform);

      when(mockAuthPlatform.delegateFor(
        app: anyNamed("app"),
      )).thenAnswer((_) => mockAuthPlatform);

      when(mockAuthPlatform.setInitialValues(
        currentUser: anyNamed("currentUser"),
        languageCode: anyNamed("languageCode"),
      )).thenAnswer((_) => mockAuthPlatform);

      when(mockAuthPlatform.createUserWithEmailAndPassword(any, any))
          .thenAnswer((_) =>
              Future<UserCredentialPlatform>.value(mockUserCredPlatform));

      when(mockAuthPlatform.getRedirectResult()).thenAnswer(
          (_) => Future<UserCredentialPlatform>.value(mockUserCredPlatform));

      when(mockAuthPlatform.signInWithCustomToken(any)).thenAnswer(
          (_) => Future<UserCredentialPlatform>.value(mockUserCredPlatform));

      when(mockAuthPlatform.signInWithEmailAndPassword(any, any)).thenAnswer(
          (_) => Future<UserCredentialPlatform>.value(mockUserCredPlatform));

      when(mockAuthPlatform.signInWithEmailLink(any, any)).thenAnswer(
          (_) => Future<UserCredentialPlatform>.value(mockUserCredPlatform));

      when(mockAuthPlatform.signInWithPhoneNumber(any, any)).thenAnswer((_) =>
          Future<ConfirmationResultPlatform>.value(
              mockConfirmationResultPlatform));
      when(mockVerifier.delegate).thenReturn(mockVerifier.mockDelegate);

      when(mockAuthPlatform.signInWithPopup(any)).thenAnswer(
          (_) => Future<UserCredentialPlatform>.value(mockUserCredPlatform));

      when(mockAuthPlatform.signInWithRedirect(any)).thenAnswer(
          (_) => Future<UserCredentialPlatform>.value(mockUserCredPlatform));

      when(mockAuthPlatform.authStateChanges()).thenAnswer((_) =>
          Stream<UserPlatform>.fromIterable(<UserPlatform>[mockUserPlatform]));

      when(mockAuthPlatform.idTokenChanges()).thenAnswer((_) =>
          Stream<UserPlatform>.fromIterable(<UserPlatform>[mockUserPlatform]));

      when(mockAuthPlatform.userChanges()).thenAnswer((_) =>
          Stream<UserPlatform>.fromIterable(<UserPlatform>[mockUserPlatform]));

      MethodChannelFirebaseAuth.channel.setMockMethodCallHandler((call) async {
        switch (call.method) {
          default:
            return <String, dynamic>{'user': user};
        }
      });
    });

    setUp(() async {
      user = kMockUser;
      await auth.signInAnonymously();
    });

    group('emulator', () {
      test('useEmulator() should call delegate method', () async {
        // Necessary as we otherwise get a "null is not a Future<void>" error
        when(mockAuthPlatform.useEmulator(kMockHost, kMockPort))
            .thenAnswer((i) async {});
        await auth.useEmulator('http://$kMockHost:$kMockPort');
        verify(mockAuthPlatform.useEmulator(kMockHost, kMockPort));
      });
    });

    group('currentUser', () {
      test('get currentUser', () {
        User user = auth.currentUser;
        verify(mockAuthPlatform.currentUser);
        expect(user, isA<User>());
      });
    });

    group('languageCode', () {
      test('.languageCode should call delegate method', () {
        auth.languageCode;
        verify(mockAuthPlatform.languageCode);
      });

      test('setLanguageCode() should call delegate method', () async {
        await auth.setLanguageCode(kMockLanguage);
        verify(mockAuthPlatform.setLanguageCode(kMockLanguage));
      });
    });

    group('checkActionCode()', () {
      test('should throw if null', () {
        expect(() => auth.checkActionCode(null), throwsAssertionError);
      });

      test('should call delegate method', () async {
        await auth.checkActionCode(kMockActionCode);
        verify(mockAuthPlatform.checkActionCode(kMockActionCode));
      });
    });

    group('confirmPasswordReset()', () {
      test('should throw if null', () {
        expect(() => auth.confirmPasswordReset(code: null, newPassword: null),
            throwsAssertionError);
      });

      test('should call delegate method', () async {
        await auth.confirmPasswordReset(
            code: kMockActionCode, newPassword: kMockPassword);
        verify(mockAuthPlatform.confirmPasswordReset(
            kMockActionCode, kMockPassword));
      });
    });

    group('createUserWithEmailAndPassword()', () {
      test('should throw if null', () {
        expect(
            () => auth.createUserWithEmailAndPassword(
                email: null, password: null),
            throwsAssertionError);
      });

      test('should call delegate method', () async {
        await auth.createUserWithEmailAndPassword(
            email: kMockEmail, password: kMockPassword);
        verify(mockAuthPlatform.createUserWithEmailAndPassword(
            kMockEmail, kMockPassword));
      });
    });

    group('fetchSignInMethodsForEmail()', () {
      test('should throw if null', () {
        expect(
            () => auth.fetchSignInMethodsForEmail(null), throwsAssertionError);
      });

      test('should call delegate method', () async {
        await auth.fetchSignInMethodsForEmail(kMockEmail);
        verify(mockAuthPlatform.fetchSignInMethodsForEmail(kMockEmail));
      });
    });

    group('getRedirectResult()', () {
      test('should call delegate method', () async {
        await auth.getRedirectResult();
        verify(mockAuthPlatform.getRedirectResult());
      });
    });

    group('isSignInWithEmailLink()', () {
      test('should throw if null', () {
        expect(() => auth.isSignInWithEmailLink(null), throwsAssertionError);
      });

      test('should call delegate method', () async {
        await auth.isSignInWithEmailLink(kMockURL);
        verify(mockAuthPlatform.isSignInWithEmailLink(kMockURL));
      });
    });

    group('authStateChanges()', () {
      test('should stream changes', () async {
        final StreamQueue<User> changes =
            StreamQueue<User>(auth.authStateChanges());
        expect(await changes.next, isA<User>());
      });
    });

    group('idTokenChanges()', () {
      test('should stream changes', () async {
        final StreamQueue<User> changes =
            StreamQueue<User>(auth.idTokenChanges());
        expect(await changes.next, isA<User>());
      });
    });

    group('userChanges()', () {
      test('should stream changes', () async {
        final StreamQueue<User> changes = StreamQueue<User>(auth.userChanges());
        expect(await changes.next, isA<User>());
      });
    });

    group('sendPasswordResetEmail()', () {
      test('should throw if null', () {
        expect(() => auth.sendPasswordResetEmail(email: null),
            throwsAssertionError);
      });

      test('should call delegate method', () async {
        await auth.sendPasswordResetEmail(email: kMockEmail);
        verify(mockAuthPlatform.sendPasswordResetEmail(kMockEmail));
      });
    });

    group('sendPasswordResetEmail()', () {
      test('should throw if null', () {
        expect(() => auth.sendPasswordResetEmail(email: null),
            throwsAssertionError);
      });

      test('should call delegate method', () async {
        await auth.sendPasswordResetEmail(email: kMockEmail);
        verify(mockAuthPlatform.sendPasswordResetEmail(kMockEmail));
      });
    });

    group('sendSignInLinkToEmail()', () {
      test('should throw if email null', () {
        expect(
            () => auth.sendSignInLinkToEmail(
                email: null, actionCodeSettings: kMockActionCodeSettings),
            throwsAssertionError);
      });

      test('should throw if actionCodeSettings null', () {
        expect(
            () => auth.sendSignInLinkToEmail(
                email: kMockEmail, actionCodeSettings: null),
            throwsAssertionError);
      });

      test('should throw if email and actionCodeSettings are null', () {
        expect(
            () => auth.sendSignInLinkToEmail(
                email: null, actionCodeSettings: null),
            throwsAssertionError);
      });

      test('should throw if actionCodeSettings.handleCodeInApp is not true',
          () async {
        final ActionCodeSettings kMockActionCodeSettingsNull =
            ActionCodeSettings(url: kMockURL, handleCodeInApp: null);
        final ActionCodeSettings kMockActionCodeSettingsFalse =
            ActionCodeSettings(url: kMockURL, handleCodeInApp: false);

        // when handleCodeInApp is null
        expect(
            () => auth.sendSignInLinkToEmail(
                email: kMockEmail,
                actionCodeSettings: kMockActionCodeSettingsNull),
            throwsArgumentError);
        // when handleCodeInApp is false
        expect(
            () => auth.sendSignInLinkToEmail(
                email: kMockEmail,
                actionCodeSettings: kMockActionCodeSettingsFalse),
            throwsArgumentError);
      });

      test('should call delegate method', () async {
        final ActionCodeSettings kMockActionCodeSettingsValid =
            ActionCodeSettings(url: kMockURL, handleCodeInApp: true);
        await auth.sendSignInLinkToEmail(
            email: kMockEmail,
            actionCodeSettings: kMockActionCodeSettingsValid);
        verify(mockAuthPlatform.sendSignInLinkToEmail(
            kMockEmail, kMockActionCodeSettingsValid));
      });
    });

    group('setSettings()', () {
      test('should call delegate method', () async {
        await auth.setSettings(
            appVerificationDisabledForTesting: true, userAccessGroup: null);
        verify(mockAuthPlatform.setSettings(
            appVerificationDisabledForTesting: true, userAccessGroup: null));
      });
    });

    group('setPersistence()', () {
      test('should throw if null', () {
        expect(() => auth.setPersistence(null), throwsAssertionError);
      });

      test('should call delegate method', () async {
        await auth.setPersistence(Persistence.LOCAL);
        verify(mockAuthPlatform.setPersistence(Persistence.LOCAL));
      });
    });

    group('signInAnonymously()', () {
      test('should call delegate method', () async {
        await auth.signInAnonymously();
        verify(mockAuthPlatform.signInAnonymously());
      });
    });

    group('signInWithCredential()', () {
      test('GithubAuthProvider signInWithCredential', () async {
        final AuthCredential credential =
            GithubAuthProvider.credential(kMockGithubToken);
        await auth.signInWithCredential(credential);
        final GithubAuthCredential captured =
            verify(mockAuthPlatform.signInWithCredential(captureAny))
                .captured
                .single;
        expect(captured.providerId, equals('github.com'));
        expect(captured.accessToken, equals(kMockGithubToken));
      });

      test('EmailAuthProvider (withLink) signInWithCredential', () async {
        final AuthCredential credential = EmailAuthProvider.credentialWithLink(
          email: 'test@example.com',
          emailLink: '<Url with domain from your Firebase project>',
        );
        await auth.signInWithCredential(credential);
        final EmailAuthCredential captured =
            verify(mockAuthPlatform.signInWithCredential(captureAny))
                .captured
                .single;
        expect(captured.providerId, equals('password'));
        expect(captured.email, equals('test@example.com'));
        expect(captured.emailLink,
            equals('<Url with domain from your Firebase project>'));
      });

      test('TwitterAuthProvider signInWithCredential', () async {
        final AuthCredential credential = TwitterAuthProvider.credential(
          accessToken: kMockIdToken,
          secret: kMockAccessToken,
        );
        await auth.signInWithCredential(credential);
        final TwitterAuthCredential captured =
            verify(mockAuthPlatform.signInWithCredential(captureAny))
                .captured
                .single;
        expect(captured.providerId, equals('twitter.com'));
        expect(captured.accessToken, equals(kMockIdToken));
        expect(captured.secret, equals(kMockAccessToken));
      });

      test('GoogleAuthProvider signInWithCredential', () async {
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: kMockIdToken,
          accessToken: kMockAccessToken,
        );
        await auth.signInWithCredential(credential);
        final GoogleAuthCredential captured =
            verify(mockAuthPlatform.signInWithCredential(captureAny))
                .captured
                .single;
        expect(captured.providerId, equals('google.com'));
        expect(captured.idToken, equals(kMockIdToken));
        expect(captured.accessToken, equals(kMockAccessToken));
      });

      test('OAuthProvider signInWithCredential for Apple', () async {
        OAuthProvider oAuthProvider = OAuthProvider("apple.com");
        final AuthCredential credential = oAuthProvider.credential(
          idToken: kMockIdToken,
          accessToken: kMockAccessToken,
        );
        await auth.signInWithCredential(credential);
        final OAuthCredential captured =
            verify(mockAuthPlatform.signInWithCredential(captureAny))
                .captured
                .single;
        expect(captured.providerId, equals('apple.com'));
        expect(captured.idToken, equals(kMockIdToken));
        expect(captured.accessToken, equals(kMockAccessToken));
      });

      test('PhoneAuthProvider signInWithCredential', () async {
        final AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: kMockVerificationId,
          smsCode: kMockSmsCode,
        );
        await auth.signInWithCredential(credential);
        final PhoneAuthCredential captured =
            verify(mockAuthPlatform.signInWithCredential(captureAny))
                .captured
                .single;
        expect(captured.providerId, equals('phone'));
        expect(captured.verificationId, equals(kMockVerificationId));
        expect(captured.smsCode, equals(kMockSmsCode));
      });

      test('FacebookAuthProvider signInWithCredential', () async {
        final AuthCredential credential =
            FacebookAuthProvider.credential(kMockAccessToken);
        await auth.signInWithCredential(credential);
        final FacebookAuthCredential captured =
            verify(mockAuthPlatform.signInWithCredential(captureAny))
                .captured
                .single;
        expect(captured.providerId, equals('facebook.com'));
        expect(captured.accessToken, equals(kMockAccessToken));
      });
    });

    group('signInWithCustomToken()', () {
      test('should throw if token null', () {
        expect(() => auth.signInWithCustomToken(null), throwsAssertionError);
      });
      test('should call delegate method', () async {
        await auth.signInWithCustomToken(kMockCustomToken);
        verify(mockAuthPlatform.signInWithCustomToken(kMockCustomToken));
      });
    });

    group('signInWithEmailAndPassword()', () {
      test('should throw if email or password are null', () {
        expect(
            () => auth.signInWithEmailAndPassword(email: null, password: null),
            throwsAssertionError);
      });
      test('should call delegate method', () async {
        await auth.signInWithEmailAndPassword(
            email: kMockEmail, password: kMockPassword);
        verify(mockAuthPlatform.signInWithEmailAndPassword(
            kMockEmail, kMockPassword));
      });
    });

    group('signInWithEmailLink()', () {
      test('should throw if email or link are null', () {
        expect(() => auth.signInWithEmailLink(email: null, emailLink: null),
            throwsAssertionError);
      });
      test('should call delegate method', () async {
        await auth.signInWithEmailLink(email: kMockEmail, emailLink: kMockURL);
        verify(mockAuthPlatform.signInWithEmailLink(kMockEmail, kMockURL));
      });
    });

    group('signInWithPhoneNumber()', () {
      test('should throw if phoneNumber or verifier are null', () {
        expect(
            () => auth.signInWithPhoneNumber(null, null), throwsAssertionError);
      });

      test('should call delegate method', () async {
        await auth.signInWithPhoneNumber(kMockPhoneNumber, mockVerifier);
        verify(mockAuthPlatform.signInWithPhoneNumber(kMockPhoneNumber, any));
      });
    });

    group('signInWithPopup()', () {
      test('should call delegate method', () async {
        await auth.signInWithPopup(testAuthProvider);
        verify(mockAuthPlatform.signInWithPopup(testAuthProvider));
      });
    });

    group('signInWithRedirect()', () {
      test('should call delegate method', () async {
        await auth.signInWithRedirect(testAuthProvider);
        verify(mockAuthPlatform.signInWithRedirect(testAuthProvider));
      });
    });

    group('signOut()', () {
      test('should call delegate method', () async {
        await auth.signOut();
        verify(mockAuthPlatform.signOut());
      });
    });

    group('verifyPasswordResetCode()', () {
      test('should throw if phoneNumber or verifier are null', () {
        expect(() => auth.verifyPasswordResetCode(null), throwsAssertionError);
      });
      test('should call delegate method', () async {
        await auth.verifyPasswordResetCode(kMockOobCode);
        verify(mockAuthPlatform.verifyPasswordResetCode(kMockOobCode));
      });
    });

    group('verifyPhoneNumber()', () {
      test('should throw if null', () {
        expect(
            () => auth.verifyPhoneNumber(
                phoneNumber: null,
                verificationCompleted: null,
                verificationFailed: null,
                codeSent: null,
                codeAutoRetrievalTimeout: null,
                autoRetrievedSmsCodeForTesting: null),
            throwsAssertionError);
      });

      test('should call delegate method', () async {
        final PhoneVerificationCompleted verificationCompleted =
            (PhoneAuthCredential phoneAuthCredential) {};
        final PhoneVerificationFailed verificationFailed =
            (FirebaseAuthException authException) {};
        final PhoneCodeSent codeSent =
            (String verificationId, [int forceResendingToken]) async {};
        final PhoneCodeAutoRetrievalTimeout autoRetrievalTimeout =
            (String verificationId) {};

        await auth.verifyPhoneNumber(
            phoneNumber: kMockPhoneNumber,
            verificationCompleted: verificationCompleted,
            verificationFailed: verificationFailed,
            codeSent: codeSent,
            codeAutoRetrievalTimeout: autoRetrievalTimeout);

        verify(mockAuthPlatform.verifyPhoneNumber(
            phoneNumber: kMockPhoneNumber,
            timeout: Duration(seconds: 30),
            forceResendingToken: null,
            verificationCompleted: verificationCompleted,
            verificationFailed: verificationFailed,
            codeSent: codeSent,
            codeAutoRetrievalTimeout: autoRetrievalTimeout));
      });
    });

    test('toString()', () async {
      expect(auth.toString(), equals('FirebaseAuth(app: [DEFAULT])'));
    });
  });
}

class MockFirebaseAuth extends Mock
    with MockPlatformInterfaceMixin
    implements TestFirebaseAuthPlatform {
  MockFirebaseAuth();
}

class MockUserPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements TestUserPlatform {
  MockUserPlatform(FirebaseAuthPlatform auth, Map<String, dynamic> _user) {
    TestUserPlatform(auth, _user);
  }
}

class MockUserCredentialPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements TestUserCredentialPlatform {
  MockUserCredentialPlatform(
      FirebaseAuthPlatform auth,
      AdditionalUserInfo additionalUserInfo,
      AuthCredential credential,
      UserPlatform userPlatform) {
    TestUserCredentialPlatform(
        auth, additionalUserInfo, credential, userPlatform);
  }
}

class MockConfirmationResultPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements TestConfirmationResultPlatform {
  MockConfirmationResultPlatform() {
    TestConfirmationResultPlatform();
  }
}

class TestConfirmationResultPlatform extends ConfirmationResultPlatform {
  TestConfirmationResultPlatform() : super('TEST');
}

class TestFirebaseAuthPlatform extends FirebaseAuthPlatform {
  TestFirebaseAuthPlatform() : super();

  instanceFor({FirebaseApp app, Map<dynamic, dynamic> pluginConstants}) {}

  FirebaseAuthPlatform delegateFor({FirebaseApp app}) {
    return this;
  }

  @override
  FirebaseAuthPlatform setInitialValues(
      {Map<String, dynamic> currentUser, String languageCode}) {
    return this;
  }
}

class MockRecaptchaVerifier extends Mock
    with MockPlatformInterfaceMixin
    implements TestRecaptchaVerifier {
  MockRecaptchaVerifier() {
    TestRecaptchaVerifier();
  }

  RecaptchaVerifierFactoryPlatform get mockDelegate {
    return MockRecaptchaVerifierFactoryPlatform(); //this.delegate;
  }
}

class MockRecaptchaVerifierFactoryPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements TestRecaptchaVerifierFactoryPlatform {
  MockRecaptchaVerifier() {
    TestRecaptchaVerifierFactoryPlatform();
  }
}

class TestRecaptchaVerifier implements RecaptchaVerifier {
  TestRecaptchaVerifier() : super();

  @override
  void clear() {}

  @override
  RecaptchaVerifierFactoryPlatform get delegate =>
      TestRecaptchaVerifierFactoryPlatform();

  @override
  Future<int> render() {
    throw UnimplementedError();
  }

  @override
  String get type => throw UnimplementedError();

  @override
  Future<String> verify() {
    throw UnimplementedError();
  }
}

class TestRecaptchaVerifierFactoryPlatform
    extends RecaptchaVerifierFactoryPlatform {
  TestRecaptchaVerifierFactoryPlatform() : super();
}

class TestAuthProvider extends AuthProvider {
  TestAuthProvider() : super("TEST");
}

class TestUserPlatform extends UserPlatform {
  TestUserPlatform(FirebaseAuthPlatform auth, Map<String, dynamic> data)
      : super(auth, data);
}

class TestUserCredentialPlatform extends UserCredentialPlatform {
  TestUserCredentialPlatform(
      FirebaseAuthPlatform auth,
      AdditionalUserInfo additionalUserInfo,
      AuthCredential credential,
      UserPlatform userPlatform)
      : super(
            auth: auth,
            additionalUserInfo: additionalUserInfo,
            credential: credential,
            user: userPlatform);
}
