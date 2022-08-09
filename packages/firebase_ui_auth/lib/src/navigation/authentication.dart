import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

/// Shows [ReauthenticateDialog].
Future<bool> showReauthenticateDialog({
  required BuildContext context,

  /// A list of all supported auth providers
  required List<AuthProvider> providers,

  /// {@macro ui.auth.auth_controller.auth}
  FirebaseAuth? auth,

  /// A callback that is being called after user has successfully signed in.
  VoidCallback? onSignedIn,
}) async {
  return await showGeneralDialog<bool>(
        context: context,
        pageBuilder: (context, _, __) => ReauthenticateDialog(
          providers: providers,
          auth: auth,
          onSignedIn: onSignedIn,
        ),
      ) ??
      false;
}

/// Shows [DifferentMethodSignInDialog].
Future<void> showDifferentMethodSignInDialog({
  required BuildContext context,

  /// A list of providers associated with the user account
  required List<String> availableProviders,

  /// A list of all supported providers
  required List<AuthProvider> providers,

  /// {@macro ui.auth.auth_controller.auth}
  FirebaseAuth? auth,

  /// A callback that is being called after user has successfully signed in.
  VoidCallback? onSignedIn,
}) async {
  await showGeneralDialog(
    context: context,
    pageBuilder: (context, _, __) => DifferentMethodSignInDialog(
      availableProviders: availableProviders,
      providers: providers,
      auth: auth,
      onSignedIn: () {
        Navigator.of(context).pop();
      },
    ),
  );
}
