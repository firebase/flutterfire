// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:intl/intl.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase/firebase.dart' as firebase;

ActionCodeInfo convertWebActionCodeInfo(
    firebase.ActionCodeInfo webActionCodeInfo) {
  if (webActionCodeInfo == null) {
    return null;
  }
  // TODO: firebase-dart missing operation, previousEmail
  return ActionCodeInfo(data: <String, dynamic>{
    'email': webActionCodeInfo.data.email,
  });
}

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

UserMetadata convertWebUserMetadata(firebase.UserMetadata webMetadata) {
  if (webMetadata == null) {
    return null;
  }

  DateFormat dateFormat = DateFormat();

  return UserMetadata(
    dateFormat.parseUTC(webMetadata.creationTime).millisecond,
    dateFormat.parseUTC(webMetadata.lastSignInTime).millisecond,
  );
}

UserInfo convertWebUserInfo(firebase.UserInfo webUserInfo) {
  if (webUserInfo == null) {
    return null;
  }

  return UserInfo(<String, dynamic>{
    'displayName': webUserInfo.displayName,
    'email': webUserInfo.email,
    'phoneNumber': webUserInfo.phoneNumber,
    'providerId': webUserInfo.providerId,
    'uid': webUserInfo.uid,
  });
}

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

firebase.AuthProvider convertPlatformAuthProvider(AuthProvider authProvider) {
  if (authProvider is EmailAuthProvider) {
    return firebase.EmailAuthProvider();
  }

  if (authProvider is FacebookAuthProvider) {
    firebase.FacebookAuthProvider facebookAuthProvider =
        firebase.FacebookAuthProvider();

    authProvider.scopes
        .forEach((String scope) => facebookAuthProvider.addScope(scope));
    facebookAuthProvider.setCustomParameters(authProvider.parameters);
    return facebookAuthProvider;
  }

  if (authProvider is GithubAuthProvider) {
    firebase.GithubAuthProvider githubAuthProvider =
        firebase.GithubAuthProvider();

    authProvider.scopes
        .forEach((String scope) => githubAuthProvider.addScope(scope));
    githubAuthProvider.setCustomParameters(authProvider.parameters);
    return githubAuthProvider;
  }

  if (authProvider is GoogleAuthProvider) {
    firebase.GoogleAuthProvider googleAuthProvider =
        firebase.GoogleAuthProvider();

    authProvider.scopes
        .forEach((String scope) => googleAuthProvider.addScope(scope));
    googleAuthProvider.setCustomParameters(authProvider.parameters);
    return googleAuthProvider;
  }

  if (authProvider is TwitterAuthProvider) {
    firebase.TwitterAuthProvider twitterAuthProvider =
        firebase.TwitterAuthProvider();

    twitterAuthProvider.setCustomParameters(authProvider.parameters);
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
    oAuthProvider.setCustomParameters(authProvider.parameters);
    return oAuthProvider;
  }

  return null;
}

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
