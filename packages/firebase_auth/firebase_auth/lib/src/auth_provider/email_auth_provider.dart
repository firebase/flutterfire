// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_auth;

class EmailAuthProvider {
  static const String providerId = 'password';

  static EmailAuthCredential getCredential({
    String email,
    String password,
  }) {
    return EmailAuthCredential(email: email, password: password);
  }

  static EmailAuthCredential getCredentialWithLink({
    String email,
    String link,
  }) {
    return EmailAuthCredential(email: email, link: link);
  }
}
