import 'package:flutter/cupertino.dart' hide Title;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Title;

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;

import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/i10n.dart';

import '../configs/provider_configuration.dart';
import '../widgets/internal/title.dart';

class LoginView extends StatefulWidget {
  final FirebaseAuth? auth;
  final AuthAction action;
  final ButtonVariant? oauthButtonVariant;
  final bool? showTitle;
  final String? email;
  final bool? showAuthActionSwitch;
  final WidgetBuilder? footerBuilder;
  final WidgetBuilder? subtitleBuilder;

  final List<ProviderConfiguration> providerConfigs;

  const LoginView({
    Key? key,
    required this.action,
    required this.providerConfigs,
    this.oauthButtonVariant = ButtonVariant.icon_and_text,
    this.auth,
    this.showTitle = true,
    this.email,
    this.showAuthActionSwitch,
    this.footerBuilder,
    this.subtitleBuilder,
  }) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late AuthAction action = widget.action;
  bool get showTitle => widget.showTitle ?? true;
  bool get showAuthActionSwitch => widget.showAuthActionSwitch ?? true;

  Widget? _buildOAuthButtons(TargetPlatform platform) {
    final oauthProviderConfigs = widget.providerConfigs
        .whereType<OAuthProviderConfiguration>()
        .where((element) => element.isSupportedPlatform(platform));

    if (oauthProviderConfigs.isEmpty) {
      return null;
    }

    final oauthButtonsList = oauthProviderConfigs.map((config) {
      if (widget.oauthButtonVariant == ButtonVariant.icon_and_text) {
        return OAuthProviderButton(
          auth: widget.auth,
          action: action,
          providerConfig: config,
        );
      } else {
        return OAuthProviderIconButton(
          providerConfig: config,
          auth: widget.auth,
          action: action,
        );
      }
    }).toList();

    if (widget.oauthButtonVariant == ButtonVariant.icon_and_text) {
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
    if (action == AuthAction.signIn) {
      setState(() {
        action = AuthAction.signUp;
      });
    } else {
      setState(() {
        action = AuthAction.signIn;
      });
    }
  }

  List<Widget> _buildHeader(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    late String title;
    late String hint;
    late String actionText;

    if (action == AuthAction.signIn) {
      title = l.signInText;
      hint = l.registerHintText;
      actionText = l.registerText;
    } else if (action == AuthAction.signUp) {
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
      if (showAuthActionSwitch) ...[
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
        if (widget.subtitleBuilder != null)
          widget.subtitleBuilder!(context)
        else
          const SizedBox(height: 16),
      ]
    ];
  }

  @override
  void didUpdateWidget(covariant LoginView oldWidget) {
    if (oldWidget.action != widget.action) {
      action = widget.action;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);
    final platform = Theme.of(context).platform;
    final oauthButtons = _buildOAuthButtons(platform);

    return IntrinsicHeight(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showTitle) ..._buildHeader(context),
          for (var config in widget.providerConfigs)
            if (config.isSupportedPlatform(platform))
              if (config is EmailProviderConfiguration)
                EmailForm(
                  key: ValueKey(action),
                  auth: widget.auth,
                  action: action,
                  config: config,
                  email: widget.email,
                )
              else if (config is PhoneProviderConfiguration) ...[
                const SizedBox(height: 8),
                PhoneVerificationButton(
                  label: l.signInWithPhoneButtonText,
                  action: action,
                  auth: widget.auth,
                ),
                const SizedBox(height: 8),
              ],
          if (oauthButtons != null) oauthButtons,
          if (widget.footerBuilder != null) widget.footerBuilder!(context),
        ],
      ),
    );
  }
}
