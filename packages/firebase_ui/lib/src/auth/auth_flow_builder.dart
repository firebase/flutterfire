import 'package:firebase_ui/firebase_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart' show AuthCredential;

import 'auth_controller.dart';
import 'auth_flow.dart';
import 'auth_state.dart';

typedef AuthFlowBuilderCallback<T extends AuthController> = Widget Function(
  BuildContext context,
  AuthState state,
  T ctrl,
  Widget? child,
);

typedef StateTransitionListener<T extends AuthController> = void Function(
  AuthState oldState,
  AuthState newState,
  T controller,
);

class AuthFlowBuilder<T extends AuthController> extends StatefulWidget {
  final AuthFlowBuilderCallback<T>? builder;
  final AuthAction? action;
  final Function(AuthCredential credential)? onComplete;
  final Widget? child;
  final StateTransitionListener? listener;

  const AuthFlowBuilder({
    Key? key,
    this.action,
    this.builder,
    this.onComplete,
    this.child,
    this.listener,
  })  : assert(
          builder != null || child != null,
          'Either child or builder should be provided',
        ),
        super(key: key);

  @override
  _AuthFlowBuilderState createState() => _AuthFlowBuilderState<T>();
}

class _AuthFlowBuilderState<T extends AuthController>
    extends State<AuthFlowBuilder> with InitializerProvider {
  @override
  AuthFlowBuilder<T> get widget => super.widget as AuthFlowBuilder<T>;
  AuthFlowBuilderCallback<T> get builder => widget.builder ?? _defaultBuilder;

  AuthState? prevState;

  late AuthFlow flow;
  late AuthAction action;

  bool initialized = false;

  Widget _defaultBuilder(_, __, ___, ____) {
    return widget.child!;
  }

  void initializeFlow() {
    if (initialized) return;

    final initializer =
        getInitializerOfType<FirebaseUIAuthInitializer>(context);

    if (widget.action == null) {
      action = widget.action!;
    } else if (initializer.auth.currentUser == null) {
      action = AuthAction.signIn;
    } else {
      action = AuthAction.link;
    }

    flow = initializer.createFlow<T>(action);

    flow.context = context;
    flow.addListener(onFlowStateChanged);

    prevState = flow.value;
    initialized = true;
  }

  void onFlowStateChanged() {
    widget.listener?.call(prevState!, flow.value, flow);
    prevState = flow.value;
  }

  @override
  void didUpdateWidget(covariant AuthFlowBuilder<AuthController> oldWidget) {
    flow.action = widget.action ?? action;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    initializeFlow();

    return AuthControllerProvider(
      action: flow.action,
      ctrl: flow,
      child: ValueListenableBuilder<AuthState>(
        valueListenable: flow,
        builder: (context, value, _) {
          final child = builder(
            context,
            value,
            flow as T,
            widget.child,
          );

          return AuthStateProvider(state: value, child: child);
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
