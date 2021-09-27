import 'package:firebase_ui/auth.dart';
import 'package:firebase_ui/responsive.dart';
import 'package:firebase_ui/src/i10n/i10n.dart';
import 'package:flutter/material.dart';

import '../auth_state.dart';

typedef SurfaceBuilder = Widget Function(BuildContext context, Widget child);

class SignInForm extends StatefulWidget {
  final SurfaceBuilder surfaceBuilder;
  final List<Widget> children;

  const SignInForm({
    Key? key,
    required this.surfaceBuilder,
    this.children = const <Widget>[],
  }) : super(key: key);

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm>
    with SingleTickerProviderStateMixin {
  AuthMethod method = AuthMethod.signIn;
  late final TabController ctrl = TabController(length: 2, vsync: this)
    ..addListener(() {
      setState(() {
        method = AuthMethod.values.elementAt(ctrl.index);
      });
    });

  late final tabs = TabBar(
    labelColor: Theme.of(context).colorScheme.secondary,
    controller: ctrl,
    tabs: const [
      Tab(text: 'Sign in'),
      Tab(text: 'Sign up'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        tabs,
        Expanded(
          child: Column(
            children: [
              AuthFlowBuilder<EmailFlowController>(
                method: method,
                listener: (oldState, newState) {
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
        child: widget.surfaceBuilder(context, content),
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

    switch (ctrl.method) {
      case AuthMethod.signIn:
        return 'Sing in';
      case AuthMethod.signUp:
        return 'Sign up';
      case AuthMethod.link:
        return 'Next';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = AuthController.ofType<EmailFlowController>(context);
    final l = FirebaseUILocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: emailCtrl,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordCtrl,
          decoration: const InputDecoration(labelText: 'Password'),
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
