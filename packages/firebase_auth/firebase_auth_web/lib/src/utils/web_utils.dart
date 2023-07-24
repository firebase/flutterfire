// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:js/js_util.dart';

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:firebase_auth_web/src/firebase_auth_web_multi_factor.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;

import '../interop/auth.dart' as auth_interop;
import '../interop/multi_factor.dart' as multi_factor_interop;
import '../interop/window_interop.dart' as window_interop;

/// Workaround test to check whether `e` is practically a FirebaseError.
///
/// Ideally we'd check whether `e instanceof FirebaseError` however
/// there are two definitions of `FirebaseError` in deployed apps, one from
/// `firebase-auth.js` (which is usually minified) and one from
/// `firebase-app.js`.
///
/// Because they are not the same, the instanceof check fails. Instead, we test
/// that it is a window.Error (since that's the base class of FirebaseError) and
/// we check that it defines "customData" property which is on the AuthError but not the FirebaseError it extends
bool _isFirebaseAuthError(Object e) =>
    instanceof(e, window_interop.errorConstructor) &&
    hasProperty(e, 'customData');

bool _hasFirebaseAuthErrorCodeAndMessage(Object e) {
  if (_isFirebaseAuthError(e)) {
    String? code = getProperty(e, 'code');
    String? message = getProperty(e, 'message');
    if (code == null || !code.startsWith('auth/')) return false;
    if (message == null || !message.contains('Firebase')) return false;
    return true;
  } else {
    return false;
  }
}

/// Given a web error, an [Exception] is returned.
///
/// The firebase-dart wrapper exposes a [core_interop.FirebaseError], allowing us to
/// use the code and message and convert it into an expected [FirebaseAuthException].
FirebaseAuthException getFirebaseAuthException(
  Object exception, [
  auth_interop.Auth? auth,
]) {
  if (!_hasFirebaseAuthErrorCodeAndMessage(exception)) {
    return FirebaseAuthException(
      code: 'unknown',
      message: 'An unknown error occurred: $exception',
    );
  }

  auth_interop.AuthError firebaseError = exception as auth_interop.AuthError;
  String code = firebaseError.code.replaceFirst('auth/', '');
  String message = firebaseError.message
      .replaceFirst(' (${firebaseError.code}).', '')
      .replaceFirst('Firebase: ', '');

  // "customData" - see Firebase AuthError docs: https://firebase.google.com/docs/reference/js/auth.autherror
  final customData =
      getProperty(exception, 'customData') as auth_interop.AuthErrorCustomData;

  if (code == 'multi-factor-auth-required') {
    final _auth = auth;
    if (_auth == null) {
      throw ArgumentError(
        'Multi-factor authentication is required, but the auth instance is null. '
        'Please ensure that the auth instance is not null before calling '
        '`getFirebaseAuthException()`.',
      );
    }
    final resolverWeb = multi_factor_interop.getMultiFactorResolver(
      _auth,
      exception,
    );

    return FirebaseAuthMultiFactorExceptionPlatform(
      code: code,
      message: message,
      email: customData.email,
      phoneNumber: customData.phoneNumber,
      tenantId: customData.tenantId,
      resolver: MultiFactorResolverWeb(
        resolverWeb.hints.map((e) {
          if (e is multi_factor_interop.PhoneMultiFactorInfo) {
            return PhoneMultiFactorInfo(
              displayName: e.displayName,
              factorId: e.factorId,
              enrollmentTimestamp:
                  HttpDate.parse(e.enrollmentTime).millisecondsSinceEpoch /
                      1000,
              uid: e.uid,
              phoneNumber: e.phoneNumber,
            );
          }
          return MultiFactorInfo(
            displayName: e.displayName,
            factorId: e.factorId,
            enrollmentTimestamp:
                HttpDate.parse(e.enrollmentTime).millisecondsSinceEpoch / 1000,
            uid: e.uid,
          );
        }).toList(),
        MultiFactorSessionWeb('web', resolverWeb.session),
        FirebaseAuthWeb.instance,
        resolverWeb,
        auth,
      ),
    );
  }

  return FirebaseAuthException(
    code: code,
    message: message,
    email: customData.email,
    phoneNumber: customData.phoneNumber,
    tenantId: customData.tenantId,
  );
}

/// Converts a [auth_interop.ActionCodeInfo] into a [ActionCodeInfo].
ActionCodeInfo? convertWebActionCodeInfo(
    auth_interop.ActionCodeInfo? webActionCodeInfo) {
  if (webActionCodeInfo == null) {
    return null;
  }

  return ActionCodeInfo(
    operation: ActionCodeInfoOperation.passwordReset,
    data: ActionCodeInfoData(
      email: webActionCodeInfo.data.email,
      previousEmail: webActionCodeInfo.data.previousEmail,
    ),
  );
}

/// Converts a [auth_interop.AdditionalUserInfo] into a [AdditionalUserInfo].
AdditionalUserInfo? convertWebAdditionalUserInfo(
  auth_interop.AdditionalUserInfo? webAdditionalUserInfo,
) {
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

/// Converts a [auth_interop.IdTokenResult] into a [IdTokenResult].
IdTokenResult convertWebIdTokenResult(
  auth_interop.IdTokenResult webIdTokenResult,
) {
  return IdTokenResult(
    PigeonIdTokenResult(
      claims: webIdTokenResult.claims,
      token: webIdTokenResult.token,
      authTimestamp: webIdTokenResult.authTime.millisecondsSinceEpoch,
      issuedAtTimestamp: webIdTokenResult.issuedAtTime.millisecondsSinceEpoch,
      expirationTimestamp:
          webIdTokenResult.expirationTime.millisecondsSinceEpoch,
      signInProvider: webIdTokenResult.signInProvider,
    ),
  );
}

/// Converts a [ActionCodeSettings] into a [auth_interop.ActionCodeSettings].
auth_interop.ActionCodeSettings? convertPlatformActionCodeSettings(
    ActionCodeSettings? actionCodeSettings) {
  if (actionCodeSettings == null) {
    return null;
  }

  Map<String, dynamic> actionCodeSettingsMap = actionCodeSettings.asMap();

  auth_interop.ActionCodeSettings webActionCodeSettings;

  if (actionCodeSettings.dynamicLinkDomain != null) {
    webActionCodeSettings = auth_interop.ActionCodeSettings(
      url: actionCodeSettings.url,
      handleCodeInApp: actionCodeSettings.handleCodeInApp,
      dynamicLinkDomain: actionCodeSettings.dynamicLinkDomain,
    );
  } else {
    webActionCodeSettings = auth_interop.ActionCodeSettings(
      url: actionCodeSettings.url,
      handleCodeInApp: actionCodeSettings.handleCodeInApp,
    );
  }

  if (actionCodeSettingsMap['android'] != null) {
    webActionCodeSettings.android = auth_interop.AndroidSettings(
        packageName: actionCodeSettingsMap['android']['packageName'],
        minimumVersion: actionCodeSettingsMap['android']['minimumVersion'],
        installApp: actionCodeSettingsMap['android']['installApp']);
  }

  if (actionCodeSettingsMap['iOS'] != null) {
    webActionCodeSettings.iOS = auth_interop.IosSettings(
        bundleId: actionCodeSettingsMap['iOS']['bundleId']);
  }

  return webActionCodeSettings;
}

/// Converts a [AuthProvider] into a [auth_interop.AuthProvider].
auth_interop.AuthProvider convertPlatformAuthProvider(
  AuthProvider authProvider,
) {
  if (authProvider is EmailAuthProvider) {
    return auth_interop.EmailAuthProvider();
  }

  if (authProvider is FacebookAuthProvider) {
    auth_interop.FacebookAuthProvider facebookAuthProvider =
        auth_interop.FacebookAuthProvider();

    authProvider.scopes.forEach(facebookAuthProvider.addScope);
    facebookAuthProvider.setCustomParameters(authProvider.parameters);
    return facebookAuthProvider;
  }

  if (authProvider is AppleAuthProvider) {
    auth_interop.OAuthProvider oAuthProvider =
        auth_interop.OAuthProvider(authProvider.providerId);

    authProvider.scopes.forEach(oAuthProvider.addScope);
    oAuthProvider.setCustomParameters(authProvider.parameters);
    return oAuthProvider;
  }

  if (authProvider is GithubAuthProvider) {
    auth_interop.GithubAuthProvider githubAuthProvider =
        auth_interop.GithubAuthProvider();

    authProvider.scopes.forEach(githubAuthProvider.addScope);
    githubAuthProvider.setCustomParameters(authProvider.parameters);
    return githubAuthProvider;
  }

  if (authProvider is GoogleAuthProvider) {
    auth_interop.GoogleAuthProvider googleAuthProvider =
        auth_interop.GoogleAuthProvider();

    authProvider.scopes.forEach(googleAuthProvider.addScope);
    googleAuthProvider.setCustomParameters(authProvider.parameters);
    return googleAuthProvider;
  }

  if (authProvider is MicrosoftAuthProvider) {
    auth_interop.OAuthProvider oAuthProvider =
        auth_interop.OAuthProvider(authProvider.providerId);

    authProvider.scopes.forEach(oAuthProvider.addScope);
    oAuthProvider.setCustomParameters(authProvider.parameters);
    return oAuthProvider;
  }

  if (authProvider is YahooAuthProvider) {
    auth_interop.OAuthProvider oAuthProvider =
        auth_interop.OAuthProvider(authProvider.providerId);

    authProvider.scopes.forEach(oAuthProvider.addScope);
    oAuthProvider.setCustomParameters(authProvider.parameters);
    return oAuthProvider;
  }

  if (authProvider is TwitterAuthProvider) {
    auth_interop.TwitterAuthProvider twitterAuthProvider =
        auth_interop.TwitterAuthProvider();

    twitterAuthProvider.setCustomParameters(authProvider.parameters);
    return twitterAuthProvider;
  }

  if (authProvider is PhoneAuthProvider) {
    return auth_interop.PhoneAuthProvider();
  }

  if (authProvider is OAuthProvider) {
    auth_interop.OAuthProvider oAuthProvider =
        auth_interop.OAuthProvider(authProvider.providerId);

    authProvider.scopes.forEach(oAuthProvider.addScope);
    oAuthProvider.setCustomParameters(authProvider.parameters);
    return oAuthProvider;
  }

  if (authProvider is SAMLAuthProvider) {
    return auth_interop.SAMLAuthProvider(authProvider.providerId);
  }

  throw UnsupportedError('Unknown AuthProvider: $authProvider.');
}

/// Converts a [auth_interop.AuthCredential] into a [AuthCredential].
AuthCredential? convertWebAuthCredential(
    auth_interop.AuthCredential? authCredential) {
  if (authCredential == null) {
    return null;
  }

  return AuthCredential(
    providerId: authCredential.providerId,
    signInMethod: authCredential.signInMethod,
  );
}

/// Converts a [auth_interop.OAuthCredential] into a [AuthCredential].
AuthCredential? convertWebOAuthCredential(
  auth_interop.UserCredential? userCredential,
) {
  if (userCredential == null) {
    return null;
  }

  final authCredential = auth_interop.OAuthProvider.credentialFromResult(
    userCredential.jsObject,
  );

  if (authCredential == null) {
    return null;
  }

  return OAuthProvider(authCredential.providerId).credential(
    signInMethod: authCredential.signInMethod,
    accessToken: authCredential.accessToken,
    secret: authCredential.secret,
    idToken: authCredential.idToken,
  );
}

/// Converts a [AuthCredential] into a [firebase.OAuthCredential].
auth_interop.OAuthCredential? convertPlatformCredential(
  AuthCredential credential,
) {
  if (credential is EmailAuthCredential) {
    if (credential.emailLink != null) {
      return auth_interop.EmailAuthProvider.credentialWithLink(
        credential.email,
        credential.emailLink!,
      );
    }
    return auth_interop.EmailAuthProvider.credential(
      credential.email,
      credential.password!,
    );
  }

  if (credential is FacebookAuthCredential) {
    return auth_interop.FacebookAuthProvider.credential(
        credential.accessToken!);
  }

  if (credential is GithubAuthCredential) {
    return auth_interop.GithubAuthProvider.credential(credential.accessToken!);
  }

  if (credential is GoogleAuthCredential) {
    return auth_interop.GoogleAuthProvider.credential(
      credential.idToken,
      credential.accessToken,
    );
  }

  if (credential is TwitterAuthCredential) {
    return auth_interop.TwitterAuthProvider.credential(
      credential.accessToken!,
      credential.secret!,
    );
  }

  if (credential is PhoneAuthCredential) {
    return auth_interop.PhoneAuthProvider.credential(
      credential.verificationId!,
      credential.smsCode!,
    ) as auth_interop.OAuthCredential;
  }

  if (credential is OAuthCredential) {
    auth_interop.OAuthCredentialOptions credentialOptions =
        auth_interop.OAuthCredentialOptions(
      accessToken: credential.accessToken,
      rawNonce: credential.rawNonce,
      idToken: credential.idToken,
    );
    return auth_interop.OAuthProvider(credential.providerId)
        .credential(credentialOptions);
  }

  return null;
}

/// Converts a [RecaptchaVerifierSize] enum into a string.
String convertRecaptchaVerifierSize(RecaptchaVerifierSize size) {
  switch (size) {
    case RecaptchaVerifierSize.compact:
      return 'compact';
    case RecaptchaVerifierSize.normal:
    default:
      return 'normal';
  }
}

/// Converts a [RecaptchaVerifierTheme] enum into a string.
String convertRecaptchaVerifierTheme(RecaptchaVerifierTheme theme) {
  switch (theme) {
    case RecaptchaVerifierTheme.dark:
      return 'dark';
    case RecaptchaVerifierTheme.light:
    default:
      return 'light';
  }
}

/// Converts a [multi_factor_interop.MultiFactorSession] into a [MultiFactorSession].
MultiFactorSession convertMultiFactorSession(
    multi_factor_interop.MultiFactorSession multiFactorSession) {
  return MultiFactorSessionWeb('web', multiFactorSession);
}
