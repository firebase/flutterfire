import 'package:firebase_ui/auth.dart';
import 'package:firebase_ui/src/i10n/i10n.dart';
import 'package:firebase_ui/src/validators.dart';
import 'package:flutter/material.dart';

import '../../../src/responsive.dart';
import '../auth_state.dart';
import '../error_text.dart';

typedef SurfaceBuilder = Widget Function(BuildContext context, Widget child);

class EmailSignInForm extends StatefulWidget {
  final SurfaceBuilder? surfaceBuilder;
  final List<Widget> children;

  const EmailSignInForm({
    Key? key,
    this.surfaceBuilder,
    this.children = const <Widget>[],
  }) : super(key: key);

  @override
  State<EmailSignInForm> createState() => _EmailSignInFormState();
}

class _EmailSignInFormState extends State<EmailSignInForm>
    with SingleTickerProviderStateMixin {
  AuthAction action = AuthAction.signIn;

  late SurfaceBuilder surfaceBuilder =
      widget.surfaceBuilder ?? _defaultSurfaceBuilder;

  late final TabController ctrl = TabController(length: 2, vsync: this)
    ..addListener(() {
      setState(() {
        action = AuthAction.values.elementAt(ctrl.index);
      });
    });

  Widget _defaultSurfaceBuilder(BuildContext context, Widget child) => child;

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    final tabs = TabBar(
      labelColor: Theme.of(context).colorScheme.secondary,
      controller: ctrl,
      tabs: [
        Tab(text: l.signInActionText),
        Tab(text: l.signUpActionText),
      ],
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        tabs,
        Expanded(
          child: Column(
            children: [
              AuthFlowBuilder<EmailFlowController>(
                action: action,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: _SignInFormContent(),
                ),
              ),
              ...widget.children,
            ],
          ),
        ),
      ],
    );

    return Center(
      child: ResponsiveContainer(
        colWidth: ColWidth(
          phone: 4,
          phablet: 6,
          tablet: 8,
          laptop: 6,
          desktop: 6,
        ),
        child: surfaceBuilder(
          context,
          IntrinsicHeight(
            child: content,
          ),
        ),
      ),
    );
  }
}

class _SignInFormContent extends StatefulWidget {
  const _SignInFormContent({Key? key}) : super(key: key);

  @override
  _SignInFormContentState createState() => _SignInFormContentState();
}

class _SignInFormContentState extends State<_SignInFormContent> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  late final emailFocusNode = FocusNode()..addListener(onEmailFieldBlur);
  final passwordFocusNode = FocusNode();

  String chooseButtonLabel() {
    final ctrl = AuthController.ofType<EmailFlowController>(context);
    final l = FirebaseUILocalizations.labelsOf(context);

    switch (ctrl.action) {
      case AuthAction.signIn:
        return l.signInActionText;
      case AuthAction.signUp:
        return l.signUpActionText;
      case AuthAction.link:
        return l.linkEmailButtonText;
    }
  }

  void onEmailFieldBlur() {
    if (!emailFocusNode.hasFocus) {
      if (!formKey.currentState!.validate()) {
        emailFocusNode.requestFocus();
      }
    }
  }

  String? validateEmail(String? value) {
    final l = FirebaseUILocalizations.labelsOf(context);

    if (value == null || value.isEmpty) {
      return l.emailIsRequiredErrorText;
    }

    if (!isValidEmail(value)) {
      return l.isNotAValidEmailErrorText;
    }

    return null;
  }

  void submit([String? value]) {
    final ctrl = AuthController.ofType<EmailFlowController>(context);

    if (formKey.currentState!.validate()) {
      ctrl.setEmailAndPassword(
        emailCtrl.text,
        passwordCtrl.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            focusNode: emailFocusNode,
            controller: emailCtrl,
            decoration: InputDecoration(labelText: l.emailInputLabel),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            validator: validateEmail,
            onFieldSubmitted: (v) {
              formKey.currentState?.validate();
              FocusScope.of(context).requestFocus(passwordFocusNode);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            focusNode: passwordFocusNode,
            controller: passwordCtrl,
            decoration: InputDecoration(labelText: l.passwordInputLabel),
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            onFieldSubmitted: submit,
          ),
          const SizedBox(height: 16),
          Builder(
            builder: (context) {
              late Widget child;
              final state = AuthState.of(context);

              if (state is SigningIn) {
                child = const CircularProgressIndicator();
              } else {
                child = Text(chooseButtonLabel());
              }

              return OutlinedButton(
                onPressed: submit,
                child: child,
              );
            },
          ),
          Builder(
            builder: (context) {
              final authState = AuthState.of(context);
              if (authState is AuthFailed) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ErrorText(
                    textAlign: TextAlign.center,
                    exception: authState.exception,
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
