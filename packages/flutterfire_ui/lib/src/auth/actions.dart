import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

/// An abstract class that all actions implement.
/// The following actions are available:
/// - [AuthStateChangeAction]
/// - [SignedOutAction]
/// - [AuthCancelledAction]
/// - [EmailLinkSignInAction]
/// - [VerifyPhoneAction]
/// - [SMSCodeRequestedAction]
/// - [EmailVerifiedAction]
/// - [ForgotPasswordAction]
abstract class FlutterFireUIAction {
  /// Looks up an instance of an action of the type [T] provided
  /// via [FlutterFireUIActions].
  static T? ofType<T extends FlutterFireUIAction>(BuildContext context) {
    final w = FlutterFireUIActions.maybeOf(context);

    if (w == null) return null;

    for (final action in w.actions) {
      if (action is T) return action;
    }

    return null;
  }
}

/// {@template ffui.auth.actions.auth_state_change_action}
/// An action that is called when auth state changes.
/// You can capture any type of [AuthState] using this action.
///
/// For example, you can perform navigation after user has signed in:
///
/// ```dart
/// SignInScreen(
///   actions: [
///     AuthStateChangeAction<SignedIn>((context, state) {
///       Navigator.pushReplacementNamed(context, '/home');
///     }),
///   ],
/// );
/// ```
/// {@endtemplate}
class AuthStateChangeAction<T extends AuthState> extends FlutterFireUIAction {
  /// A callback that is being called when underlying auth flow transitioned to
  /// a state of type [T].
  final void Function(BuildContext context, T state) callback;

  /// {@macro ffui.auth.actions.auth_state_change_action}
  AuthStateChangeAction(this.callback);

  /// Verifies that a current [state] is a [T]
  bool matches(AuthState state) => state is T;

  /// Invokes the callback with the provided [context] and [state].
  void invoke(BuildContext context, T state) => callback(context, state);
}

/// {@template ffui.auth.actions.signed_out_action}
/// An action that is being called when user has signed out.
/// {@endtemplate}
class SignedOutAction extends FlutterFireUIAction {
  /// A callback that is being called when user has signed out.
  final void Function(BuildContext context) callback;

  /// {@macro ffui.auth.actions.signed_out_action}
  SignedOutAction(this.callback);
}

/// {@template ffui.auth.actions.cancel}
/// An action that is being called when user has cancelled an auth action.
/// {@endtemplate}
class AuthCancelledAction extends FlutterFireUIAction {
  /// A callback that is being called when user has cancelled an auth action.
  final void Function(BuildContext context) callback;

  /// {@macro ffui.auth.actions.cancel}
  AuthCancelledAction(this.callback);
}

/// {@template ffui.auth.actions.flutter_fire_ui_actions}
/// An inherited widget that provides a list of actions down the widget tree.
/// {@endtemplate}
class FlutterFireUIActions extends InheritedWidget {
  /// A list of [FlutterFireUIAction]s that will be provided to the descendant
  /// widgets.
  final List<FlutterFireUIAction> actions;

  /// Looks up an instance of [FlutterFireUIActions] in the widget tree.
  static FlutterFireUIActions? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FlutterFireUIActions>();
  }

  /// Inherits a list of actions from the context and provides those to the
  /// [child].
  static Widget inherit({
    /// A [BuildContext] to inherit from.
    required BuildContext from,

    /// A [Widget] to wrap with [FlutterFireUIActions].
    required Widget child,
  }) {
    final w = maybeOf(from);

    if (w != null) {
      return FlutterFireUIActions(actions: w.actions, child: child);
    }

    return child;
  }

  /// {@macro ffui.auth.actions.flutter_fire_ui_actions}
  const FlutterFireUIActions({
    Key? key,
    required this.actions,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(FlutterFireUIActions oldWidget) {
    return oldWidget.actions != actions;
  }

  @override
  InheritedElement createElement() {
    return _FlutterfireUIAuthActionsElement(this);
  }
}

class _FlutterfireUIAuthActionsElement extends InheritedElement {
  _FlutterfireUIAuthActionsElement(InheritedWidget widget) : super(widget);

  @override
  FlutterFireUIActions get widget => super.widget as FlutterFireUIActions;

  @override
  Widget build() {
    return AuthStateListener<AuthController>(
      listener: (oldState, newState, controller) {
        for (final action in widget.actions) {
          if (action is AuthStateChangeAction && action.matches(newState)) {
            action.invoke(this, newState);
          }
        }

        return null;
      },
      child: super.build(),
    );
  }
}
