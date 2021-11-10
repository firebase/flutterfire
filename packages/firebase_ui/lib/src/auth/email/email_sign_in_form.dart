import 'package:firebase_ui/auth.dart';
import 'package:firebase_ui/src/responsive.dart';
import 'package:firebase_ui/src/i10n/i10n.dart';
import 'package:flutter/material.dart';

import '../auth_state.dart';

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
                listener: (oldState, newState, _) {
                  if (newState is AuthFailed) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          newState.exception.toString(),
                        ),
                      ),
                    );
                  }
                },
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

  @override
  Widget build(BuildContext context) {
    final ctrl = AuthController.ofType<EmailFlowController>(context);
    final l = FirebaseUILocalizations.labelsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: emailCtrl,
          decoration: InputDecoration(labelText: l.emailInputLabel),
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordCtrl,
          decoration: InputDecoration(labelText: l.passwordInputLabel),
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            ctrl.setEmailAndPassword(
              emailCtrl.text,
              passwordCtrl.text,
            );
          },
          child: Text(chooseButtonLabel()),
        ),
      ],
    );
  }
}
