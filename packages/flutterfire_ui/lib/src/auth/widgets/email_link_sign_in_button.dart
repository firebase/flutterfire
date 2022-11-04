// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/i10n.dart';

import './internal/universal_button.dart';
import './internal/universal_page_route.dart';

class EmailLinkSignInButton extends StatelessWidget {
  final FirebaseAuth? auth;
  final EmailLinkProviderConfiguration config;

  const EmailLinkSignInButton({
    Key? key,
    required this.config,
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
                    config: config,
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
