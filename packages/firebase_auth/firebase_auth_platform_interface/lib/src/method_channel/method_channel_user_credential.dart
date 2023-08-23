// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_platform_interface/src/method_channel/method_channel_multi_factor.dart';
import 'package:firebase_auth_platform_interface/src/method_channel/method_channel_user.dart';
import 'package:firebase_auth_platform_interface/src/pigeon/messages.pigeon.dart';

/// Method Channel delegate for [UserCredentialPlatform].
class MethodChannelUserCredential extends UserCredentialPlatform {
  // ignore: public_member_api_docs
  MethodChannelUserCredential(
      FirebaseAuthPlatform auth, PigeonUserCredential data)
      : super(
          auth: auth,
          additionalUserInfo: data.additionalUserInfo == null
              ? null
              : AdditionalUserInfo(
                  isNewUser: data.additionalUserInfo!.isNewUser,
                  profile: Map<String, dynamic>.from(
                      data.additionalUserInfo!.profile ?? {}),
                  providerId: data.additionalUserInfo!.providerId,
                  username: data.additionalUserInfo!.username,
                  authorizationCode: data.additionalUserInfo?.authorizationCode,
                ),
          credential: data.credential == null
              ? null
              : AuthCredential(
                  providerId: data.credential!.providerId,
                  signInMethod: data.credential!.signInMethod,
                  token: data.credential!.nativeId,
                  accessToken: data.credential!.accessToken,
                ),
          user: data.user == null
              ? null
              : MethodChannelUser(
                  auth,
                  MethodChannelMultiFactor(auth),
                  data.user!,
                ),
        );
}
