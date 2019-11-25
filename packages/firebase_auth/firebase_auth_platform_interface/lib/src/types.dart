// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:meta/meta.dart';

typedef void PhoneVerificationCompleted(AuthCredential phoneAuthCredential);
typedef void PhoneVerificationFailed(AuthException error);
typedef void PhoneCodeSent(String verificationId, [int forceResendingToken]);
typedef void PhoneCodeAutoRetrievalTimeout(String verificationId);

/// Represents a `User` in Firebase.
///
/// See also: https://firebase.google.com/docs/reference/js/firebase.User
class PlatformUser {
  const PlatformUser({
    @required this.providerId,
    @required this.uid,
    this.displayName,
    this.photoUrl,
    this.email,
    this.phoneNumber,
    this.creationTimestamp,
    this.lastSignInTimestamp,
    @required this.isAnonymous,
    @required this.isEmailVerified,
    @required this.providerData,
  });

  final String providerId;
  final String uid;
  final String displayName;
  final String photoUrl;
  final String email;
  final String phoneNumber;
  final int creationTimestamp;
  final int lastSignInTimestamp;
  final bool isAnonymous;
  final bool isEmailVerified;
  final List<PlatformUserInfo> providerData;
}

/// Represents a `UserInfo` from Firebase.
///
/// See also: https://firebase.google.com/docs/reference/js/firebase.UserInfo
class PlatformUserInfo {
  const PlatformUserInfo({
    @required this.providerId,
    @required this.uid,
    this.displayName,
    this.photoUrl,
    this.email,
    this.phoneNumber,
  });

  final String providerId;
  final String uid;
  final String displayName;
  final String photoUrl;
  final String email;
  final String phoneNumber;
}

/// Represents `AdditionalUserInfo` from Firebase.
///
/// See also: https://firebase.google.com/docs/reference/js/firebase.auth.html#additionaluserinfo
class PlatformAdditionalUserInfo {
  const PlatformAdditionalUserInfo({
    @required this.isNewUser,
    @required this.providerId,
    @required this.username,
    @required this.profile,
  });

  final bool isNewUser;
  final String providerId;
  final String username;
  final Map<String, dynamic> profile;
}

class PlatformAuthResult {
  const PlatformAuthResult({
    @required this.user,
    @required this.additionalUserInfo,
  });

  final PlatformUser user;
  final PlatformAdditionalUserInfo additionalUserInfo;
}

/// Represents `AuthCredential` from Firebase.
abstract class AuthCredential {
  const AuthCredential(this.providerId);

  /// An id that identifies the specific type of provider.
  final String providerId;

  /// Returns the data for this credential as a map.
  Map<String, String> asMap();
}

class EmailAuthCredential extends AuthCredential {
  static const String _providerId = 'password';
  const EmailAuthCredential({@required this.email, this.password, this.link})
      : assert(password != null || link != null,
            'One of "password" or "link" must be provided'),
        super(_providerId);

  final String email;
  final String password;
  final String link;

  @override
  Map<String, String> asMap() {
    final Map<String, String> result = <String, String>{'email': email};
    if (password != null) {
      result['password'] = password;
    }
    if (link != null) {
      result['link'] = link;
    }
    return result;
  }
}

class GoogleAuthCredential extends AuthCredential {
  static const String _providerId = 'google.com';
  const GoogleAuthCredential({
    @required this.idToken,
    @required this.accessToken,
  }) : super(_providerId);

  final String idToken;
  final String accessToken;

  @override
  Map<String, String> asMap() => <String, String>{
        'idToken': idToken,
        'accessToken': accessToken,
      };
}

class FacebookAuthCredential extends AuthCredential {
  static const String _providerId = 'facebook.com';
  const FacebookAuthCredential({@required this.accessToken})
      : super(_providerId);

  final String accessToken;

  @override
  Map<String, String> asMap() => <String, String>{
        'accessToken': accessToken,
      };
}

class TwitterAuthCredential extends AuthCredential {
  static const String _providerId = 'twitter.com';
  const TwitterAuthCredential({
    @required this.authToken,
    @required this.authTokenSecret,
  }) : super(_providerId);

  final String authToken;
  final String authTokenSecret;

  @override
  Map<String, String> asMap() => <String, String>{
        'authToken': authToken,
        'authTokenSecret': authTokenSecret,
      };
}

class GithubAuthCredential extends AuthCredential {
  static const String _providerId = 'github.com';
  const GithubAuthCredential({@required this.token}) : super(_providerId);

  final String token;

  @override
  Map<String, String> asMap() => <String, String>{
        'token': token,
      };
}

class PhoneAuthCredential extends AuthCredential {
  static const String _providerId = 'phone';
  const PhoneAuthCredential(
      {this.verificationId, this.smsCode, this.jsonObject})
      : assert(verificationId != null || jsonObject != null),
        super(_providerId);

  final String verificationId;
  final String smsCode;
  final String jsonObject;

  @override
  Map<String, String> asMap() {
    final Map<String, String> result = <String, String>{};
    if (verificationId != null) {
      result['verificationId'] = verificationId;
    }
    if (smsCode != null) {
      result['smsCode'] = smsCode;
    }
    if (jsonObject != null) {
      result['jsonObject'] = jsonObject;
    }
    return result;
  }
}

class PlatformIdTokenResult {
  const PlatformIdTokenResult({
    @required this.token,
    @required this.expirationTimestamp,
    @required this.authTimestamp,
    @required this.issuedAtTimestamp,
    @required this.claims,
    this.signInProvider,
  });

  final String token;
  final int expirationTimestamp;
  final int authTimestamp;
  final int issuedAtTimestamp;
  final Map<dynamic, dynamic> claims;
  final String signInProvider;
}

/// Generic exception related to Firebase Authentication.
/// Check the error code and message for more details.
class AuthException implements Exception {
  const AuthException(this.code, this.message);

  final String code;
  final String message;
}
