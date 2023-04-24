// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth_platform_interface/src/pigeon/messages.pigeon.dart';
import 'package:meta/meta.dart';

/// User profile information, visible only to the Firebase project's apps.
class UserInfo {
  // ignore: public_member_api_docs
  @protected
  UserInfo.fromPigeon(this._data);

  @protected
  UserInfo.fromJson(Map<dynamic, dynamic> data)
      : _data = PigeonUserInfo(
          uid: data['uid'] as String,
          email: data['email'] as String?,
          displayName: data['displayName'] as String?,
          photoUrl: data['photoUrl'] as String?,
          phoneNumber: data['phoneNumber'] as String?,
          isAnonymous: data['isAnonymous'] as bool,
          isEmailVerified: data['isEmailVerified'] as bool,
          providerId: data['providerId'] as String?,
          tenantId: data['tenantId'] as String?,
          refreshToken: data['refreshToken'] as String?,
          creationTimestamp: data['creationTimestamp'] as int?,
          lastSignInTimestamp: data['lastSignInTimestamp'] as int?,
        );

  final PigeonUserInfo _data;

  /// The users display name.
  ///
  /// Will be `null` if signing in anonymously or via password authentication.
  String? get displayName {
    return _data.displayName;
  }

  /// The users email address.
  ///
  /// Will be `null` if signing in anonymously.
  String? get email {
    return _data.email;
  }

  /// Returns the users phone number.
  ///
  /// This property will be `null` if the user has not signed in or been has
  /// their phone number linked.
  String? get phoneNumber {
    return _data.phoneNumber;
  }

  /// Returns a photo URL for the user.
  ///
  /// This property will be populated if the user has signed in or been linked
  /// with a 3rd party OAuth provider (such as Google).
  String? get photoURL {
    return _data.photoUrl;
  }

  /// The federated provider ID.
  String get providerId {
    // UserInfo objects are only available from providers.
    return _data.providerId!;
  }

  /// The user's unique ID.
  String? get uid {
    return _data.uid;
  }

  @override
  String toString() {
    return '$UserInfo(displayName: $displayName, email: $email, phoneNumber: $phoneNumber, photoURL: $photoURL, providerId: $providerId, uid: $uid)';
  }
}
