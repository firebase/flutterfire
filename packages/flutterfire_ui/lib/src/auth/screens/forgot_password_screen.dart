import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui/auth.dart';
import '../widgets/internal/universal_scaffold.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final void Function(BuildContext context)? onEmailSent;

  const ForgotPasswordScreen({Key? key, this.onEmailSent}) : super(key: key);

  Future<void> _onEmailSent(BuildContext context) async {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final child = ForgotPasswordView(onEmailSent: onEmailSent ?? _onEmailSent);

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
