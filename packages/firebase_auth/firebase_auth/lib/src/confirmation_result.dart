// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_auth;

class ConfirmationResult {
  ConfirmationResultPlatform _delegate;

  final FirebaseAuth _auth;

  ConfirmationResult._(this._auth, this._delegate) {
    ConfirmationResultPlatform.verifyExtends(_delegate);
  }

  String get verificationId {
    return _delegate.verificationId;
  }

  Future<UserCredential> confirm(String verificationCode) async {
    assert(verificationCode != null);
    return UserCredential._(
      _auth,
      await _delegate.confirm(verificationCode),
    );
  }
}
