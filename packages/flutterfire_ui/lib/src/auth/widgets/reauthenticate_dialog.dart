import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/i10n.dart';

import '../configs/provider_configuration.dart';

class ReauthenticateDialog extends StatelessWidget {
  final FirebaseAuth? auth;
  final List<ProviderConfiguration> providerConfigs;
  final VoidCallback? onSignedIn;

  const ReauthenticateDialog({
    Key? key,
    required this.providerConfigs,
    this.auth,
    this.onSignedIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.verifyItsYouText, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ReauthenticateView(
              auth: auth,
              providerConfigs: providerConfigs,
              onSignedIn: onSignedIn,
            ),
          ],
        ),
      ),
    );
  }
}
