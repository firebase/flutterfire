import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui/auth.dart';
import '../widgets/internal/universal_scaffold.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final FirebaseAuth? auth;
  final WidgetBuilder? subtitleBuilder;
  final WidgetBuilder? footerBuilder;
  final String? email;

  const ForgotPasswordScreen({
    Key? key,
    this.auth,
    this.email,
    this.subtitleBuilder,
    this.footerBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final child = ListView(
      shrinkWrap: true,
      children: [
        ForgotPasswordView(
          auth: auth,
          email: email,
          footerBuilder: footerBuilder,
          subtitleBuilder: subtitleBuilder,
        ),
      ],
    );

    return UniversalScaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 500) {
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: child,
                );
              } else {
                return child;
              }
            },
          ),
        ),
      ),
    );
  }
}
