// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/cupertino.dart' hide Title;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Title;

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;

import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/i10n.dart';
import 'package:flutterfire_ui/src/auth/widgets/email_link_sign_in_button.dart';

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

  final List<ProviderConfiguration> providerConfigs;

  const LoginView({
    Key? key,
    required this.action,
    required this.providerConfigs,
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
    final oauthProviderConfigs = widget.providerConfigs
        .whereType<OAuthProviderConfiguration>()
        .where((element) => element.isSupportedPlatform(platform));

    _buttonsBuilt = true;

    final oauthButtonsList = oauthProviderConfigs.map((config) {
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
          for (var config in widget.providerConfigs)
            if (config.isSupportedPlatform(platform))
              if (config is EmailProviderConfiguration) ...[
                const SizedBox(height: 8),
                EmailForm(
                  key: ValueKey(_action),
                  auth: widget.auth,
                  action: _action,
                  config: config,
                  email: widget.email,
                )
              ] else if (config is PhoneProviderConfiguration) ...[
                const SizedBox(height: 8),
                PhoneVerificationButton(
                  label: l.signInWithPhoneButtonText,
                  action: _action,
                  auth: widget.auth,
                ),
                const SizedBox(height: 8),
              ] else if (config is EmailLinkProviderConfiguration) ...[
                const SizedBox(height: 8),
                EmailLinkSignInButton(
                  auth: widget.auth,
                  config: config,
                ),
              ] else if (config is OAuthProviderConfiguration && !_buttonsBuilt)
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
