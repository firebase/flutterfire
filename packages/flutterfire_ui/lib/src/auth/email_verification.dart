import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

enum EmailVerificationState {
  unresolved,
  unverified,
  dismissed,
  sending,
  pending,
  sent,
  verified,
  failed,
}

class EmailVerificationService extends ValueNotifier<EmailVerificationState> {
  final FirebaseAuth auth;

  EmailVerificationService(this.auth)
      : super(EmailVerificationState.unresolved);

  User get user => auth.currentUser!;
  EmailVerificationState get state => value;

  Exception? error;

  bool _isMobile(TargetPlatform platform) {
    return platform == TargetPlatform.android || platform == TargetPlatform.iOS;
  }

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

  void dismiss() {
    value = EmailVerificationState.dismissed;
  }

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
