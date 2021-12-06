import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutterfire_ui/src/auth/widgets/internal/universal_scaffold.dart';

import '../../configs/provider_configuration.dart';
import '../../widgets/internal/keyboard_appearence_listener.dart';

import 'responsive_page.dart';

class LoginScreen extends StatefulWidget {
  final FirebaseAuth? auth;
  final AuthAction action;
  final List<ProviderConfiguration> providerConfigs;
  final HeaderBuilder? headerBuilder;
  final double? headerMaxExtent;
  final ButtonVariant? oauthButtonVariant;
  final SideBuilder? sideBuilder;
  final TextDirection? desktopLayoutDirection;
  final String? email;
  final bool? showAuthActionSwitch;
  final AuthViewContentBuilder? subtitleBuilder;
  final AuthViewContentBuilder? footerBuilder;
  final Key? loginViewKey;

  const LoginScreen({
    Key? key,
    required this.action,
    required this.providerConfigs,
    this.auth,
    this.oauthButtonVariant,
    this.headerBuilder,
    this.headerMaxExtent = defaultHeaderImageHeight,
    this.sideBuilder,
    this.desktopLayoutDirection = TextDirection.ltr,
    this.email,
    this.showAuthActionSwitch,
    this.subtitleBuilder,
    this.footerBuilder,
    this.loginViewKey,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ctrl = ScrollController();

  void _onKeyboardPositionChanged(double position) {
    if (!ctrl.hasClients) {
      return;
    }

    if (widget.headerBuilder == null) return;

    final max = widget.headerMaxExtent ?? defaultHeaderImageHeight;
    final ctrlPosition = position.clamp(0.0, max);
    ctrl.jumpTo(ctrlPosition);
  }

  @override
  Widget build(BuildContext context) {
    final loginContent = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: LoginView(
          key: widget.loginViewKey,
          action: widget.action,
          providerConfigs: widget.providerConfigs,
          oauthButtonVariant: widget.oauthButtonVariant,
          email: widget.email,
          showAuthActionSwitch: widget.showAuthActionSwitch,
          subtitleBuilder: widget.subtitleBuilder,
          footerBuilder: widget.footerBuilder,
        ),
      ),
    );

    final body = ResponsivePage(
      breakpoint: 800,
      desktopLayoutDirection: widget.desktopLayoutDirection,
      headerBuilder: widget.headerBuilder,
      headerMaxExtent: widget.headerMaxExtent,
      sideBuilder: widget.sideBuilder,
      child: loginContent,
    );

    return UniversalScaffold(
      body: body,
      resizeToAvoidBottomInset: false,
    );
  }
}
