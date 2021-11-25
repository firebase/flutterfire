import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutterfire_ui/auth.dart';

import '../configs/provider_configuration.dart';
import 'internal/login_screen.dart';

/// A screen displaying a fully styled Registration flow for Authentication.
///
/// {@subCategory service:auth}
/// {@subCategory type:screen}
/// {@subCategory description:A screen displaying a fully styled Registration flow for Authentication.}
/// {@subCategory img:https://place-hold.it/400x150}
class RegisterScreen extends StatelessWidget {
  final FirebaseAuth? auth;
  final List<ProviderConfiguration> providerConfigs;
  final double? headerMaxExtent;
  final HeaderBuilder? headerBuilder;
  final SideBuilder? sideBuilder;
  final ButtonVariant? oauthButtonVariant;
  final TextDirection? desktopLayoutDirection;
  final String? email;
  final bool? showAuthActionSwitch;

  const RegisterScreen({
    Key? key,
    required this.providerConfigs,
    this.auth,
    this.headerMaxExtent,
    this.headerBuilder,
    this.sideBuilder,
    this.oauthButtonVariant = ButtonVariant.icon_and_text,
    this.desktopLayoutDirection,
    this.email,
    this.showAuthActionSwitch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      action: AuthAction.signUp,
      providerConfigs: providerConfigs,
      auth: auth,
      headerMaxExtent: headerMaxExtent,
      headerBuilder: headerBuilder,
      sideBuilder: sideBuilder,
      desktopLayoutDirection: desktopLayoutDirection,
      oauthButtonVariant: oauthButtonVariant,
      email: email,
      showAuthActionSwitch: showAuthActionSwitch,
    );
  }
}
