// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

class AdditionalUserInfo {
  @protected
  AdditionalUserInfo(
      {this.isNewUser, this.profile, this.providerId, this.username});

  final bool isNewUser;
  final Map<String, dynamic> profile;
  final String providerId;
  final String username;

  @override
  String toString() {
    return '$AdditionalUserInfo(isNewUser: $isNewUser, profile: ${profile.toString()}, providerId: $providerId, username: $username)';
  }
}
