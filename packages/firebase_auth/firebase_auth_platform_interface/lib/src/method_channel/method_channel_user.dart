// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_platform_interface/src/method_channel/method_channel_user_credential.dart';
import 'package:firebase_auth_platform_interface/src/method_channel/utils/convert_auth_provider.dart';
import 'package:firebase_auth_platform_interface/src/pigeon/messages.pigeon.dart';

import 'utils/exception.dart';

/// Method Channel delegate for [UserPlatform] instances.
class MethodChannelUser extends UserPlatform {
  /// Constructs a new [MethodChannelUser] instance.
  MethodChannelUser(FirebaseAuthPlatform auth, MultiFactorPlatform multiFactor,
      PigeonUserDetails data)
      : super(auth, multiFactor, data);

  final _api = FirebaseAuthUserHostApi();

  AuthPigeonFirebaseApp get pigeonDefault {
    return AuthPigeonFirebaseApp(
      appName: auth.app.name,
      tenantId: auth.tenantId,
    );
  }

  @override
  Future<void> delete() async {
    try {
      await _api.delete(pigeonDefault);
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<String?> getIdToken(bool forceRefresh) async {
    try {
      final data = await _api.getIdToken(
        pigeonDefault,
        forceRefresh,
      );

      return data.token;
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<IdTokenResult> getIdTokenResult(bool forceRefresh) async {
    try {
      final data = await _api.getIdToken(
        pigeonDefault,
        forceRefresh,
      );

      return IdTokenResult(data);
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<UserCredentialPlatform> linkWithCredential(
    AuthCredential credential,
  ) async {
    try {
      final result = await _api.linkWithCredential(
        pigeonDefault,
        credential.asMap(),
      );

      MethodChannelUserCredential userCredential =
          MethodChannelUserCredential(auth, result);

      auth.currentUser = userCredential.user;
      return userCredential;
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<UserCredentialPlatform> linkWithProvider(
    AuthProvider provider,
  ) async {
    try {
      // To extract scopes and custom parameters from the provider
      final convertedProvider = convertToOAuthProvider(provider);

      final result = await _api.linkWithProvider(
        pigeonDefault,
        PigeonSignInProvider(
          providerId: convertedProvider.providerId,
          scopes: convertedProvider is OAuthProvider
              ? convertedProvider.scopes
              : null,
          customParameters: convertedProvider is OAuthProvider
              ? convertedProvider.parameters
              : null,
        ),
      );

      MethodChannelUserCredential userCredential =
          MethodChannelUserCredential(auth, result);

      auth.currentUser = userCredential.user;
      return userCredential;
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<UserCredentialPlatform> reauthenticateWithCredential(
    AuthCredential credential,
  ) async {
    try {
      final result = await _api.reauthenticateWithCredential(
        pigeonDefault,
        credential.asMap(),
      );

      MethodChannelUserCredential userCredential =
          MethodChannelUserCredential(auth, result);

      auth.currentUser = userCredential.user;
      return userCredential;
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<UserCredentialPlatform> reauthenticateWithProvider(
    AuthProvider provider,
  ) async {
    try {
      // To extract scopes and custom parameters from the provider
      final convertedProvider = convertToOAuthProvider(provider);

      final result = await _api.reauthenticateWithProvider(
        pigeonDefault,
        PigeonSignInProvider(
          providerId: convertedProvider.providerId,
          scopes: convertedProvider is OAuthProvider
              ? convertedProvider.scopes
              : null,
          customParameters: convertedProvider is OAuthProvider
              ? convertedProvider.parameters
              : null,
        ),
      );

      MethodChannelUserCredential userCredential =
          MethodChannelUserCredential(auth, result);

      auth.currentUser = userCredential.user;
      return userCredential;
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<void> reload() async {
    try {
      final result = await _api.reload(pigeonDefault);

      MethodChannelUser user =
          MethodChannelUser(auth, super.multiFactor, result);
      auth.currentUser = user;
      auth.sendAuthChangesEvent(auth.app.name, user);
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<void> sendEmailVerification(
    ActionCodeSettings? actionCodeSettings,
  ) async {
    try {
      await _api.sendEmailVerification(
        pigeonDefault,
        actionCodeSettings == null
            ? null
            : PigeonActionCodeSettings(
                url: actionCodeSettings.url,
                handleCodeInApp: actionCodeSettings.handleCodeInApp,
                iOSBundleId: actionCodeSettings.iOSBundleId,
                androidPackageName: actionCodeSettings.androidPackageName,
                androidInstallApp: actionCodeSettings.androidInstallApp,
                androidMinimumVersion: actionCodeSettings.androidMinimumVersion,
                dynamicLinkDomain: actionCodeSettings.dynamicLinkDomain,
              ),
      );
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<UserPlatform> unlink(String providerId) async {
    try {
      final result = await _api.unlink(pigeonDefault, providerId);

      // Native returns a UserCredential, whereas Dart should expect a User
      MethodChannelUserCredential userCredential =
          MethodChannelUserCredential(auth, result);
      MethodChannelUser? user = userCredential.user as MethodChannelUser?;

      auth.currentUser = user;
      auth.sendAuthChangesEvent(auth.app.name, user);
      return user!;
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    try {
      final result = await _api.updateEmail(pigeonDefault, newEmail);

      MethodChannelUser user =
          MethodChannelUser(auth, super.multiFactor, result);
      auth.currentUser = user;
      auth.sendAuthChangesEvent(auth.app.name, user);
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      final result = await _api.updatePassword(pigeonDefault, newPassword);

      MethodChannelUser user =
          MethodChannelUser(auth, super.multiFactor, result);
      auth.currentUser = user;
      auth.sendAuthChangesEvent(auth.app.name, user);
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<void> updatePhoneNumber(PhoneAuthCredential phoneCredential) async {
    try {
      final result = await _api.updatePhoneNumber(
        pigeonDefault,
        phoneCredential.asMap(),
      );

      MethodChannelUser user =
          MethodChannelUser(auth, super.multiFactor, result);
      auth.currentUser = user;
      auth.sendAuthChangesEvent(auth.app.name, user);
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<void> updateProfile(Map<String, String?> profile) async {
    try {
      final result = await _api.updateProfile(
        pigeonDefault,
        PigeonUserProfile(
          displayName: profile['displayName'],
          photoUrl: profile['photoURL'],
          displayNameChanged: profile.containsKey('displayName'),
          photoUrlChanged: profile.containsKey('photoURL'),
        ),
      );
      MethodChannelUser user =
          MethodChannelUser(auth, super.multiFactor, result);
      auth.currentUser = user;
      auth.sendAuthChangesEvent(auth.app.name, user);
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<void> verifyBeforeUpdateEmail(
    String newEmail, [
    ActionCodeSettings? actionCodeSettings,
  ]) async {
    try {
      await _api.verifyBeforeUpdateEmail(
        pigeonDefault,
        newEmail,
        actionCodeSettings == null
            ? null
            : PigeonActionCodeSettings(
                url: actionCodeSettings.url,
                handleCodeInApp: actionCodeSettings.handleCodeInApp,
                iOSBundleId: actionCodeSettings.iOSBundleId,
                androidPackageName: actionCodeSettings.androidPackageName,
                androidInstallApp: actionCodeSettings.androidInstallApp,
                androidMinimumVersion: actionCodeSettings.androidMinimumVersion,
                dynamicLinkDomain: actionCodeSettings.dynamicLinkDomain,
              ),
      );
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }
}
