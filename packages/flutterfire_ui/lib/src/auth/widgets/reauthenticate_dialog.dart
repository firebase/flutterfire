import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide Title;
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/i10n.dart';

import '../widgets/internal/title.dart';

/// {@template ffui.auth.widgets.reauthenticate_dialog}
/// A dialog that prompts the user to re-authenticate their account
/// Used to confirm destructive actions (like account deletion).
/// {@endtemplate}
class ReauthenticateDialog extends StatelessWidget {
  /// {@macro ffui.auth.auth_controller.auth}
  final FirebaseAuth? auth;

  /// A list of all supported auth providers.
  final List<AuthProvider> providers;

  /// A callback that is being called when the user has successfully signed in.
  final VoidCallback? onSignedIn;

  /// {@macro ffui.auth.widgets.reauthenticate_dialog}
  const ReauthenticateDialog({
    Key? key,
    required this.providers,
    this.auth,
    this.onSignedIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = FlutterFireUILocalizations.labelsOf(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Title(text: l.verifyItsYouText),
                const SizedBox(height: 16),
                ReauthenticateView(
                  auth: auth,
                  providers: providers,
                  onSignedIn: onSignedIn,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
