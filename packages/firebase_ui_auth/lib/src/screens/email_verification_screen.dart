// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide Title;
import 'package:flutter/scheduler.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';

import '../widgets/internal/loading_button.dart';
import '../widgets/internal/title.dart';
import '../widgets/internal/universal_button.dart';
import '../widgets/internal/universal_scaffold.dart';

import 'internal/responsive_page.dart';

/// An action that is being called when email was successfully verified.
class EmailVerifiedAction extends FirebaseUIAction {
  final VoidCallback callback;

  EmailVerifiedAction(this.callback);
}

/// {@template ui.auth.screens.email_verification_screen}
/// A screen that contains hints of how to verify the email.
/// A verification email is being sent automatically when this screen is opened.
/// {@endtemplate}
class EmailVerificationScreen extends StatelessWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final FirebaseAuth? auth;

  /// {@macro ui.auth.screens.responsive_page.header_builder}
  final HeaderBuilder? headerBuilder;

  /// EmailVerificationScreen could invoke these actions:
  ///
  /// * [AuthCancelledAction]
  /// * [EmailVerifiedAction]
  ///
  /// ```dart
  /// EmailVerificationScreen(
  ///   actions: [
  ///     EmailVerified(() {
  ///       Navigator.pushReplacementNamed(context, '/profile');
  ///     }),
  ///     Cancel((context) {
  ///       Navigator.of(context).pop();
  ///     }),
  ///   ],
  /// );
  /// ```
  final List<FirebaseUIAction> actions;

  /// {@macro ui.auth.screens.responsive_page.header_max_extent}
  final double? headerMaxExtent;

  /// {@macro ui.auth.screens.responsive_page.side_builder}
  final SideBuilder? sideBuilder;

  /// {@macro ui.auth.screens.responsive_page.desktop_layout_direction}
  final TextDirection? desktopLayoutDirection;

  /// {@macro ui.auth.screens.responsive_page.breakpoint}
  final double breakpoint;

  /// A configuration object used to construct a dynamic link.
  final ActionCodeSettings? actionCodeSettings;

  /// {@macro ui.auth.screens.email_verification_screen}
  const EmailVerificationScreen({
    Key? key,
    this.auth,
    this.actions = const [],
    this.headerBuilder,
    this.headerMaxExtent,
    this.sideBuilder,
    this.desktopLayoutDirection,
    this.breakpoint = 500,
    this.actionCodeSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FirebaseUIActions(
      actions: actions,
      child: UniversalScaffold(
        body: ResponsivePage(
          breakpoint: breakpoint,
          desktopLayoutDirection: desktopLayoutDirection,
          headerBuilder: headerBuilder,
          headerMaxExtent: headerMaxExtent,
          sideBuilder: sideBuilder,
          maxWidth: 1200,
          contentFlex: 2,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: _EmailVerificationScreenContent(
              auth: auth,
              actionCodeSettings: actionCodeSettings,
            ),
          ),
        ),
      ),
    );
  }
}

/// This allows a value of type T or T?
/// to be treated as a value of type T?.
///
/// We use this so that APIs that have become
/// non-nullable can still be used with `!` and `?`
/// to support older versions of the API as well.
T? _ambiguate<T>(T? value) => value;

class _EmailVerificationScreenContent extends StatefulWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final FirebaseAuth? auth;
  final ActionCodeSettings? actionCodeSettings;

  const _EmailVerificationScreenContent({
    Key? key,
    required this.auth,
    required this.actionCodeSettings,
  }) : super(key: key);

  @override
  State<_EmailVerificationScreenContent> createState() =>
      __EmailVerificationScreenContentState();
}

class __EmailVerificationScreenContentState
    extends State<_EmailVerificationScreenContent> {
  late final controller = EmailVerificationController(auth);
  FirebaseAuth get auth => widget.auth ?? FirebaseAuth.instance;
  User get user => auth.currentUser!;
  bool isLoading = false;

  @override
  void initState() {
    _ambiguate(SchedulerBinding.instance)!
        .addPostFrameCallback(_sendEmailVerification);
    super.initState();
  }

  void _sendEmailVerification(_) {
    controller
      ..addListener(() {
        setState(() {});

        if (state == EmailVerificationState.verified) {
          final action = FirebaseUIAction.ofType<EmailVerifiedAction>(context);
          action?.callback();
        }
      })
      ..sendVerificationEmail(
        Theme.of(context).platform,
        widget.actionCodeSettings,
      );
  }

  EmailVerificationState get state => controller.state;

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Align(
          child: Title(text: 'Verify your email'),
        ),
        const SizedBox(height: 32),
        const Text(
          'A verification email has been sent to your email address. '
          'Please check your email and click on the link to verify '
          'your email address.',
        ),
        const SizedBox(height: 32),
        if (state == EmailVerificationState.pending)
          const LoadingIndicator(size: 32, borderWidth: 2)
        else if (state == EmailVerificationState.sent) ...[
          LoadingButton(
            isLoading: isLoading,
            variant: ButtonVariant.filled,
            label: l.continueText,
            onTap: () async {
              await controller.reload();
            },
          ),
        ],
        if (state == EmailVerificationState.sending)
          const LoadingIndicator(size: 32, borderWidth: 2),
        if (state == EmailVerificationState.unverified) ...[
          Text(
            "We couldn't verify your email address. ",
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 16),
          UniversalButton(
            text: 'Resend verification email',
            onPressed: () {
              controller.sendVerificationEmail(
                Theme.of(context).platform,
                widget.actionCodeSettings,
              );
            },
          )
        ],
        if (state == EmailVerificationState.failed) ...[
          const SizedBox(height: 16),
          ErrorText(exception: controller.error!),
        ],
        const SizedBox(height: 16),
        UniversalButton(
          variant: ButtonVariant.text,
          text: l.goBackButtonLabel,
          onPressed: () {
            FirebaseUIAction.ofType<AuthCancelledAction>(context)
                ?.callback(context);
          },
        )
      ],
    );
  }
}
