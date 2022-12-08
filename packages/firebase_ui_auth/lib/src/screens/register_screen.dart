// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import 'internal/login_screen.dart';
import 'internal/multi_provider_screen.dart';

/// A screen displaying a fully styled Registration flow for Authentication.
///
/// {@subCategory service:auth}
/// {@subCategory type:screen}
/// {@subCategory description:A screen displaying a fully styled Registration flow for Authentication.}
/// {@subCategory img:https://place-hold.it/400x150}
class RegisterScreen extends MultiProviderScreen {
  /// {@macro ui.auth.screens.responsive_page.header_max_extent}
  final double? headerMaxExtent;

  /// {@macro ui.auth.screens.responsive_page.header_builder}
  final HeaderBuilder? headerBuilder;

  /// {@macro ui.auth.screens.responsive_page.side_builder}
  final SideBuilder? sideBuilder;

  /// Indicates whether icon-only or icon and text OAuth buttons should be used.
  /// Icon-only buttons are placed in a row.
  final OAuthButtonVariant? oauthButtonVariant;

  /// {@macro ui.auth.screens.responsive_page.desktop_layout_direction}
  final TextDirection? desktopLayoutDirection;

  /// [RegisterScreen] could invoke these actions:
  ///
  /// * [EmailLinkSignInAction]
  /// * [VerifyPhoneAction]
  /// * [AuthStateChangeAction]
  ///
  /// These actions could be used to trigger route transtion or display
  /// a dialog.
  ///
  /// ```dart
  /// SignInScreen(
  ///   actions: [
  ///     VerifyPhoneAction((context, _) {
  ///       Navigator.pushNamed(context, '/phone');
  ///     }),
  ///     AuthStateChangeAction<SignedIn>((context, state) {
  ///       if (!state.user!.emailVerified) {
  ///         Navigator.pushNamed(context, '/verify-email');
  ///       } else {
  ///         Navigator.pushReplacementNamed(context, '/profile');
  ///       }
  ///     }),
  ///     EmailLinkSignInAction((context) {
  ///       Navigator.pushReplacementNamed(context, '/email-link-sign-in');
  ///     }),
  ///   ],
  /// )
  /// ```
  final List<FirebaseUIAction>? actions;

  /// An email that [EmailForm] should be pre-filled with.
  final String? email;

  /// See [Scaffold.resizeToAvoidBottomInset]
  final bool? resizeToAvoidBottomInset;

  /// Whether the "Login/Register" link should be displayed. The link changes
  /// the type of the [AuthAction] from [AuthAction.signIn]
  /// and [AuthAction.signUp] and vice versa.
  final bool? showAuthActionSwitch;

  /// {@macro ui.auth.views.login_view.subtitle_builder}
  final AuthViewContentBuilder? subtitleBuilder;

  /// {@macro ui.auth.views.login_view.footer_builder}
  final AuthViewContentBuilder? footerBuilder;

  /// {@macro ui.auth.screens.responsive_page.breakpoint}
  final double breakpoint;

  /// A set of styles that are provided to the descendant widgets.
  ///
  /// Possible styles are:
  /// * [EmailFormStyle]
  final Set<FirebaseUIStyle>? styles;

  const RegisterScreen({
    Key? key,
    FirebaseAuth? auth,
    List<AuthProvider>? providers,
    this.actions,
    this.headerMaxExtent,
    this.headerBuilder,
    this.sideBuilder,
    this.oauthButtonVariant = OAuthButtonVariant.icon_and_text,
    this.desktopLayoutDirection,
    this.email,
    this.resizeToAvoidBottomInset = false,
    this.showAuthActionSwitch,
    this.subtitleBuilder,
    this.footerBuilder,
    this.breakpoint = 800,
    this.styles,
  }) : super(key: key, auth: auth, providers: providers);

  @override
  Widget build(BuildContext context) {
    return FirebaseUIActions(
      actions: actions ?? [],
      child: LoginScreen(
        styles: styles,
        action: AuthAction.signUp,
        providers: providers,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
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
      ),
    );
  }
}
