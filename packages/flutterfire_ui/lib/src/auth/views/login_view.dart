import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;

import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/i10n.dart';

import '../configs/provider_configuration.dart';
import '../configs/oauth_provider_configuration.dart';
import '../widgets/internal/oauth_provider_button.dart';
import '../screens/internal/login_screen.dart' show HeaderBuilder;

class LoginView extends StatefulWidget {
  final FirebaseAuth? auth;
  final AuthAction action;
  final ButtonVariant? oauthButtonVariant;
  final double? headerMaxExtent;
  final HeaderBuilder? headerBuilder;
  final bool? showTitle;

  final List<ProviderConfiguration> providerConfigs;

  const LoginView({
    Key? key,
    required this.action,
    required this.providerConfigs,
    this.oauthButtonVariant = ButtonVariant.icon_and_text,
    this.auth,
    this.headerMaxExtent,
    this.headerBuilder,
    this.showTitle = true,
  }) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late AuthAction action = widget.action;
  bool get showTitle => widget.showTitle ?? true;

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

    return [
      Text(
        title,
        style: Theme.of(context).textTheme.headline6,
      ),
      const SizedBox(height: 16),
      RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$hint ',
              style: Theme.of(context).textTheme.caption,
            ),
            TextSpan(
              text: actionText,
              style: Theme.of(context).textTheme.button?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
              mouseCursor: SystemMouseCursors.click,
              recognizer: TapGestureRecognizer()
                ..onTap = () => _handleDifferentAuthAction(context),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
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
                )
              else if (config is PhoneProviderConfiguration)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: PhoneVerificationButton(
                    label: l.signInWithPhoneButtonText,
                    action: action,
                    auth: widget.auth,
                  ),
                ),
          if (oauthButtons != null) oauthButtons
        ],
      ),
    );
  }
}
