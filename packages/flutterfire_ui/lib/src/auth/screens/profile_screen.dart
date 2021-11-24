import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutterfire_ui/i10n.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

import '../configs/provider_configuration.dart';

class ProfileScreen extends StatelessWidget {
  final List<ProviderConfiguration> providerConfigs;
  final List<Widget> children;
  final FirebaseAuth? auth;
  final Color? avatarPlaceholderColor;
  final ShapeBorder? avatarShape;
  final double? avatarSize;

  const ProfileScreen({
    Key? key,
    required this.providerConfigs,
    this.auth,
    this.avatarPlaceholderColor,
    this.avatarShape,
    this.avatarSize,
    this.children = const [],
  }) : super(key: key);

  void _logout() {
    (auth ?? FirebaseAuth.instance).signOut();
  }

  void _reauthenticate(BuildContext context) {
    showReauthenticateDialog(
      context: context,
      providerConfigs: providerConfigs,
      auth: auth,
      onSignedIn: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.profile),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              child: UserAvatar(
                auth: auth,
                placeholderColor: avatarPlaceholderColor,
                shape: avatarShape,
                size: avatarSize,
              ),
            ),
            const SizedBox(height: 16),
            Align(child: EditableUserDisplayName(auth: auth)),
            const SizedBox(height: 16),
            ...children,
            DeleteAccountButton(
              auth: auth,
              onSignInRequired: () async {
                _reauthenticate(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
