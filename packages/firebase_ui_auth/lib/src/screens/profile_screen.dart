// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart'
    show
        ActionCodeSettings,
        FirebaseAuth,
        FirebaseAuthException,
        MultiFactorInfo,
        PhoneAuthCredential,
        PhoneMultiFactorGenerator,
        User;
import 'package:firebase_ui_auth/src/widgets/internal/universal_icon.dart';
import 'package:flutter/cupertino.dart' hide Title;
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/material.dart' hide Title;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth/firebase_ui_oauth.dart'
    hide OAuthProviderButtonBase;
import 'package:flutter/services.dart';

import '../widgets/internal/loading_button.dart';
import '../widgets/internal/universal_button.dart';
import '../widgets/internal/rebuild_scope.dart';
import '../widgets/internal/subtitle.dart';
import '../widgets/internal/universal_icon_button.dart';

import 'internal/multi_provider_screen.dart';

class _AvailableProvidersRow extends StatefulWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final FirebaseAuth? auth;
  final List<AuthProvider> providers;
  final VoidCallback onProviderLinked;

  const _AvailableProvidersRow({
    Key? key,
    this.auth,
    required this.providers,
    required this.onProviderLinked,
  }) : super(key: key);

  @override
  State<_AvailableProvidersRow> createState() => _AvailableProvidersRowState();
}

class _AvailableProvidersRowState extends State<_AvailableProvidersRow> {
  AuthFailed? error;

  Future<void> connectProvider({
    required BuildContext context,
    required AuthProvider provider,
  }) async {
    setState(() {
      error = null;
    });

    switch (provider.providerId) {
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
              provider: provider as EmailAuthProvider,
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
    final l = FirebaseUILocalizations.labelsOf(context);
    final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;

    final providers = widget.providers
        .where((provider) => provider is! EmailLinkAuthProvider)
        .toList();

    Widget child = Row(
      children: [
        for (var provider in providers)
          if (provider is! OAuthProvider)
            if (isCupertino)
              CupertinoButton(
                onPressed: () => connectProvider(
                  context: context,
                  provider: provider,
                ).then((_) => widget.onProviderLinked()),
                child: Icon(
                  providerIcon(context, provider.providerId),
                ),
              )
            else
              IconButton(
                icon: Icon(
                  providerIcon(context, provider.providerId),
                ),
                onPressed: () => connectProvider(
                  context: context,
                  provider: provider,
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
              child: OAuthProviderButton(
                provider: provider,
                auth: widget.auth,
                action: AuthAction.link,
                variant: OAuthButtonVariant.icon,
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

class _EditButton extends StatelessWidget {
  final bool isEditing;
  final VoidCallback? onPressed;

  const _EditButton({
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

class _LinkedProvidersRow extends StatefulWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final FirebaseAuth? auth;
  final List<AuthProvider> providers;
  final VoidCallback onProviderUnlinked;

  const _LinkedProvidersRow({
    Key? key,
    this.auth,
    required this.providers,
    required this.onProviderUnlinked,
  }) : super(key: key);

  @override
  State<_LinkedProvidersRow> createState() => _LinkedProvidersRowState();
}

class _LinkedProvidersRowState extends State<_LinkedProvidersRow> {
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
    final l = FirebaseUILocalizations.labelsOf(context);
    Widget child = Row(
      children: [
        for (var provider in widget.providers)
          buildProviderIcon(context, provider.providerId)
      ]
          .map((e) => [e, const SizedBox(width: 8)])
          .expand((element) => element)
          .toList(),
    );

    if (widget.providers.length > 1) {
      child = Row(
        children: [
          Expanded(child: child),
          const SizedBox(width: 8),
          _EditButton(
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

class _EmailVerificationBadge extends StatefulWidget {
  final FirebaseAuth auth;
  final ActionCodeSettings? actionCodeSettings;
  const _EmailVerificationBadge({
    Key? key,
    required this.auth,
    this.actionCodeSettings,
  }) : super(key: key);

  @override
  State<_EmailVerificationBadge> createState() =>
      _EmailVerificationBadgeState();
}

class _EmailVerificationBadgeState extends State<_EmailVerificationBadge> {
  late final service = EmailVerificationController(widget.auth)
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

class _MFABadge extends StatelessWidget {
  final bool enrolled;
  final FirebaseAuth auth;
  final VoidCallback onToggled;
  final List<AuthProvider> providers;

  const _MFABadge({
    Key? key,
    required this.enrolled,
    required this.auth,
    required this.onToggled,
    required this.providers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Subtitle(text: l.mfaTitle),
          const SizedBox(height: 8),
          _MFAToggle(
            enrolled: enrolled,
            auth: auth,
            onToggled: onToggled,
            providers: providers,
          ),
        ],
      ),
    );
  }
}

class _MFAToggle extends StatefulWidget {
  final bool enrolled;
  final FirebaseAuth auth;
  final VoidCallback? onToggled;
  final List<AuthProvider> providers;

  const _MFAToggle({
    Key? key,
    required this.enrolled,
    required this.auth,
    required this.onToggled,
    required this.providers,
  }) : super(key: key);

  @override
  State<_MFAToggle> createState() => _MFAToggleState();
}

class _MFAToggleState extends State<_MFAToggle> {
  bool isLoading = false;
  Exception? exception;

  IconData getCupertinoIcon() {
    if (widget.enrolled) {
      return CupertinoIcons.check_mark_circled;
    } else {
      return CupertinoIcons.circle;
    }
  }

  IconData getMaterialIcon() {
    if (widget.enrolled) {
      return Icons.check_circle;
    } else {
      return Icons.remove_circle_sharp;
    }
  }

  Color getColor() {
    if (widget.enrolled) {
      return Theme.of(context).colorScheme.primary;
    } else {
      return Theme.of(context).colorScheme.error;
    }
  }

  Future<bool> _reauthenticate() async {
    return await showReauthenticateDialog(
      context: context,
      providers: widget.providers,
      auth: widget.auth,
      onSignedIn: () {
        Navigator.of(context).pop(true);
      },
    );
  }

  Future<void> _disable() async {
    setState(() {
      exception = null;
      isLoading = true;
    });

    final mfa = widget.auth.currentUser!.multiFactor;
    final factors = await mfa.getEnrolledFactors();

    if (factors.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      await mfa.unenroll(multiFactorInfo: factors.first);
      widget.onToggled?.call();
    } on PlatformException catch (e) {
      if (e.code == 'FirebaseAuthRecentLoginRequiredException') {
        if (await _reauthenticate()) {
          await _disable();
        }
      } else {
        rethrow;
      }
    } on Exception catch (e) {
      setState(() {
        exception = e;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _enable() async {
    setState(() {
      exception = null;
      isLoading = true;
    });

    final currentRoute = ModalRoute.of(context);

    final mfa = widget.auth.currentUser!.multiFactor;
    final session = await mfa.getSession();

    await startPhoneVerification(
      context: context,
      action: AuthAction.none,
      multiFactorSession: session,
      auth: widget.auth,
      actions: [
        AuthStateChangeAction<CredentialReceived>((context, state) async {
          final cred = state.credential as PhoneAuthCredential;
          final assertion = PhoneMultiFactorGenerator.getAssertion(cred);

          try {
            await mfa.enroll(assertion);
            widget.onToggled?.call();
          } on Exception catch (e) {
            setState(() {
              exception = e;
            });
          } finally {
            setState(() {
              isLoading = false;
            });

            Navigator.of(context).popUntil((route) => route == currentRoute);
          }
        })
      ],
    );

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            UniversalIcon(
              cupertinoIcon: getCupertinoIcon(),
              materialIcon: getMaterialIcon(),
              color: getColor(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(widget.enrolled ? l.on : l.off),
            ),
            LoadingButton(
              variant: ButtonVariant.text,
              label: widget.enrolled ? l.disable : l.enable,
              onTap: widget.enrolled ? _disable : _enable,
              isLoading: isLoading,
            )
          ],
        ),
        if (exception != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ErrorText(exception: exception!),
          )
      ],
    );
  }
}

/// {@template ui.auth.screens.profile_screen}
/// A pre-built profile screen that allows to link more auth providers,
/// unlink auth providers, edit user name and delete the account. Could also
/// contain a user-defined content.
/// {@endtemplate}
class ProfileScreen extends MultiProviderScreen {
  /// A user-defined content of the screen.
  final List<Widget> children;

  /// {@macro ui.auth.widgets.user_avatar.placeholder_color}
  final Color? avatarPlaceholderColor;

  /// {@macro ui.auth.widgets.user_avatar.shape}
  final ShapeBorder? avatarShape;

  /// {@macro ui.auth.widgets.user_avatar.size}
  final double? avatarSize;

  /// Possible actions that could be triggered:
  ///
  /// - [SignedOutAction]
  /// - [AuthStateChangeAction]
  ///
  /// ```dart
  /// ProfileScreen(
  ///   actions: [
  ///     SignedOutAction((context) {
  ///       Navigator.of(context).pushReplacementNamed('/sign-in');
  ///     }),
  ///     AuthStateChangeAction<CredentialLinked>((context, state) {
  ///       ScaffoldMessenger.of(context).showSnackBar(
  ///         SnackBar(
  ///           content: Text("Provider sucessfully linked!"),
  ///         ),
  ///       );
  ///     }),
  ///   ]
  /// )
  /// ```
  final List<FirebaseUIAction>? actions;

  /// See [Scaffold.appBar].
  final AppBar? appBar;

  /// See [CupertinoPageScaffold.navigationBar].
  final CupertinoNavigationBar? cupertinoNavigationBar;

  /// A configuration object used to construct a dynamic link for email
  /// verification.
  final ActionCodeSettings? actionCodeSettings;

  final bool showMFATile;

  const ProfileScreen({
    Key? key,
    FirebaseAuth? auth,
    List<AuthProvider>? providers,
    this.avatarPlaceholderColor,
    this.avatarShape,
    this.avatarSize,
    this.children = const [],
    this.actions,
    this.appBar,
    this.cupertinoNavigationBar,
    this.actionCodeSettings,
    this.showMFATile = false,
  }) : super(key: key, providers: providers, auth: auth);

  Future<bool> _reauthenticate(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    return showReauthenticateDialog(
      context: context,
      providers: providers,
      auth: auth,
      onSignedIn: () => Navigator.of(context).pop(true),
      actionButtonLabelOverride: l.deleteAccount,
    );
  }

  List<AuthProvider> getLinkedProviders(User user) {
    return providers
        .where((provider) => user.isProviderLinked(provider.providerId))
        .toList();
  }

  List<AuthProvider> getAvailableProviders(BuildContext context, User user) {
    final platform = Theme.of(context).platform;

    return providers
        .where(
          (provider) =>
              !user.isProviderLinked(provider.providerId) &&
              provider.supportsPlatform(platform),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FirebaseUITheme(
      styles: const {},
      child: Builder(builder: buildPage),
    );
  }

  Widget buildPage(BuildContext context) {
    final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;
    final providersScopeKey = RebuildScopeKey();
    final mfaScopeKey = RebuildScopeKey();
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

              return _EmailVerificationBadge(
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
              child: _LinkedProvidersRow(
                auth: auth,
                providers: linkedProviders,
                onProviderUnlinked: providersScopeKey.rebuild,
              ),
            );
          },
          scopeKey: providersScopeKey,
        ),
        RebuildScope(
          builder: (context) {
            final user = auth.currentUser!;
            final availableProviders = getAvailableProviders(context, user);

            if (availableProviders.isEmpty) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(top: 32),
              child: _AvailableProvidersRow(
                auth: auth,
                providers: availableProviders,
                onProviderLinked: providersScopeKey.rebuild,
              ),
            );
          },
          scopeKey: providersScopeKey,
        ),
        if (showMFATile)
          RebuildScope(
            builder: (context) {
              final user = auth.currentUser!;
              final mfa = user.multiFactor;

              return FutureBuilder<List<MultiFactorInfo>>(
                future: mfa.getEnrolledFactors(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final enrolledFactors = snapshot.requireData;

                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _MFABadge(
                      providers: providers,
                      enrolled: enrolledFactors.isNotEmpty,
                      auth: auth,
                      onToggled: mfaScopeKey.rebuild,
                    ),
                  );
                },
              );
            },
            scopeKey: mfaScopeKey,
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

    return FirebaseUIActions(
      actions: actions ?? const [],
      child: child,
    );
  }
}
