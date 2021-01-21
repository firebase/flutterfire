// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_platform_interface/src/method_channel/method_channel_user.dart';
import 'package:firebase_auth_platform_interface/src/platform_interface/platform_interface_user_credential.dart';

/// Method Channel delegate for [UserCredentialPlatform].
class MethodChannelUserCredential extends UserCredentialPlatform {
  // ignore: public_member_api_docs
  MethodChannelUserCredential(
      FirebaseAuthPlatform auth, Map<String, dynamic> data)
      : super(
          auth: auth,
          additionalUserInfo: data['additionalUserInfo'] == null
              ? null
              : AdditionalUserInfo(
                  isNewUser: data['additionalUserInfo']['isNewUser'],
                  profile: Map<String, dynamic>.from(
                      data['additionalUserInfo']['profile'] ?? {}),
                  providerId: data['additionalUserInfo']['providerId'],
                  username: data['additionalUserInfo']['username'],
                ),
          credential: data['authCredential'] == null
              ? null
              : AuthCredential(
                  providerId: data['authCredential']['providerId'],
                  signInMethod: data['authCredential']['signInMethod'],
                ),
          user: data['user'] == null
              ? null
              : MethodChannelUser(
                  auth, Map<String, dynamic>.from(data['user'])),
        );
}
