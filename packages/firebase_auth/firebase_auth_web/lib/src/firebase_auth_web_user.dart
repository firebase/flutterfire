// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:js_interop' as js_interop;
import 'dart:js_interop_unsafe';

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_web/src/firebase_auth_web_user_credential.dart';

import 'firebase_auth_web_confirmation_result.dart';
import 'interop/auth.dart' as auth_interop;
import 'utils/web_utils.dart';

/// Web delegate implementation of [UserPlatform].
class UserWeb extends UserPlatform {
  /// Creates a new [UserWeb] instance.
  UserWeb(
    FirebaseAuthPlatform auth,
    MultiFactorPlatform multiFactor,
    this._webUser,
    this._webAuth,
  ) : super(
          auth,
          multiFactor,
          PigeonUserDetails(
              userInfo: PigeonUserInfo(
                displayName: _webUser.displayName,
                email: _webUser.email,
                isEmailVerified: _webUser.emailVerified,
                isAnonymous: _webUser.isAnonymous,
                creationTimestamp: _webUser.metadata.creationTime != null
                    ? (js_interop.globalContext.getProperty('Date'.toJS)!
                            as js_interop.JSObject)
                        .callMethod<js_interop.JSNumber>(
                            'parse'.toJS, _webUser.metadata.creationTime)
                        .toDartInt
                    : null,
                lastSignInTimestamp: _webUser.metadata.lastSignInTime != null
                    ? (js_interop.globalContext.getProperty('Date'.toJS)!
                            as js_interop.JSObject)
                        .callMethod<js_interop.JSNumber>(
                            'parse'.toJS, _webUser.metadata.lastSignInTime)
                        .toDartInt
                    : null,
                phoneNumber: _webUser.phoneNumber,
                photoUrl: _webUser.photoURL,
                refreshToken: _webUser.refreshToken,
                tenantId: _webUser.tenantId,
                uid: _webUser.uid,
              ),
              providerData: _webUser.providerData
                  .map((auth_interop.UserInfo webUserInfo) => <String, dynamic>{
                        'displayName': webUserInfo.displayName,
                        'email': webUserInfo.email,
                        // isAnonymous is always false for providerData
                        'isAnonymous': false,
                        // isEmailVerified is always true for providerData
                        'isEmailVerified': true,
                        'phoneNumber': webUserInfo.phoneNumber,
                        'providerId': webUserInfo.providerId,
                        'photoUrl': webUserInfo.photoURL,
                        'uid': webUserInfo.uid,
                      })
                  .toList()),
        );

  final auth_interop.User _webUser;
  final auth_interop.Auth? _webAuth;

  @override
  Future<void> delete() async {
    _assertIsSignedOut(auth);
    await guardAuthExceptions(_webUser.delete);
  }

  @override
  Future<String> getIdToken(bool forceRefresh) async {
    _assertIsSignedOut(auth);
    final token = await guardAuthExceptions(
      () => _webUser.getIdToken(forceRefresh),
    );
    return token;
  }

  @override
  Future<IdTokenResult> getIdTokenResult(bool forceRefresh) async {
    _assertIsSignedOut(auth);
    final result = convertWebIdTokenResult(
      await guardAuthExceptions(
        () => _webUser.getIdTokenResult(forceRefresh),
      ),
    );
    return result;
  }

  @override
  Future<UserCredentialPlatform> linkWithCredential(
      AuthCredential credential) async {
    _assertIsSignedOut(auth);
    final userCredential = await guardAuthExceptions(
      () => _webUser.linkWithCredential(
        convertPlatformCredential(credential),
      ),
      auth: _webAuth,
    );

    return UserCredentialWeb(
      auth,
      userCredential,
      _webAuth,
    );
  }

  @override
  Future<UserCredentialPlatform> linkWithPopup(AuthProvider provider) async {
    _assertIsSignedOut(auth);
    final userCredential = await guardAuthExceptions(
      () => _webUser.linkWithPopup(
        convertPlatformAuthProvider(provider),
      ),
      auth: _webAuth,
    );

    return UserCredentialWeb(
      auth,
      userCredential,
      _webAuth,
    );
  }

  @override
  Future<void> linkWithRedirect(AuthProvider provider) async {
    await guardAuthExceptions(
      () => _webUser.linkWithRedirect(
        convertPlatformAuthProvider(provider),
      ),
      auth: _webAuth,
    );
  }

  @override
  Future<ConfirmationResultPlatform> linkWithPhoneNumber(
    String phoneNumber,
    RecaptchaVerifierFactoryPlatform applicationVerifier,
  ) async {
    _assertIsSignedOut(auth);

    // Do not inline - type is not inferred & error is thrown.
    auth_interop.RecaptchaVerifier verifier = applicationVerifier.delegate;
    final confirmationResult = await guardAuthExceptions(
      () => _webUser.linkWithPhoneNumber(phoneNumber, verifier),
      auth: _webAuth,
    );
    return ConfirmationResultWeb(
      auth,
      confirmationResult,
      _webAuth,
    );
  }

  @override
  Future<UserCredentialPlatform> reauthenticateWithCredential(
      AuthCredential credential) async {
    _assertIsSignedOut(auth);

    auth_interop.UserCredential userCredential = await guardAuthExceptions(
      () => _webUser.reauthenticateWithCredential(
        convertPlatformCredential(credential)!,
      ),
      auth: _webAuth,
    );
    return UserCredentialWeb(auth, userCredential, _webAuth);
  }

  @override
  Future<UserCredentialPlatform> reauthenticateWithPopup(
      AuthProvider provider) async {
    _assertIsSignedOut(auth);

    auth_interop.UserCredential userCredential = await guardAuthExceptions(
      () => _webUser.reauthenticateWithPopup(
        convertPlatformAuthProvider(provider),
      ),
      auth: _webAuth,
    );
    return UserCredentialWeb(auth, userCredential, _webAuth);
  }

  @override
  Future<void> reauthenticateWithRedirect(AuthProvider provider) async {
    _assertIsSignedOut(auth);

    return guardAuthExceptions(
      () => _webUser.reauthenticateWithRedirect(
        convertPlatformAuthProvider(provider),
      ),
    );
  }

  @override
  Future<void> reload() async {
    _assertIsSignedOut(auth);
    await guardAuthExceptions(_webUser.reload, auth: _webAuth);
    auth.sendAuthChangesEvent(auth.app.name, auth.currentUser);
  }

  @override
  Future<void> sendEmailVerification(ActionCodeSettings? actionCodeSettings) {
    _assertIsSignedOut(auth);

    return guardAuthExceptions(
      () => _webUser.sendEmailVerification(
        convertPlatformActionCodeSettings(actionCodeSettings),
      ),
      auth: _webAuth,
    );
  }

  @override
  Future<UserPlatform> unlink(String providerId) async {
    _assertIsSignedOut(auth);

    final userPlatform = await guardAuthExceptions(
      () => _webUser.unlink(providerId),
      auth: _webAuth,
    );

    return UserWeb(
      auth,
      multiFactor,
      userPlatform,
      _webAuth,
    );
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    _assertIsSignedOut(auth);

    await guardAuthExceptions(
      () => _webUser.updateEmail(newEmail),
      auth: _webAuth,
    );
    await guardAuthExceptions(_webUser.reload);
    auth.sendAuthChangesEvent(auth.app.name, auth.currentUser);
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    _assertIsSignedOut(auth);

    await guardAuthExceptions(
      () => _webUser.updatePassword(newPassword),
      auth: _webAuth,
    );
    await guardAuthExceptions(_webUser.reload);
    auth.sendAuthChangesEvent(auth.app.name, auth.currentUser);
  }

  @override
  Future<void> updatePhoneNumber(PhoneAuthCredential phoneCredential) async {
    _assertIsSignedOut(auth);

    await guardAuthExceptions(
      () => _webUser.updatePhoneNumber(
        convertPlatformCredential(phoneCredential),
      ),
      auth: _webAuth,
    );
    await guardAuthExceptions(
      _webUser.reload,
      auth: _webAuth,
    );
    auth.sendAuthChangesEvent(auth.app.name, auth.currentUser);
  }

  @override
  Future<void> updateProfile(Map<String, String?> profile) async {
    _assertIsSignedOut(auth);

    auth_interop.UserProfile newProfile;

    if (profile.containsKey('displayName') && profile.containsKey('photoURL')) {
      newProfile = auth_interop.UserProfile(
        displayName: profile['displayName']?.toJS,
        photoURL: profile['photoURL']?.toJS,
      );
    } else if (profile.containsKey('displayName')) {
      newProfile = auth_interop.UserProfile(
        displayName: profile['displayName']?.toJS,
      );
    } else {
      newProfile = auth_interop.UserProfile(
        photoURL: profile['photoURL']?.toJS,
      );
    }

    await guardAuthExceptions(
      () => _webUser.updateProfile(newProfile),
      auth: _webAuth,
    );
    await guardAuthExceptions(
      _webUser.reload,
      auth: _webAuth,
    );
    auth.sendAuthChangesEvent(auth.app.name, auth.currentUser);
  }

  @override
  Future<void> verifyBeforeUpdateEmail(
    String newEmail, [
    ActionCodeSettings? actionCodeSettings,
  ]) async {
    _assertIsSignedOut(auth);

    await guardAuthExceptions(
      () => _webUser.verifyBeforeUpdateEmail(
        newEmail,
        convertPlatformActionCodeSettings(actionCodeSettings),
      ),
      auth: _webAuth,
    );
  }
}

/// Keeps the platform logic the same as native. Since we can keep reference to
/// a user, sign-out and then call a method on the user reference, we first check
/// whether the user is signed out before calling a method. This replicates
/// what happens on native since requests are sent over the method channel.
void _assertIsSignedOut(FirebaseAuthPlatform instance) {
  if (instance.currentUser == null) {
    throw FirebaseAuthException(
      code: 'no-current-user',
      message: 'No user currently signed in.',
    );
  }
}
