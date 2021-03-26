// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_platform_interface/src/method_channel/method_channel_user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_platform_interface/src/method_channel/method_channel_firebase_auth.dart';
import '../mock.dart';
import 'package:flutter/services.dart';

void main() {
  setupFirebaseAuthMocks();

  final List<MethodCall> log = <MethodCall>[];
  bool mockPlatformExceptionThrown = false;
  bool mockExceptionThrown = false;
  late FirebaseAuthPlatform auth;
  const String kMockProviderId = 'firebase';
  const String kMockUid = '12345';
  const String kMockDisplayName = 'Flutter Test User';
  const String kMockPhotoURL = 'http://www.example.com/';
  const String kMockEmail = 'test@example.com';
  const String kMockIdToken = '12345';
  const String kMockNewPhoneNumber = '5555555556';
  const String kMockIdTokenResultSignInProvider = 'password';
  const String kMockIdTokenResultSignInFactor = 'test';
  const Map<Object?, Object?> kMockIdTokenResultClaims = <Object?, Object?>{
    'claim1': 'value1',
  };
  const String kMockPhoneNumber = TEST_PHONE_NUMBER;
  final int kMockIdTokenResultExpirationTimestamp =
      DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch;
  final int kMockIdTokenResultAuthTimestamp =
      DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch;
  final int kMockIdTokenResultIssuedAtTimestamp =
      DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch;
  final Map<String, Object?> kMockIdTokenResult = Map.unmodifiable(
    <String, Object?>{
      'token': kMockIdToken,
      'expirationTimestamp': kMockIdTokenResultExpirationTimestamp,
      'authTimestamp': kMockIdTokenResultAuthTimestamp,
      'issuedAtTimestamp': kMockIdTokenResultIssuedAtTimestamp,
      'signInProvider': kMockIdTokenResultSignInProvider,
      'claims': kMockIdTokenResultClaims,
      'signInSecondFactor': kMockIdTokenResultSignInFactor
    },
  );

  final int kMockCreationTimestamp =
      DateTime.now().subtract(const Duration(days: 2)).millisecondsSinceEpoch;
  final int kMockLastSignInTimestamp =
      DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch;

  const kMockInitialProviderData = <Map<String, String>>[
    <String, String>{
      'providerId': kMockProviderId,
      'uid': kMockUid,
      'displayName': kMockDisplayName,
      'photoURL': kMockPhotoURL,
      'email': kMockEmail,
      'phoneNumber': kMockPhoneNumber,
    },
  ];

  final kMockUser = Map<String, Object?>.unmodifiable(
    <String, Object?>{
      'uid': kMockUid,
      'isAnonymous': true,
      'emailVerified': false,
      'metadata': <String, int>{
        'creationTime': kMockCreationTimestamp,
        'lastSignInTime': kMockLastSignInTimestamp,
      },
      'photoURL': kMockPhotoURL,
      'providerData': kMockInitialProviderData,
    },
  );

  Future<void> mockSignIn() async {
    await auth.signInAnonymously();
  }

  group('$MethodChannelUser', () {
    late Map<String, Object?> user;
    late List kMockProviderData;

    setUpAll(() async {
      FirebaseApp app = await Firebase.initializeApp();

      handleMethodCall((call) async {
        log.add(call);

        if (mockExceptionThrown) {
          throw Exception();
        } else if (mockPlatformExceptionThrown) {
          throw PlatformException(code: 'UNKNOWN');
        }

        switch (call.method) {
          case 'Auth#registerChangeListeners':
            return <String, Object?>{};
          case 'Auth#signInAnonymously':
            return <String, Object?>{'user': user};
          case 'Auth#signInWithEmailAndPassword':
            user = generateUser(
                user, <String, Object?>{'email': call.arguments['email']});
            return <String, Object?>{'user': user};
          case 'User#updateProfile':
            Map<String, Object?> previousUser = user;
            user = generateUser(
              user,
              Map<String, Object?>.from(
                call.arguments['profile'] as Map<String, Object?>,
              ),
            );
            return previousUser;
          case 'User#updatePhoneNumber':
            Map<String, Object?> previousUser = user;
            user = generateUser(
                user, <String, Object?>{'phoneNumber': kMockNewPhoneNumber});
            return previousUser;
          case 'User#updatePassword':
          case 'User#updateEmail':
          case 'User#sendLinkToEmail':
          case 'User#sendPasswordResetEmail':
            Map<String, Object?> previousUser = user;
            user = generateUser(
                user, <String, Object?>{'email': call.arguments['newEmail']});
            return previousUser;
          case 'User#getIdToken':
            if (call.arguments['tokenOnly'] == false) {
              return kMockIdTokenResult;
            }
            return <String, Object?>{'token': kMockIdToken};
          case 'User#reload':
            return user;
          case 'User#reauthenticateUserWithCredential':
          case 'User#linkWithCredential':
            user = generateUser(
                user, <String, Object?>{'providerData': kMockProviderData});
            return <String, Object?>{'user': user};
          case 'User#unlink':
            user = generateUser(
              user,
              <String, Object?>{'providerData': <Object?>[]},
            );
            return <String, Object?>{'user': user};
          default:
            return <String, Object?>{'user': user};
        }
      });

      auth = MethodChannelFirebaseAuth(app: app);
      user = kMockUser;
    });

    setUp(() async {
      user = kMockUser;

      mockPlatformExceptionThrown = false;
      mockExceptionThrown = false;
      kMockProviderData = kMockInitialProviderData;
      await mockSignIn();

      log.clear();
    });
    group('User.displayName', () {
      test('should return null', () async {
        expect(auth.currentUser!.displayName, isNull);
      });
      test('should return correct value', () async {
        // Setup
        user =
            generateUser(user, <String, Object?>{'displayName': 'updatedName'});
        await auth.currentUser!.reload();

        expect(auth.currentUser!.displayName, equals('updatedName'));
      });
    });

    group('User.email', () {
      test('should return null', () async {
        expect(auth.currentUser!.email, isNull);
      });
      test('should return correct value', () async {
        const updatedEmail = 'updated@email.com';
        user = generateUser(user, <String, Object?>{'email': updatedEmail});
        await auth.currentUser!.reload();

        expect(auth.currentUser!.email, equals(updatedEmail));
      });
    });

    group('User.emailVerified', () {
      test('should return false', () async {
        expect(auth.currentUser!.emailVerified, isFalse);
      });
      test('should return true', () async {
        user = generateUser(user, <String, Object?>{'emailVerified': true});
        await auth.currentUser!.reload();

        expect(auth.currentUser!.emailVerified, isTrue);
      });
    });

    group('User.isAnonymous', () {
      test('should return true', () async {
        expect(auth.currentUser!.isAnonymous, isTrue);
      });
      test('should return false', () async {
        user = generateUser(user, <String, Object?>{'isAnonymous': false});
        await auth.currentUser!.reload();

        expect(auth.currentUser!.isAnonymous, isFalse);
      });
    });

    test('User.metadata', () async {
      final metadata = auth.currentUser!.metadata;

      expect(metadata, isA<UserMetadata>());
      expect(metadata.creationTime!.millisecondsSinceEpoch,
          kMockCreationTimestamp);
      expect(metadata.lastSignInTime!.millisecondsSinceEpoch,
          kMockLastSignInTimestamp);
    });

    test('User.photoURL', () async {
      expect(auth.currentUser!.photoURL, equals(kMockPhotoURL));
    });

    test('User.providerData', () async {
      final providerData = auth.currentUser!.providerData;
      expect(providerData, isA<List<UserInfo>>());

      expect(providerData[0].displayName, equals(kMockDisplayName));
      expect(providerData[0].email, equals(kMockEmail));
      expect(providerData[0].photoURL, equals(kMockPhotoURL));
      expect(providerData[0].phoneNumber, equals(kMockPhoneNumber));
      expect(providerData[0].uid, equals(kMockUid));
      expect(providerData[0].providerId, equals(kMockProviderId));
    });

    test('User.refreshToken', () async {
      expect(auth.currentUser!.refreshToken, isNull);
    });

    test('User.tenantId', () async {
      expect(auth.currentUser!.tenantId, isNull);
    });

    test('User.uid', () async {
      expect(auth.currentUser!.uid, equals(kMockUid));
    });

    group('delete()', () {
      test('should run successfully', () async {
        await auth.currentUser!.delete();

        expect(
          log,
          <Matcher>[
            isMethodCall(
              'User#delete',
              arguments: <String, String>{'appName': '[DEFAULT]'},
            ),
          ],
        );
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseAuthException] error',
          () async {
        mockPlatformExceptionThrown = true;

        void callMethod() => auth.currentUser!.delete();
        await testExceptionHandling('PLATFORM', callMethod);
      });
    });

    group('getIdToken()', () {
      test('should run successfully', () async {
        final token = await auth.currentUser!.getIdToken(true);

        expect(
          log,
          <Matcher>[
            isMethodCall(
              'User#getIdToken',
              arguments: <String, Object?>{
                'appName': '[DEFAULT]',
                'forceRefresh': true,
                'tokenOnly': true
              },
            ),
          ],
        );
        expect(token, isA<String>());
        expect(token, equals(kMockIdToken));
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseAuthException] error',
          () async {
        mockPlatformExceptionThrown = true;

        void callMethod() => auth.currentUser!.getIdToken(true);
        await testExceptionHandling('PLATFORM', callMethod);
      });
    });
    group('getIdTokenResult()', () {
      test('should run successfully', () async {
        final idTokenResult = await auth.currentUser!.getIdTokenResult(true);

        expect(
          log,
          <Matcher>[
            isMethodCall(
              'User#getIdToken',
              arguments: <String, Object?>{
                'appName': '[DEFAULT]',
                'forceRefresh': true,
                'tokenOnly': false
              },
            ),
          ],
        );
        expect(idTokenResult, isA<IdTokenResult>());
        expect(idTokenResult.authTime!.millisecondsSinceEpoch,
            equals(kMockIdTokenResultAuthTimestamp));
        expect(idTokenResult.claims, equals(kMockIdTokenResultClaims));
        expect(idTokenResult.expirationTime!.millisecondsSinceEpoch,
            equals(kMockIdTokenResultExpirationTimestamp));
        expect(idTokenResult.issuedAtTime!.millisecondsSinceEpoch,
            equals(kMockIdTokenResultIssuedAtTimestamp));
        expect(idTokenResult.token, equals(kMockIdToken));
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseAuthException] error',
          () async {
        mockPlatformExceptionThrown = true;

        void callMethod() => auth.currentUser!.getIdTokenResult(true);
        await testExceptionHandling('PLATFORM', callMethod);
      });
    });

    group('linkWithCredential()', () {
      String newEmail = 'new@email.com';
      EmailAuthCredential credential =
          EmailAuthProvider.credential(email: newEmail, password: 'test')
              as EmailAuthCredential;

      test('should run successfully', () async {
        kMockProviderData.add(<String, String>{
          'email': newEmail,
          'providerId': 'email',
          'uid': kMockUid,
          'displayName': kMockDisplayName,
          'photoURL': kMockPhotoURL,
        });
        final result = await auth.currentUser!.linkWithCredential(credential);

        expect(
          log,
          <Matcher>[
            isMethodCall(
              'User#linkWithCredential',
              arguments: <String, Object?>{
                'appName': '[DEFAULT]',
                'credential': credential.asMap()
              },
            ),
          ],
        );
        expect(result, isA<UserCredentialPlatform>());
        expect(result.user!.providerData.length, equals(2));

        // check currentUser updated
        expect(auth.currentUser!.providerData.length, equals(2));
        expect(auth.currentUser!.providerData[1].email, equals(newEmail));
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseAuthException] error',
          () async {
        mockPlatformExceptionThrown = true;

        void callMethod() => auth.currentUser!.linkWithCredential(credential);
        await testExceptionHandling('PLATFORM', callMethod);
      });
    });

    group('reauthenticateWithCredential()', () {
      String newEmail = 'new@email.com';
      EmailAuthCredential credential =
          EmailAuthProvider.credential(email: newEmail, password: 'test')
              as EmailAuthCredential;

      test('should run successfully', () async {
        kMockProviderData.add(<String, String>{
          'email': newEmail,
          'providerId': 'email',
          'uid': kMockUid,
          'displayName': kMockDisplayName,
          'photoURL': kMockPhotoURL,
        });
        final result =
            await auth.currentUser!.reauthenticateWithCredential(credential);

        expect(
          log,
          <Matcher>[
            isMethodCall(
              'User#reauthenticateUserWithCredential',
              arguments: <String, Object?>{
                'appName': '[DEFAULT]',
                'credential': credential.asMap()
              },
            ),
          ],
        );
        expect(result, isA<UserCredentialPlatform>());
        expect(result.user!.providerData.length, equals(2));

        // check currentUser updated
        expect(auth.currentUser!.providerData.length, equals(2));
        expect(auth.currentUser!.providerData[1].email, equals(newEmail));
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseAuthException] error',
          () async {
        mockPlatformExceptionThrown = true;

        void callMethod() =>
            auth.currentUser!.reauthenticateWithCredential(credential);
        await testExceptionHandling('PLATFORM', callMethod);
      });
    });

    group('reload()', () {
      test('should run successfully', () async {
        // Setup
        expect(auth.currentUser!.displayName, isNull);
        user = generateUser(
            user, <String, Object?>{'displayName': 'test'}); // change mock user

        // Test
        await auth.currentUser!.reload();

        // Assumptions
        expect(
          log,
          <Matcher>[
            isMethodCall(
              'User#reload',
              arguments: <String, Object?>{
                'appName': '[DEFAULT]',
              },
            )
          ],
        );
        expect(auth.currentUser!.displayName, 'test');
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseAuthException] error',
          () async {
        mockPlatformExceptionThrown = true;

        void callMethod() => auth.currentUser!.reload();
        await testExceptionHandling('PLATFORM', callMethod);
      });
    });
    group('sendEmailVerification()', () {
      ActionCodeSettings actionCodeSettings = ActionCodeSettings(url: 'test');

      test('should run successfully', () async {
        // Test
        await auth.currentUser!.sendEmailVerification(actionCodeSettings);

        // Assumptions
        expect(
          log,
          <Matcher>[
            isMethodCall(
              'User#sendEmailVerification',
              arguments: <String, Object?>{
                'appName': '[DEFAULT]',
                'actionCodeSettings': actionCodeSettings.asMap()
              },
            )
          ],
        );
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseAuthException] error',
          () async {
        mockPlatformExceptionThrown = true;

        void callMethod() =>
            auth.currentUser!.sendEmailVerification(actionCodeSettings);
        await testExceptionHandling('PLATFORM', callMethod);
      });
    });

    group('unlink()', () {
      test('should run successfully', () async {
        expect(auth.currentUser!.providerData.length, equals(1));
        final unlinkedUser = await auth.currentUser!.unlink(kMockProviderId);

        expect(
          log,
          <Matcher>[
            isMethodCall(
              'User#unlink',
              arguments: <String, Object?>{
                'appName': '[DEFAULT]',
                'providerId': kMockProviderId
              },
            )
          ],
        );

        expect(unlinkedUser, isA<UserPlatform>());
        expect(unlinkedUser.providerData.length, equals(0));

        // check currentUser updated
        expect(auth.currentUser!.providerData.length, equals(0));
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseAuthException] error',
          () async {
        mockPlatformExceptionThrown = true;

        void callMethod() => auth.currentUser!.unlink(kMockProviderId);
        await testExceptionHandling('PLATFORM', callMethod);
      });
    });

    group('updateEmail()', () {
      const newEmail = 'new@email.com';

      test('should run successfully', () async {
        await auth.currentUser!.updateEmail(newEmail);

        expect(
          log,
          <Matcher>[
            isMethodCall(
              'User#updateEmail',
              arguments: <String, Object?>{
                'appName': '[DEFAULT]',
                'newEmail': newEmail
              },
            )
          ],
        );

        await auth.currentUser!.reload();
        expect(auth.currentUser!.email, equals(newEmail));
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseAuthException] error',
          () async {
        mockPlatformExceptionThrown = true;

        void callMethod() => auth.currentUser!.updateEmail(newEmail);
        await testExceptionHandling('PLATFORM', callMethod);
      });
    });

    group('updatePassword()', () {
      const newPassword = 'newPassword';

      test('gets result successfully', () async {
        await auth.currentUser!.updatePassword(newPassword);

        expect(
          log[0],
          isMethodCall(
            'User#updatePassword',
            arguments: <String, Object?>{
              'appName': '[DEFAULT]',
              'newPassword': newPassword
            },
          ),
        );
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseAuthException] error',
          () async {
        mockPlatformExceptionThrown = true;

        void callMethod() => auth.currentUser!.updatePassword(newPassword);
        await testExceptionHandling('PLATFORM', callMethod);
      });
    });

    group('updatePhoneNumber()', () {
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: 'test',
        smsCode: 'test',
      );

      test('gets result successfully', () async {
        await auth.currentUser!.updatePhoneNumber(phoneAuthCredential);

        expect(
          log,
          <Matcher>[
            isMethodCall(
              'User#updatePhoneNumber',
              arguments: <String, Object?>{
                'appName': '[DEFAULT]',
                'credential': <String, Object?>{
                  'providerId': 'phone',
                  'signInMethod': 'phone',
                  'verificationId': 'test',
                  'smsCode': 'test',
                  'token': null
                }
              },
            )
          ],
        );

        await auth.currentUser!.reload();
        expect(auth.currentUser!.phoneNumber, kMockNewPhoneNumber);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseAuthException] error',
          () async {
        mockPlatformExceptionThrown = true;

        void callMethod() =>
            auth.currentUser!.updatePhoneNumber(phoneAuthCredential);
        await testExceptionHandling('PLATFORM', callMethod);
      });
    });

    group('updateProfile()', () {
      String newDisplayName = 'newDisplayName';
      String newPhotoURL = 'newPhotoURL';
      Map<String, String> data = <String, String>{
        'displayName': newDisplayName,
        'photoURL': newPhotoURL
      };
      test('updateProfile()', () async {
        await auth.currentUser!.updateProfile(data);

        expect(
          log,
          <Matcher>[
            isMethodCall(
              'User#updateProfile',
              arguments: <String, Object?>{
                'appName': '[DEFAULT]',
                'profile': <String, Object?>{
                  'displayName': newDisplayName,
                  'photoURL': newPhotoURL,
                }
              },
            )
          ],
        );

        await auth.currentUser!.reload();
        expect(auth.currentUser!.displayName, equals(newDisplayName));
        expect(auth.currentUser!.photoURL, equals(newPhotoURL));
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseAuthException] error',
          () async {
        mockPlatformExceptionThrown = true;

        void callMethod() => auth.currentUser!.updateProfile(data);
        await testExceptionHandling('PLATFORM', callMethod);
      });
    });

    group('verifyBeforeUpdateEmail()', () {
      final ActionCodeSettings actionCodeSettings = ActionCodeSettings(
        url: 'test',
      );
      const newEmail = 'new@email.com';
      test('verifyBeforeUpdateEmail()', () async {
        await auth.currentUser!
            .verifyBeforeUpdateEmail(newEmail, actionCodeSettings);
        expect(
          log,
          <Matcher>[
            isMethodCall(
              'User#verifyBeforeUpdateEmail',
              arguments: <String, Object?>{
                'appName': '[DEFAULT]',
                'newEmail': newEmail,
                'actionCodeSettings': actionCodeSettings.asMap(),
              },
            )
          ],
        );
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseAuthException] error',
          () async {
        mockPlatformExceptionThrown = true;

        void callMethod() => auth.currentUser!
            .verifyBeforeUpdateEmail(newEmail, actionCodeSettings);
        await testExceptionHandling('PLATFORM', callMethod);
      });
    });
  });
}
