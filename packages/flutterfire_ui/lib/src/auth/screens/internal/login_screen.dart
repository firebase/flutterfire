import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;

import '../../widgets/internal/universal_scaffold.dart';

import 'responsive_page.dart';

class LoginScreen extends StatelessWidget {
  final FirebaseAuth? auth;
  final AuthAction action;
  final List<ProviderConfiguration> providerConfigs;
  final HeaderBuilder? headerBuilder;
  final double? headerMaxExtent;
  final OAuthButtonVariant? oauthButtonVariant;
  final SideBuilder? sideBuilder;
  final TextDirection? desktopLayoutDirection;
  final String? email;
  final bool? showAuthActionSwitch;
  final AuthViewContentBuilder? subtitleBuilder;
  final AuthViewContentBuilder? footerBuilder;
  final Key? loginViewKey;
  final double breakpoint;

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
    this.breakpoint = 800,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginContent = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: LoginView(
          key: loginViewKey,
          action: action,
          auth: auth,
          providerConfigs: providerConfigs,
          oauthButtonVariant: oauthButtonVariant,
          email: email,
          showAuthActionSwitch: showAuthActionSwitch,
          subtitleBuilder: subtitleBuilder,
          footerBuilder: footerBuilder,
        ),
      ),
    );

    final body = ResponsivePage(
      breakpoint: breakpoint,
      desktopLayoutDirection: desktopLayoutDirection,
      headerBuilder: headerBuilder,
      headerMaxExtent: headerMaxExtent,
      sideBuilder: sideBuilder,
      child: loginContent,
    );

    return UniversalScaffold(
      body: body,
      resizeToAvoidBottomInset: false,
    );
  }
}
