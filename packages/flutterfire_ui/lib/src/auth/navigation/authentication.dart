import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

import '../configs/provider_configuration.dart';

Future<void> showReauthenticateDialog({
  required BuildContext context,
  required List<ProviderConfiguration> providerConfigs,
  FirebaseAuth? auth,
  VoidCallback? onSignedIn,
}) async {
  await showDialog(
    context: context,
    builder: (context) => ReauthenticateDialog(
      providerConfigs: providerConfigs,
      auth: auth,
      onSignedIn: () {
        Navigator.of(context).pop();
      },
    ),
  );
}

Future<void> showDifferentMethodSignInDialog({
  required BuildContext context,
  required List<String> availableProviders,
  required List<ProviderConfiguration> providerConfigs,
  FirebaseAuth? auth,
  VoidCallback? onSignedIn,
}) async {
  await showDialog(
    context: context,
    builder: (context) => DifferentMethodSignInDialog(
      availableProviders: availableProviders,
      providerConfigs: providerConfigs,
      auth: auth,
      onSignedIn: () {
        Navigator.of(context).pop();
      },
    ),
  );
}
