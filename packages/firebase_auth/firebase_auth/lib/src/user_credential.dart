// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_auth;

class UserCredential {
  UserCredentialPlatform _delegate;

  final FirebaseAuth _auth;

  UserCredential._(this._auth, this._delegate) {
    UserCredentialPlatform.verifyExtends(_delegate);
  }

  AdditionalUserInfo get additionalUserInfo {
    return _delegate.additionalUserInfo;
  }

  AuthCredential get credential {
    return _delegate.credential;
  }

  User get user {
    return User._(_auth, _delegate.user);
  }

  @override
  String toString() {
    return 'UserCredential(additionalUserInfo: ${additionalUserInfo.toString()}, credential: ${credential.toString()}, user: ${user})';
  }
}
