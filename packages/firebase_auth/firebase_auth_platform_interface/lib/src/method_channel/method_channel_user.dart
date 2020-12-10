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
  MethodChannelUser(FirebaseAuthPlatform auth, Map<String, dynamic> data)
      : assert(data != null),
        super(auth, data);

  @override
  Future<void> delete() async {
    return MethodChannelFirebaseAuth.channel
        .invokeMethod<void>('User#delete', <String, dynamic>{
      'appName': auth.app.name,
    }).catchError(catchPlatformException);
  }

  @override
  Future<String> getIdToken(bool forceRefresh) async {
    Map<String, dynamic> data = await MethodChannelFirebaseAuth.channel
        .invokeMapMethod<String, dynamic>('User#getIdToken', <String, dynamic>{
      'appName': auth.app.name,
      'forceRefresh': forceRefresh,
      'tokenOnly': true,
    }).catchError(catchPlatformException);

    return data['token'];
  }

  @override
  Future<IdTokenResult> getIdTokenResult(bool forceRefresh) async {
    Map<String, dynamic> data = await MethodChannelFirebaseAuth.channel
        .invokeMapMethod<String, dynamic>('User#getIdToken', <String, dynamic>{
      'appName': auth.app.name,
      'forceRefresh': forceRefresh,
      'tokenOnly': false,
    }).catchError(catchPlatformException);

    return IdTokenResult(data);
  }

  @override
  Future<UserCredentialPlatform> linkWithCredential(
      AuthCredential credential) async {
    Map<String, dynamic> data = await MethodChannelFirebaseAuth.channel
        .invokeMapMethod<String, dynamic>(
            'User#linkWithCredential', <String, dynamic>{
      'appName': auth.app.name,
      'credential': credential.asMap(),
    }).catchError(catchPlatformException);

    MethodChannelUserCredential userCredential =
        MethodChannelUserCredential(auth, data);

    auth.currentUser = userCredential.user;
    return userCredential;
  }

  @override
  Future<UserCredentialPlatform> reauthenticateWithCredential(
      AuthCredential credential) async {
    Map<String, dynamic> data = await MethodChannelFirebaseAuth.channel
        .invokeMapMethod<String, dynamic>(
            'User#reauthenticateUserWithCredential', <String, dynamic>{
      'appName': auth.app.name,
      'credential': credential.asMap(),
    }).catchError(catchPlatformException);

    MethodChannelUserCredential userCredential =
        MethodChannelUserCredential(auth, data);

    auth.currentUser = userCredential.user;
    return userCredential;
  }

  @override
  Future<void> reload() async {
    Map<String, dynamic> data = await MethodChannelFirebaseAuth.channel
        .invokeMapMethod<String, dynamic>('User#reload', <String, dynamic>{
      'appName': auth.app.name,
    }).catchError(catchPlatformException);

    MethodChannelUser user = MethodChannelUser(auth, data);
    auth.currentUser = user;
    auth.sendAuthChangesEvent(auth.app.name, user);
  }

  @override
  Future<void> sendEmailVerification(
      ActionCodeSettings actionCodeSettings) async {
    return MethodChannelFirebaseAuth.channel.invokeMethod<void>(
        'User#sendEmailVerification', <String, dynamic>{
      'appName': auth.app.name,
      'actionCodeSettings': actionCodeSettings?.asMap()
    }).catchError(catchPlatformException);
  }

  @override
  Future<UserPlatform> unlink(String providerId) async {
    Map<String, dynamic> data = await MethodChannelFirebaseAuth.channel
        .invokeMapMethod<String, dynamic>('User#unlink', <String, dynamic>{
      'appName': auth.app.name,
      'providerId': providerId,
    }).catchError(catchPlatformException);

    // Native returns a UserCredential, whereas Dart should expect a User
    MethodChannelUserCredential userCredential =
        MethodChannelUserCredential(auth, data);
    MethodChannelUser user = userCredential.user;

    auth.currentUser = user;
    auth.sendAuthChangesEvent(auth.app.name, user);
    return user;
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    Map<String, dynamic> data = await MethodChannelFirebaseAuth.channel
        .invokeMapMethod<String, dynamic>('User#updateEmail', <String, dynamic>{
      'appName': auth.app.name,
      'newEmail': newEmail,
    }).catchError(catchPlatformException);

    MethodChannelUser user = MethodChannelUser(auth, data);
    auth.currentUser = user;
    auth.sendAuthChangesEvent(auth.app.name, user);
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    Map<String, dynamic> data = await MethodChannelFirebaseAuth.channel
        .invokeMapMethod<String, dynamic>(
            'User#updatePassword', <String, dynamic>{
      'appName': auth.app.name,
      'newPassword': newPassword,
    }).catchError(catchPlatformException);

    MethodChannelUser user = MethodChannelUser(auth, data);
    auth.currentUser = user;
    auth.sendAuthChangesEvent(auth.app.name, user);
  }

  @override
  Future<void> updatePhoneNumber(PhoneAuthCredential phoneCredential) async {
    Map<String, dynamic> data = await MethodChannelFirebaseAuth.channel
        .invokeMapMethod<String, dynamic>(
            'User#updatePhoneNumber', <String, dynamic>{
      'appName': auth.app.name,
      'credential': phoneCredential.asMap(),
    }).catchError(catchPlatformException);

    MethodChannelUser user = MethodChannelUser(auth, data);
    auth.currentUser = user;
    auth.sendAuthChangesEvent(auth.app.name, user);
  }

  @override
  Future<void> updateProfile(Map<String, String> profile) async {
    Map<String, dynamic> data = await MethodChannelFirebaseAuth.channel
        .invokeMapMethod<String, dynamic>(
            'User#updateProfile', <String, dynamic>{
      'appName': auth.app.name,
      'profile': profile,
    }).catchError(catchPlatformException);

    MethodChannelUser user = MethodChannelUser(auth, data);
    auth.currentUser = user;
    auth.sendAuthChangesEvent(auth.app.name, user);
  }

  @override
  Future<void> verifyBeforeUpdateEmail(String newEmail,
      [ActionCodeSettings actionCodeSettings]) async {
    return MethodChannelFirebaseAuth.channel
        .invokeMethod<void>('User#verifyBeforeUpdateEmail', <String, dynamic>{
      'appName': auth.app.name,
      'newEmail': newEmail,
      'actionCodeSettings': actionCodeSettings?.asMap(),
    }).catchError(catchPlatformException);
  }
}
