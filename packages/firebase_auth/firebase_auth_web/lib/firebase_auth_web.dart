// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase/firebase.dart' as firebase;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:http_parser/http_parser.dart';

class FirebaseAuthWeb extends FirebaseAuthPlatform {
  static const _firebaseJsErrorCodesMapping = {
    'auth/admin-restricted-operation': 'ADMIN_ONLY_OPERATION',
    'auth/app-not-installed': 'APP_NOT_INSTALLED',
    'auth/code-expired': 'CODE_EXPIRED',
    'auth/cordova-not-ready': 'CORDOVA_NOT_READY',
    'auth/cors-unsupported': 'CORS_UNSUPPORTED',
    'auth/dynamic-link-not-activated': 'DYNAMIC_LINK_NOT_ACTIVATED',
    'auth/invalid-app-id': 'INVALID_APP_ID',
    'auth/invalid-auth-event': 'INVALID_AUTH_EVENT',
    'auth/invalid-cert-hash': 'INVALID_CERT_HASH',
    'auth/invalid-cordova-configuration': 'INVALID_CORDOVA_CONFIGURATION',
    'auth/invalid-dynamic-link-domain': 'INVALID_DYNAMIC_LINK_DOMAIN',
    'auth/invalid-oauth-provider': 'INVALID_OAUTH_PROVIDER',
    'auth/invalid-provider-id': 'INVALID_PROVIDER_ID',
    'auth/invalid-recipient-email': 'INVALID_RECIPIENT_EMAIL',
    'auth/missing-iframe-start': 'MISSING_IFRAME_START',
    'auth/missing-or-invalid-nonce': 'MISSING_OR_INVALID_NONCE',
    'auth/no-auth-event': 'NO_AUTH_EVENT',
    'auth/popup-blocked': 'POPUP_BLOCKED',
    'auth/redirect-cancelled-by-user': 'REDIRECT_CANCELLED_BY_USER',
    'auth/redirect-operation-pending': 'REDIRECT_OPERATION_PENDING',
    'auth/rejected-credential': 'REJECTED_CREDENTIAL',
    'auth/unsupported-tenant-operation': 'UNSUPPORTED_TENANT_OPERATION',
    'auth/user-cancelled': 'USER_CANCELLED',
    'auth/user-signed-out': 'USER_SIGNED_OUT',
    'auth/invalid-custom-token': 'ERROR_INVALID_CUSTOM_TOKEN',
    'auth/custom-token-mismatch': 'ERROR_CUSTOM_TOKEN_MISMATCH',
    'auth/invalid-credential': 'ERROR_INVALID_CREDENTIAL',
    'auth/user-disabled': 'ERROR_USER_DISABLED',
    'auth/operation-not-allowed': 'ERROR_OPERATION_NOT_ALLOWED',
    'auth/email-already-in-use': 'ERROR_EMAIL_ALREADY_IN_USE',
    'auth/invalid-email': 'ERROR_INVALID_EMAIL',
    'auth/wrong-password': 'ERROR_WRONG_PASSWORD',
    'auth/too-many-requests': 'ERROR_TOO_MANY_REQUESTS',
    'auth/user-not-found': 'ERROR_USER_NOT_FOUND',
    'auth/account-exists-with-different-credential':
        'ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL',
    'auth/requires-recent-login': 'ERROR_REQUIRES_RECENT_LOGIN',
    'auth/provider-already-linked': 'ERROR_PROVIDER_ALREADY_LINKED',
    'auth/no-such-provider': 'ERROR_NO_SUCH_PROVIDER',
    'auth/invalid-user-token': 'ERROR_INVALID_USER_TOKEN',
    'auth/network-request-failed': 'ERROR_NETWORK_REQUEST_FAILED',
    'auth/user-token-expired': 'ERROR_USER_TOKEN_EXPIRED',
    'auth/invalid-api-key': 'ERROR_INVALID_API_KEY',
    'auth/user-mismatch': 'ERROR_USER_MISMATCH',
    'auth/credential-already-in-use': 'ERROR_CREDENTIAL_ALREADY_IN_USE',
    'auth/weak-password': 'ERROR_WEAK_PASSWORD',
    'auth/app-not-authorized': 'ERROR_APP_NOT_AUTHORIZED',
    'auth/expired-action-code': 'ERROR_EXPIRED_ACTION_CODE',
    'auth/invalid-action-code': 'ERROR_INVALID_ACTION_CODE',
    'auth/invalid-message-payload': 'ERROR_INVALID_MESSAGE_PAYLOAD',
    'auth/invalid-sender': 'ERROR_INVALID_SENDER',
    'auth/missing-ios-bundle-id': 'ERROR_MISSING_IOS_BUNDLE_ID',
    'auth/missing-android-pkg-name': 'ERROR_MISSING_ANDROID_PKG_NAME',
    'auth/unauthorized-domain': 'ERROR_UNAUTHORIZED_DOMAIN',
    'auth/invalid-continue-uri': 'ERROR_INVALID_CONTINUE_URI',
    'auth/missing-continue-uri': 'ERROR_MISSING_CONTINUE_URI',
    'auth/missing-phone-number': 'ERROR_MISSING_PHONE_NUMBER',
    'auth/invalid-phone-number': 'ERROR_INVALID_PHONE_NUMBER',
    'auth/missing-verification-code': 'ERROR_MISSING_VERIFICATION_CODE',
    'auth/invalid-verification-code': 'ERROR_INVALID_VERIFICATION_CODE',
    'auth/missing-verification-id': 'ERROR_MISSING_VERIFICATION_ID',
    'auth/invalid-verification-id': 'ERROR_INVALID_VERIFICATION_ID',
    'auth/missing-app-credential': 'MISSING_APP_CREDENTIAL',
    'auth/invalid-app-credential': 'INVALID_APP_CREDENTIAL',
    'auth/user-token-expired ?': 'ERROR_SESSION_EXPIRED',
    'auth/quota-exceeded': 'ERROR_QUOTA_EXCEEDED',
    'auth/captcha-check-failed': 'ERROR_CAPTCHA_CHECK_FAILED',
    'auth/invalid-oauth-client-id': 'ERROR_INVALID_CLIENT_ID',
    'auth/null-user': 'ERROR_NULL_USER',
    'auth/internal-error': 'ERROR_INTERNAL_ERROR',
    'auth/operation-not-supported-in-this-environment':
        'ERROR_OPERATION_NOT_SUPPORTED_IN_ENV',
    'auth/timeout': 'ERROR_TIMEOUT',
    'auth/argument-error': 'ERROR_ARGUMENT_ERROR',
    'auth/invalid-persistence-type': 'ERROR_INVALID_PERSISTENCE_TYPE',
    'auth/unsupported-persistence-type': 'ERROR_UNSUPPORTED_PERSISTENCE_TYPE',
    'auth/cancelled-popup-request': 'ERROR_CANCELLED_POPUP_REQUEST',
    'auth/popup-closed-by-user': 'ERROR_POPUP_CLOSED_BY_USER',
    'auth/tenant-id-mismatch': 'ERROR_TENANT_ID_MISMATCH',
    'auth/invalid-tenant-id': 'ERROR_TENANT_INVALID',
    'auth/app-deleted': 'ERROR_APP_DELETED',
    'auth/web-storage-unsupported': 'ERROR_WEB_STORAGE_UNSUPPORTED',
    'auth/auth-domain-config-required': 'ERROR_DOMAIN_CONFIG_REQUIRED',
    'auth/unauthorized-continue-uri': 'ERROR_UNAUTHORIZED_CONTINUE_URI',
  };

  static void registerWith(Registrar registrar) {
    FirebaseAuthPlatform.instance = FirebaseAuthWeb();
  }

  @visibleForTesting
  static dynamic mapFirebaseException(dynamic exception) {
    if (exception is firebase.FirebaseError) {
      return PlatformException(
          code: _firebaseJsErrorCodesMapping[exception.code],
          message: exception.message);
    }

    return exception;
  }

  firebase.Auth _getAuth(String name) {
    final firebase.App app = firebase.app(name);
    return firebase.auth(app);
  }

  PlatformAdditionalUserInfo _fromJsAdditionalUserInfo(
      firebase.AdditionalUserInfo additionalUserInfo) {
    return PlatformAdditionalUserInfo(
      isNewUser: additionalUserInfo.isNewUser,
      providerId: additionalUserInfo.providerId,
      username: additionalUserInfo.username,
      profile: additionalUserInfo.profile,
    );
  }

  PlatformUserInfo _fromJsUserInfo(firebase.UserInfo userInfo) {
    return PlatformUserInfo(
      providerId: userInfo.providerId,
      uid: userInfo.providerId,
      displayName: userInfo.displayName,
      photoUrl: userInfo.photoURL,
      email: userInfo.email,
      phoneNumber: userInfo.phoneNumber,
    );
  }

  PlatformUser _fromJsUser(firebase.User user) {
    if (user == null) {
      return null;
    }
    return PlatformUser(
      providerId: user.providerId,
      uid: user.uid,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      email: user.email,
      phoneNumber: user.phoneNumber,
      creationTimestamp:
          parseHttpDate(user.metadata.creationTime).millisecondsSinceEpoch,
      lastSignInTimestamp:
          parseHttpDate(user.metadata.lastSignInTime).millisecondsSinceEpoch,
      isAnonymous: user.isAnonymous,
      isEmailVerified: user.emailVerified,
      providerData:
          user.providerData.map<PlatformUserInfo>(_fromJsUserInfo).toList(),
    );
  }

  PlatformAuthResult _fromJsUserCredential(firebase.UserCredential credential) {
    return PlatformAuthResult(
      user: _fromJsUser(credential.user),
      additionalUserInfo: _fromJsAdditionalUserInfo(
        credential.additionalUserInfo,
      ),
    );
  }

  PlatformIdTokenResult _fromJsIdTokenResult(
      firebase.IdTokenResult idTokenResult) {
    return PlatformIdTokenResult(
      token: idTokenResult.token,
      expirationTimestamp: idTokenResult.expirationTime.millisecondsSinceEpoch,
      authTimestamp: idTokenResult.authTime.millisecondsSinceEpoch,
      issuedAtTimestamp: idTokenResult.issuedAtTime.millisecondsSinceEpoch,
      claims: idTokenResult.claims,
      signInProvider: idTokenResult.signInProvider,
    );
  }

  firebase.User _getCurrentUserOrThrow(firebase.Auth auth) {
    final firebase.User user = auth.currentUser;
    if (user == null) {
      throw PlatformException(
        code: 'USER_REQUIRED',
        message: 'Please authenticate with Firebase first',
      );
    }
    return user;
  }

  firebase.OAuthCredential _getCredential(AuthCredential credential) {
    if (credential is EmailAuthCredential) {
      return firebase.EmailAuthProvider.credential(
        credential.email,
        credential.password,
      );
    }
    if (credential is GoogleAuthCredential) {
      return firebase.GoogleAuthProvider.credential(
        credential.idToken,
        credential.accessToken,
      );
    }
    if (credential is FacebookAuthCredential) {
      return firebase.FacebookAuthProvider.credential(credential.accessToken);
    }
    if (credential is TwitterAuthCredential) {
      return firebase.TwitterAuthProvider.credential(
        credential.authToken,
        credential.authTokenSecret,
      );
    }
    if (credential is GithubAuthCredential) {
      return firebase.GithubAuthProvider.credential(credential.token);
    }
    if (credential is PhoneAuthCredential) {
      return firebase.PhoneAuthProvider.credential(
        credential.verificationId,
        credential.smsCode,
      );
    }
    return null;
  }

  @override
  Future<PlatformAuthResult> createUserWithEmailAndPassword(
      String app, String email, String password) async {
    try {
      final firebase.Auth auth = _getAuth(app);
      final firebase.UserCredential credential =
          await auth.createUserWithEmailAndPassword(email, password);
      return _fromJsUserCredential(credential);
    } catch (e) {
      throw mapFirebaseException(e);
    }
  }

  @override
  Future<void> delete(String app) async {
    try {
      final firebase.Auth auth = _getAuth(app);
      final firebase.User user = _getCurrentUserOrThrow(auth);
      await user.delete();
    } catch (e) {
      throw mapFirebaseException(e);
    }
  }

  @override
  Future<List<String>> fetchSignInMethodsForEmail(String app, String email) {
    final firebase.Auth auth = _getAuth(app);
    return auth.fetchSignInMethodsForEmail(email);
  }

  @override
  Future<PlatformUser> getCurrentUser(String app) async {
    try {
      final firebase.Auth auth = _getAuth(app);
      final firebase.User currentUser = auth.currentUser;
      return _fromJsUser(currentUser);
    } catch (e) {
      throw mapFirebaseException(e);
    }
  }

  @override
  Future<PlatformIdTokenResult> getIdToken(String app, bool refresh) async {
    try {
      final firebase.Auth auth = _getAuth(app);
      final firebase.User currentUser = auth.currentUser;
      final firebase.IdTokenResult idTokenResult =
        await currentUser.getIdTokenResult(refresh);
      return _fromJsIdTokenResult(idTokenResult);
    } catch (e) {
      throw mapFirebaseException(e);
    }
  }

  @override
  Future<bool> isSignInWithEmailLink(String app, String link) {
    final firebase.Auth auth = _getAuth(app);
    return Future.value(auth.isSignInWithEmailLink(link));
  }

  @override
  Future<PlatformAuthResult> linkWithCredential(
      String app, AuthCredential credential) async {
    try {
      final firebase.Auth auth = _getAuth(app);
      final firebase.User currentUser = _getCurrentUserOrThrow(auth);
      final firebase.OAuthCredential firebaseCredential =
          _getCredential(credential);
      final firebase.UserCredential userCredential =
          await currentUser.linkWithCredential(firebaseCredential);
      return _fromJsUserCredential(userCredential);
    } catch (e) {
      throw mapFirebaseException(e);
    }
  }

  @override
  Stream<PlatformUser> onAuthStateChanged(String app) {
    final firebase.Auth auth = _getAuth(app);
    return auth.onAuthStateChanged
        .map<PlatformUser>(_fromJsUser)
        .handleError((e) => throw mapFirebaseException(e));
  }

  @override
  Future<PlatformAuthResult> reauthenticateWithCredential(
      String app, AuthCredential credential) async {
    try {
      final firebase.Auth auth = _getAuth(app);
      final firebase.User currentUser = _getCurrentUserOrThrow(auth);
      final firebase.OAuthCredential firebaseCredential =
          _getCredential(credential);
      final firebase.UserCredential userCredential =
          await currentUser.reauthenticateWithCredential(firebaseCredential);
      return _fromJsUserCredential(userCredential);
    } catch (e) {
      throw mapFirebaseException(e);
    }
  }

  @override
  Future<void> reload(String app) async {
    try {
      final firebase.Auth auth = _getAuth(app);
      final firebase.User currentUser = _getCurrentUserOrThrow(auth);
      await currentUser.reload();
    } catch (e) {
      throw mapFirebaseException(e);
    }
  }

  @override
  Future<void> sendEmailVerification(String app) async {
    try {
      final firebase.Auth auth = _getAuth(app);
      final firebase.User currentUser = _getCurrentUserOrThrow(auth);
      await currentUser.sendEmailVerification();
    } catch (e) {
      throw mapFirebaseException(e);
    }
  }

  @override
  Future<void> sendLinkToEmail(String app,
      {String email,
      String url,
      bool handleCodeInApp,
      String iOSBundleID,
      String androidPackageName,
      bool androidInstallIfNotAvailable,
      String androidMinimumVersion}) {
    final firebase.Auth auth = _getAuth(app);
    final actionCodeSettings = firebase.ActionCodeSettings(
      url: url,
      handleCodeInApp: handleCodeInApp,
      iOS: firebase.IosSettings(
        bundleId: iOSBundleID,
      ),
      android: firebase.AndroidSettings(
        packageName: androidPackageName,
        installApp: androidInstallIfNotAvailable,
        minimumVersion: androidMinimumVersion,
      ),
    );
    return auth.sendSignInLinkToEmail(email, actionCodeSettings);
  }

  @override
  Future<void> sendPasswordResetEmail(String app, String email) async {
    try {
      final firebase.Auth auth = _getAuth(app);
      await auth.sendPasswordResetEmail(email);
    } catch (e) {
      throw mapFirebaseException(e);
    }
  }

  @override
  Future<void> setLanguageCode(String app, String language) async {
    final firebase.Auth auth = _getAuth(app);
    auth.languageCode = language;
  }

  @override
  Future<PlatformAuthResult> signInAnonymously(String app) async {
    try {
      final firebase.Auth auth = _getAuth(app);
      final firebase.UserCredential userCredential =
          await auth.signInAnonymously();
      return _fromJsUserCredential(userCredential);
    } catch (e) {
      throw mapFirebaseException(e);
    }
  }

  @override
  Future<PlatformAuthResult> signInWithCredential(
      String app, AuthCredential credential) async {
    try {
      final firebase.Auth auth = _getAuth(app);
      final firebase.OAuthCredential firebaseCredential =
          _getCredential(credential);
      final firebase.UserCredential userCredential =
          await auth.signInWithCredential(firebaseCredential);
      return _fromJsUserCredential(userCredential);
    } catch (e) {
      throw mapFirebaseException(e);
    }
  }

  @override
  Future<PlatformAuthResult> signInWithCustomToken(
      String app, String token) async {
    try {
      final firebase.Auth auth = _getAuth(app);
      final firebase.UserCredential userCredential =
          await auth.signInWithCustomToken(token);
      return _fromJsUserCredential(userCredential);
    } catch (e) {
      throw mapFirebaseException(e);
    }
  }

  @override
  Future<PlatformAuthResult> signInWithEmailAndLink(
      String app, String email, String link) async {
    final firebase.Auth auth = _getAuth(app);
    final firebase.UserCredential userCredential =
        await auth.signInWithEmailLink(email, link);
    return _fromJsUserCredential(userCredential);
  }

  @override
  Future<void> signOut(String app) async {
    try {
      final firebase.Auth auth = _getAuth(app);
      await auth.signOut();
    } catch (e) {
      throw mapFirebaseException(e);
    }
  }

  @override
  Future<void> unlinkFromProvider(String app, String provider) async {
    try {
      final firebase.Auth auth = _getAuth(app);
      final firebase.User currentUser = _getCurrentUserOrThrow(auth);
      await currentUser.unlink(provider);
    } catch (e) {
      throw mapFirebaseException(e);
    }
  }

  @override
  Future<void> updateEmail(String app, String email) async {
    try {
      final firebase.Auth auth = _getAuth(app);
      final firebase.User currentUser = _getCurrentUserOrThrow(auth);
      await currentUser.updateEmail(email);
    } catch (e) {
      throw mapFirebaseException(e);
    }
  }

  @override
  Future<void> updatePassword(String app, String password) async {
    try {
      final firebase.Auth auth = _getAuth(app);
      final firebase.User currentUser = _getCurrentUserOrThrow(auth);
      await currentUser.updatePassword(password);
    } catch (e) {
      throw mapFirebaseException(e);
    }
  }

  @override
  Future<void> updatePhoneNumberCredential(
      String app, PhoneAuthCredential phoneAuthCredential) async {
    try {
      final firebase.Auth auth = _getAuth(app);
      final firebase.User currentUser = _getCurrentUserOrThrow(auth);
      final firebase.OAuthCredential credential =
          _getCredential(phoneAuthCredential);
      await currentUser.updatePhoneNumber(credential);
    } catch (e) {
      throw mapFirebaseException(e);
    }
  }

  @override
  Future<void> updateProfile(String app,
      {String displayName, String photoUrl}) async {
    try {
      final firebase.Auth auth = _getAuth(app);
      final firebase.User currentUser = _getCurrentUserOrThrow(auth);
      final firebase.UserProfile profile = firebase.UserProfile();
      if (displayName != null) {
        profile.displayName = displayName;
      }
      if (photoUrl != null) {
        profile.photoURL = photoUrl;
      }
      await currentUser.updateProfile(profile);
    } catch (e) {
      throw mapFirebaseException(e);
    }
  }

  @override
  Future<void> verifyPhoneNumber(String app,
      {String phoneNumber,
      Duration timeout,
      int forceResendingToken,
      PhoneVerificationCompleted verificationCompleted,
      PhoneVerificationFailed verificationFailed,
      PhoneCodeSent codeSent,
      PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout}) async {
    // TODO(hterkelsen): Figure out how to do this on Web. We need to display
    // a DOM element to contain the reCaptcha.
    // See https://github.com/flutter/flutter/issues/46021
    throw UnimplementedError('verifyPhoneNumber');
  }
}
