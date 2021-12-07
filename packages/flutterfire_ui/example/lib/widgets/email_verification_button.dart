import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutter/material.dart';

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(right: 12),
      child: Icon(Icons.verified),
    );
  }
}

class EmailVerificationButton extends StatefulWidget {
  const EmailVerificationButton({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _EmailVerificationButtonState createState() =>
      _EmailVerificationButtonState();
}

class _EmailVerificationButtonState extends State<EmailVerificationButton> {
  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser?.emailVerified ?? false) {
      return const VerifiedBadge();
    }

    return AuthFlowBuilder<EmailFlowController>(
      action: AuthAction.link,
      builder: (context, state, ctrl, _) {
        if (state is AwaitingEmailVerification) {
          return const CircularProgressIndicator();
        }

        if (state is EmailVerified) {
          return const VerifiedBadge();
        }

        return IconButton(
          icon: const Icon(Icons.warning),
          onPressed: () async {
            await ctrl.verifyEmail();
          },
        );
      },
    );
  }
}
