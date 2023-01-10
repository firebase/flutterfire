// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';

import '../widgets/internal/universal_button.dart';
import '../widgets/internal/universal_scaffold.dart';
import '../screens/internal/responsive_page.dart';

/// A screen displaying a UI which allows users to enter an SMS validation code
/// sent from Firebase.
///
/// {@subCategory service:auth}
/// {@subCategory type:screen}
/// {@subCategory description:A screen displaying SMS verification UI.}
/// {@subCategory img:https://place-hold.it/400x150}
class SMSCodeInputScreen extends StatelessWidget {
  /// {@macro ui.auth.auth_action}
  final AuthAction? action;

  /// SMSCodeInputScreen could invoke these actions:
  ///
  /// * [AuthStateChangeAction]
  ///
  /// ```dart
  /// SMSCodeInputScreen(
  ///   actions: [
  ///     AuthStateChangeAction<SignedIn>((context, state) {
  ///       Navigator.pushReplacementNamed(context, '/');
  ///     }),
  ///   ],
  /// );
  /// ```
  final List<FirebaseUIAction>? actions;

  /// {@macro ui.auth.auth_controller.auth}
  final FirebaseAuth? auth;

  /// A unique key that could be used to obtain an instance of the
  /// [PhoneAuthController].
  ///
  /// ```dart
  /// final ctrl = AuthFlowBuilder.getController<PhoneAuthController>(flowKey);
  /// ctrl.acceptPhoneNumber('+1234567890');
  /// ```
  final Object flowKey;

  /// {@macro ui.auth.screens.responsive_page.desktop_layout_direction}
  final TextDirection? desktopLayoutDirection;

  /// {@macro ui.auth.screens.responsive_page.side_builder}
  final SideBuilder? sideBuilder;

  /// {@macro ui.auth.screens.responsive_page.header_builder}
  final HeaderBuilder? headerBuilder;

  /// {@macro ui.auth.screens.responsive_page.header_max_extent}
  final double? headerMaxExtent;

  /// {@macro ui.auth.screens.responsive_page.content_flex}
  final int? contentFlex;

  /// {@macro ui.auth.screens.responsive_page.max_width}
  final double? maxWidth;

  /// {@macro ui.auth.screens.responsive_page.breakpoint}
  final double breakpoint;

  const SMSCodeInputScreen({
    Key? key,
    this.action,
    this.actions,
    this.auth,
    required this.flowKey,
    this.desktopLayoutDirection,
    this.sideBuilder,
    this.headerBuilder,
    this.headerMaxExtent,
    this.breakpoint = 670,
    this.contentFlex,
    this.maxWidth,
  }) : super(key: key);

  void _reset() {
    final ctrl = AuthFlowBuilder.getController<PhoneAuthController>(flowKey);
    ctrl?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    return WillPopScope(
      onWillPop: () async {
        _reset();
        return true;
      },
      child: FirebaseUIActions(
        actions: actions ?? const [],
        child: UniversalScaffold(
          body: Center(
            child: ResponsivePage(
              breakpoint: breakpoint,
              maxWidth: maxWidth,
              desktopLayoutDirection: desktopLayoutDirection,
              sideBuilder: sideBuilder,
              headerBuilder: headerBuilder,
              headerMaxExtent: headerMaxExtent,
              contentFlex: contentFlex,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SMSCodeInputView(
                    auth: auth,
                    action: action,
                    flowKey: flowKey,
                    onCodeVerified: () {
                      if (actions != null) return;

                      Navigator.of(context).popUntil((route) {
                        return route.isFirst;
                      });
                    },
                  ),
                  UniversalButton(
                    variant: ButtonVariant.text,
                    text: l.goBackButtonLabel,
                    onPressed: () {
                      _reset();
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
