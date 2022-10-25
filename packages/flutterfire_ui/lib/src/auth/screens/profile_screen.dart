// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart'
    show ActionCodeSettings, FirebaseAuth, FirebaseAuthException, User;
import 'package:flutter/cupertino.dart' hide Title;
import 'package:flutterfire_ui/i10n.dart';
import 'package:flutter/material.dart' hide Title;
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/src/auth/widgets/internal/loading_button.dart';

import '../widgets/internal/universal_button.dart';

import 'internal/multi_provider_screen.dart';

import '../widgets/internal/rebuild_scope.dart';
import '../widgets/internal/subtitle.dart';
import '../widgets/internal/universal_icon_button.dart';

class AvailableProvidersRow extends StatefulWidget {
  final FirebaseAuth? auth;
  final List<ProviderConfiguration> providerConfigs;
  final VoidCallback onProviderLinked;

  const AvailableProvidersRow({
    Key? key,
    this.auth,
    required this.providerConfigs,
    required this.onProviderLinked,
  }) : super(key: key);

  @override
  State<AvailableProvidersRow> createState() => _AvailableProvidersRowState();
}

class _AvailableProvidersRowState extends State<AvailableProvidersRow> {
  AuthFailed? error;

  Future<void> connectProvider({
    required BuildContext context,
    required ProviderConfiguration config,
  }) async {
    setState(() {
      error = null;
    });

    switch (config.providerId) {
      case 'phone':
        await startPhoneVerification(
          context: context,
          action: AuthAction.link,
          auth: widget.auth,
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
              auth: widget.auth,
              action: AuthAction.link,
            );
          },
        );
    }

    await (widget.auth ?? FirebaseAuth.instance).currentUser!.reload();
  }

  @override
  Widget build(BuildContext context) {
    final l = FlutterFireUILocalizations.labelsOf(context);
    final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;

    final providerConfigs = widget.providerConfigs
        .where((config) => config is! EmailLinkProviderConfiguration)
        .toList();

    Widget child = Row(
      children: [
        for (var config in providerConfigs)
          if (config is! OAuthProviderConfiguration)
            if (isCupertino)
              CupertinoButton(
                onPressed: () => connectProvider(
                  context: context,
                  config: config,
                ).then((_) => widget.onProviderLinked()),
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
                ).then((_) => widget.onProviderLinked()),
              )
          else
            AuthStateListener<OAuthController>(
              listener: (oldState, newState, controller) {
                if (newState is CredentialLinked) {
                  widget.onProviderLinked();
                } else if (newState is AuthFailed) {
                  setState(() => error = newState);
                }
                return null;
              },
              child: OAuthProviderIconButton(
                providerConfig: config,
                auth: widget.auth,
                action: AuthAction.link,
                onTap: () {
                  setState(() => error = null);
                },
              ),
            ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Subtitle(text: l.enableMoreSignInMethods),
        const SizedBox(height: 16),
        child,
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ErrorText(exception: error!.exception),
          ),
      ],
    );
  }
}

class EditButton extends StatelessWidget {
  final bool isEditing;
  final VoidCallback? onPressed;

  const EditButton({
    Key? key,
    required this.isEditing,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return UniversalIconButton(
      materialIcon: isEditing ? Icons.check : Icons.edit,
      cupertinoIcon: isEditing ? CupertinoIcons.check_mark : CupertinoIcons.pen,
      color: theme.colorScheme.secondary,
      onPressed: () {
        onPressed?.call();
      },
    );
  }
}

class LinkedProvidersRow extends StatefulWidget {
  final FirebaseAuth? auth;
  final List<ProviderConfiguration> providerConfigs;
  final VoidCallback onProviderUnlinked;

  const LinkedProvidersRow({
    Key? key,
    this.auth,
    required this.providerConfigs,
    required this.onProviderUnlinked,
  }) : super(key: key);

  @override
  State<LinkedProvidersRow> createState() => _LinkedProvidersRowState();
}

class _LinkedProvidersRowState extends State<LinkedProvidersRow> {
  bool isEditing = false;
  String? unlinkingProvider;
  FirebaseAuthException? error;

  final size = 32.0;

  void _toggleEdit() {
    setState(() {
      isEditing = !isEditing;
      error = null;
    });
  }

  Future<void> _unlinkProvider(BuildContext context, String providerId) async {
    setState(() {
      unlinkingProvider = providerId;
      error = null;
    });

    try {
      final user = widget.auth!.currentUser!;
      await user.unlink(providerId);
      await user.reload();

      setState(() {
        widget.onProviderUnlinked();
        isEditing = false;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e;
      });
    } finally {
      setState(() {
        unlinkingProvider = null;
      });
    }
  }

  Widget buildProviderIcon(BuildContext context, String providerId) {
    final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;
    const animationDuration = Duration(milliseconds: 150);
    const curve = Curves.easeOut;

    void unlink() {
      _unlinkProvider(context, providerId);
    }

    return Stack(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: unlinkingProvider == providerId
              ? Center(
                  child: LoadingIndicator(
                    size: size - (size / 4),
                    borderWidth: 1,
                  ),
                )
              : Icon(providerIcon(context, providerId)),
        ),
        if (unlinkingProvider != providerId)
          AnimatedOpacity(
            duration: animationDuration,
            opacity: isEditing ? 1 : 0,
            curve: curve,
            child: GestureDetector(
              onTap: unlink,
              child: SizedBox(
                width: size,
                height: size,
                child: Align(
                  alignment: Alignment.topRight,
                  child: Transform.translate(
                    offset: const Offset(14, -12),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: unlink,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          isCupertino
                              ? CupertinoIcons.minus_circle_fill
                              : Icons.remove_circle,
                          size: 20,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = FlutterFireUILocalizations.labelsOf(context);
    Widget child = Row(
      children: [
        for (var config in widget.providerConfigs)
          buildProviderIcon(context, config.providerId)
      ]
          .map((e) => [e, const SizedBox(width: 8)])
          .expand((element) => element)
          .toList(),
    );

    if (widget.providerConfigs.length > 1) {
      child = Row(
        children: [
          Expanded(child: child),
          const SizedBox(width: 8),
          EditButton(
            isEditing: isEditing,
            onPressed: _toggleEdit,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Subtitle(text: l.signInMethods),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}

class EmailVerificationBadge extends StatefulWidget {
  final FirebaseAuth auth;
  final ActionCodeSettings? actionCodeSettings;
  const EmailVerificationBadge({
    Key? key,
    required this.auth,
    this.actionCodeSettings,
  }) : super(key: key);

  @override
  State<EmailVerificationBadge> createState() => _EmailVerificationBadgeState();
}

class _EmailVerificationBadgeState extends State<EmailVerificationBadge> {
  late final service = EmailVerificationService(widget.auth)
    ..addListener(() {
      setState(() {});
    })
    ..reload();

  EmailVerificationState get state => service.state;

  User get user {
    return widget.auth.currentUser!;
  }

  TargetPlatform get platform {
    return Theme.of(context).platform;
  }

  @override
  Widget build(BuildContext context) {
    if (state == EmailVerificationState.dismissed ||
        state == EmailVerificationState.unresolved ||
        state == EmailVerificationState.verified) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Subtitle(
                    text: state == EmailVerificationState.sent ||
                            state == EmailVerificationState.pending
                        ? 'Verification email sent'
                        : 'Email is not verified',
                    fontWeight: FontWeight.bold,
                  ),
                  if (state == EmailVerificationState.pending) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Please check your email and click the link to verify your email address.',
                    ),
                  ]
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (state == EmailVerificationState.pending)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                LoadingIndicator(size: 16, borderWidth: 0.5),
                SizedBox(width: 16),
                Text('Waiting for email verification'),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (state != EmailVerificationState.sent &&
                    state != EmailVerificationState.sending)
                  UniversalButton(
                    variant: ButtonVariant.text,
                    color: Theme.of(context).colorScheme.error,
                    text: 'Dismiss',
                    onPressed: () {
                      setState(service.dismiss);
                    },
                  ),
                if (state != EmailVerificationState.sent)
                  LoadingButton(
                    isLoading: state == EmailVerificationState.sending,
                    label: 'Send verification email',
                    onTap: () {
                      service.sendVerificationEmail(
                        platform,
                        widget.actionCodeSettings,
                      );
                    },
                  )
                else
                  UniversalButton(
                    variant: ButtonVariant.text,
                    text: 'Ok',
                    onPressed: () {
                      setState(service.dismiss);
                    },
                  )
              ],
            )
        ],
      ),
    );
  }
}

class ProfileScreen extends MultiProviderScreen {
  final List<Widget> children;
  final Color? avatarPlaceholderColor;
  final ShapeBorder? avatarShape;
  final double? avatarSize;
  final List<FlutterFireUIAction>? actions;
  final AppBar? appBar;
  final CupertinoNavigationBar? cupertinoNavigationBar;
  final ActionCodeSettings? actionCodeSettings;
  final Set<FlutterFireUIStyle>? styles;

  const ProfileScreen({
    Key? key,
    FirebaseAuth? auth,
    List<ProviderConfiguration>? providerConfigs,
    this.avatarPlaceholderColor,
    this.avatarShape,
    this.avatarSize,
    this.children = const [],
    this.actions,
    this.appBar,
    this.cupertinoNavigationBar,
    this.actionCodeSettings,
    this.styles,
  }) : super(key: key, providerConfigs: providerConfigs, auth: auth);

  Future<bool> _reauthenticate(BuildContext context) {
    return showReauthenticateDialog(
      context: context,
      providerConfigs: providerConfigs,
      auth: auth,
      onSignedIn: () => Navigator.of(context).pop(true),
    );
  }

  List<ProviderConfiguration> getLinkedProviders(User user) {
    return providerConfigs
        .where((config) => user.isProviderLinked(config.providerId))
        .toList();
  }

  List<ProviderConfiguration> getAvailableProviders(User user) {
    return providerConfigs
        .where((config) => !user.isProviderLinked(config.providerId))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterFireUITheme(
      styles: styles ?? const {},
      child: Builder(builder: buildPage),
    );
  }

  Widget buildPage(BuildContext context) {
    final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;
    final providersScopeKey = RebuildScopeKey();
    final emailVerificationScopeKey = RebuildScopeKey();

    final user = auth.currentUser!;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          child: UserAvatar(
            auth: auth,
            placeholderColor: avatarPlaceholderColor,
            shape: avatarShape,
            size: avatarSize,
          ),
        ),
        Align(child: EditableUserDisplayName(auth: auth)),
        if (!user.emailVerified) ...[
          RebuildScope(
            builder: (context) {
              if (user.emailVerified) {
                return const SizedBox.shrink();
              }

              return EmailVerificationBadge(
                auth: auth,
                actionCodeSettings: actionCodeSettings,
              );
            },
            scopeKey: emailVerificationScopeKey,
          ),
        ],
        RebuildScope(
          builder: (context) {
            final user = auth.currentUser!;
            final linkedProviders = getLinkedProviders(user);

            if (linkedProviders.isEmpty) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(top: 32),
              child: LinkedProvidersRow(
                auth: auth,
                providerConfigs: linkedProviders,
                onProviderUnlinked: providersScopeKey.rebuild,
              ),
            );
          },
          scopeKey: providersScopeKey,
        ),
        RebuildScope(
          builder: (context) {
            final user = auth.currentUser!;
            final availableProviders = getAvailableProviders(user);

            if (availableProviders.isEmpty) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(top: 32),
              child: AvailableProvidersRow(
                auth: auth,
                providerConfigs: availableProviders,
                onProviderLinked: providersScopeKey.rebuild,
              ),
            );
          },
          scopeKey: providersScopeKey,
        ),
        ...children,
        const SizedBox(height: 16),
        SignOutButton(
          auth: auth,
          variant: ButtonVariant.outlined,
        ),
        const SizedBox(height: 8),
        DeleteAccountButton(
          auth: auth,
          onSignInRequired: () {
            return _reauthenticate(context);
          },
        ),
      ],
    );
    final body = Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
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
      ),
    );

    Widget child = SafeArea(child: SingleChildScrollView(child: body));

    if (isCupertino) {
      child = CupertinoPageScaffold(
        navigationBar: cupertinoNavigationBar,
        child: SafeArea(
          child: SingleChildScrollView(child: child),
        ),
      );
    } else {
      child = Scaffold(
        appBar: appBar,
        body: SafeArea(
          child: SingleChildScrollView(child: body),
        ),
      );
    }

    return FlutterFireUIActions(
      actions: actions ?? const [],
      child: child,
    );
  }
}
