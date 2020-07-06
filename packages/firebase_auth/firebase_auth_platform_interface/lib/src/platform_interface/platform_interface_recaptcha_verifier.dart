// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class RecaptchaVerifierPlatform {
  RecaptchaVerifierPlatform(this._delegate);

  final dynamic _delegate;

  /// Used by platform implementers to obtain a value suitable for being passed
  /// through to the underlying implementation.
  static dynamic getDelegate(RecaptchaVerifierPlatform recaptchaVerifier) =>
      recaptchaVerifier._delegate;
}
