import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutterfire_ui/auth.dart';

import 'internal/login_screen.dart';
import 'internal/multi_provider_screen.dart';

/// A screen displaying a fully styled Registration flow for Authentication.
///
/// {@subCategory service:auth}
/// {@subCategory type:screen}
/// {@subCategory description:A screen displaying a fully styled Registration flow for Authentication.}
/// {@subCategory img:https://place-hold.it/400x150}
class RegisterScreen extends MultiProviderScreen {
  final double? headerMaxExtent;
  final HeaderBuilder? headerBuilder;
  final SideBuilder? sideBuilder;
  final OAuthButtonVariant? oauthButtonVariant;
  final TextDirection? desktopLayoutDirection;
  final String? email;
  final bool? showAuthActionSwitch;
  final AuthViewContentBuilder? subtitleBuilder;
  final AuthViewContentBuilder? footerBuilder;
  final double breakpoint;

  const RegisterScreen({
    Key? key,
    FirebaseAuth? auth,
    List<ProviderConfiguration>? providerConfigs,
    this.headerMaxExtent,
    this.headerBuilder,
    this.sideBuilder,
    this.oauthButtonVariant = OAuthButtonVariant.icon_and_text,
    this.desktopLayoutDirection,
    this.email,
    this.showAuthActionSwitch,
    this.subtitleBuilder,
    this.footerBuilder,
    this.breakpoint = 800,
  }) : super(key: key, auth: auth, providerConfigs: providerConfigs);

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
      subtitleBuilder: subtitleBuilder,
      footerBuilder: footerBuilder,
    );
  }
}
