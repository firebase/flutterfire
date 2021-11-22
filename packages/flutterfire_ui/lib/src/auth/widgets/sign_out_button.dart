import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterfire_ui/i10n.dart';
import 'package:flutter/material.dart';

class SignOutButton extends StatelessWidget {
  const SignOutButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    return OutlinedButton.icon(
      icon: const Icon(Icons.logout),
      onPressed: () {
        FirebaseAuth.instance.signOut();
      },
      label: Text(l.signOut),
    );
  }
}
