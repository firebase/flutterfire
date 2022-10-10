import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/i10n.dart';

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
  final AuthAction? action;
  final List<FlutterFireUIAction>? actions;
  final FirebaseAuth? auth;
  final Object flowKey;
  final TextDirection? desktopLayoutDirection;
  final SideBuilder? sideBuilder;
  final HeaderBuilder? headerBuilder;
  final double? headerMaxExtent;
  final int? contentFlex;
  final double? maxWidth;
  final double breakpoint;
  final Set<FlutterFireUIStyle>? styles;

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
    this.breakpoint = 500,
    this.contentFlex,
    this.maxWidth,
    this.styles,
  }) : super(key: key);

  void _reset() {
    final ctrl = AuthFlowBuilder.getController<PhoneAuthController>(flowKey);
    ctrl?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final l = FlutterFireUILocalizations.labelsOf(context);

    return WillPopScope(
      onWillPop: () async {
        _reset();
        return true;
      },
      child: FlutterFireUITheme(
        styles: styles ?? const {},
        child: FlutterFireUIActions(
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
      ),
    );
  }
}
