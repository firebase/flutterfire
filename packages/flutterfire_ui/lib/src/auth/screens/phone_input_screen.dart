// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/i10n.dart';

import '../widgets/internal/universal_button.dart';
import '../widgets/internal/universal_page_route.dart';
import '../widgets/internal/universal_scaffold.dart';

import 'internal/responsive_page.dart';

/// A screen displaying a fully styled phone number entry screen, with a country-code
/// picker.
///
/// {@subCategory service:auth}
/// {@subCategory type:screen}
/// {@subCategory description:A screen displaying a fully styled phone number entry input with a country-code picker.}
/// {@subCategory img:https://place-hold.it/400x150}
class PhoneInputScreen extends StatelessWidget {
  final AuthAction? action;
  final List<FlutterFireUIAction>? actions;
  final FirebaseAuth? auth;
  final WidgetBuilder? subtitleBuilder;
  final WidgetBuilder? footerBuilder;
  final HeaderBuilder? headerBuilder;
  final double? headerMaxExtent;
  final SideBuilder? sideBuilder;
  final TextDirection? desktopLayoutDirection;
  final double breakpoint;
  final Set<FlutterFireUIStyle>? styles;

  const PhoneInputScreen({
    Key? key,
    this.action,
    this.actions,
    this.auth,
    this.subtitleBuilder,
    this.footerBuilder,
    this.headerBuilder,
    this.headerMaxExtent,
    this.sideBuilder,
    this.desktopLayoutDirection,
    this.breakpoint = 500,
    this.styles,
  }) : super(key: key);

  void _next(BuildContext context, AuthAction? action, Object flowKey, _) {
    Navigator.of(context).push(
      createPageRoute(
        context: context,
        builder: (_) => FlutterFireUIActions.inherit(
          from: context,
          child: SMSCodeInputScreen(
            action: action,
            flowKey: flowKey,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flowKey = Object();
    final l = FlutterFireUILocalizations.labelsOf(context);

    return FlutterFireUITheme(
      styles: styles ?? const {},
      child: FlutterFireUIActions(
        actions: actions ?? [SMSCodeRequestedAction(_next)],
        child: UniversalScaffold(
          body: ResponsivePage(
            desktopLayoutDirection: desktopLayoutDirection,
            sideBuilder: sideBuilder,
            headerBuilder: headerBuilder,
            headerMaxExtent: headerMaxExtent,
            breakpoint: breakpoint,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  PhoneInputView(
                    auth: auth,
                    action: action,
                    subtitleBuilder: subtitleBuilder,
                    footerBuilder: footerBuilder,
                    flowKey: flowKey,
                  ),
                  UniversalButton(
                    text: l.goBackButtonLabel,
                    variant: ButtonVariant.text,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
