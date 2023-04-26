// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

/// A controller interface of the [UniversalEmailSignInFlow].
abstract class UniversalEmailSignInController extends AuthController {
  /// {@template ui.auth.auth_controller.find_providers_for_email}
  /// Finds providers that can be used to sign in with a provided email.
  /// Calls [AuthListener.onBeforeProvidersForEmailFetch], if request succeded –
  /// [AuthListener.onDifferentProvidersFound] is called and
  /// [AuthListener.onError] if failed.
  /// {@endtemplate}
  void findProvidersForEmail(String email);
}

/// {@template ui.auth.flows.universal_email_sign_in_flow}
/// An auth flow that resolves providers that are accosicatied with the given
/// email.
/// {@endtemplate}
class UniversalEmailSignInFlow extends AuthFlow<UniversalEmailSignInProvider>
    implements UniversalEmailSignInController, UniversalEmailSignInListener {
  // {@macro ui.auth.flows.universal_email_sign_in_flow}
  UniversalEmailSignInFlow({
    /// {@macro ui.auth.auth_flow.ctor.provider}
    required UniversalEmailSignInProvider provider,

    /// {@macro ui.auth.auth_controller.auth}
    FirebaseAuth? auth,

    /// {@macro @macro ui.auth.auth_action}
    AuthAction? action,
  }) : super(
          initialState: const Uninitialized(),
          provider: provider,
          auth: auth,
          action: action,
        );

  @override
  void findProvidersForEmail(String email) {
    provider.findProvidersForEmail(email);
  }
}
