import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/i10n.dart';

import '../configs/provider_configuration.dart';

class DifferentMethodSignInDialog extends StatelessWidget {
  final FirebaseAuth? auth;
  final List<String> availableProviders;
  final List<ProviderConfiguration> providerConfigs;
  final VoidCallback? onSignedIn;

  const DifferentMethodSignInDialog({
    Key? key,
    required this.availableProviders,
    required this.providerConfigs,
    this.auth,
    this.onSignedIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.differentMethodsSignInTitlText,
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 32),
            DifferentMethodSignInView(
              auth: auth,
              providerConfigs: providerConfigs,
              availableProviders: availableProviders,
              onSignedIn: onSignedIn,
            ),
          ],
        ),
      ),
    );
  }
}
