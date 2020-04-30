// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

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
const String kMockOobCode = 'oobcode';
const Map<dynamic, dynamic> kMockIdTokenResultClaims = <dynamic, dynamic>{
  'claim1': 'value1',
};
const int kMockIdTokenResultExpirationTimestamp = 123456;
const int kMockIdTokenResultAuthTimestamp = 1234567;
const int kMockIdTokenResultIssuedAtTimestamp = 12345678;
const Map<String, dynamic> kMockIdTokenResult = <String, dynamic>{
  'token': kMockIdToken,
  'expirationTimestamp': kMockIdTokenResultExpirationTimestamp,
  'authTimestamp': kMockIdTokenResultAuthTimestamp,
  'issuedAtTimestamp': kMockIdTokenResultIssuedAtTimestamp,
  'signInProvider': kMockIdTokenResultSignInProvider,
  'claims': kMockIdTokenResultClaims,
};

final int kMockCreationTimestamp = DateTime(2019, 1, 1).millisecondsSinceEpoch;
final int kMockLastSignInTimestamp =
    DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch;
final Map<String, dynamic> kMockUser = <String, dynamic>{
  'isAnonymous': true,
  'isEmailVerified': false,
  'creationTimestamp': kMockCreationTimestamp,
  'lastSignInTimestamp': kMockLastSignInTimestamp,
  'providerData': <Map<String, String>>[
    <String, String>{
      'providerId': kMockProviderId,
      'uid': kMockUid,
      'displayName': kMockDisplayName,
      'photoUrl': kMockPhotoUrl,
      'email': kMockEmail,
    },
  ],
};
const Map<String, dynamic> kMockAdditionalUserInfo = <String, dynamic>{
  'isNewUser': false,
  'username': 'flutterUser',
  'providerId': 'testProvider',
  'profile': <String, dynamic>{'foo': 'bar'},
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$MethodChannelFirebaseAuth', () {
    final String appName = 'testApp';
    final FirebaseAuthPlatform auth = MethodChannelFirebaseAuth();
    final List<MethodCall> log = <MethodCall>[];

    int mockHandleId = 0;

    setUp(() {
      log.clear();
      MethodChannelFirebaseAuth.channel
          .setMockMethodCallHandler((MethodCall call) async {
        log.add(call);
        switch (call.method) {
          case "getIdToken":
            return kMockIdTokenResult;
            break;
          case "isSignInWithEmailLink":
            return true;
          case "startListeningAuthState":
            return mockHandleId++;
            break;
          case "currentUser":
            return kMockUser;
          case "sendLinkToEmail":
          case "sendPasswordResetEmail":
          case "updateEmail":
          case "updatePhoneNumberCredential":
          case "updatePassword":
          case "updateProfile":
            return null;
            break;
          case "fetchSignInMethodsForEmail":
            return List<String>(0);
            break;
          case "verifyPhoneNumber":
            return null;
            break;
          default:
            return <String, dynamic>{
              'user': kMockUser,
              'additionalUserInfo': kMockAdditionalUserInfo,
            };
            break;
        }
      });
    });

    void verifyUser(PlatformUser user) {
      expect(user, isNotNull);
      expect(user.isAnonymous, isTrue);
      expect(user.isEmailVerified, isFalse);
      expect(user.providerData.length, 1);
      final PlatformUserInfo userInfo = user.providerData[0];
      expect(userInfo.providerId, kMockProviderId);
      expect(userInfo.uid, kMockUid);
      expect(userInfo.displayName, kMockDisplayName);
      expect(userInfo.photoUrl, kMockPhotoUrl);
      expect(userInfo.email, kMockEmail);
      expect(user.creationTimestamp, kMockCreationTimestamp);
      expect(user.lastSignInTimestamp, kMockLastSignInTimestamp);
    }

    void verifyAuthResult(PlatformAuthResult result) {
      verifyUser(result.user);
      final PlatformAdditionalUserInfo additionalUserInfo =
          result.additionalUserInfo;
      expect(
          additionalUserInfo.isNewUser, kMockAdditionalUserInfo['isNewUser']);
      expect(additionalUserInfo.username, kMockAdditionalUserInfo['username']);
      expect(
          additionalUserInfo.providerId, kMockAdditionalUserInfo['providerId']);
      expect(additionalUserInfo.profile, kMockAdditionalUserInfo['profile']);
    }

    test('getCurrentUser', () async {
      await auth.getCurrentUser(appName);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'currentUser',
            arguments: <String, dynamic>{
              'app': appName,
            },
          ),
        ],
      );
    });

    test('getIdToken', () async {
      void verifyIdTokenResult(PlatformIdTokenResult idTokenResult) {
        expect(idTokenResult.token, equals(kMockIdToken));
        expect(
          idTokenResult.expirationTimestamp,
          equals(kMockIdTokenResultExpirationTimestamp),
        );
        expect(
          idTokenResult.authTimestamp,
          equals(kMockIdTokenResultAuthTimestamp),
        );
        expect(
          idTokenResult.issuedAtTimestamp,
          equals(kMockIdTokenResultIssuedAtTimestamp),
        );
        expect(idTokenResult.signInProvider,
            equals(kMockIdTokenResultSignInProvider));
        expect(idTokenResult.claims, equals(kMockIdTokenResultClaims));
      }

      verifyIdTokenResult(await auth.getIdToken(appName, false));
      verifyIdTokenResult(await auth.getIdToken(appName, true));
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'getIdToken',
            arguments: <String, dynamic>{
              'refresh': false,
              'app': appName,
            },
          ),
          isMethodCall(
            'getIdToken',
            arguments: <String, dynamic>{'refresh': true, 'app': appName},
          ),
        ],
      );
    });

    test('signInAnonymously', () async {
      final PlatformAuthResult result = await auth.signInAnonymously(appName);
      verifyAuthResult(result);
      expect(
        log,
        <Matcher>[
          isMethodCall('signInAnonymously',
              arguments: <String, String>{'app': appName}),
        ],
      );
    });

    test('signInAnonymously with null additionalUserInfo', () async {
      MethodChannelFirebaseAuth.channel
          .setMockMethodCallHandler((MethodCall call) async {
        log.add(call);
        return <String, dynamic>{
          'user': kMockUser,
        };
      });
      final PlatformAuthResult result = await auth.signInAnonymously(appName);
      verifyUser(result.user);
      expect(result.additionalUserInfo, isNull);
      expect(
        log,
        <Matcher>[
          isMethodCall('signInAnonymously',
              arguments: <String, String>{'app': appName}),
        ],
      );
    });

    test('sendLinkToEmail', () async {
      await auth.sendLinkToEmail(
        appName,
        email: 'test@example.com',
        url: 'http://www.example.com/',
        handleCodeInApp: true,
        iOSBundleID: 'com.example.app',
        androidPackageName: 'com.example.app',
        androidInstallIfNotAvailable: false,
        androidMinimumVersion: "12",
      );
      expect(
        log,
        <Matcher>[
          isMethodCall('sendLinkToEmail', arguments: <String, dynamic>{
            'email': 'test@example.com',
            'url': 'http://www.example.com/',
            'handleCodeInApp': true,
            'iOSBundleID': 'com.example.app',
            'androidPackageName': 'com.example.app',
            'androidInstallIfNotAvailable': false,
            'androidMinimumVersion': '12',
            'app': appName,
          }),
        ],
      );
    });

    test('isSignInWithEmailLink', () async {
      final bool result = await auth.isSignInWithEmailLink(appName, 'foo');
      expect(result, true);
      expect(
        log,
        <Matcher>[
          isMethodCall('isSignInWithEmailLink',
              arguments: <String, String>{'link': 'foo', 'app': appName}),
        ],
      );
    });

    test('signInWithEmailAndLink', () async {
      final PlatformAuthResult result = await auth.signInWithEmailAndLink(
        appName,
        'test@example.com',
        '<Url with domain from your Firebase project>',
      );
      verifyAuthResult(result);
      expect(
        log,
        <Matcher>[
          isMethodCall('signInWithEmailAndLink', arguments: <String, dynamic>{
            'email': 'test@example.com',
            'link': '<Url with domain from your Firebase project>',
            'app': appName,
          }),
        ],
      );
    });

    test('createUserWithEmailAndPassword', () async {
      final PlatformAuthResult result =
          await auth.createUserWithEmailAndPassword(
        appName,
        kMockEmail,
        kMockPassword,
      );
      verifyAuthResult(result);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'createUserWithEmailAndPassword',
            arguments: <String, String>{
              'email': kMockEmail,
              'password': kMockPassword,
              'app': appName,
            },
          ),
        ],
      );
    });

    test('fetchSignInMethodsForEmail', () async {
      final List<String> providers =
          await auth.fetchSignInMethodsForEmail(appName, kMockEmail);
      expect(providers, isNotNull);
      expect(providers.length, 0);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'fetchSignInMethodsForEmail',
            arguments: <String, String>{
              'email': kMockEmail,
              'app': appName,
            },
          ),
        ],
      );
    });

    test('EmailAuthProvider (withLink) linkWithCredential', () async {
      const AuthCredential credential = EmailAuthCredential(
        email: 'test@example.com',
        link: '<Url with domain from your Firebase project>',
      );
      final PlatformAuthResult result =
          await auth.linkWithCredential(appName, credential);
      verifyAuthResult(result);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'linkWithCredential',
            arguments: <String, dynamic>{
              'app': appName,
              'provider': 'password',
              'data': <String, String>{
                'email': 'test@example.com',
                'link': '<Url with domain from your Firebase project>',
              },
            },
          ),
        ],
      );
    });

    test('EmailAuthProvider (withLink) signInWithCredential', () async {
      const AuthCredential credential = EmailAuthCredential(
        email: 'test@example.com',
        link: '<Url with domain from your Firebase project>',
      );
      final PlatformAuthResult result =
          await auth.signInWithCredential(appName, credential);
      verifyAuthResult(result);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'signInWithCredential',
            arguments: <String, dynamic>{
              'app': appName,
              'provider': 'password',
              'data': <String, String>{
                'email': 'test@example.com',
                'link': '<Url with domain from your Firebase project>',
              },
            },
          ),
        ],
      );
    });

    test('EmailAuthProvider (withLink) reauthenticateWithCredential', () async {
      const AuthCredential credential = EmailAuthCredential(
        email: 'test@example.com',
        link: '<Url with domain from your Firebase project>',
      );
      await auth.reauthenticateWithCredential(appName, credential);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'reauthenticateWithCredential',
            arguments: <String, dynamic>{
              'app': appName,
              'provider': 'password',
              'data': <String, String>{
                'email': 'test@example.com',
                'link': '<Url with domain from your Firebase project>',
              }
            },
          ),
        ],
      );
    });

    test('TwitterAuthProvider linkWithCredential', () async {
      const AuthCredential credential = TwitterAuthCredential(
        authToken: kMockIdToken,
        authTokenSecret: kMockAccessToken,
      );
      final PlatformAuthResult result =
          await auth.linkWithCredential(appName, credential);
      verifyAuthResult(result);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'linkWithCredential',
            arguments: <String, dynamic>{
              'app': appName,
              'provider': 'twitter.com',
              'data': <String, String>{
                'authToken': kMockIdToken,
                'authTokenSecret': kMockAccessToken,
              },
            },
          ),
        ],
      );
    });

    test('TwitterAuthProvider signInWithCredential', () async {
      const AuthCredential credential = TwitterAuthCredential(
        authToken: kMockIdToken,
        authTokenSecret: kMockAccessToken,
      );
      final PlatformAuthResult result =
          await auth.signInWithCredential(appName, credential);
      verifyAuthResult(result);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'signInWithCredential',
            arguments: <String, dynamic>{
              'app': appName,
              'provider': 'twitter.com',
              'data': <String, String>{
                'authToken': kMockIdToken,
                'authTokenSecret': kMockAccessToken,
              },
            },
          ),
        ],
      );
    });

    test('GithubAuthProvider linkWithCredential', () async {
      const AuthCredential credential = GithubAuthCredential(
        token: kMockGithubToken,
      );
      final PlatformAuthResult result =
          await auth.linkWithCredential(appName, credential);
      verifyAuthResult(result);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'linkWithCredential',
            arguments: <String, dynamic>{
              'app': appName,
              'provider': 'github.com',
              'data': <String, String>{
                'token': kMockGithubToken,
              }
            },
          ),
        ],
      );
    });

    test('GitHubAuthProvider signInWithCredential', () async {
      const AuthCredential credential = GithubAuthCredential(
        token: kMockGithubToken,
      );
      final PlatformAuthResult result =
          await auth.signInWithCredential(appName, credential);
      verifyAuthResult(result);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'signInWithCredential',
            arguments: <String, dynamic>{
              'app': appName,
              'provider': 'github.com',
              'data': <String, String>{
                'token': kMockGithubToken,
              },
            },
          ),
        ],
      );
    });

    test('EmailAuthProvider linkWithCredential', () async {
      const AuthCredential credential = EmailAuthCredential(
        email: kMockEmail,
        password: kMockPassword,
      );
      final PlatformAuthResult result =
          await auth.linkWithCredential(appName, credential);
      verifyAuthResult(result);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'linkWithCredential',
            arguments: <String, dynamic>{
              'app': appName,
              'provider': 'password',
              'data': <String, String>{
                'email': kMockEmail,
                'password': kMockPassword,
              },
            },
          ),
        ],
      );
    });

    test('GoogleAuthProvider signInWithCredential', () async {
      const AuthCredential credential = GoogleAuthCredential(
        idToken: kMockIdToken,
        accessToken: kMockAccessToken,
      );
      final PlatformAuthResult result =
          await auth.signInWithCredential(appName, credential);
      verifyAuthResult(result);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'signInWithCredential',
            arguments: <String, dynamic>{
              'app': appName,
              'provider': 'google.com',
              'data': <String, String>{
                'idToken': kMockIdToken,
                'accessToken': kMockAccessToken,
              },
            },
          ),
        ],
      );
    });

    test('PlatformOAuthProvider signInWithCredential', () async {
      const AuthCredential credential = PlatformOAuthCredential(
        providerId: "generic_provider.com",
        idToken: kMockIdToken,
        accessToken: kMockAccessToken,
      );
      final PlatformAuthResult result =
          await auth.signInWithCredential(appName, credential);
      verifyAuthResult(result);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'signInWithCredential',
            arguments: <String, dynamic>{
              'app': appName,
              'provider': 'generic_provider.com',
              'data': <String, String>{
                'idToken': kMockIdToken,
                'accessToken': kMockAccessToken,
                'providerId': "generic_provider.com",
                'rawNonce': null
              },
            },
          ),
        ],
      );
    });

    test('PhoneAuthProvider signInWithCredential', () async {
      const AuthCredential credential = PhoneAuthCredential(
        verificationId: kMockVerificationId,
        smsCode: kMockSmsCode,
      );
      final PlatformAuthResult result =
          await auth.signInWithCredential(appName, credential);
      verifyAuthResult(result);
      expect(log, <Matcher>[
        isMethodCall('signInWithCredential', arguments: <String, dynamic>{
          'app': appName,
          'provider': 'phone',
          'data': <String, String>{
            'verificationId': kMockVerificationId,
            'smsCode': kMockSmsCode,
          },
        })
      ]);
    });

    test('verifyPhoneNumber', () async {
      await auth.verifyPhoneNumber(appName,
          phoneNumber: kMockPhoneNumber,
          timeout: const Duration(seconds: 5),
          verificationCompleted: null,
          verificationFailed: null,
          codeSent: null,
          codeAutoRetrievalTimeout: null);
      expect(log, <Matcher>[
        isMethodCall('verifyPhoneNumber', arguments: <String, dynamic>{
          'handle': 1,
          'phoneNumber': kMockPhoneNumber,
          'timeout': 5000,
          'forceResendingToken': null,
          'app': appName,
        })
      ]);
    });

    test('EmailAuthProvider reauthenticateWithCredential', () async {
      const AuthCredential credential = EmailAuthCredential(
        email: kMockEmail,
        password: kMockPassword,
      );
      final PlatformAuthResult result =
          await auth.reauthenticateWithCredential(appName, credential);
      verifyAuthResult(result);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'reauthenticateWithCredential',
            arguments: <String, dynamic>{
              'app': appName,
              'provider': 'password',
              'data': <String, String>{
                'email': kMockEmail,
                'password': kMockPassword,
              }
            },
          ),
        ],
      );
    });
    test('GoogleAuthProvider reauthenticateWithCredential', () async {
      const AuthCredential credential = GoogleAuthCredential(
        idToken: kMockIdToken,
        accessToken: kMockAccessToken,
      );
      final PlatformAuthResult result =
          await auth.reauthenticateWithCredential(appName, credential);
      verifyAuthResult(result);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'reauthenticateWithCredential',
            arguments: <String, dynamic>{
              'app': appName,
              'provider': 'google.com',
              'data': <String, String>{
                'idToken': kMockIdToken,
                'accessToken': kMockAccessToken,
              },
            },
          ),
        ],
      );
    });

    test('PlatformOAuthProvider reauthenticateWithCredential', () async {
      const AuthCredential credential = PlatformOAuthCredential(
        providerId: "generic_provider.com",
        idToken: kMockIdToken,
        accessToken: kMockAccessToken,
      );
      final PlatformAuthResult result =
          await auth.reauthenticateWithCredential(appName, credential);
      verifyAuthResult(result);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'reauthenticateWithCredential',
            arguments: <String, dynamic>{
              'app': appName,
              'provider': 'generic_provider.com',
              'data': <String, String>{
                'idToken': kMockIdToken,
                'accessToken': kMockAccessToken,
                'providerId': "generic_provider.com",
                'rawNonce': null
              },
            },
          ),
        ],
      );
    });

    test('FacebookAuthProvider reauthenticateWithCredential', () async {
      const AuthCredential credential = FacebookAuthCredential(
        accessToken: kMockAccessToken,
      );
      final PlatformAuthResult result =
          await auth.reauthenticateWithCredential(appName, credential);
      verifyAuthResult(result);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'reauthenticateWithCredential',
            arguments: <String, dynamic>{
              'app': appName,
              'provider': 'facebook.com',
              'data': <String, String>{
                'accessToken': kMockAccessToken,
              },
            },
          ),
        ],
      );
    });

    test('TwitterAuthProvider reauthenticateWithCredential', () async {
      const AuthCredential credential = TwitterAuthCredential(
        authToken: kMockAuthToken,
        authTokenSecret: kMockAuthTokenSecret,
      );
      final PlatformAuthResult result =
          await auth.reauthenticateWithCredential(appName, credential);
      verifyAuthResult(result);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'reauthenticateWithCredential',
            arguments: <String, dynamic>{
              'app': appName,
              'provider': 'twitter.com',
              'data': <String, String>{
                'authToken': kMockAuthToken,
                'authTokenSecret': kMockAuthTokenSecret,
              },
            },
          ),
        ],
      );
    });

    test('GithubAuthProvider reauthenticateWithCredential', () async {
      const AuthCredential credential = GithubAuthCredential(
        token: kMockGithubToken,
      );
      final PlatformAuthResult result =
          await auth.reauthenticateWithCredential(appName, credential);
      verifyAuthResult(result);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'reauthenticateWithCredential',
            arguments: <String, dynamic>{
              'app': appName,
              'provider': 'github.com',
              'data': <String, String>{
                'token': kMockGithubToken,
              },
            },
          ),
        ],
      );
    });

    test('GoogleAuthProvider linkWithCredential', () async {
      const AuthCredential credential = GoogleAuthCredential(
        idToken: kMockIdToken,
        accessToken: kMockAccessToken,
      );
      final PlatformAuthResult result =
          await auth.linkWithCredential(appName, credential);
      verifyAuthResult(result);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'linkWithCredential',
            arguments: <String, dynamic>{
              'app': appName,
              'provider': 'google.com',
              'data': <String, String>{
                'idToken': kMockIdToken,
                'accessToken': kMockAccessToken,
              },
            },
          ),
        ],
      );
    });

    test('PlatformOAuthProvider linkWithCredential', () async {
      const AuthCredential credential = PlatformOAuthCredential(
        providerId: "generic_provider.com",
        idToken: kMockIdToken,
        accessToken: kMockAccessToken,
      );
      final PlatformAuthResult result =
          await auth.linkWithCredential(appName, credential);
      verifyAuthResult(result);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'linkWithCredential',
            arguments: <String, dynamic>{
              'app': appName,
              'provider': 'generic_provider.com',
              'data': <String, String>{
                'idToken': kMockIdToken,
                'accessToken': kMockAccessToken,
                'providerId': "generic_provider.com",
                'rawNonce': null
              },
            },
          ),
        ],
      );
    });

    test('FacebookAuthProvider linkWithCredential', () async {
      const AuthCredential credential = FacebookAuthCredential(
        accessToken: kMockAccessToken,
      );
      final PlatformAuthResult result =
          await auth.linkWithCredential(appName, credential);
      verifyAuthResult(result);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'linkWithCredential',
            arguments: <String, dynamic>{
              'app': appName,
              'provider': 'facebook.com',
              'data': <String, String>{
                'accessToken': kMockAccessToken,
              },
            },
          ),
        ],
      );
    });

    test('FacebookAuthProvider signInWithCredential', () async {
      const AuthCredential credential = FacebookAuthCredential(
        accessToken: kMockAccessToken,
      );
      final PlatformAuthResult result =
          await auth.signInWithCredential(appName, credential);
      verifyAuthResult(result);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'signInWithCredential',
            arguments: <String, dynamic>{
              'app': appName,
              'provider': 'facebook.com',
              'data': <String, String>{
                'accessToken': kMockAccessToken,
              }
            },
          ),
        ],
      );
    });

    test('TwitterAuthProvider linkWithCredential', () async {
      const AuthCredential credential = TwitterAuthCredential(
        authToken: kMockAuthToken,
        authTokenSecret: kMockAuthTokenSecret,
      );
      final PlatformAuthResult result =
          await auth.linkWithCredential(appName, credential);
      verifyAuthResult(result);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'linkWithCredential',
            arguments: <String, dynamic>{
              'app': appName,
              'provider': 'twitter.com',
              'data': <String, String>{
                'authToken': kMockAuthToken,
                'authTokenSecret': kMockAuthTokenSecret,
              },
            },
          ),
        ],
      );
    });

    test('TwitterAuthProvider signInWithCredential', () async {
      const AuthCredential credential = TwitterAuthCredential(
        authToken: kMockAuthToken,
        authTokenSecret: kMockAuthTokenSecret,
      );
      final PlatformAuthResult result =
          await auth.signInWithCredential(appName, credential);
      verifyAuthResult(result);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'signInWithCredential',
            arguments: <String, dynamic>{
              'app': appName,
              'provider': 'twitter.com',
              'data': <String, String>{
                'authToken': kMockAuthToken,
                'authTokenSecret': kMockAuthTokenSecret,
              },
            },
          ),
        ],
      );
    });

    test('GithubAuthProvider linkWithCredential', () async {
      const AuthCredential credential = GithubAuthCredential(
        token: kMockGithubToken,
      );
      final PlatformAuthResult result =
          await auth.linkWithCredential(appName, credential);
      verifyAuthResult(result);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'linkWithCredential',
            arguments: <String, dynamic>{
              'app': appName,
              'provider': 'github.com',
              'data': <String, String>{
                'token': kMockGithubToken,
              },
            },
          ),
        ],
      );
    });

    test('GithubAuthProvider signInWithCredential', () async {
      const AuthCredential credential = GithubAuthCredential(
        token: kMockGithubToken,
      );
      final PlatformAuthResult result =
          await auth.signInWithCredential(appName, credential);
      verifyAuthResult(result);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'signInWithCredential',
            arguments: <String, dynamic>{
              'app': appName,
              'provider': 'github.com',
              'data': <String, String>{
                'token': kMockGithubToken,
              },
            },
          ),
        ],
      );
    });

    test('EmailAuthProvider linkWithCredential', () async {
      const AuthCredential credential = EmailAuthCredential(
        email: kMockEmail,
        password: kMockPassword,
      );
      final PlatformAuthResult result =
          await auth.linkWithCredential(appName, credential);
      verifyAuthResult(result);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'linkWithCredential',
            arguments: <String, dynamic>{
              'app': appName,
              'provider': 'password',
              'data': <String, String>{
                'email': kMockEmail,
                'password': kMockPassword,
              },
            },
          ),
        ],
      );
    });

    test('sendEmailVerification', () async {
      await auth.sendEmailVerification(appName);

      expect(
        log,
        <Matcher>[
          isMethodCall(
            'sendEmailVerification',
            arguments: <String, String>{'app': appName},
          ),
        ],
      );
    });

    test('reload', () async {
      await auth.reload(appName);

      expect(
        log,
        <Matcher>[
          isMethodCall(
            'reload',
            arguments: <String, String>{'app': appName},
          ),
        ],
      );
    });

    test('delete', () async {
      await auth.delete(appName);

      expect(
        log,
        <Matcher>[
          isMethodCall(
            'delete',
            arguments: <String, String>{'app': appName},
          ),
        ],
      );
    });

    test('sendPasswordResetEmail', () async {
      await auth.sendPasswordResetEmail(
        appName,
        kMockEmail,
      );
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'sendPasswordResetEmail',
            arguments: <String, String>{'email': kMockEmail, 'app': appName},
          ),
        ],
      );
    });

    test('updateEmail', () async {
      await auth.updateEmail(appName, kMockEmail);
      expect(log, <Matcher>[
        isMethodCall(
          'updateEmail',
          arguments: <String, String>{
            'email': kMockEmail,
            'app': appName,
          },
        ),
      ]);
    });

    test('updatePhoneNumberCredential', () async {
      const AuthCredential credentials = PhoneAuthCredential(
        verificationId: kMockVerificationId,
        smsCode: kMockSmsCode,
      );
      await auth.updatePhoneNumberCredential(appName, credentials);
      expect(log, <Matcher>[
        isMethodCall(
          'updatePhoneNumberCredential',
          arguments: <String, dynamic>{
            'app': appName,
            'provider': 'phone',
            'data': <String, String>{
              'verificationId': kMockVerificationId,
              'smsCode': kMockSmsCode,
            },
          },
        ),
      ]);
    });

    test('updatePassword', () async {
      await auth.updatePassword(appName, kMockPassword);
      expect(log, <Matcher>[
        isMethodCall(
          'updatePassword',
          arguments: <String, String>{
            'password': kMockPassword,
            'app': appName,
          },
        ),
      ]);
    });

    test('updateProfile', () async {
      await auth.updateProfile(
        appName,
        displayName: kMockDisplayName,
        photoUrl: kMockPhotoUrl,
      );
      expect(log, <Matcher>[
        isMethodCall(
          'updateProfile',
          arguments: <String, String>{
            'photoUrl': kMockPhotoUrl,
            'displayName': kMockDisplayName,
            'app': appName,
          },
        ),
      ]);
    });

    test('EmailAuthProvider unlinkFromProvider', () async {
      const EmailAuthCredential emailCredential = EmailAuthCredential(
        email: kMockEmail,
        password: kMockPassword,
      );
      await auth.unlinkFromProvider(appName, emailCredential.providerId);
      expect(log, <Matcher>[
        isMethodCall(
          'unlinkFromProvider',
          arguments: <String, String>{
            'app': appName,
            'provider': 'password',
          },
        ),
      ]);
    });

    test('GoogleAuthProvider unlinkFromProvider', () async {
      const GoogleAuthCredential googleCredential = GoogleAuthCredential(
        idToken: kMockIdToken,
        accessToken: kMockAccessToken,
      );
      await auth.unlinkFromProvider(appName, googleCredential.providerId);
      expect(log, <Matcher>[
        isMethodCall(
          'unlinkFromProvider',
          arguments: <String, String>{
            'app': appName,
            'provider': 'google.com',
          },
        ),
      ]);
    });

    test('PlatformOAuthProvider unlinkFromProvider', () async {
      const PlatformOAuthCredential oAuthCredential = PlatformOAuthCredential(
        providerId: "generic_provider.com",
        idToken: kMockIdToken,
        accessToken: kMockAccessToken,
      );
      await auth.unlinkFromProvider(appName, oAuthCredential.providerId);
      expect(log, <Matcher>[
        isMethodCall(
          'unlinkFromProvider',
          arguments: <String, String>{
            'app': appName,
            'provider': 'generic_provider.com',
          },
        ),
      ]);
    });

    test('FacebookAuthProvider unlinkFromProvider', () async {
      const FacebookAuthCredential facebookCredential =
          FacebookAuthCredential(accessToken: kMockAccessToken);
      await auth.unlinkFromProvider(appName, facebookCredential.providerId);
      expect(log, <Matcher>[
        isMethodCall(
          'unlinkFromProvider',
          arguments: <String, String>{
            'app': appName,
            'provider': 'facebook.com',
          },
        ),
      ]);
    });

    test('PhoneAuthProvider unlinkFromProvider', () async {
      const PhoneAuthCredential phoneCredential = PhoneAuthCredential(
        verificationId: kMockVerificationId,
        smsCode: kMockSmsCode,
      );
      await auth.unlinkFromProvider(appName, phoneCredential.providerId);
      expect(log, <Matcher>[
        isMethodCall(
          'unlinkFromProvider',
          arguments: <String, String>{
            'app': appName,
            'provider': 'phone',
          },
        ),
      ]);
    });

    test('TwitterAuthProvider unlinkFromProvider', () async {
      const TwitterAuthCredential twitterCredential = TwitterAuthCredential(
        authToken: kMockAuthToken,
        authTokenSecret: kMockAuthTokenSecret,
      );
      await auth.unlinkFromProvider(appName, twitterCredential.providerId);
      expect(log, <Matcher>[
        isMethodCall(
          'unlinkFromProvider',
          arguments: <String, String>{
            'app': appName,
            'provider': 'twitter.com',
          },
        ),
      ]);
    });

    test('GithubAuthProvider unlinkFromProvider', () async {
      const GithubAuthCredential githubCredential =
          GithubAuthCredential(token: kMockGithubToken);
      await auth.unlinkFromProvider(appName, githubCredential.providerId);
      expect(log, <Matcher>[
        isMethodCall(
          'unlinkFromProvider',
          arguments: <String, String>{
            'app': appName,
            'provider': 'github.com',
          },
        ),
      ]);
    });

    test('signInWithCustomToken', () async {
      final PlatformAuthResult result =
          await auth.signInWithCustomToken(appName, kMockCustomToken);
      verifyAuthResult(result);
      expect(
        log,
        <Matcher>[
          isMethodCall('signInWithCustomToken', arguments: <String, String>{
            'token': kMockCustomToken,
            'app': appName,
          })
        ],
      );
    });

    test('onAuthStateChanged', () async {
      mockHandleId = 42;

      Future<void> simulateEvent(Map<String, dynamic> user) async {
        // TODO(hterkelsen): Remove this when defaultBinaryMessages is in stable.
        // https://github.com/flutter/flutter/issues/33446
        // ignore: deprecated_member_use
        await BinaryMessages.handlePlatformMessage(
          MethodChannelFirebaseAuth.channel.name,
          MethodChannelFirebaseAuth.channel.codec.encodeMethodCall(
            MethodCall(
              'onAuthStateChanged',
              <String, dynamic>{'id': 42, 'user': user, 'app': appName},
            ),
          ),
          (_) {},
        );
      }

      final AsyncQueue<PlatformUser> events = AsyncQueue<PlatformUser>();

      // Subscribe and allow subscription to complete.
      final StreamSubscription<PlatformUser> subscription =
          auth.onAuthStateChanged(appName).listen(events.add);
      await Future<void>.delayed(const Duration(seconds: 0));

      await simulateEvent(null);
      await simulateEvent(kMockUser);

      final PlatformUser user1 = await events.remove();
      expect(user1, isNull);

      final PlatformUser user2 = await events.remove();
      verifyUser(user2);

      // Cancel subscription and allow cancellation to complete.
      subscription.cancel();
      await Future<void>.delayed(const Duration(seconds: 0));

      expect(
        log,
        <Matcher>[
          isMethodCall('startListeningAuthState', arguments: <String, String>{
            'app': appName,
          }),
          isMethodCall(
            'stopListeningAuthState',
            arguments: <String, dynamic>{
              'id': 42,
              'app': appName,
            },
          ),
        ],
      );
    });

    test('setLanguageCode', () async {
      await auth.setLanguageCode(appName, kMockLanguage);

      expect(
        log,
        <Matcher>[
          isMethodCall(
            'setLanguageCode',
            arguments: <String, String>{
              'language': kMockLanguage,
              'app': appName,
            },
          ),
        ],
      );
    });

    test('confirmPasswordReset', () async {
      await auth.confirmPasswordReset(appName, kMockOobCode, kMockPassword);

      expect(
        log,
        <Matcher>[
          isMethodCall(
            'confirmPasswordReset',
            arguments: <String, String>{
              'app': appName,
              'oobCode': kMockOobCode,
              'newPassword': kMockPassword,
            },
          ),
        ],
      );
    });
  });
}

/// Queue whose remove operation is asynchronous, awaiting a corresponding add.
class AsyncQueue<T> {
  Map<int, Completer<T>> _completers = <int, Completer<T>>{};
  int _nextToRemove = 0;
  int _nextToAdd = 0;

  void add(T element) {
    _completer(_nextToAdd++).complete(element);
  }

  Future<T> remove() {
    final Future<T> result = _completer(_nextToRemove++).future;
    return result;
  }

  Completer<T> _completer(int index) {
    if (_completers.containsKey(index)) {
      return _completers.remove(index);
    } else {
      return _completers[index] = Completer<T>();
    }
  }
}
