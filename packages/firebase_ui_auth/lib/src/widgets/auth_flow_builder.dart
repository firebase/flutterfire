// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show AuthCredential, FirebaseAuth;
import 'package:firebase_ui_oauth/firebase_ui_oauth.dart';

import '../auth_controller.dart';
import '../auth_state.dart';

/// {@template ui.auth.widgets.auth_flow_builder.auth_flow_builder_callback}
/// A callback that is being called every time the [AuthFlow] changes it's
/// state. Returned widget is rendered as a child of [AuthFlowBuilder].
/// {@endtemplate}
typedef AuthFlowBuilderCallback<T extends AuthController> = Widget Function(
  BuildContext context,

  /// Current [AuthState] of the [AuthFlow].
  AuthState state,

  /// An instance of [AuthController] that could be used to control the
  /// [AuthFlow].
  T ctrl,

  /// A [Widget] that was provided to the [AuthFlowBuilder].
  Widget? child,
);

/// {@template ui.auth.widgets.auth_flow_builder.state_transition_listener}
/// A callback that is being called when [AuthFlow] changes it's state.
///
/// Invoked before the widget is built.
/// {@endtemplate}
typedef StateTransitionListener<T extends AuthController> = void Function(
  /// Previous state of the [AuthFlow].
  AuthState oldState,

  /// Current state of the [AuthFlow].
  AuthState newState,

  /// An instance of the [AuthController] that could be used to manipulate the
  /// [AuthFlow].
  T controller,
);

/// {@template ui.auth.widgets.auth_flow_builder}
/// A widget that is used to wire up the [AuthFlow]s with the widget tree.
///
/// Could be used to build a custom UI and facilitate the built-in functionality
/// of the all available [AuthFlow]s:
///
/// * [EmailAuthFlow]
/// * [EmailLinkFlow]
/// * [OAuthFlow]
/// * [PhoneAuthFlow]
/// * [UniversalEmailSignInFlow].
///
/// An example of how to build a custom email sign up form using
/// [AuthFlowBuilder]:
///
/// ```dart
/// final emailCtrl = TextEditingController();
/// final passwordCtrl = TextEditingController();
///
/// AuthFlowBuilder<EmailAuthController>(
///   auth: FirebaseAuth.instance,
///   action: AuthAction.signUp,
///   listener: (oldState, newState, ctrl) {
///     if (newState is UserCreated) {
///       Navigator.of(context).pushReplacementNamed('/profile');
///     }
///   },
///   builder: (context, state, ctrl, child) {
///     if (state is AwaitingEmailAndPassword) {
///       return Column(
///         children: [
///           TextField(
///             decoration: InputDecoration(labelText: 'Email'),
///             controller: emailCtrl,
///           ),
///           TextField(
///             decoration: InputDecoration(labelText: 'Password'),
///             controller: passwordCtrl,
///           ),
///           OutlinedButton(
///             child: Text('Sign Up'),
///             onPressed: () {
///               ctrl.setEmailAndPassword(emailCtrl.text, passwordCtrl.text);
///             }
///           ),
///         ]
///       );
///     } else if (state is SigningIn) {
///       return Center(child: CircularProgressIndicator());
///     } else if (state is AuthFailed) {
///       return ErrorText(exception: state.exception);
///     }
///   }
/// )
/// ```
/// {@endtemplate}
class AuthFlowBuilder<T extends AuthController> extends StatefulWidget {
  static final _flows = <Object, AuthFlow>{};

  /// Resolves an [AuthController] by the [flowKey].
  static T? getController<T extends AuthController>(Object flowKey) {
    final flow = _flows[flowKey];
    if (flow == null) return null;
    return flow as T;
  }

  /// Returns a current [AuthState] of the [AuthFlow] given the [flowKey].
  static AuthState? getState(Object flowKey) {
    final flow = _flows[flowKey];
    if (flow == null) return null;
    return flow.value;
  }

  /// A unique object that is used as a key for an [AuthFlow].
  /// Could be used to obtain a controller via [getController] or
  /// to read a current state using [getState].
  final Object? flowKey;

  /// {@macro ui.auth.auth_controller.auth}
  final FirebaseAuth? auth;

  /// {@macro ui.auth.auth_action}
  final AuthAction? action;

  /// An optional instance of the [AuthProvider] that should be used to
  /// authenticate. If not provided, a default instance of the [AuthProvider]
  /// will be created. A type of provider is resolved by the type of the
  /// [AuthController] provided to the [AuthFlowBuilder].
  ///
  /// The following providers are optional to provide:
  /// * [EmailAuthController]
  /// * [PhoneAuthController]
  /// * [UniversalEmailSignInController]
  final AuthProvider? provider;

  /// An optional instance of the [AuthFlow].
  /// Should be rarely provided, as the [AuthFlow] is created automatically,
  /// based on [provider].
  final AuthFlow? flow;

  /// {@macro ui.auth.widgets.auth_flow_builder.auth_flow_builder_callback}
  final AuthFlowBuilderCallback<T>? builder;

  /// A pre-built child that will be provided as an argument of the [builder].
  final Widget? child;

  /// A callback that is being called when the auth flow completes.
  final Function(AuthCredential credential)? onComplete;

  /// {@macro ui.auth.widgets.auth_flow_builder.state_transition_listener}
  final StateTransitionListener<T>? listener;

  /// {@macro ui.auth.widgets.auth_flow_builder}
  const AuthFlowBuilder({
    Key? key,
    this.flowKey,
    this.action,
    this.builder,
    this.onComplete,
    this.child,
    this.listener,
    this.provider,
    this.auth,
    this.flow,
  })  : assert(
          builder != null || child != null,
          'Either child or builder should be provided',
        ),
        super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AuthFlowBuilderState createState() => _AuthFlowBuilderState<T>();
}

class _AuthFlowBuilderState<T extends AuthController>
    extends State<AuthFlowBuilder> {
  @override
  AuthFlowBuilder<T> get widget => super.widget as AuthFlowBuilder<T>;
  AuthFlowBuilderCallback<T> get builder => widget.builder ?? _defaultBuilder;

  AuthState? prevState;

  late AuthFlow flow;
  late AuthAction action;

  bool initialized = false;

  late AuthProvider provider = widget.provider ?? _createDefaultProvider();

  Widget _defaultBuilder(_, __, ___, ____) {
    return widget.child!;
  }

  @override
  void initState() {
    super.initState();
    provider.auth = widget.auth ?? FirebaseAuth.instance;

    flow = widget.flow ?? createFlow();

    if (widget.flowKey != null) {
      AuthFlowBuilder._flows[widget.flowKey!] = flow;

      flow.onDispose = () {
        AuthFlowBuilder._flows.remove(widget.flowKey);
      };
    }

    action = widget.action ??
        (flow.auth.currentUser != null ? AuthAction.link : AuthAction.signIn);

    flow.addListener(onFlowStateChanged);
    prevState = flow.value;
    initialized = true;
  }

  AuthProvider _createDefaultProvider() {
    switch (T) {
      case EmailAuthController:
        return EmailAuthProvider();
      case PhoneAuthController:
        return PhoneAuthProvider();
      case UniversalEmailSignInController:
        return UniversalEmailSignInProvider();
      default:
        throw Exception("Can't create $T provider");
    }
  }

  AuthFlow createFlow() {
    if (widget.flowKey != null) {
      final existingFlow = AuthFlowBuilder._flows[widget.flowKey!];
      if (existingFlow != null) {
        return existingFlow;
      }
    }

    final provider = this.provider;

    if (provider is EmailAuthProvider) {
      return EmailAuthFlow(
        provider: provider,
        action: widget.action,
        auth: widget.auth,
      );
    } else if (provider is EmailLinkAuthProvider) {
      return EmailLinkFlow(
        provider: provider,
        auth: widget.auth,
      );
    } else if (provider is OAuthProvider) {
      return OAuthFlow(
        provider: provider,
        action: widget.action,
        auth: widget.auth,
      );
    } else if (provider is PhoneAuthProvider) {
      return PhoneAuthFlow(
        provider: provider,
        action: widget.action,
        auth: widget.auth,
      );
    } else if (provider is UniversalEmailSignInProvider) {
      return UniversalEmailSignInFlow(
        provider: provider,
        action: widget.action,
        auth: widget.auth,
      );
    } else {
      throw Exception('Unknown provider $provider');
    }
  }

  void onFlowStateChanged() {
    AuthStateTransition(prevState!, flow.value, flow as T).dispatch(context);
    widget.listener?.call(prevState!, flow.value, flow as T);
    prevState = flow.value;
  }

  @override
  void didUpdateWidget(covariant AuthFlowBuilder<AuthController> oldWidget) {
    flow.action = widget.action ?? action;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
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

    if (widget.flowKey == null && widget.flow == null) {
      flow.reset();
    }

    super.dispose();
  }
}
