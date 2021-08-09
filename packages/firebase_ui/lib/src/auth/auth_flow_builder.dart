import 'package:firebase_ui/auth.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_controller.dart';
import 'auth_flow.dart';

typedef AuthFlowBuilderCallback<T extends AuthController> = Widget Function(
  BuildContext context,
  AuthState state,
  T ctrl,
  Widget? child,
);

typedef StateTransitionListener = void Function(
    AuthState oldState, AuthState newState);

class AuthFlowBuilder<T extends AuthController> extends StatefulWidget {
  final AuthFlow flow;
  final AuthFlowBuilderCallback<T>? builder;
  final Function(AuthCredential credential)? onComplete;
  final Widget? child;
  final StateTransitionListener? listener;

  const AuthFlowBuilder({
    Key? key,
    required this.flow,
    this.builder,
    this.onComplete,
    this.child,
    this.listener,
  }) : super(key: key);

  @override
  _AuthFlowBuilderState createState() => _AuthFlowBuilderState<T>();
}

class _AuthFlowBuilderState<T extends AuthController>
    extends State<AuthFlowBuilder> {
  AuthFlow get flow => widget.flow;
  @override
  AuthFlowBuilder<T> get widget => super.widget as AuthFlowBuilder<T>;
  Widget? get child => widget.child;

  AuthState? prevState;

  @override
  void initState() {
    prevState = flow.value;
    flow.addListener(onFlowStateChanged);

    super.initState();
  }

  void onFlowStateChanged() {
    widget.listener?.call(prevState!, flow.value);
    prevState = flow.value;
  }

  @override
  Widget build(BuildContext context) {
    return AuthControllerProvider(
      ctrl: flow,
      child: ValueListenableBuilder<AuthState>(
        valueListenable: flow,
        builder: (context, value, _) {
          return widget.builder?.call(context, value, flow as T, child) ??
              child!;
        },
      ),
    );
  }

  @override
  void dispose() {
    flow.removeListener(onFlowStateChanged);
    super.dispose();
  }
}
