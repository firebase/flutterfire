// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_platform_interface/src/method_channel/method_channel_firebase_auth.dart';
import 'package:firebase_auth_platform_interface/src/method_channel/method_channel_user_credential.dart';
import 'package:firebase_auth_platform_interface/src/platform_interface/platform_interface_user.dart';

import 'utils/exception.dart';

/// Method Channel delegate for [UserPlatform] instances.
class MethodChannelUser extends UserPlatform {
  /// Constructs a new [MethodChannelUser] instance.
  MethodChannelUser(FirebaseAuthPlatform auth, Map<String, Object?> data)
      : super(auth, data);

  @override
  Future<void> delete() async {
    try {
      await MethodChannelFirebaseAuth.channel.invokeMethod<void>(
        'User#delete',
        <String, Object?>{
          'appName': auth.app.name,
        },
      );
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<String> getIdToken(bool forceRefresh) async {
    try {
      final data = await MethodChannelFirebaseAuth.channel
          .invokeMapMethod<String, Object?>(
        'User#getIdToken',
        <String, Object?>{
          'appName': auth.app.name,
          'forceRefresh': forceRefresh,
          'tokenOnly': true,
        },
      );

      return data!['token']! as String;
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<IdTokenResult> getIdTokenResult(bool forceRefresh) async {
    try {
      final data = await MethodChannelFirebaseAuth.channel
          .invokeMapMethod<String, Object?>(
        'User#getIdToken',
        <String, Object?>{
          'appName': auth.app.name,
          'forceRefresh': forceRefresh,
          'tokenOnly': false,
        },
      );

      return IdTokenResult(data!);
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<UserCredentialPlatform> linkWithCredential(
    AuthCredential credential,
  ) async {
    try {
      final data = await MethodChannelFirebaseAuth.channel
          .invokeMapMethod<String, Object?>(
        'User#linkWithCredential',
        <String, Object?>{
          'appName': auth.app.name,
          'credential': credential.asMap(),
        },
      );

      final userCredential = MethodChannelUserCredential(auth, data!);

      auth.currentUser = userCredential.user;
      return userCredential;
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<UserCredentialPlatform> reauthenticateWithCredential(
    AuthCredential credential,
  ) async {
    try {
      final data = await MethodChannelFirebaseAuth.channel
          .invokeMapMethod<String, Object?>(
        'User#reauthenticateUserWithCredential',
        <String, Object?>{
          'appName': auth.app.name,
          'credential': credential.asMap(),
        },
      );

      final userCredential = MethodChannelUserCredential(auth, data!);

      auth.currentUser = userCredential.user;
      return userCredential;
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<void> reload() async {
    try {
      final data = await MethodChannelFirebaseAuth.channel
          .invokeMapMethod<String, Object?>(
        'User#reload',
        <String, Object?>{
          'appName': auth.app.name,
        },
      );

      MethodChannelUser user = MethodChannelUser(auth, data!);
      auth.currentUser = user;
      auth.sendAuthChangesEvent(auth.app.name, user);
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<void> sendEmailVerification(
    ActionCodeSettings? actionCodeSettings,
  ) async {
    try {
      await MethodChannelFirebaseAuth.channel.invokeMethod<void>(
          'User#sendEmailVerification', <String, Object?>{
        'appName': auth.app.name,
        'actionCodeSettings': actionCodeSettings?.asMap()
      });
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<UserPlatform> unlink(String providerId) async {
    try {
      final data = await MethodChannelFirebaseAuth.channel
          .invokeMapMethod<String, Object?>(
        'User#unlink',
        <String, Object?>{
          'appName': auth.app.name,
          'providerId': providerId,
        },
      );

      // Native returns a UserCredential, whereas Dart should expect a User
      final userCredential = MethodChannelUserCredential(auth, data!);
      MethodChannelUser? user = userCredential.user as MethodChannelUser?;

      auth.currentUser = user;
      auth.sendAuthChangesEvent(auth.app.name, user);
      return user!;
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    try {
      final data = await MethodChannelFirebaseAuth.channel
          .invokeMapMethod<String, Object?>(
        'User#updateEmail',
        <String, Object?>{
          'appName': auth.app.name,
          'newEmail': newEmail,
        },
      );

      MethodChannelUser user = MethodChannelUser(auth, data!);
      auth.currentUser = user;
      auth.sendAuthChangesEvent(auth.app.name, user);
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      final data = await MethodChannelFirebaseAuth.channel
          .invokeMapMethod<String, Object?>(
        'User#updatePassword',
        <String, Object?>{
          'appName': auth.app.name,
          'newPassword': newPassword,
        },
      );

      MethodChannelUser user = MethodChannelUser(auth, data!);
      auth.currentUser = user;
      auth.sendAuthChangesEvent(auth.app.name, user);
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<void> updatePhoneNumber(PhoneAuthCredential phoneCredential) async {
    try {
      final data = await MethodChannelFirebaseAuth.channel
          .invokeMapMethod<String, Object?>(
        'User#updatePhoneNumber',
        <String, Object?>{
          'appName': auth.app.name,
          'credential': phoneCredential.asMap(),
        },
      );

      MethodChannelUser user = MethodChannelUser(auth, data!);
      auth.currentUser = user;
      auth.sendAuthChangesEvent(auth.app.name, user);
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<void> updateProfile(Map<String, String?> profile) async {
    try {
      final data = await MethodChannelFirebaseAuth.channel
          .invokeMapMethod<String, Object?>(
        'User#updateProfile',
        <String, Object?>{
          'appName': auth.app.name,
          'profile': profile,
        },
      );

      MethodChannelUser user = MethodChannelUser(auth, data!);
      auth.currentUser = user;
      auth.sendAuthChangesEvent(auth.app.name, user);
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<void> verifyBeforeUpdateEmail(
    String newEmail, [
    ActionCodeSettings? actionCodeSettings,
  ]) async {
    try {
      await MethodChannelFirebaseAuth.channel.invokeMethod<void>(
        'User#verifyBeforeUpdateEmail',
        <String, Object?>{
          'appName': auth.app.name,
          'newEmail': newEmail,
          'actionCodeSettings': actionCodeSettings?.asMap(),
        },
      );
    } catch (e) {
      throw convertPlatformException(e);
    }
  }
}
