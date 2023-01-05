// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

export 'package:firebase_auth/firebase_auth.dart' show OAuthCredential;
export 'package:desktop_webview_auth/desktop_webview_auth.dart'
    show AuthResult, ProviderArgs;
export 'package:desktop_webview_auth/google.dart';
export 'package:desktop_webview_auth/facebook.dart';
export 'package:desktop_webview_auth/twitter.dart';

export './src/oauth_provider.dart';
export './src/oauth_provider_button_base.dart';
export './src/oauth_provider_button_style.dart';

export 'package:firebase_ui_auth/firebase_ui_auth.dart'
    show AuthAction, AuthCancelledException;
