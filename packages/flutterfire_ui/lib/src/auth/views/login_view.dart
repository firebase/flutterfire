import 'package:flutter/cupertino.dart' hide Title;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Title;

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;

import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/i10n.dart';
import 'package:flutterfire_ui/src/auth/widgets/email_link_sign_in_button.dart';
import 'package:flutterfire_ui_oauth/flutterfire_ui_oauth.dart';

import '../widgets/internal/title.dart';

typedef AuthViewContentBuilder = Widget Function(
  BuildContext context,
  AuthAction action,
);

class LoginView extends StatefulWidget {
  final FirebaseAuth? auth;
  final AuthAction action;
  final OAuthButtonVariant? oauthButtonVariant;
  final bool? showTitle;
  final String? email;
  final bool? showAuthActionSwitch;
  final AuthViewContentBuilder? footerBuilder;
  final AuthViewContentBuilder? subtitleBuilder;

  final List<AuthProvider> providers;

  const LoginView({
    Key? key,
    required this.action,
    required this.providers,
    this.oauthButtonVariant = OAuthButtonVariant.icon_and_text,
    this.auth,
    this.showTitle = true,
    this.email,
    this.showAuthActionSwitch,
    this.footerBuilder,
    this.subtitleBuilder,
  }) : super(key: key);

  @override
  State<LoginView> createState() => LoginViewState();
}

class LoginViewState extends State<LoginView> {
  late AuthAction _action = widget.action;
  bool get _showTitle => widget.showTitle ?? true;
  bool get _showAuthActionSwitch => widget.showAuthActionSwitch ?? true;
  bool _buttonsBuilt = false;

  void setAction(AuthAction action) {
    setState(() {
      _action = action;
    });
  }

  Widget _buildOAuthButtons(TargetPlatform platform) {
    final oauthproviders = widget.providers
        .whereType<OAuthProvider>()
        .where((element) => element.supportsPlatform(platform));

    _buttonsBuilt = true;

    final oauthButtonsList = oauthproviders.map((config) {
      if (widget.oauthButtonVariant == OAuthButtonVariant.icon_and_text) {
        return OAuthProviderButton(
          auth: widget.auth,
          action: _action,
          providerConfig: config,
        );
      } else {
        return OAuthProviderIconButton(
          providerConfig: config,
          auth: widget.auth,
          action: _action,
        );
      }
    }).toList();

    if (widget.oauthButtonVariant == OAuthButtonVariant.icon_and_text) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: oauthButtonsList,
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: oauthButtonsList,
      );
    }
  }

  void _handleDifferentAuthAction(BuildContext context) {
    if (_action == AuthAction.signIn) {
      setState(() {
        _action = AuthAction.signUp;
      });
    } else {
      setState(() {
        _action = AuthAction.signIn;
      });
    }
  }

  List<Widget> _buildHeader(BuildContext context) {
    final l = FlutterFireUILocalizations.labelsOf(context);

    late String title;
    late String hint;
    late String actionText;

    if (_action == AuthAction.signIn) {
      title = l.signInText;
      hint = l.registerHintText;
      actionText = l.registerText;
    } else if (_action == AuthAction.signUp) {
      title = l.registerText;
      hint = l.signInHintText;
      actionText = l.signInText;
    }

    final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;
    TextStyle? hintStyle;
    late Color registerTextColor;

    if (isCupertino) {
      final theme = CupertinoTheme.of(context);
      registerTextColor = theme.primaryColor;
      hintStyle = theme.textTheme.textStyle.copyWith(fontSize: 12);
    } else {
      final theme = Theme.of(context);
      hintStyle = Theme.of(context).textTheme.caption;
      registerTextColor = theme.colorScheme.primary;
    }

    return [
      Title(text: title),
      const SizedBox(height: 16),
      if (widget.subtitleBuilder != null)
        widget.subtitleBuilder!(
          context,
          _action,
        ),
      if (_showAuthActionSwitch) ...[
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$hint ',
                style: hintStyle,
              ),
              TextSpan(
                text: actionText,
                style: Theme.of(context).textTheme.button?.copyWith(
                      color: registerTextColor,
                    ),
                mouseCursor: SystemMouseCursors.click,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => _handleDifferentAuthAction(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ]
    ];
  }

  @override
  void didUpdateWidget(covariant LoginView oldWidget) {
    if (oldWidget.action != widget.action) {
      _action = widget.action;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final l = FlutterFireUILocalizations.labelsOf(context);
    final platform = Theme.of(context).platform;
    _buttonsBuilt = false;

    return IntrinsicHeight(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_showTitle) ..._buildHeader(context),
          for (var provider in widget.providers)
            if (provider.supportsPlatform(platform))
              if (provider is EmailAuthProvider) ...[
                const SizedBox(height: 8),
                EmailForm(
                  key: ValueKey(_action),
                  auth: widget.auth,
                  action: _action,
                  provider: provider,
                  email: widget.email,
                )
              ] else if (provider is PhoneAuthProvider) ...[
                const SizedBox(height: 8),
                PhoneVerificationButton(
                  label: l.signInWithPhoneButtonText,
                  action: _action,
                  auth: widget.auth,
                ),
                const SizedBox(height: 8),
              ] else if (provider is EmailLinkAuthProvider) ...[
                const SizedBox(height: 8),
                EmailLinkSignInButton(
                  auth: widget.auth,
                  provider: provider,
                ),
              ] else if (provider is OAuthProvider && !_buttonsBuilt)
                _buildOAuthButtons(platform),
          if (widget.footerBuilder != null)
            widget.footerBuilder!(
              context,
              widget.action,
            ),
        ],
      ),
    );
  }
}
