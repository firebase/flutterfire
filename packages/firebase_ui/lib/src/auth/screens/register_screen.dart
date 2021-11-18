import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:firebase_ui/auth.dart';

import '../configs/provider_configuration.dart';
import 'internal/login_screen.dart';

class RegisterScreen extends StatelessWidget {
  final FirebaseAuth? auth;
  final List<ProviderConfiguration> providerConfigs;
  final double? headerMaxExtent;
  final HeaderBuilder? headerBuilder;
  final SideBuilder? sideBuilder;
  final ButtonVariant? oauthButtonVariant;
  final TextDirection? desktopLayoutDirection;

  const RegisterScreen({
    Key? key,
    required this.providerConfigs,
    this.auth,
    this.headerMaxExtent,
    this.headerBuilder,
    this.sideBuilder,
    this.oauthButtonVariant = ButtonVariant.icon_and_text,
    this.desktopLayoutDirection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      action: AuthAction.signIn,
      providerConfigs: providerConfigs,
      auth: auth,
      headerMaxExtent: headerMaxExtent,
      headerBuilder: headerBuilder,
      sideBuilder: sideBuilder,
      desktopLayoutDirection: desktopLayoutDirection,
      oauthButtonVariant: oauthButtonVariant,
    );
  }
}
