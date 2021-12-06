import 'package:flutter/material.dart' hide Title;

import 'package:firebase_auth/firebase_auth.dart'
    show ActionCodeSettings, FirebaseAuth, FirebaseAuthException;
import 'package:flutterfire_ui/auth.dart' hide ButtonVariant;
import 'package:flutterfire_ui/i10n.dart';
import 'package:flutterfire_ui/src/auth/widgets/internal/universal_button.dart';

import '../widgets/internal/loading_button.dart';
import '../widgets/internal/title.dart';

class ForgotPasswordView extends StatefulWidget {
  final FirebaseAuth? auth;
  final ActionCodeSettings? actionCodeSettings;
  final WidgetBuilder? subtitleBuilder;
  final WidgetBuilder? footerBuilder;
  final String? email;

  const ForgotPasswordView({
    Key? key,
    this.auth,
    this.email,
    this.actionCodeSettings,
    this.subtitleBuilder,
    this.footerBuilder,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ForgotPasswordViewState createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final emailCtrl = TextEditingController(text: widget.email ?? '');
  final formKey = GlobalKey<FormState>();
  bool emailSent = false;

  FirebaseAuth get auth => widget.auth ?? FirebaseAuth.instance;
  bool isLoading = false;
  FirebaseAuthException? exception;

  Future<void> _submit(String email) async {
    setState(() => isLoading = true);
    try {
      await auth.sendPasswordResetEmail(
        email: email,
        actionCodeSettings: widget.actionCodeSettings,
      );

      emailSent = true;
    } on FirebaseAuthException catch (e) {
      exception = e;
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);
    const spacer = SizedBox(height: 32);

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Title(text: l.forgotPasswordViewTitle),
          spacer,
          if (widget.subtitleBuilder != null) widget.subtitleBuilder!(context),
          if (!emailSent)
            EmailInput(
              autofocus: true,
              controller: emailCtrl,
              onSubmitted: _submit,
            )
          else
            Text(l.passwordResetEmailSentText),
          spacer,
          if (exception != null) ...[
            ErrorText(exception: exception!),
            spacer,
          ],
          if (!emailSent)
            LoadingButton(
              isLoading: isLoading,
              label: l.resetPasswordButtonLabel,
              onTap: () {
                if (formKey.currentState!.validate()) {
                  _submit(emailCtrl.text);
                }
              },
            ),
          const SizedBox(height: 8),
          UniversalButton(
            variant: ButtonVariant.text,
            text: l.goBackButtonLabel,
            onPressed: () => Navigator.pop(context),
          ),
          if (widget.footerBuilder != null) widget.footerBuilder!(context),
        ],
      ),
    );
  }
}
