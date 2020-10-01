// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_auth;

/// A UserCredential is returned from authentication requests such as
/// [createUserWithEmailAndPassword].
class UserCredential {
  UserCredentialPlatform _delegate;

  final FirebaseAuth _auth;

  UserCredential._(this._auth, this._delegate) {
    UserCredentialPlatform.verifyExtends(_delegate);
  }

  /// Returns additional information about the user, such as whether they are a
  /// newly created one.
  AdditionalUserInfo get additionalUserInfo {
    return _delegate.additionalUserInfo;
  }

  /// The users [AuthCredential].
  AuthCredential get credential {
    return _delegate.credential;
  }

  /// Returns a [User] containing additional information and user specific
  /// methods.
  User get user {
    return _delegate.user == null ? null : User._(_auth, _delegate.user);
  }

  @override
  String toString() {
    return 'UserCredential(additionalUserInfo: ${additionalUserInfo.toString()}, credential: ${credential.toString()}, user: $user)';
  }
}
