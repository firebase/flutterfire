import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/cupertino.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutter/material.dart';
import '../widgets/internal/universal_button.dart';

/// {@template ffui.auth.widgets.phone_verification_button}
/// A button that triggers phone verification flow.
///
/// Triggers a [VerifyPhoneAction] action if provided, otherwise
/// uses [startPhoneVerification].
/// {@endtemplate}
class PhoneVerificationButton extends StatelessWidget {
  /// {@macro ffui.auth.auth_controller.auth}
  final FirebaseAuth? auth;

  /// {@macro ffui.auth.auth_action}
  final AuthAction? action;

  /// A text that should be displayed on the button.
  final String label;

  /// {@macro ffui.auth.widgets.phone_verification_button}
  const PhoneVerificationButton({
    Key? key,
    required this.label,
    this.action,
    this.auth,
  }) : super(key: key);

  void _onPressed(BuildContext context) {
    final _action = FlutterFireUIAction.ofType<VerifyPhoneAction>(context);
    if (_action != null) {
      _action.callback(context, action);
    } else {
      startPhoneVerification(context: context, action: action, auth: auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return UniversalButton(
      variant: ButtonVariant.text,
      text: label,
      onPressed: () => _onPressed(context),
    );
  }
}
