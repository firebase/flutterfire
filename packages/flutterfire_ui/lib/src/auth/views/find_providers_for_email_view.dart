// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide Title;
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/i10n.dart';
import '../auth_flow.dart';
import '../widgets/internal/loading_button.dart';

import '../auth_state.dart';
import '../widgets/internal/title.dart';

typedef ProvidersFoundCallback = void Function(
  String email,
  List<String> providers,
);

class FindProvidersForEmailView extends StatefulWidget {
  final ProvidersFoundCallback? onProvidersFound;
  final FirebaseAuth? auth;

  const FindProvidersForEmailView({
    Key? key,
    this.onProvidersFound,
    this.auth,
  }) : super(key: key);

  @override
  State<FindProvidersForEmailView> createState() =>
      _FindProvidersForEmailViewState();
}

class _FindProvidersForEmailViewState extends State<FindProvidersForEmailView> {
  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  late final flow = AuthFlow(
    initialState: const Uninitialized(),
    auth: widget.auth,
  );

  void _submit(AuthController ctrl, String email) {
    if (formKey.currentState!.validate()) {
      ctrl.findProvidersForEmail(email);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = FlutterFireUILocalizations.labelsOf(context);
    const spacer = SizedBox(height: 24);

    return AuthFlowBuilder<AuthController>(
      flow: flow,
      listener: (oldState, newState, controller) {
        if (newState is DifferentSignInMethodsFound) {
          widget.onProvidersFound?.call(
            emailCtrl.text,
            newState.methods,
          );
        }
      },
      builder: (context, state, ctrl, child) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Title(
            text: l.findProviderForEmailTitleText,
          ),
          spacer,
          Form(
            key: formKey,
            child: EmailInput(
              controller: emailCtrl,
              onSubmitted: (_) {
                _submit(ctrl, emailCtrl.text);
              },
            ),
          ),
          spacer,
          LoadingButton(
            isLoading: state is FetchingProvidersForEmail,
            label: l.continueText,
            onTap: () {
              _submit(ctrl, emailCtrl.text);
            },
          )
        ],
      ),
    );
  }
}
