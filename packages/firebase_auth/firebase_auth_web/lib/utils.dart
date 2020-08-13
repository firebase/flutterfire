// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase/firebase.dart' as firebase;

/// Given a web error, a [FirebaseAuthException] is returned.
///
/// The firebase-dart wrapper exposes a [firebase.FirebaseError], allowing us to
/// use the code and message and convert it into an expected [FirebaseAuthException].
///
/// TODO: The firebase-dart wrapper does not support email or credential properties.
FirebaseAuthException throwFirebaseAuthException(Object exception) {
  if (exception is! firebase.FirebaseError) {
    return FirebaseAuthException(
        code: 'unknown', message: 'An unknown error occurred.');
  }

  firebase.FirebaseError firebaseError = exception as firebase.FirebaseError;

  String code = firebaseError.code.replaceFirst('auth/', '');
  String message =
      firebaseError.message.replaceFirst('(${firebaseError.code})', '');
  return FirebaseAuthException(code: code, message: message);
}

/// Converts a [firebase.ActionCodeInfo] into a [ActionCodeInfo].
ActionCodeInfo convertWebActionCodeInfo(
    firebase.ActionCodeInfo webActionCodeInfo) {
  if (webActionCodeInfo == null) {
    return null;
  }
  // TODO: firebase-dart missing operation, previousEmail - defaulting to 'unknown'.
  return ActionCodeInfo(operation: 0, data: <String, dynamic>{
    'email': webActionCodeInfo.data.email,
  });
}

/// Converts a [firebase.AdditionalUserInfo] into a [AdditionalUserInfo].
AdditionalUserInfo convertWebAdditionalUserInfo(
    firebase.AdditionalUserInfo webAdditionalUserInfo) {
  if (webAdditionalUserInfo == null) {
    return null;
  }

  return AdditionalUserInfo(
    isNewUser: webAdditionalUserInfo.isNewUser,
    profile: webAdditionalUserInfo.profile,
    providerId: webAdditionalUserInfo.providerId,
    username: webAdditionalUserInfo.username,
  );
}

/// Converts a [firebase.IdTokenResult] into a [IdTokenResult].
IdTokenResult convertWebIdTokenResult(firebase.IdTokenResult webIdTokenResult) {
  return IdTokenResult(<String, dynamic>{
    'claims': webIdTokenResult.claims,
    'expirationTimestamp': webIdTokenResult.expirationTime.millisecond,
    'issuedAtTimestamp': webIdTokenResult.issuedAtTime.millisecond,
    'signInProvider': webIdTokenResult.signInProvider,
    'signInSecondFactor': null,
    'token': webIdTokenResult.token,
  });
}

/// Converts a [ActionCodeSettings] into a [firebase.ActionCodeSettings].
firebase.ActionCodeSettings convertPlatformActionCodeSettings(
    ActionCodeSettings actionCodeSettings) {
  if (actionCodeSettings == null) {
    return null;
  }

  return firebase.ActionCodeSettings(
      url: actionCodeSettings.url,
      handleCodeInApp: actionCodeSettings.handleCodeInApp,
      android: actionCodeSettings.android == null
          ? null
          : firebase.AndroidSettings(
              packageName: actionCodeSettings.android['packageName'],
              minimumVersion: actionCodeSettings.android['minimumVersion'],
              installApp: actionCodeSettings.android['installApp']),
      iOS: actionCodeSettings.iOS == null
          ? null
          : firebase.IosSettings(bundleId: actionCodeSettings.iOS['bundleId']));
}

/// Converts a [Persistence] enum into a web string persistence value.
String convertPlatformPersistence(Persistence persistence) {
  switch (persistence) {
    case Persistence.SESSION:
      return 'session';
    case Persistence.NONE:
      return 'none';
    case Persistence.LOCAL:
    default:
      return 'local';
  }
}

/// Converts a [AuthProvider] into a [firebase.AuthProvider].
firebase.AuthProvider convertPlatformAuthProvider(AuthProvider authProvider) {
  if (authProvider is EmailAuthProvider) {
    return firebase.EmailAuthProvider();
  }

  if (authProvider is FacebookAuthProvider) {
    firebase.FacebookAuthProvider facebookAuthProvider =
        firebase.FacebookAuthProvider();

    authProvider.scopes
        .forEach((String scope) => facebookAuthProvider.addScope(scope));
    facebookAuthProvider.setCustomParameters(
        Map<String, dynamic>.from(authProvider.parameters));
    return facebookAuthProvider;
  }

  if (authProvider is GithubAuthProvider) {
    firebase.GithubAuthProvider githubAuthProvider =
        firebase.GithubAuthProvider();

    authProvider.scopes
        .forEach((String scope) => githubAuthProvider.addScope(scope));
    githubAuthProvider.setCustomParameters(
        Map<String, dynamic>.from(authProvider.parameters));
    return githubAuthProvider;
  }

  if (authProvider is GoogleAuthProvider) {
    firebase.GoogleAuthProvider googleAuthProvider =
        firebase.GoogleAuthProvider();

    authProvider.scopes
        .forEach((String scope) => googleAuthProvider.addScope(scope));
    googleAuthProvider.setCustomParameters(
        Map<String, dynamic>.from(authProvider.parameters));
    return googleAuthProvider;
  }

  if (authProvider is TwitterAuthProvider) {
    firebase.TwitterAuthProvider twitterAuthProvider =
        firebase.TwitterAuthProvider();

    twitterAuthProvider.setCustomParameters(
        Map<String, dynamic>.from(authProvider.parameters));
    return twitterAuthProvider;
  }

  if (authProvider is PhoneAuthProvider) {
    return firebase.PhoneAuthProvider();
  }

  if (authProvider is OAuthProvider) {
    firebase.OAuthProvider oAuthProvider =
        firebase.OAuthProvider(authProvider.providerId);

    authProvider.scopes
        .forEach((String scope) => oAuthProvider.addScope(scope));
    oAuthProvider.setCustomParameters(
        Map<String, dynamic>.from(authProvider.parameters));
    return oAuthProvider;
  }

  return null;
}

/// Converts a [firebase.OAuthCredential] into a [AuthCredential].
AuthCredential convertWebOAuthCredential(
    firebase.OAuthCredential oAuthCredential) {
  if (oAuthCredential == null) {
    return null;
  }

  return OAuthProvider(oAuthCredential.providerId).credential(
    accessToken: oAuthCredential.accessToken,
    idToken: oAuthCredential.idToken,
  );
}

/// Converts a [AuthCredential] into a [firebase.OAuthCredential].
firebase.OAuthCredential convertPlatformCredential(AuthCredential credential) {
  if (credential is EmailAuthCredential) {
    if (credential.emailLink != null) {
      // TODO: not supported by firebase-dart
      throw UnimplementedError(
          "EmailAuthProvider.credentialWithLink() is not supported on web");
    }
    return firebase.EmailAuthProvider.credential(
        credential.email, credential.password);
  }

  if (credential is FacebookAuthCredential) {
    return firebase.FacebookAuthProvider.credential(credential.accessToken);
  }

  if (credential is GithubAuthCredential) {
    return firebase.GithubAuthProvider.credential(credential.accessToken);
  }

  if (credential is GoogleAuthCredential) {
    return firebase.GoogleAuthProvider.credential(
        credential.idToken, credential.accessToken);
  }

  if (credential is OAuthCredential) {
    return firebase.OAuthProvider(credential.providerId)
        .credential(credential.idToken, credential.accessToken);
  }

  if (credential is TwitterAuthCredential) {
    return firebase.TwitterAuthProvider.credential(
        credential.accessToken, credential.secret);
  }

  if (credential is PhoneAuthCredential) {
    return firebase.PhoneAuthProvider.credential(
        credential.verificationId, credential.smsCode);
  }

  if (credential is OAuthCredential) {
    return firebase.OAuthProvider(credential.providerId)
        .credential(credential.idToken, credential.accessToken);
  }

  return null;
}
