// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutterfire_ui/auth.dart';

import 'internal/login_screen.dart';
import 'internal/multi_provider_screen.dart';

/// A screen displaying a fully styled Sign In flow for Authentication.
///
/// {@subCategory service:auth}
/// {@subCategory type:screen}
/// {@subCategory description:A screen displaying a fully styled Sign In flow for Authentication.}
/// {@subCategory img:https://place-hold.it/400x150}
class SignInScreen extends MultiProviderScreen {
  final double? headerMaxExtent;
  final HeaderBuilder? headerBuilder;
  final SideBuilder? sideBuilder;
  final OAuthButtonVariant? oauthButtonVariant;
  final TextDirection? desktopLayoutDirection;
  final String? email;
  final bool? resizeToAvoidBottomInset;
  final bool? showAuthActionSwitch;
  final AuthViewContentBuilder? subtitleBuilder;
  final AuthViewContentBuilder? footerBuilder;
  final Key? loginViewKey;
  final List<FlutterFireUIAction> actions;
  final double breakpoint;
  final Set<FlutterFireUIStyle>? styles;

  const SignInScreen({
    Key? key,
    List<ProviderConfiguration>? providerConfigs,
    FirebaseAuth? auth,
    this.headerMaxExtent,
    this.headerBuilder,
    this.sideBuilder,
    this.oauthButtonVariant = OAuthButtonVariant.icon_and_text,
    this.desktopLayoutDirection,
    this.resizeToAvoidBottomInset = false,
    this.showAuthActionSwitch,
    this.email,
    this.subtitleBuilder,
    this.footerBuilder,
    this.loginViewKey,
    this.actions = const [],
    this.breakpoint = 800,
    this.styles,
  }) : super(key: key, providerConfigs: providerConfigs, auth: auth);

  Future<void> _signInWithDifferentProvider(
    BuildContext context,
    DifferentSignInMethodsFound state,
  ) async {
    await showDifferentMethodSignInDialog(
      availableProviders: state.methods,
      providerConfigs: providerConfigs,
      context: context,
      auth: auth,
      onSignedIn: () {
        Navigator.of(context).pop();
      },
    );

    await auth.currentUser!.linkWithCredential(state.credential!);
  }

  @override
  Widget build(BuildContext context) {
    final handlesDifferentSignInMethod = actions
        .whereType<AuthStateChangeAction<DifferentSignInMethodsFound>>()
        .isNotEmpty;

    final _actions = [
      ...actions,
      if (!handlesDifferentSignInMethod)
        AuthStateChangeAction(_signInWithDifferentProvider)
    ];

    return FlutterFireUIActions(
      actions: _actions,
      child: LoginScreen(
        styles: styles,
        loginViewKey: loginViewKey,
        action: AuthAction.signIn,
        providerConfigs: providerConfigs,
        auth: auth,
        headerMaxExtent: headerMaxExtent,
        headerBuilder: headerBuilder,
        sideBuilder: sideBuilder,
        desktopLayoutDirection: desktopLayoutDirection,
        oauthButtonVariant: oauthButtonVariant,
        email: email,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        showAuthActionSwitch: showAuthActionSwitch,
        subtitleBuilder: subtitleBuilder,
        footerBuilder: footerBuilder,
        breakpoint: breakpoint,
      ),
    );
  }
}
