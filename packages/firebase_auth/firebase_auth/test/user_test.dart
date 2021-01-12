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

  late FirebaseAuth auth;

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

  MockUserPlatform? mockUserPlatform;
  MockUserCredentialPlatform? mockUserCredPlatform;

  AdditionalUserInfo mockAdditionalInfo = AdditionalUserInfo(
    isNewUser: false,
    username: 'flutterUser',
    providerId: 'testProvider',
    profile: <String, dynamic>{'foo': 'bar'},
  );

  EmailAuthCredential mockCredential =
      EmailAuthProvider.credential(email: 'test', password: 'test')
          as EmailAuthCredential;

  group('$User', () {
    Map<String, dynamic>? user;
    FirebaseAuthPlatform.instance = mockAuthPlatform;

    setUpAll(() async {
      await Firebase.initializeApp();

      auth = FirebaseAuth.instance;

      user = kMockUser;

      mockUserPlatform = MockUserPlatform(mockAuthPlatform, user!);

      mockUserCredPlatform = MockUserCredentialPlatform(
        FirebaseAuthPlatform.instance,
        mockAdditionalInfo,
        mockCredential,
        mockUserPlatform!,
      );

      when(mockAuthPlatform.signInAnonymously()).thenAnswer(
          (_) => Future<UserCredentialPlatform>.value(mockUserCredPlatform));

      when(mockAuthPlatform.currentUser).thenReturn(mockUserPlatform!);

      // TODO
      // when(mockAuthPlatform.instanceFor(
      //   app: anyNamed('app'),
      //   pluginConstants: anyNamed('pluginConstants'),
      // )).thenAnswer((_) => mockUserPlatform);

      when(mockAuthPlatform.delegateFor(
        app: anyNamed('app'),
      )).thenAnswer((_) => mockAuthPlatform);

      when(mockAuthPlatform.setInitialValues(
        currentUser: anyNamed('currentUser'),
        languageCode: anyNamed('languageCode'),
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
      await auth.currentUser!.delete();

      verify(mockUserPlatform!.delete());
    });

    test('getIdToken()', () async {
      when(mockUserPlatform!.getIdToken(any)).thenAnswer((_) async => 'token');

      final token = await auth.currentUser!.getIdToken(true);

      verify(mockUserPlatform!.getIdToken(true));
      expect(token, isA<String>());
    });

    test('getIdTokenResult()', () async {
      when(mockUserPlatform!.getIdTokenResult(any))
          .thenAnswer((_) async => IdTokenResult(kMockIdTokenResult));

      final idTokenResult = await auth.currentUser!.getIdTokenResult(true);

      verify(mockUserPlatform!.getIdTokenResult(true));
      expect(idTokenResult, isA<IdTokenResult>());
    });

    group('linkWithCredential()', () {
      setUp(() {
        when(mockUserPlatform!.linkWithCredential(any))
            .thenAnswer((_) async => mockUserCredPlatform!);
      });

      test('should call linkWithCredential()', () async {
        String newEmail = 'new@email.com';
        EmailAuthCredential credential =
            EmailAuthProvider.credential(email: newEmail, password: 'test')
                as EmailAuthCredential;

        await auth.currentUser!.linkWithCredential(credential);

        verify(mockUserPlatform!.linkWithCredential(credential));
      });
    });

    group('reauthenticateWithCredential()', () {
      setUp(() {
        when(mockUserPlatform!.reauthenticateWithCredential(any))
            .thenAnswer((_) => Future.value(mockUserCredPlatform));
      });
      test('should call reauthenticateWithCredential()', () async {
        String newEmail = 'new@email.com';
        EmailAuthCredential credential =
            EmailAuthProvider.credential(email: newEmail, password: 'test')
                as EmailAuthCredential;

        await auth.currentUser!.reauthenticateWithCredential(credential);

        verify(mockUserPlatform!.reauthenticateWithCredential(credential));
      });
    });

    test('reload()', () async {
      await auth.currentUser!.reload();

      verify(mockUserPlatform!.reload());
    });

    test('sendEmailVerification()', () async {
      final ActionCodeSettings actionCodeSettings =
          ActionCodeSettings(url: 'test');

      await auth.currentUser!.sendEmailVerification(actionCodeSettings);

      verify(mockUserPlatform!.sendEmailVerification(actionCodeSettings));
    });

    group('unlink()', () {
      setUp(() {
        when(mockUserPlatform!.unlink(any))
            .thenAnswer((_) => Future.value(mockUserPlatform));
      });
      test('should call unlink()', () async {
        const String providerId = 'providerId';

        await auth.currentUser!.unlink(providerId);

        verify(mockUserPlatform!.unlink(providerId));
      });
    });
    group('updateEmail()', () {
      test('should call updateEmail()', () async {
        const String newEmail = 'newEmail';

        await auth.currentUser!.updateEmail(newEmail);

        verify(mockUserPlatform!.updateEmail(newEmail));
      });
    });

    group('updatePassword()', () {
      test('should call updatePassword()', () async {
        const String newPassword = 'newPassword';

        await auth.currentUser!.updatePassword(newPassword);

        verify(mockUserPlatform!.updatePassword(newPassword));
      });
    });
    group('updatePhoneNumber()', () {
      test('should call updatePhoneNumber()', () async {
        PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
            verificationId: 'test', smsCode: 'test') as PhoneAuthCredential;

        await auth.currentUser!.updatePhoneNumber(phoneAuthCredential);

        verify(mockUserPlatform!.updatePhoneNumber(phoneAuthCredential));
      });
    });

    test('updateProfile()', () async {
      const String displayName = 'updatedName';
      const String photoURL = 'testUrl';
      Map<String, String> data = <String, String>{
        'displayName': displayName,
        'photoURL': photoURL
      };

      await auth.currentUser!
          .updateProfile(displayName: displayName, photoURL: photoURL);

      verify(mockUserPlatform!.updateProfile(data));
    });

    group('verifyBeforeUpdateEmail()', () {
      test('should call verifyBeforeUpdateEmail()', () async {
        const newEmail = 'new@email.com';
        ActionCodeSettings actionCodeSettings = ActionCodeSettings(url: 'test');

        await auth.currentUser!
            .verifyBeforeUpdateEmail(newEmail, actionCodeSettings);

        verify(mockUserPlatform!
            .verifyBeforeUpdateEmail(newEmail, actionCodeSettings));
      });
    });

    test('toString()', () async {
      when(mockAuthPlatform.currentUser)
          .thenReturn(TestUserPlatform(mockAuthPlatform, user!));

      const userInfo = 'UserInfo('
          'displayName: Flutter Test User, '
          'email: test@example.com, '
          'phoneNumber: null, '
          'photoURL: http://www.example.com/, '
          'providerId: firebase, '
          'uid: 12345)';

      final userMetadata = 'UserMetadata('
          'creationTime: ${DateTime.fromMillisecondsSinceEpoch(kMockCreationTimestamp)}, '
          'lastSignInTime: ${DateTime.fromMillisecondsSinceEpoch(kMockLastSignInTimestamp)})';

      expect(
        auth.currentUser.toString(),
        'User('
        'displayName: displayName, '
        'email: null, '
        'emailVerified: false, '
        'isAnonymous: true, '
        'metadata: $userMetadata, '
        'phoneNumber: null, '
        'photoURL: null, '
        'providerData, '
        '[$userInfo], '
        'refreshToken: null, '
        'tenantId: null, '
        'uid: null)',
      );
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
    UserPlatform userPlatform,
  ) {
    TestUserCredentialPlatform(
      auth,
      additionalUserInfo,
      credential,
      userPlatform,
    );
  }
}

class TestFirebaseAuthPlatform extends FirebaseAuthPlatform {
  TestFirebaseAuthPlatform() : super();

  // TODO
  // instanceFor({FirebaseApp? app, Map<dynamic, dynamic>? pluginConstants}) {}

  @override
  FirebaseAuthPlatform delegateFor({FirebaseApp? app}) => this;

  @override
  FirebaseAuthPlatform setInitialValues({
    Map<String, dynamic>? currentUser,
    String? languageCode,
  }) {
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
    UserPlatform userPlatform,
  ) : super(
            auth: auth,
            additionalUserInfo: additionalUserInfo,
            credential: credential,
            user: userPlatform);
}
