// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_platform_interface/src/auth_provider.dart';
import 'package:meta/meta.dart';

const _kLinkProviderId = 'emailLink';
const _kProviderId = 'password';

abstract class EmailAuthProvider extends AuthProvider {
  EmailAuthProvider() : super(_kProviderId);

  static String get EMAIL_LINK_SIGN_IN_METHOD {
    return _kLinkProviderId;
  }

  static String get EMAIL_PASSWORD_SIGN_IN_METHOD {
    return _kProviderId;
  }

  static String get PROVIDER_ID {
    return _kProviderId;
  }

  static AuthCredential credential(String email, String password) {
    assert(email != null);
    assert(password != null);
    return EmailAuthCredential._credential(email, password);
  }

  static AuthCredential credentialWithLink(String email, String emailLink) {
    assert(email != null);
    assert(emailLink != null);
    return EmailAuthCredential._credentialWithLink(email, emailLink);
  }

  @Deprecated('Deprecated in favor of `EmailAuthProvider.credential()`')
  static AuthCredential getCredential({
    @required String email,
    @required String password,
  }) {
    return EmailAuthProvider.credential(email, password);
  }

  @Deprecated('Deprecated in favor of `EmailAuthProvider.credentialWithLink()`')
  static AuthCredential getCredentialWithLink({
    @required String email,
    @required String link,
  }) {
    return EmailAuthProvider.credentialWithLink(email, link);
  }
}

// TODO code docs
class EmailAuthCredential extends AuthCredential {
  EmailAuthCredential._(
    String _signInMethod, {
    @required this.email,
    this.password,
    this.emailLink,
  }) : super(providerId: _kProviderId, signInMethod: _signInMethod);

  factory EmailAuthCredential._credential(String email, String password) {
    return EmailAuthCredential._(_kProviderId,
        email: email, password: password);
  }

  factory EmailAuthCredential._credentialWithLink(
      String email, String emailLink) {
    return EmailAuthCredential._(_kLinkProviderId,
        email: email, emailLink: emailLink);
  }

  /// The user's email address.
  final String email;

  /// The user account password.
  final String password;

  /// The sign-in email link.
  final String emailLink;

  @override
  Map<String, String> asMap() {
    return <String, String>{
      'providerId': providerId,
      'email': email,
      'emailLink': emailLink,
      'secret': password,
    };
  }

  @override
  Object toJSON() {
    throw UnimplementedError();
  }
}
