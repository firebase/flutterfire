import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/cupertino.dart' hide Title;
import 'package:flutterfire_ui/i10n.dart';
import 'package:flutter/material.dart' hide Title;
import 'package:flutterfire_ui/auth.dart';

import '../configs/provider_configuration.dart';
import '../widgets/internal/subtitle.dart';

class AvailableProvidersRow extends StatelessWidget {
  final FirebaseAuth? auth;
  final List<ProviderConfiguration> providerConfigs;
  final VoidCallback onProviderLinked;

  const AvailableProvidersRow({
    Key? key,
    this.auth,
    required this.providerConfigs,
    required this.onProviderLinked,
  }) : super(key: key);

  Future<void> connectProvider({
    required BuildContext context,
    required ProviderConfiguration config,
  }) async {
    switch (config.providerId) {
      case 'phone':
        await startPhoneVerification(
          context: context,
          action: AuthAction.link,
          auth: auth,
        );
        break;
      case 'password':
        await showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: '',
          pageBuilder: (context, _, __) {
            return EmailSignUpDialog(
              config: config as EmailProviderConfiguration,
              auth: auth,
            );
          },
        );
    }

    await (auth ?? FirebaseAuth.instance).currentUser!.reload();
  }

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);
    final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Subtitle(text: l.enableMoreSignInMethods),
        const SizedBox(height: 16),
        Row(
          children: [
            for (var config in providerConfigs)
              if (config is! OAuthProviderConfiguration)
                if (isCupertino)
                  CupertinoButton(
                    onPressed: () => connectProvider(
                      context: context,
                      config: config,
                    ).then((_) => onProviderLinked()),
                    child: Icon(
                      providerIcon(context, config.providerId),
                    ),
                  )
                else
                  IconButton(
                    icon: Icon(
                      providerIcon(context, config.providerId),
                    ),
                    onPressed: () => connectProvider(
                      context: context,
                      config: config,
                    ).then((_) => onProviderLinked()),
                  )
              else
                AuthStateListener<OAuthController>(
                  listener: (oldState, newState, controller) {
                    if (newState is CredentialLinked) {
                      onProviderLinked();
                    }
                  },
                  child: OAuthProviderIconButton(
                    providerConfig: config,
                    auth: auth,
                    action: AuthAction.link,
                  ),
                ),
          ],
        ),
      ],
    );
  }
}

class LinkedProvidersRow extends StatelessWidget {
  final FirebaseAuth? auth;
  final List<ProviderConfiguration> providerConfigs;

  const LinkedProvidersRow({
    Key? key,
    this.auth,
    required this.providerConfigs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Subtitle(text: l.signInMethods),
        const SizedBox(height: 16),
        Row(
          children: [
            for (var config in providerConfigs)
              Icon(providerIcon(context, config.providerId))
          ]
              .map((e) => [e, const SizedBox(width: 8)])
              .expand((element) => element)
              .toList(),
        ),
      ],
    );
  }
}

class ProfileScreen extends StatefulWidget {
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

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _logout() {
    (widget.auth ?? FirebaseAuth.instance).signOut();
  }

  void _reauthenticate(BuildContext context) {
    showReauthenticateDialog(
      context: context,
      providerConfigs: widget.providerConfigs,
      auth: widget.auth,
      onSignedIn: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);
    final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;
    final platform = Theme.of(context).platform;
    final _auth = widget.auth ?? FirebaseAuth.instance;
    final _user = _auth.currentUser!;

    final linkedProviders = widget.providerConfigs
        .where((config) => _user.isProviderLinked(config.providerId))
        .toList();

    final availableProviders = widget.providerConfigs
        .where((config) => !_user.isProviderLinked(config.providerId))
        .where((config) => config.isSupportedPlatform(platform))
        .toList();

    final content = Column(
      children: [
        Align(
          child: UserAvatar(
            auth: widget.auth,
            placeholderColor: widget.avatarPlaceholderColor,
            shape: widget.avatarShape,
            size: widget.avatarSize,
          ),
        ),
        const SizedBox(height: 16),
        Align(child: EditableUserDisplayName(auth: widget.auth)),
        if (linkedProviders.isNotEmpty) ...[
          const SizedBox(height: 32),
          LinkedProvidersRow(
            auth: widget.auth,
            providerConfigs: linkedProviders,
          ),
        ],
        if (availableProviders.isNotEmpty) ...[
          const SizedBox(height: 32),
          AvailableProvidersRow(
            auth: widget.auth,
            providerConfigs: availableProviders,
            onProviderLinked: () => setState(() {}),
          ),
        ],
        ...widget.children,
        const SizedBox(height: 16),
        DeleteAccountButton(
          auth: widget.auth,
          onSignInRequired: () async {
            _reauthenticate(context);
          },
        ),
      ],
    );
    final body = Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 500) {
            return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: content,
            );
          } else {
            return content;
          }
        },
      ),
    );

    if (isCupertino) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(l.profile),
          trailing: Transform.translate(
            offset: const Offset(0, -6),
            child: CupertinoButton(
              onPressed: _logout,
              child: const Icon(CupertinoIcons.arrow_right_circle),
            ),
          ),
        ),
        child: SafeArea(child: body),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(l.profile),
          actions: [
            IconButton(
              onPressed: _logout,
              icon: const Icon(
                Icons.logout_outlined,
              ),
            )
          ],
        ),
        body: body,
      );
    }
  }
}
