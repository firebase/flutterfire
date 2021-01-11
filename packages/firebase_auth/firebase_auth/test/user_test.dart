// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_platform_interface/src/method_channel/method_channel_firebase_auth.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import './mock.dart';

import 'package:mockito/mockito.dart';

Map<String, dynamic> kMockUser1 = <String, dynamic>{
  'isAnonymous': true,
  'emailVerified': false,
  'displayName': 'displayName',
};
MockFirebaseAuth mockAuthPlatform = MockFirebaseAuth();
void main() {
  setupFirebaseAuthMocks();

  /*late*/ FirebaseAuth auth;

  const Map<String, dynamic> kMockIdTokenResult = <String, dynamic>{
    'token': '12345',
    'expirationTimestamp': 123456,
    'authTimestamp': 1234567,
    'issuedAtTimestamp': 12345678,
    'signInProvider': 'password',
    'claims': <dynamic, dynamic>{
      'claim1': 'value1',
    },
  };

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

  MockUserPlatform mockUserPlatform;
  MockUserCredentialPlatform mockUserCredPlatform;

  AdditionalUserInfo mockAdditionalInfo = AdditionalUserInfo(
    isNewUser: false,
    username: 'flutterUser',
    providerId: 'testProvider',
    profile: <String, dynamic>{'foo': 'bar'},
  );

  EmailAuthCredential mockCredential =
      EmailAuthProvider.credential(email: 'test', password: 'test');

  group("$User", () {
    Map<String, dynamic> user;
    FirebaseAuthPlatform.instance = mockAuthPlatform;

    setUpAll(() async {
      await Firebase.initializeApp();

      auth = FirebaseAuth.instance;

      user = kMockUser;

      mockUserPlatform = MockUserPlatform(mockAuthPlatform, user);

      mockUserCredPlatform = MockUserCredentialPlatform(
          FirebaseAuthPlatform.instance,
          mockAdditionalInfo,
          mockCredential,
          mockUserPlatform);

      when(mockAuthPlatform.signInAnonymously()).thenAnswer(
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

    test('delete()', () async {
      await auth.currentUser.delete();

      verify(mockUserPlatform.delete());
    });

    test('getIdToken()', () async {
      when(mockUserPlatform.getIdToken(any))
          .thenAnswer((_) => Future.value('token'));

      final token = await auth.currentUser.getIdToken(true);

      verify(mockUserPlatform.getIdToken(true));
      expect(token, isA<String>());
    });

    test('getIdTokenResult()', () async {
      when(mockUserPlatform.getIdTokenResult(any))
          .thenAnswer((_) => Future.value(IdTokenResult(kMockIdTokenResult)));

      final idTokenResult = await auth.currentUser.getIdTokenResult(true);

      verify(mockUserPlatform.getIdTokenResult(true));
      expect(idTokenResult, isA<IdTokenResult>());
    });

    group('linkWithCredential()', () {
      setUp(() {
        when(mockUserPlatform.linkWithCredential(any))
            .thenAnswer((_) => Future.value(mockUserCredPlatform));
      });
      test('should call linkWithCredential()', () async {
        String newEmail = 'new@email.com';
        EmailAuthCredential credential =
            EmailAuthProvider.credential(email: newEmail, password: 'test');

        await auth.currentUser.linkWithCredential(credential);

        verify(mockUserPlatform.linkWithCredential(credential));
      });

      test('throws an AssertionError', () async {
        try {
          await auth.currentUser.linkWithCredential(null);
        } on AssertionError catch (_) {
          verifyNever(mockUserPlatform.linkWithCredential(
            null,
          ));
          return;
        }

        fail('should have thrown an AssertionError');
      });
    });

    group('reauthenticateWithCredential()', () {
      setUp(() {
        when(mockUserPlatform.reauthenticateWithCredential(any))
            .thenAnswer((_) => Future.value(mockUserCredPlatform));
      });
      test('should call reauthenticateWithCredential()', () async {
        String newEmail = 'new@email.com';
        EmailAuthCredential credential =
            EmailAuthProvider.credential(email: newEmail, password: 'test');

        await auth.currentUser.reauthenticateWithCredential(credential);

        verify(mockUserPlatform.reauthenticateWithCredential(credential));
      });

      test('throws an AssertionError', () async {
        try {
          await auth.currentUser.reauthenticateWithCredential(null);
        } on AssertionError catch (_) {
          verifyNever(mockUserPlatform.reauthenticateWithCredential(
            null,
          ));
          return;
        }

        fail('should have thrown an AssertionError');
      });
    });

    test('reload()', () async {
      await auth.currentUser.reload();

      verify(mockUserPlatform.reload());
    });

    test('sendEmailVerification()', () async {
      final ActionCodeSettings actionCodeSettings =
          ActionCodeSettings(url: 'test');

      await auth.currentUser.sendEmailVerification(actionCodeSettings);

      verify(mockUserPlatform.sendEmailVerification(actionCodeSettings));
    });

    group('unlink()', () {
      setUp(() {
        when(mockUserPlatform.unlink(any))
            .thenAnswer((_) => Future.value(mockUserPlatform));
      });
      test('should call unlink()', () async {
        final String providerId = 'providerId';

        await auth.currentUser.unlink(providerId);

        verify(mockUserPlatform.unlink(providerId));
      });

      test('throws an AssertionError', () async {
        try {
          await auth.currentUser.unlink(null);
        } on AssertionError catch (_) {
          verifyNever(mockUserPlatform.unlink(
            null,
          ));
          return;
        }

        fail('should have thrown an AssertionError');
      });
    });
    group('updateEmail()', () {
      test('should call updateEmail()', () async {
        final String newEmail = 'newEmail';

        await auth.currentUser.updateEmail(newEmail);

        verify(mockUserPlatform.updateEmail(newEmail));
      });

      test('throws an AssertionError', () async {
        try {
          await auth.currentUser.updateEmail(null);
        } on AssertionError catch (_) {
          verifyNever(mockUserPlatform.updateEmail(
            null,
          ));
          return;
        }

        fail('should have thrown an AssertionError');
      });
    });

    group('updatePassword()', () {
      test('should call updatePassword()', () async {
        final String newPassword = 'newPassword';

        await auth.currentUser.updatePassword(newPassword);

        verify(mockUserPlatform.updatePassword(newPassword));
      });

      test('throws an AssertionError', () async {
        try {
          await auth.currentUser.updatePassword(null);
        } on AssertionError catch (_) {
          verifyNever(mockUserPlatform.updatePassword(
            null,
          ));
          return;
        }

        fail('should have thrown an AssertionError');
      });
    });
    group('updatePhoneNumber()', () {
      test('should call updatePhoneNumber()', () async {
        PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
            verificationId: 'test', smsCode: 'test');

        await auth.currentUser.updatePhoneNumber(phoneAuthCredential);

        verify(mockUserPlatform.updatePhoneNumber(phoneAuthCredential));
      });
      test('throws an AssertionError', () async {
        try {
          await auth.currentUser.updatePhoneNumber(null);
        } on AssertionError catch (_) {
          verifyNever(mockUserPlatform.updatePhoneNumber(
            null,
          ));
          return;
        }

        fail('should have thrown an AssertionError');
      });
    });

    test('updateProfile()', () async {
      final String displayName = 'updatedName';
      final String photoURL = 'testUrl';
      Map<String, String> data = <String, String>{
        'displayName': displayName,
        'photoURL': photoURL
      };
      await auth.currentUser
          .updateProfile(displayName: displayName, photoURL: photoURL);

      verify(mockUserPlatform.updateProfile(data));
    });

    group('verifyBeforeUpdateEmail()', () {
      test('should call verifyBeforeUpdateEmail()', () async {
        const newEmail = 'new@email.com';
        ActionCodeSettings actionCodeSettings = ActionCodeSettings(url: 'test');

        await auth.currentUser
            .verifyBeforeUpdateEmail(newEmail, actionCodeSettings);

        verify(mockUserPlatform.verifyBeforeUpdateEmail(
            newEmail, actionCodeSettings));
      });

      test('throws an AssertionError', () async {
        ActionCodeSettings actionCodeSettings = ActionCodeSettings(url: 'test');

        try {
          await auth.currentUser
              .verifyBeforeUpdateEmail(null, actionCodeSettings);
        } on AssertionError catch (_) {
          verifyNever(mockUserPlatform.verifyBeforeUpdateEmail(
              null, actionCodeSettings));
          return;
        }

        fail('should have thrown an AssertionError');
      });
    });

    test('toString()', () async {
      when(mockAuthPlatform.currentUser)
          .thenReturn(TestUserPlatform(mockAuthPlatform, user));

      expect(
          auth.currentUser.toString(),
          equals(
              'User(displayName: displayName, email: null, emailVerified: false, isAnonymous: true, metadata: UserMetadata(creationTime: ${DateTime.fromMillisecondsSinceEpoch(kMockCreationTimestamp)}, lastSignInTime: ${DateTime.fromMillisecondsSinceEpoch(kMockLastSignInTimestamp).toString()}), phoneNumber: null, photoURL: null, providerData, [UserInfo(displayName: Flutter Test User, email: test@example.com, phoneNumber: null, photoURL: http://www.example.com/, providerId: firebase, uid: 12345)], refreshToken: null, tenantId: null, uid: null)'));
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
