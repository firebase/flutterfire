import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

abstract class FlutterfireUIAuthAction {
  static T? ofType<T extends FlutterfireUIAuthAction>(BuildContext context) {
    final w =
        context.dependOnInheritedWidgetOfExactType<FlutterfireUIAuthActions>();

    if (w == null) return null;

    for (final action in w.actions) {
      if (action is T) return action;
    }

    return null;
  }
}

class AuthStateChange<T extends AuthState> extends FlutterfireUIAuthAction {
  final void Function(BuildContext context, T state) callback;
  AuthStateChange(this.callback);

  bool matches(AuthState state) => state is T;
  void invoke(BuildContext context, T state) => callback(context, state);
}

class SignedOut extends FlutterfireUIAuthAction {
  final void Function(BuildContext context) callback;
  SignedOut(this.callback);
}

class FlutterfireUIAuthActions extends InheritedWidget {
  final List<FlutterfireUIAuthAction> actions;

  const FlutterfireUIAuthActions({
    Key? key,
    required this.actions,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(FlutterfireUIAuthActions oldWidget) {
    return oldWidget.actions != actions;
  }

  @override
  InheritedElement createElement() {
    return FlutterfireUIAuthActionsElement(this);
  }
}

class FlutterfireUIAuthActionsElement extends InheritedElement {
  FlutterfireUIAuthActionsElement(InheritedWidget widget) : super(widget);

  @override
  FlutterfireUIAuthActions get widget =>
      super.widget as FlutterfireUIAuthActions;

  @override
  Widget build() {
    return AuthStateListener<AuthController>(
      listener: (oldState, newState, controller) {
        for (final action in widget.actions) {
          if (action is AuthStateChange && action.matches(newState)) {
            action.invoke(this, newState);
          }
        }
      },
      child: super.build(),
    );
  }
}
