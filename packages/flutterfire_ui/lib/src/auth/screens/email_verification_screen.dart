// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide Title;
import 'package:flutter/scheduler.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/i10n.dart';
import 'package:flutterfire_ui/src/auth/widgets/internal/loading_button.dart';

import '../widgets/internal/title.dart';
import '../widgets/internal/universal_button.dart';
import '../widgets/internal/universal_scaffold.dart';
import 'internal/responsive_page.dart';

class EmailVerified extends FlutterFireUIAction {
  final VoidCallback callback;

  EmailVerified(this.callback);
}

class EmailVerificationScreen extends StatelessWidget {
  final FirebaseAuth? auth;
  final HeaderBuilder? headerBuilder;
  final List<FlutterFireUIAction> actions;
  final double? headerMaxExtent;
  final SideBuilder? sideBuilder;
  final TextDirection? desktoplayoutDirection;
  final double breakpoint;
  final ActionCodeSettings? actionCodeSettings;
  final Set<FlutterFireUIStyle>? styles;

  const EmailVerificationScreen({
    Key? key,
    this.auth,
    this.actions = const [],
    this.headerBuilder,
    this.headerMaxExtent,
    this.sideBuilder,
    this.desktoplayoutDirection,
    this.breakpoint = 500,
    this.actionCodeSettings,
    this.styles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlutterFireUITheme(
      styles: styles ?? const {},
      child: FlutterFireUIActions(
        actions: actions,
        child: UniversalScaffold(
          body: ResponsivePage(
            breakpoint: breakpoint,
            desktopLayoutDirection: desktoplayoutDirection,
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
  late final service = EmailVerificationService(auth);
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
    service
      ..addListener(() {
        setState(() {});

        if (state == EmailVerificationState.verified) {
          final action = FlutterFireUIAction.ofType<EmailVerified>(context);
          action?.callback();
        }
      })
      ..sendVerificationEmail(
        Theme.of(context).platform,
        widget.actionCodeSettings,
      );
  }

  EmailVerificationState get state => service.state;

  @override
  Widget build(BuildContext context) {
    final l = FlutterFireUILocalizations.labelsOf(context);

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
              await service.reload();
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
              service.sendVerificationEmail(
                Theme.of(context).platform,
                widget.actionCodeSettings,
              );
            },
          )
        ],
        if (state == EmailVerificationState.failed) ...[
          const SizedBox(height: 16),
          ErrorText(exception: service.error!),
        ],
        const SizedBox(height: 16),
        UniversalButton(
          variant: ButtonVariant.text,
          text: l.goBackButtonLabel,
          onPressed: () {
            FlutterFireUIAction.ofType<Cancel>(context)?.callback(context);
          },
        )
      ],
    );
  }
}
