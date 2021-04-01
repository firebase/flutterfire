// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'interop/auth.dart' as auth_interop;
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_web/src/firebase_auth_web_user_credential.dart';
import 'package:intl/intl.dart';

import 'firebase_auth_web_confirmation_result.dart';
import 'utils/web_utils.dart';

/// The format of an incoming metadata string timestamp from the firebase-dart library
final DateFormat _dateFormat = DateFormat('EEE, d MMM yyyy HH:mm:ss', 'en_US');

/// Web delegate implementation of [UserPlatform].
class UserWeb extends UserPlatform {
  /// Creates a new [UserWeb] instance.
  UserWeb(FirebaseAuthPlatform auth, this._webUser)
      : super(auth, {
          'displayName': _webUser.displayName,
          'email': _webUser.email,
          'emailVerified': _webUser.emailVerified,
          'isAnonymous': _webUser.isAnonymous,
          'metadata': <String, int>{
            'creationTime': _dateFormat
                .parse(_webUser.metadata.creationTime)
                .millisecondsSinceEpoch,
            'lastSignInTime': _dateFormat
                .parse(_webUser.metadata.lastSignInTime)
                .millisecondsSinceEpoch,
          },
          'phoneNumber': _webUser.phoneNumber,
          'photoURL': _webUser.photoURL,
          'providerData': _webUser.providerData
              .map((auth_interop.UserInfo webUserInfo) => <String, dynamic>{
                    'displayName': webUserInfo.displayName,
                    'email': webUserInfo.email,
                    'phoneNumber': webUserInfo.phoneNumber,
                    'providerId': webUserInfo.providerId,
                    'photoURL': webUserInfo.photoURL,
                    'uid': webUserInfo.uid,
                  })
              .toList(),
          'refreshToken': _webUser.refreshToken,
          'tenantId': _webUser.tenantId,
          'uid': _webUser.uid,
        });

  final auth_interop.User _webUser;

  @override
  Future<void> delete() async {
    _assertIsSignedOut(auth);
    try {
      await _webUser.delete();
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<String> getIdToken(bool forceRefresh) async {
    _assertIsSignedOut(auth);

    try {
      return await _webUser.getIdToken(forceRefresh);
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<IdTokenResult> getIdTokenResult(bool forceRefresh) async {
    _assertIsSignedOut(auth);
    return convertWebIdTokenResult(
        await _webUser.getIdTokenResult(forceRefresh));
  }

  @override
  Future<UserCredentialPlatform> linkWithCredential(
      AuthCredential credential) async {
    _assertIsSignedOut(auth);
    try {
      return UserCredentialWeb(
          auth,
          await _webUser
              .linkWithCredential(convertPlatformCredential(credential)));
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<ConfirmationResultPlatform> linkWithPhoneNumber(
    String phoneNumber,
    RecaptchaVerifierFactoryPlatform applicationVerifier,
  ) async {
    _assertIsSignedOut(auth);
    try {
      // Do not inline - type is not inferred & error is thrown.
      auth_interop.RecaptchaVerifier verifier = applicationVerifier.delegate;

      return ConfirmationResultWeb(
        auth,
        await _webUser.linkWithPhoneNumber(phoneNumber, verifier),
      );
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<UserCredentialPlatform> reauthenticateWithCredential(
      AuthCredential credential) async {
    _assertIsSignedOut(auth);
    try {
      auth_interop.UserCredential userCredential = await _webUser
          .reauthenticateWithCredential(convertPlatformCredential(credential)!);
      return UserCredentialWeb(auth, userCredential);
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<void> reload() async {
    _assertIsSignedOut(auth);

    try {
      await _webUser.reload();
      auth.sendAuthChangesEvent(auth.app.name, auth.currentUser);
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<void> sendEmailVerification(ActionCodeSettings? actionCodeSettings) {
    _assertIsSignedOut(auth);

    try {
      return _webUser.sendEmailVerification(
        convertPlatformActionCodeSettings(actionCodeSettings),
      );
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<UserPlatform> unlink(String providerId) async {
    _assertIsSignedOut(auth);

    try {
      return UserWeb(auth, await _webUser.unlink(providerId));
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    _assertIsSignedOut(auth);

    try {
      await _webUser.updateEmail(newEmail);
      await _webUser.reload();
      auth.sendAuthChangesEvent(auth.app.name, auth.currentUser);
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    _assertIsSignedOut(auth);

    try {
      await _webUser.updatePassword(newPassword);
      await _webUser.reload();
      auth.sendAuthChangesEvent(auth.app.name, auth.currentUser);
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<void> updatePhoneNumber(PhoneAuthCredential phoneCredential) async {
    _assertIsSignedOut(auth);

    try {
      await _webUser
          .updatePhoneNumber(convertPlatformCredential(phoneCredential));
      await _webUser.reload();
      auth.sendAuthChangesEvent(auth.app.name, auth.currentUser);
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<void> updateProfile(Map<String, String?> profile) async {
    _assertIsSignedOut(auth);

    try {
      await _webUser.updateProfile(auth_interop.UserProfile(
        displayName: profile['displayName'],
        photoURL: profile['photoURL'],
      ));
      await _webUser.reload();
      auth.sendAuthChangesEvent(auth.app.name, auth.currentUser);
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<void> verifyBeforeUpdateEmail(
    String newEmail, [
    ActionCodeSettings? actionCodeSettings,
  ]) async {
    _assertIsSignedOut(auth);

    await _webUser.verifyBeforeUpdateEmail(
      newEmail,
      convertPlatformActionCodeSettings(actionCodeSettings),
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
