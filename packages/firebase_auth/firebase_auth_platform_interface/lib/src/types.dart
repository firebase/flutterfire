// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_auth_platform_interface;

typedef void PhoneVerificationCompleted(AuthCredential phoneAuthCredential);
typedef void PhoneVerificationFailed(AuthException error);
typedef void PhoneCodeSent(String verificationId, [int forceResendingToken]);
typedef void PhoneCodeAutoRetrievalTimeout(String verificationId);

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

/// Represents a `User` in Firebase.
///
/// See also: https://firebase.google.com/docs/reference/js/firebase.User
class PlatformUser extends PlatformUserInfo {
  const PlatformUser({
    @required String providerId,
    @required String uid,
    String displayName,
    String photoUrl,
    String email,
    String phoneNumber,
    this.creationTimestamp,
    this.lastSignInTimestamp,
    @required this.isAnonymous,
    @required this.isEmailVerified,
    @required this.providerData,
  }) : super(
          providerId: providerId,
          uid: uid,
          displayName: displayName,
          photoUrl: photoUrl,
          email: email,
          phoneNumber: phoneNumber,
        );

  final int creationTimestamp;
  final int lastSignInTimestamp;
  final bool isAnonymous;
  final bool isEmailVerified;
  final List<PlatformUserInfo> providerData;
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

/// Represents `UserCredential` from Firebase.
///
/// See also: https://firebase.google.com/docs/reference/js/firebase.auth.html#usercredential
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

  /// Returns the data for this credential serialized as a map.
  Map<String, String> _asMap();

  @override
  String toString() => _asMap().toString();
}

/// An [AuthCredential] created by an email auth provider.
class EmailAuthCredential extends AuthCredential {
  const EmailAuthCredential({@required this.email, this.password, this.link})
      : assert(password != null || link != null,
            'One of "password" or "link" must be provided'),
        super(_providerId);

  static const String _providerId = 'password';

  /// The user's email address.
  final String email;

  /// The user account password.
  final String password;

  /// The sign-in email link.
  final String link;

  @override
  Map<String, String> _asMap() {
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

/// An [AuthCredential] for authenticating via google.com.
class GoogleAuthCredential extends AuthCredential {
  const GoogleAuthCredential({
    @required this.idToken,
    @required this.accessToken,
  }) : super(_providerId);

  static const String _providerId = 'google.com';

  /// The Google ID token.
  final String idToken;

  /// The Google access token.
  final String accessToken;

  @override
  Map<String, String> _asMap() => <String, String>{
        'idToken': idToken,
        'accessToken': accessToken,
      };
}

/// An [OAuthCredential] for authenticating via custom providerId.
/// Example: For Apple you can do it with
/// PlatformOAuthCredential _credential = PlatformOAuthCredential(
///   providerId: "apple.com",
///   idToken: appleIdToken,
///   accessToken: appleAccessToken
/// )
/// Optionally you can provide a rawNonce param
/// More info in https://firebase.google.com/docs/auth/ios/apple
class PlatformOAuthCredential extends OAuthCredential {
  const PlatformOAuthCredential(
      {@required String providerId,
      @required String idToken,
      String accessToken,
      String rawNonce})
      : super(providerId, idToken, accessToken, rawNonce);
}

/// Abstract class to implement [OAuthCredential] authentications
abstract class OAuthCredential extends AuthCredential {
  /// The ID Token associated with this credential.
  final String idToken;

  /// The OAuth access token.
  final String accessToken;

  /// The OAuth raw nonce.
  final String rawNonce;

  /// The OAuth raw nonce.
  final String providerId;

  const OAuthCredential(
    this.providerId,
    this.idToken,
    this.accessToken,
    this.rawNonce,
  ) : super(providerId);

  @override
  Map<String, String> _asMap() => <String, String>{
        'idToken': idToken,
        'accessToken': accessToken,
        'providerId': providerId,
        'rawNonce': rawNonce,
      };
}

/// An [AuthCredential] for authenticating via facebook.com.
class FacebookAuthCredential extends AuthCredential {
  const FacebookAuthCredential({@required this.accessToken})
      : super(_providerId);

  static const String _providerId = 'facebook.com';

  /// The Facebook access token.
  final String accessToken;

  @override
  Map<String, String> _asMap() => <String, String>{
        'accessToken': accessToken,
      };
}

/// An [AuthCredential] for authenticating via twitter.com.
class TwitterAuthCredential extends AuthCredential {
  const TwitterAuthCredential({
    @required this.authToken,
    @required this.authTokenSecret,
  }) : super(_providerId);

  static const String _providerId = 'twitter.com';

  /// The Twitter access token.
  final String authToken;

  /// The Twitter secret token.
  final String authTokenSecret;

  @override
  Map<String, String> _asMap() => <String, String>{
        'authToken': authToken,
        'authTokenSecret': authTokenSecret,
      };
}

/// An [AuthCredential] for authenticating via github.com.
class GithubAuthCredential extends AuthCredential {
  const GithubAuthCredential({@required this.token}) : super(_providerId);

  static const String _providerId = 'github.com';

  /// The Github token.
  final String token;

  @override
  Map<String, String> _asMap() => <String, String>{
        'token': token,
      };
}

/// An [AuthCredential] for authenticating via phone.
class PhoneAuthCredential extends AuthCredential {
  const PhoneAuthCredential(
      {@required this.verificationId, @required this.smsCode})
      : _jsonObject = null,
        super(_providerId);

  /// On Android, when the SMS code is automatically detected, the credential
  /// is returned serialized as JSON.
  const PhoneAuthCredential._fromDetectedOnAndroid(
      {@required String jsonObject})
      : _jsonObject = jsonObject,
        verificationId = null,
        smsCode = null,
        super(_providerId);

  static const String _providerId = 'phone';

  /// The verification ID returned from [FirebaseAuthPlatform.verifyPhoneNumber].
  final String verificationId;

  /// The verification code sent to the user's phone.
  final String smsCode;

  /// The credential serialized to JSON.
  ///
  /// See [PhoneAuthCredential._fromDetectedOnAndroid].
  final String _jsonObject;

  @override
  Map<String, String> _asMap() {
    final Map<String, String> result = <String, String>{};
    if (verificationId != null) {
      result['verificationId'] = verificationId;
    }
    if (smsCode != null) {
      result['smsCode'] = smsCode;
    }
    if (_jsonObject != null) {
      result['jsonObject'] = _jsonObject;
    }
    return result;
  }
}

/// The result of calling [FirebaseAuthPlatform.getIdToken].
class PlatformIdTokenResult {
  const PlatformIdTokenResult({
    @required this.token,
    @required this.expirationTimestamp,
    @required this.authTimestamp,
    @required this.issuedAtTimestamp,
    @required this.claims,
    this.signInProvider,
  });

  /// The Firebase Auth ID token JWT string.
  final String token;

  /// The time when the ID token expires.
  final int expirationTimestamp;

  /// The time the user authenticated (signed in).
  ///
  /// Note that this is not the time the token was refreshed.
  final int authTimestamp;

  /// The time when ID token was issued.
  final int issuedAtTimestamp;

  /// The sign-in provider through which the ID token was obtained (anonymous,
  /// custom, phone, password, etc). Note, this does not map to provider IDs.
  final Map<dynamic, dynamic> claims;

  /// The entire payload claims of the ID token including the standard reserved
  /// claims as well as the custom claims.
  final String signInProvider;
}

/// Generic exception related to Firebase Authentication.
/// Check the error code and message for more details.
class AuthException implements Exception {
  const AuthException(this.code, this.message);

  /// The error code of the exception.
  final String code;

  /// A message containing extra information about the exception.
  final String message;
}
