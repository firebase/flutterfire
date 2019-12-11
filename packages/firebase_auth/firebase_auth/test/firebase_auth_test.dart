// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:async/async.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

const String kMockProviderId = 'firebase';
const String kMockUid = '12345';
const String kMockDisplayName = 'Flutter Test User';
const String kMockPhotoUrl = 'http://www.example.com/';
const String kMockEmail = 'test@example.com';
const String kMockPassword = 'passw0rd';
const String kMockIdToken = '12345';
const String kMockAccessToken = '67890';
const String kMockGithubToken = 'github';
const String kMockAuthToken = '23456';
const String kMockAuthTokenSecret = '78901';
const String kMockCustomToken = '12345';
const String kMockPhoneNumber = '5555555555';
const String kMockVerificationId = '12345';
const String kMockSmsCode = '123456';
const String kMockLanguage = 'en';
const String kMockIdTokenResultSignInProvider = 'password';
const Map<dynamic, dynamic> kMockIdTokenResultClaims = <dynamic, dynamic>{
  'claim1': 'value1',
};
const int kMockIdTokenResultExpirationTimestamp = 123456;
const int kMockIdTokenResultAuthTimestamp = 1234567;
const int kMockIdTokenResultIssuedAtTimestamp = 12345678;
const PlatformIdTokenResult kMockIdTokenResult = PlatformIdTokenResult(
  token: kMockIdToken,
  expirationTimestamp: kMockIdTokenResultExpirationTimestamp,
  authTimestamp: kMockIdTokenResultAuthTimestamp,
  issuedAtTimestamp: kMockIdTokenResultIssuedAtTimestamp,
  signInProvider: kMockIdTokenResultSignInProvider,
  claims: kMockIdTokenResultClaims,
);

final int kMockCreationTimestamp = DateTime(2019, 1, 1).millisecondsSinceEpoch;
final int kMockLastSignInTimestamp =
    DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch;
// ignore: missing_required_param_with_details
final PlatformUser kMockUser = PlatformUser(
  providerId: 'foo',
  uid: 'bar',
  isAnonymous: true,
  isEmailVerified: false,
  creationTimestamp: kMockCreationTimestamp,
  lastSignInTimestamp: kMockLastSignInTimestamp,
  providerData: <PlatformUserInfo>[
    const PlatformUserInfo(
      providerId: kMockProviderId,
      uid: kMockUid,
      displayName: kMockDisplayName,
      photoUrl: kMockPhotoUrl,
      email: kMockEmail,
    )
  ],
);
final PlatformAdditionalUserInfo kMockAdditionalUserInfo =
    const PlatformAdditionalUserInfo(
  isNewUser: false,
  username: 'flutterUser',
  providerId: 'testProvider',
  profile: <String, dynamic>{'foo': 'bar'},
);
final PlatformAuthResult kMockAuthResult = PlatformAuthResult(
  user: kMockUser,
  additionalUserInfo: kMockAdditionalUserInfo,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$FirebaseAuth', () {
    final String appName = 'testApp';
    final FirebaseApp app = FirebaseApp(name: appName);
    final FirebaseAuth auth = FirebaseAuth.fromApp(app);
    MockFirebaseAuth mock;

    setUp(() {
      mock = MockFirebaseAuth();
      when(mock.isMock).thenReturn(true);
      when(mock.getIdToken(any, any)).thenAnswer(
          (_) => Future<PlatformIdTokenResult>.value(kMockIdTokenResult));
      when(mock.isSignInWithEmailLink(any, any))
          .thenAnswer((_) => Future<bool>.value(true));
      when(mock.getCurrentUser(any))
          .thenAnswer((_) => Future<PlatformUser>.value(kMockUser));
      when(mock.fetchSignInMethodsForEmail(any, any))
          .thenAnswer((_) => Future<List<String>>.value(<String>[]));
      when(mock.signInAnonymously(any))
          .thenAnswer((_) => Future<PlatformAuthResult>.value(kMockAuthResult));
      when(mock.signInWithEmailAndLink(any, any, any))
          .thenAnswer((_) => Future<PlatformAuthResult>.value(kMockAuthResult));
      when(mock.createUserWithEmailAndPassword(any, any, any))
          .thenAnswer((_) => Future<PlatformAuthResult>.value(kMockAuthResult));
      when(mock.linkWithCredential(any, any))
          .thenAnswer((_) => Future<PlatformAuthResult>.value(kMockAuthResult));
      when(mock.signInWithCredential(any, any))
          .thenAnswer((_) => Future<PlatformAuthResult>.value(kMockAuthResult));
      when(mock.reauthenticateWithCredential(any, any))
          .thenAnswer((_) => Future<PlatformAuthResult>.value(kMockAuthResult));
      when(mock.signInWithCustomToken(any, any))
          .thenAnswer((_) => Future<PlatformAuthResult>.value(kMockAuthResult));
      FirebaseAuthPlatform.instance = mock;
    });

    void verifyUser(FirebaseUser user) {
      expect(user, isNotNull);
      expect(user.isAnonymous, isTrue);
      expect(user.isEmailVerified, isFalse);
      expect(user.providerData.length, 1);
      final UserInfo userInfo = user.providerData[0];
      expect(userInfo.providerId, kMockProviderId);
      expect(userInfo.uid, kMockUid);
      expect(userInfo.displayName, kMockDisplayName);
      expect(userInfo.photoUrl, kMockPhotoUrl);
      expect(userInfo.email, kMockEmail);
      expect(user.metadata.creationTime.millisecondsSinceEpoch,
          kMockCreationTimestamp);
      expect(user.metadata.lastSignInTime.millisecondsSinceEpoch,
          kMockLastSignInTimestamp);
    }

    void verifyAuthResult(AuthResult result) {
      verifyUser(result.user);
      final AdditionalUserInfo additionalUserInfo = result.additionalUserInfo;
      expect(additionalUserInfo.isNewUser, kMockAdditionalUserInfo.isNewUser);
      expect(additionalUserInfo.username, kMockAdditionalUserInfo.username);
      expect(additionalUserInfo.providerId, kMockAdditionalUserInfo.providerId);
      expect(additionalUserInfo.profile, kMockAdditionalUserInfo.profile);
    }

    test('getIdToken', () async {
      void verifyIdTokenResult(IdTokenResult idTokenResult) {
        expect(idTokenResult.token, equals(kMockIdToken));
        expect(
            idTokenResult.expirationTime,
            equals(DateTime.fromMillisecondsSinceEpoch(
                kMockIdTokenResultExpirationTimestamp * 1000)));
        expect(
            idTokenResult.authTime,
            equals(DateTime.fromMillisecondsSinceEpoch(
                kMockIdTokenResultAuthTimestamp * 1000)));
        expect(
            idTokenResult.issuedAtTime,
            equals(DateTime.fromMillisecondsSinceEpoch(
                kMockIdTokenResultIssuedAtTimestamp * 1000)));
        expect(idTokenResult.signInProvider,
            equals(kMockIdTokenResultSignInProvider));
        expect(idTokenResult.claims, equals(kMockIdTokenResultClaims));
      }

      final FirebaseUser user = await auth.currentUser();
      verifyIdTokenResult(await user.getIdToken());
      verifyIdTokenResult(await user.getIdToken(refresh: true));
      // It's ugly to specify types for mockito verifications
      // ignore: always_specify_types
      verifyInOrder([
        mock.getCurrentUser(auth.app.name),
        mock.getIdToken(auth.app.name, false),
        mock.getIdToken(auth.app.name, true),
      ]);
    });

    test('signInAnonymously', () async {
      final AuthResult result = await auth.signInAnonymously();
      verifyAuthResult(result);
      verify(mock.signInAnonymously(auth.app.name));
    });

    test('sendSignInWithEmailLink', () async {
      await auth.sendSignInWithEmailLink(
        email: 'test@example.com',
        url: 'http://www.example.com/',
        handleCodeInApp: true,
        iOSBundleID: 'com.example.app',
        androidPackageName: 'com.example.app',
        androidInstallIfNotAvailable: false,
        androidMinimumVersion: "12",
      );
      expect(
        verify(mock.sendLinkToEmail(
          auth.app.name,
          email: captureAnyNamed('email'),
          url: captureAnyNamed('url'),
          handleCodeInApp: captureAnyNamed('handleCodeInApp'),
          iOSBundleID: captureAnyNamed('iOSBundleID'),
          androidPackageName: captureAnyNamed('androidPackageName'),
          androidInstallIfNotAvailable:
              captureAnyNamed('androidInstallIfNotAvailable'),
          androidMinimumVersion: captureAnyNamed('androidMinimumVersion'),
        )).captured,
        <dynamic>[
          'test@example.com',
          'http://www.example.com/',
          true,
          'com.example.app',
          'com.example.app',
          false,
          '12',
        ],
      );
    });

    test('isSignInWithEmailLink', () async {
      final bool result = await auth.isSignInWithEmailLink('foo');
      expect(result, true);
      verify(mock.isSignInWithEmailLink(app.name, 'foo'));
    });

    test('signInWithEmailAndLink', () async {
      final AuthResult result = await auth.signInWithEmailAndLink(
        email: 'test@example.com',
        link: '<Url with domain from your Firebase project>',
      );
      verifyAuthResult(result);
      verify(mock.signInWithEmailAndLink(
        app.name,
        'test@example.com',
        '<Url with domain from your Firebase project>',
      ));
    });

    test('createUserWithEmailAndPassword', () async {
      final AuthResult result = await auth.createUserWithEmailAndPassword(
        email: kMockEmail,
        password: kMockPassword,
      );
      verifyAuthResult(result);
      verify(mock.createUserWithEmailAndPassword(
        auth.app.name,
        kMockEmail,
        kMockPassword,
      ));
    });

    test('fetchSignInMethodsForEmail', () async {
      final List<String> providers =
          await auth.fetchSignInMethodsForEmail(email: kMockEmail);
      expect(providers, isNotNull);
      expect(providers.length, 0);
      verify(mock.fetchSignInMethodsForEmail(
        auth.app.name,
        kMockEmail,
      ));
    });

    test('EmailAuthProvider (withLink) linkWithCredential', () async {
      final AuthCredential credential = EmailAuthProvider.getCredentialWithLink(
        email: 'test@example.com',
        link: '<Url with domain from your Firebase project>',
      );
      final FirebaseUser user = await auth.currentUser();
      final AuthResult result = await user.linkWithCredential(credential);
      verifyAuthResult(result);
      verify(mock.getCurrentUser(auth.app.name));
      final EmailAuthCredential captured =
          verify(mock.linkWithCredential(auth.app.name, captureAny))
              .captured
              .single;
      expect(captured.providerId, equals('password'));
      expect(captured.email, equals('test@example.com'));
      expect(captured.link,
          equals('<Url with domain from your Firebase project>'));
    });

    test('EmailAuthProvider (withLink) signInWithCredential', () async {
      final AuthCredential credential = EmailAuthProvider.getCredentialWithLink(
        email: 'test@example.com',
        link: '<Url with domain from your Firebase project>',
      );
      final AuthResult result = await auth.signInWithCredential(credential);
      verifyAuthResult(result);
      final EmailAuthCredential captured =
          verify(mock.signInWithCredential(auth.app.name, captureAny))
              .captured
              .single;
      expect(captured.providerId, equals('password'));
      expect(captured.email, equals('test@example.com'));
      expect(captured.link,
          equals('<Url with domain from your Firebase project>'));
    });

    test('EmailAuthProvider (withLink) reauthenticateWithCredential', () async {
      final FirebaseUser user = await auth.currentUser();
      final AuthCredential credential = EmailAuthProvider.getCredentialWithLink(
        email: 'test@example.com',
        link: '<Url with domain from your Firebase project>',
      );
      await user.reauthenticateWithCredential(credential);
      verify(mock.getCurrentUser(auth.app.name));
      final EmailAuthCredential captured =
          verify(mock.reauthenticateWithCredential(auth.app.name, captureAny))
              .captured
              .single;
      expect(captured.providerId, equals('password'));
      expect(captured.email, equals('test@example.com'));
      expect(captured.link,
          equals('<Url with domain from your Firebase project>'));
    });

    test('TwitterAuthProvider linkWithCredential', () async {
      final AuthCredential credential = TwitterAuthProvider.getCredential(
        authToken: kMockIdToken,
        authTokenSecret: kMockAccessToken,
      );
      final FirebaseUser user = await auth.currentUser();
      final AuthResult result = await user.linkWithCredential(credential);
      verifyAuthResult(result);
      verify(mock.getCurrentUser(auth.app.name));
      final TwitterAuthCredential captured =
          verify(mock.linkWithCredential(auth.app.name, captureAny))
              .captured
              .single;
      expect(captured.providerId, equals('twitter.com'));
      expect(captured.authToken, equals(kMockIdToken));
      expect(captured.authTokenSecret, equals(kMockAccessToken));
    });

    test('TwitterAuthProvider signInWithCredential', () async {
      final AuthCredential credential = TwitterAuthProvider.getCredential(
        authToken: kMockIdToken,
        authTokenSecret: kMockAccessToken,
      );
      final AuthResult result = await auth.signInWithCredential(credential);
      verifyAuthResult(result);
      final TwitterAuthCredential captured =
          verify(mock.signInWithCredential(auth.app.name, captureAny))
              .captured
              .single;
      expect(captured.providerId, equals('twitter.com'));
      expect(captured.authToken, equals(kMockIdToken));
      expect(captured.authTokenSecret, equals(kMockAccessToken));
    });

    test('GithubAuthProvider linkWithCredential', () async {
      final AuthCredential credential = GithubAuthProvider.getCredential(
        token: kMockGithubToken,
      );
      final FirebaseUser user = await auth.currentUser();
      final AuthResult result = await user.linkWithCredential(credential);
      verifyAuthResult(result);
      verify(mock.getCurrentUser(auth.app.name));
      final GithubAuthCredential captured =
          verify(mock.linkWithCredential(auth.app.name, captureAny))
              .captured
              .single;
      expect(captured.providerId, equals('github.com'));
      expect(captured.token, equals(kMockGithubToken));
    });

    test('GitHubAuthProvider signInWithCredential', () async {
      final AuthCredential credential = GithubAuthProvider.getCredential(
        token: kMockGithubToken,
      );
      final AuthResult result = await auth.signInWithCredential(credential);
      verifyAuthResult(result);
      final GithubAuthCredential captured =
          verify(mock.signInWithCredential(auth.app.name, captureAny))
              .captured
              .single;
      expect(captured.providerId, equals('github.com'));
      expect(captured.token, equals(kMockGithubToken));
    });

    test('EmailAuthProvider linkWithCredential', () async {
      final AuthCredential credential = EmailAuthProvider.getCredential(
        email: kMockEmail,
        password: kMockPassword,
      );
      final FirebaseUser user = await auth.currentUser();
      final AuthResult result = await user.linkWithCredential(credential);
      verifyAuthResult(result);
      verify(mock.getCurrentUser(auth.app.name));
      final EmailAuthCredential captured =
          verify(mock.linkWithCredential(auth.app.name, captureAny))
              .captured
              .single;
      expect(captured.providerId, equals('password'));
      expect(captured.email, equals(kMockEmail));
      expect(captured.password, equals(kMockPassword));
    });

    test('GoogleAuthProvider signInWithCredential', () async {
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: kMockIdToken,
        accessToken: kMockAccessToken,
      );
      final AuthResult result = await auth.signInWithCredential(credential);
      verifyAuthResult(result);
      final GoogleAuthCredential captured =
          verify(mock.signInWithCredential(auth.app.name, captureAny))
              .captured
              .single;
      expect(captured.providerId, equals('google.com'));
      expect(captured.idToken, equals(kMockIdToken));
      expect(captured.accessToken, equals(kMockAccessToken));
    });

    test('PhoneAuthProvider signInWithCredential', () async {
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: kMockVerificationId,
        smsCode: kMockSmsCode,
      );
      final AuthResult result = await auth.signInWithCredential(credential);
      verifyAuthResult(result);
      final PhoneAuthCredential captured =
          verify(mock.signInWithCredential(auth.app.name, captureAny))
              .captured
              .single;
      expect(captured.providerId, equals('phone'));
      expect(captured.verificationId, equals(kMockVerificationId));
      expect(captured.smsCode, equals(kMockSmsCode));
    });

    test('verifyPhoneNumber', () async {
      await auth.verifyPhoneNumber(
          phoneNumber: kMockPhoneNumber,
          timeout: const Duration(seconds: 5),
          verificationCompleted: null,
          verificationFailed: null,
          codeSent: null,
          codeAutoRetrievalTimeout: null);
      final List<dynamic> captured = verify(mock.verifyPhoneNumber(
        auth.app.name,
        phoneNumber: captureAnyNamed('phoneNumber'),
        timeout: captureAnyNamed('timeout'),
        verificationCompleted: anyNamed('verificationCompleted'),
        verificationFailed: anyNamed('verificationFailed'),
        codeSent: anyNamed('codeSent'),
        codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
      )).captured;
      expect(captured, <dynamic>[
        kMockPhoneNumber,
        const Duration(seconds: 5),
      ]);
    });

    test('EmailAuthProvider reauthenticateWithCredential', () async {
      final FirebaseUser user = await auth.currentUser();
      final AuthCredential credential = EmailAuthProvider.getCredential(
        email: kMockEmail,
        password: kMockPassword,
      );
      final AuthResult result =
          await user.reauthenticateWithCredential(credential);
      verifyAuthResult(result);
      verify(mock.getCurrentUser(auth.app.name));
      final EmailAuthCredential captured =
          verify(mock.reauthenticateWithCredential(auth.app.name, captureAny))
              .captured
              .single;
      expect(captured.providerId, equals('password'));
      expect(captured.email, equals(kMockEmail));
      expect(captured.password, equals(kMockPassword));
    });

    test('GoogleAuthProvider reauthenticateWithCredential', () async {
      final FirebaseUser user = await auth.currentUser();
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: kMockIdToken,
        accessToken: kMockAccessToken,
      );
      final AuthResult result =
          await user.reauthenticateWithCredential(credential);
      verifyAuthResult(result);
      verify(mock.getCurrentUser(auth.app.name));
      final GoogleAuthCredential captured =
          verify(mock.reauthenticateWithCredential(auth.app.name, captureAny))
              .captured
              .single;
      expect(captured.providerId, equals('google.com'));
      expect(captured.idToken, equals(kMockIdToken));
      expect(captured.accessToken, equals(kMockAccessToken));
    });

    test('FacebookAuthProvider reauthenticateWithCredential', () async {
      final FirebaseUser user = await auth.currentUser();
      final AuthCredential credential = FacebookAuthProvider.getCredential(
        accessToken: kMockAccessToken,
      );
      final AuthResult result =
          await user.reauthenticateWithCredential(credential);
      verifyAuthResult(result);
      verify(mock.getCurrentUser(auth.app.name));
      final FacebookAuthCredential captured =
          verify(mock.reauthenticateWithCredential(auth.app.name, captureAny))
              .captured
              .single;
      expect(captured.providerId, equals('facebook.com'));
      expect(captured.accessToken, equals(kMockAccessToken));
    });

    test('TwitterAuthProvider reauthenticateWithCredential', () async {
      final FirebaseUser user = await auth.currentUser();
      final AuthCredential credential = TwitterAuthProvider.getCredential(
        authToken: kMockAuthToken,
        authTokenSecret: kMockAuthTokenSecret,
      );
      final AuthResult result =
          await user.reauthenticateWithCredential(credential);
      verifyAuthResult(result);
      verify(mock.getCurrentUser(auth.app.name));
      final TwitterAuthCredential captured =
          verify(mock.reauthenticateWithCredential(auth.app.name, captureAny))
              .captured
              .single;
      expect(captured.providerId, equals('twitter.com'));
      expect(captured.authToken, equals(kMockAuthToken));
      expect(captured.authTokenSecret, equals(kMockAuthTokenSecret));
    });

    test('GithubAuthProvider reauthenticateWithCredential', () async {
      final FirebaseUser user = await auth.currentUser();
      final AuthCredential credential = GithubAuthProvider.getCredential(
        token: kMockGithubToken,
      );
      final AuthResult result =
          await user.reauthenticateWithCredential(credential);
      verifyAuthResult(result);
      verify(mock.getCurrentUser(auth.app.name));
      final GithubAuthCredential captured =
          verify(mock.reauthenticateWithCredential(auth.app.name, captureAny))
              .captured
              .single;
      expect(captured.providerId, equals('github.com'));
      expect(captured.token, equals(kMockGithubToken));
    });

    test('GoogleAuthProvider linkWithCredential', () async {
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: kMockIdToken,
        accessToken: kMockAccessToken,
      );
      final FirebaseUser user = await auth.currentUser();
      final AuthResult result = await user.linkWithCredential(credential);
      verifyAuthResult(result);
      verify(mock.getCurrentUser(auth.app.name));
      final GoogleAuthCredential captured =
          verify(mock.linkWithCredential(auth.app.name, captureAny))
              .captured
              .single;
      expect(captured.providerId, equals('google.com'));
      expect(captured.idToken, equals(kMockIdToken));
      expect(captured.accessToken, equals(kMockAccessToken));
    });

    test('FacebookAuthProvider linkWithCredential', () async {
      final AuthCredential credential = FacebookAuthProvider.getCredential(
        accessToken: kMockAccessToken,
      );
      final FirebaseUser user = await auth.currentUser();
      final AuthResult result = await user.linkWithCredential(credential);
      verifyAuthResult(result);
      verify(mock.getCurrentUser(auth.app.name));
      final FacebookAuthCredential captured =
          verify(mock.linkWithCredential(auth.app.name, captureAny))
              .captured
              .single;
      expect(captured.providerId, equals('facebook.com'));
      expect(captured.accessToken, equals(kMockAccessToken));
    });

    test('FacebookAuthProvider signInWithCredential', () async {
      final AuthCredential credential = FacebookAuthProvider.getCredential(
        accessToken: kMockAccessToken,
      );
      final AuthResult result = await auth.signInWithCredential(credential);
      verifyAuthResult(result);
      final FacebookAuthCredential captured =
          verify(mock.signInWithCredential(auth.app.name, captureAny))
              .captured
              .single;
      expect(captured.providerId, equals('facebook.com'));
      expect(captured.accessToken, equals(kMockAccessToken));
    });

    test('TwitterAuthProvider linkWithCredential', () async {
      final AuthCredential credential = TwitterAuthProvider.getCredential(
        authToken: kMockAuthToken,
        authTokenSecret: kMockAuthTokenSecret,
      );
      final FirebaseUser user = await auth.currentUser();
      final AuthResult result = await user.linkWithCredential(credential);
      verifyAuthResult(result);
      verify(mock.getCurrentUser(auth.app.name));
      final TwitterAuthCredential captured =
          verify(mock.linkWithCredential(auth.app.name, captureAny))
              .captured
              .single;
      expect(captured.providerId, equals('twitter.com'));
      expect(captured.authToken, equals(kMockAuthToken));
      expect(captured.authTokenSecret, equals(kMockAuthTokenSecret));
    });

    test('TwitterAuthProvider signInWithCredential', () async {
      final AuthCredential credential = TwitterAuthProvider.getCredential(
        authToken: kMockAuthToken,
        authTokenSecret: kMockAuthTokenSecret,
      );
      final AuthResult result = await auth.signInWithCredential(credential);
      verifyAuthResult(result);
      final TwitterAuthCredential captured =
          verify(mock.signInWithCredential(auth.app.name, captureAny))
              .captured
              .single;
      expect(captured.providerId, equals('twitter.com'));
      expect(captured.authToken, equals(kMockAuthToken));
      expect(captured.authTokenSecret, equals(kMockAuthTokenSecret));
    });

    test('GithubAuthProvider linkWithCredential', () async {
      final AuthCredential credential = GithubAuthProvider.getCredential(
        token: kMockGithubToken,
      );
      final FirebaseUser user = await auth.currentUser();
      final AuthResult result = await user.linkWithCredential(credential);
      verifyAuthResult(result);
      verify(mock.getCurrentUser(auth.app.name));
      final GithubAuthCredential captured =
          verify(mock.linkWithCredential(auth.app.name, captureAny))
              .captured
              .single;
      expect(captured.providerId, equals('github.com'));
      expect(captured.token, equals(kMockGithubToken));
    });

    test('GithubAuthProvider signInWithCredential', () async {
      final AuthCredential credential = GithubAuthProvider.getCredential(
        token: kMockGithubToken,
      );
      final AuthResult result = await auth.signInWithCredential(credential);
      verifyAuthResult(result);
      final GithubAuthCredential captured =
          verify(mock.signInWithCredential(auth.app.name, captureAny))
              .captured
              .single;
      expect(captured.providerId, equals('github.com'));
      expect(captured.token, equals(kMockGithubToken));
    });

    test('EmailAuthProvider linkWithCredential', () async {
      final AuthCredential credential = EmailAuthProvider.getCredential(
        email: kMockEmail,
        password: kMockPassword,
      );
      final FirebaseUser user = await auth.currentUser();
      final AuthResult result = await user.linkWithCredential(credential);
      verifyAuthResult(result);
      verify(mock.getCurrentUser(auth.app.name));
      final EmailAuthCredential captured =
          verify(mock.linkWithCredential(auth.app.name, captureAny))
              .captured
              .single;
      expect(captured.providerId, equals('password'));
      expect(captured.email, equals('test@example.com'));
      expect(captured.password, equals(kMockPassword));
    });

    test('sendEmailVerification', () async {
      final FirebaseUser user = await auth.currentUser();
      await user.sendEmailVerification();
      verify(mock.getCurrentUser(auth.app.name));
      verify(mock.sendEmailVerification(auth.app.name));
    });

    test('reload', () async {
      final FirebaseUser user = await auth.currentUser();
      await user.reload();
      verify(mock.getCurrentUser(auth.app.name));
      verify(mock.reload(auth.app.name));
    });

    test('delete', () async {
      final FirebaseUser user = await auth.currentUser();
      await user.delete();
      verify(mock.getCurrentUser(auth.app.name));
      verify(mock.delete(auth.app.name));
    });

    test('sendPasswordResetEmail', () async {
      await auth.sendPasswordResetEmail(
        email: kMockEmail,
      );
      verify(mock.sendPasswordResetEmail(auth.app.name, kMockEmail));
    });

    test('updateEmail', () async {
      final FirebaseUser user = await auth.currentUser();
      await user.updateEmail(kMockEmail);
      verify(mock.getCurrentUser(auth.app.name));
      verify(mock.updateEmail(auth.app.name, kMockEmail));
    });

    test('updatePhoneNumberCredential', () async {
      final FirebaseUser user = await auth.currentUser();
      final AuthCredential credentials = PhoneAuthProvider.getCredential(
        verificationId: kMockVerificationId,
        smsCode: kMockSmsCode,
      );
      await user.updatePhoneNumberCredential(credentials);
      verify(mock.getCurrentUser(auth.app.name));
      final PhoneAuthCredential captured =
          verify(mock.updatePhoneNumberCredential(auth.app.name, captureAny))
              .captured
              .single;
      expect(captured.providerId, equals('phone'));
      expect(captured.verificationId, equals(kMockVerificationId));
      expect(captured.smsCode, equals(kMockSmsCode));
    });

    test('updatePassword', () async {
      final FirebaseUser user = await auth.currentUser();
      await user.updatePassword(kMockPassword);
      verify(mock.getCurrentUser(auth.app.name));
      verify(mock.updatePassword(auth.app.name, kMockPassword));
    });

    test('updateProfile', () async {
      final UserUpdateInfo userUpdateInfo = UserUpdateInfo();
      userUpdateInfo.photoUrl = kMockPhotoUrl;
      userUpdateInfo.displayName = kMockDisplayName;

      final FirebaseUser user = await auth.currentUser();
      await user.updateProfile(userUpdateInfo);
      verify(mock.getCurrentUser(auth.app.name));
      final List<dynamic> captured = verify(
        mock.updateProfile(
          auth.app.name,
          displayName: captureAnyNamed('displayName'),
          photoUrl: captureAnyNamed('photoUrl'),
        ),
      ).captured;
      expect(captured, equals(<String>[kMockDisplayName, kMockPhotoUrl]));
    });

    test('EmailAuthProvider unlinkFromProvider', () async {
      final FirebaseUser user = await auth.currentUser();
      await user.unlinkFromProvider(EmailAuthProvider.providerId);
      verify(mock.getCurrentUser(auth.app.name));
      verify(mock.unlinkFromProvider(auth.app.name, 'password'));
    });

    test('GoogleAuthProvider unlinkFromProvider', () async {
      final FirebaseUser user = await auth.currentUser();
      await user.unlinkFromProvider(GoogleAuthProvider.providerId);
      verify(mock.getCurrentUser(auth.app.name));
      verify(mock.unlinkFromProvider(auth.app.name, 'google.com'));
    });

    test('FacebookAuthProvider unlinkFromProvider', () async {
      final FirebaseUser user = await auth.currentUser();
      await user.unlinkFromProvider(FacebookAuthProvider.providerId);
      verify(mock.getCurrentUser(auth.app.name));
      verify(mock.unlinkFromProvider(auth.app.name, 'facebook.com'));
    });

    test('PhoneAuthProvider unlinkFromProvider', () async {
      final FirebaseUser user = await auth.currentUser();
      await user.unlinkFromProvider(PhoneAuthProvider.providerId);
      verify(mock.getCurrentUser(auth.app.name));
      verify(mock.unlinkFromProvider(auth.app.name, 'phone'));
    });

    test('TwitterAuthProvider unlinkFromProvider', () async {
      final FirebaseUser user = await auth.currentUser();
      await user.unlinkFromProvider(TwitterAuthProvider.providerId);
      verify(mock.getCurrentUser(auth.app.name));
      verify(mock.unlinkFromProvider(auth.app.name, 'twitter.com'));
    });

    test('GithubAuthProvider unlinkFromProvider', () async {
      final FirebaseUser user = await auth.currentUser();
      await user.unlinkFromProvider(GithubAuthProvider.providerId);
      verify(mock.getCurrentUser(auth.app.name));
      verify(mock.unlinkFromProvider(auth.app.name, 'github.com'));
    });

    test('signInWithCustomToken', () async {
      final AuthResult result =
          await auth.signInWithCustomToken(token: kMockCustomToken);
      verifyAuthResult(result);
      verify(mock.signInWithCustomToken(auth.app.name, kMockCustomToken));
    });

    test('onAuthStateChanged', () async {
      when(mock.onAuthStateChanged(auth.app.name)).thenAnswer((_) =>
          Stream<PlatformUser>.fromIterable(<PlatformUser>[null, kMockUser]));

      // Wrap onAuthStateChanged in a StreamQueue so we can request events.
      final StreamQueue<FirebaseUser> changes =
          StreamQueue<FirebaseUser>(auth.onAuthStateChanged);

      expect(await changes.next, isNull);

      final FirebaseUser user2 = await changes.next;
      verifyUser(user2);

      changes.cancel();
    });

    test('setLanguageCode', () async {
      await auth.setLanguageCode(kMockLanguage);
      verify(mock.setLanguageCode(auth.app.name, kMockLanguage));
    });
  });
}

class MockFirebaseAuth extends Mock implements FirebaseAuthPlatform {}
