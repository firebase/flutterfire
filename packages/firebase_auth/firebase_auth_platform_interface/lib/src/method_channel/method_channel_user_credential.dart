// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_platform_interface/src/method_channel/method_channel_user.dart';
import 'package:firebase_auth_platform_interface/src/method_channel/utils/convert.dart';
import 'package:firebase_auth_platform_interface/src/platform_interface/platform_interface_user_credential.dart';

/// Method Channel delegate for [UserCredentialPlatform].
class MethodChannelUserCredential extends UserCredentialPlatform {
  // ignore: public_member_api_docs
  MethodChannelUserCredential(
    FirebaseAuthPlatform auth,
    Map<String, Object?> data,
  ) : super(
          auth: auth,
          additionalUserInfo: data['additionalUserInfo'] //
              .castMap<String, Object?>()
              .guard(
                (v) => AdditionalUserInfo(
                  isNewUser: v['isNewUser']! as bool,
                  profile: v['profile'].castMap<String, Object?>() ?? {},
                  providerId: v['providerId'] as String?,
                  username: v['username'] as String?,
                ),
              ),
          credential: data['authCredential'] //
              .castMap<String, Object?>()
              .guard(
                (v) => AuthCredential(
                  providerId: v['providerId']! as String,
                  signInMethod: v['signInMethod']! as String,
                ),
              ),
          user: data['user'] //
              .castMap<String, Object?>()
              .guard((v) => MethodChannelUser(auth, v)),
        );
}
