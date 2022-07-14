import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/i10n.dart';

import 'internal/universal_button.dart';
import 'internal/universal_page_route.dart';

/// {@template ffui.auth.widget.email_link_sign_in_button}
/// A button that starts an email link sign in flow.
///
/// Triggers an [EmailLinkSignInAction] if provided, otherwise
/// opens an [EmailLinkSignInScreen].
///
/// {@endtemplate}
class EmailLinkSignInButton extends StatelessWidget {
  /// {@macro ffui.auth.auth_controller.auth}
  final FirebaseAuth? auth;

  /// An instance of [EmailLinkAuthProvider] that should be used to
  /// authenticate.
  final EmailLinkAuthProvider provider;

  /// {@macro ffui.auth.widget.email_link_sign_in_button}
  const EmailLinkSignInButton({
    Key? key,
    required this.provider,
    this.auth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;
    final l = FlutterFireUILocalizations.labelsOf(context);

    return UniversalButton(
      text: l.emailLinkSignInButtonLabel,
      icon: isCupertino ? CupertinoIcons.link : Icons.link,
      onPressed: () {
        final action =
            FlutterFireUIAction.ofType<EmailLinkSignInAction>(context);
        if (action != null) {
          action.callback(context);
        } else {
          Navigator.of(context).push(
            createPageRoute(
              context: context,
              builder: (_) {
                return FlutterFireUIActions.inherit(
                  from: context,
                  child: EmailLinkSignInScreen(
                    auth: auth,
                    provider: provider,
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
