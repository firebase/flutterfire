// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_platform_interface/src/method_channel/method_channel_user.dart';
import 'package:firebase_auth_platform_interface/src/platform_interface/platform_interface_user_credential.dart';
// ignore: implementation_imports
import 'package:firebase_core/src/internals.dart';

/// Method Channel delegate for [UserCredentialPlatform].
class MethodChannelUserCredential extends UserCredentialPlatform {
  // ignore: public_member_api_docs
  MethodChannelUserCredential(
      FirebaseAuthPlatform auth, Map<String, Object?> data)
      : super(
          auth: auth,
          additionalUserInfo: data['additionalUserInfo']
              .safeCast<Map<Object?, Object?>>()
              .guard((value) {
            return AdditionalUserInfo(
              isNewUser: value['isNewUser']! as bool,
              profile: {
                ...?value['profile'].safeCast<Map<String, Object?>>(),
              },
              providerId: value['providerId'] as String?,
              username: value['username'] as String?,
            );
          }),
          credential: data['authCredential']
              .safeCast<Map<Object?, Object?>>()
              .guard((value) {
            return AuthCredential(
              providerId: value['providerId']! as String,
              signInMethod: value['signInMethod']! as String,
            );
          }),
          user: data['user']
              .safeCast<Map<String, Object?>>()
              .guard((value) => MethodChannelUser(auth, {...value})),
        );
}
