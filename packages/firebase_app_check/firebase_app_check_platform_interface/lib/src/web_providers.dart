// Copyright 2023 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

abstract class WebProvider {
  final String siteKey;

  WebProvider(this.siteKey);
}

class ReCaptchaV3Provider extends WebProvider {
  ReCaptchaV3Provider(String siteKey) : super(siteKey);
}

class ReCaptchaEnterpriseProvider extends WebProvider {
  ReCaptchaEnterpriseProvider(String siteKey) : super(siteKey);
}

/// Debug provider for Web.
///
/// Sets `self.FIREBASE_APPCHECK_DEBUG_TOKEN` before initializing App Check.
/// If [debugToken] is provided, that token is used. Otherwise the Firebase JS
/// SDK auto-generates one and prints it to the browser console — you then
/// register that token in the Firebase Console.
///
/// See documentation: https://firebase.google.com/docs/app-check/web/debug-provider
class WebDebugProvider extends WebProvider {
  /// Creates a web debug provider with an optional debug token.
  WebDebugProvider({this.debugToken}) : super('');

  /// The debug token for this provider.
  final String? debugToken;
}
