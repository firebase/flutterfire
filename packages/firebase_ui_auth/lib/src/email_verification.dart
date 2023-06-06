// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

/// All possible states of the email verification process.
enum EmailVerificationState {
  /// An initial state of the email verification process.
  unresolved,

  /// A state that indicates that the user has not yet verified the email.
  unverified,

  /// A state that indicates that the user has cancelled the email verification
  /// process.
  dismissed,

  /// A state that indicates that email is being sent.
  sending,

  /// A state that indicates that user needs to follow the link and the app
  /// awaits a valid dynamic link.
  pending,

  /// A state that indicates that the verification email was successfully sent.
  sent,

  /// A state that indicates that the user has verified its email.
  verified,

  /// A state that indiicates that email verification failed. Likely the
  /// received link is invalid and verification email should be sent again.
  failed,
}

/// A [ValueNotifier] that manages the email verification process.
class EmailVerificationController extends ValueNotifier<EmailVerificationState>
    with WidgetsBindingObserver {
  /// {@macro ui.auth.auth_controller.auth}
  final FirebaseAuth auth;

  EmailVerificationController(this.auth)
      : super(EmailVerificationState.unresolved) {
    final user = auth.currentUser;

    if (user != null) {
      if (user.emailVerified) {
        value = EmailVerificationState.verified;
      } else {
        value = EmailVerificationState.unverified;
      }
    }

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      reload();
    }
  }

  /// An instance of user that is currently signed in.
  User get user => auth.currentUser!;

  /// Current [EmailVerificationState].
  EmailVerificationState get state => value;

  /// Contains an [Exception] if [state] is [EmailVerificationState.failed].
  Exception? error;

  bool _isMobile(TargetPlatform platform) {
    return platform == TargetPlatform.android || platform == TargetPlatform.iOS;
  }

  /// Reloads firebase user and updates the [state].
  Future<void> reload() async {
    await user.reload();

    if (user.email == null) {
      value = EmailVerificationState.unresolved;
    } else if (user.emailVerified) {
      value = EmailVerificationState.verified;
    } else {
      value = EmailVerificationState.unverified;
    }
  }

  /// Indicates that email verification process was cancelled.
  void dismiss() {
    value = EmailVerificationState.dismissed;
  }

  /// Sends an email with a link to verify the user's email address.
  Future<void> sendVerificationEmail(
    TargetPlatform platform,
    ActionCodeSettings? actionCodeSettings,
  ) async {
    value = EmailVerificationState.sending;
    try {
      await user.sendEmailVerification(actionCodeSettings);
    } on Exception catch (e) {
      error = e;
      value = EmailVerificationState.failed;
      return;
    }

    if (_isMobile(platform)) {
      value = EmailVerificationState.pending;
      final linkData = await FirebaseDynamicLinks.instance.onLink.first;

      try {
        final code = linkData.link.queryParameters['oobCode']!;
        await auth.checkActionCode(code);
        await auth.applyActionCode(code);
        await user.reload();
        value = EmailVerificationState.verified;
      } on Exception catch (err) {
        error = err;
        value = EmailVerificationState.failed;
      }
    } else {
      value = EmailVerificationState.sent;
    }
  }
}
