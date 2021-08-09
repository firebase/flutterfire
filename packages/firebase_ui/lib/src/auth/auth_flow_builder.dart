import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_controller.dart';
import 'auth_flow.dart';

typedef AuthFlowBuilderCallback<T extends AuthController> = Widget Function(
  BuildContext context,
  AuthState state,
  T ctrl,
);

class AuthFlowBuilder<T extends AuthController> extends StatefulWidget {
  final AuthFlow flow;
  final FirebaseAuth auth;
  final AuthFlowBuilderCallback<T> builder;
  final Function(AuthCredential credential) onComplete;

  const AuthFlowBuilder({
    Key? key,
    required this.flow,
    required this.auth,
    required this.builder,
    required this.onComplete,
  }) : super(key: key);

  @override
  _AuthFlowBuilderState createState() => _AuthFlowBuilderState<T>();
}

class _AuthFlowBuilderState<T extends AuthController>
    extends State<AuthFlowBuilder> {
  AuthFlow get flow => widget.flow;

  @override
  void initState() {
    flow.auth = widget.auth;
    flow.credentials.then(widget.onComplete);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthState>(
      valueListenable: flow,
      builder: (context, value, _) {
        return widget.builder(context, value, flow as T);
      },
    );
  }
}
