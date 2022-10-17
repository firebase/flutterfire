import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide Title;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';

import 'internal/title.dart';
import 'internal/universal_button.dart';

/// {@template ui.auth.widgets.reauthenticate_dialog}
/// A dialog that prompts the user to re-authenticate their account
/// Used to confirm destructive actions (like account deletion or disabling MFA).
/// {@endtemplate}
class ReauthenticateDialog extends StatelessWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final FirebaseAuth? auth;

  /// A list of all supported auth providers.
  final List<AuthProvider> providers;

  /// A callback that is being called when the user has successfully signed in.
  final VoidCallback? onSignedIn;

  /// A label that would be used for the "Sign in" button.
  final String? actionButtonLabelOverride;

  /// {@macro ui.auth.widgets.reauthenticate_dialog}
  const ReauthenticateDialog({
    Key? key,
    required this.providers,
    this.auth,
    this.onSignedIn,
    this.actionButtonLabelOverride,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

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
                const SizedBox(height: 16),
                UniversalButton(
                  text: l.cancelLabel,
                  variant: ButtonVariant.text,
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
