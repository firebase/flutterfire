// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show AuthCredential, MultiFactorResolver, User, UserCredential;

/// An abstract class for all auth states.
/// [AuthState] transitions could be captured with an [AuthStateChangeAction]:
///
/// ```dart
/// SignInScreen(
///   actions: [
///     AuthStateChangeAction<SignedIn>((context, state) {
///       print(state.user!.displayName);
///       print(state.user!.emailVerified);
///     }),
///   ],
/// );
/// ```
///
/// You could also subscribe your widget to auth state transitions with
/// [AuthState.of]:
///
/// ```dart
/// AuthFlowBuilder<EmailAuthController>(
///   child: MyCustomWidget(),
/// );
///
///class MyCustomWidget extends StatelessWidget {
///  @override
///  Widget build(BuildContext context) {
///    final state = AuthState.of(context);
///
///    if (state is AwaitingEmailAndPassword) {
///      return EmailForm();
///    } else if (state is AuthFailed) {
///      return ErrorText(state);
///    } else if (state is SignedIn) {
///      return Text(state.user!.displayName);
///    } else {
///      return Text("Unknown state ${state.runtimeType}");
///    }
///  }
///}
/// ```
abstract class AuthState {
  const AuthState();

  /// Returns current [AuthState] of the auth flow.
  /// Should be used only inside the widget that has an [AuthFlowBuilder] as
  /// an ancestor. Use [maybeOf] if there is a chance that the widget is used
  /// without [AuthFlowBuilder] as an ancestor.
  static AuthState of(BuildContext context) => maybeOf(context)!;

  /// Returns current [AuthState] of the auth flow.
  /// Could return null if no [AuthFlowBuilder] was found up  the widget tree.
  ///
  /// See [AuthFlowBuilder] for more examples.
  static AuthState? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuthStateProvider>()?.state;
}

/// {@template ui.auth.auth_state.uninitialized}
/// A default [AuthState] for many auth flows.
/// {@endtemplate}
class Uninitialized extends AuthState {
  /// {@macrp ffui.auth.auth_state.uninitialized}
  const Uninitialized();
}

/// {@template ui.auth.auth_state.signing_in}
/// Indicates that sign in is in progress.
/// Could be used to reflect the loading state on the ui.
///
/// See [AuthState] docs for usage examples.
/// {@endtemplate}
class SigningIn extends AuthState {
  /// {@macro ui.auth.auth_state.signing_in}
  const SigningIn();
}

/// {@template ui.auth.auth_state.credential_received}
/// Indicates that the auth credential was successfully received.
/// This is an intermediate state that should transition to either [SignedIn],
/// [CredentialLinked] or [AuthFailed] depending on [AuthAction].
/// Could be used to reflect the loading state on the ui.
///
/// See [AuthState] docs for usage examples.
/// {@endtemplate}
class CredentialReceived extends AuthState {
  /// A credential that was received during auth flow.
  final AuthCredential credential;

  CredentialReceived(this.credential);
}

/// {@template ui.auth.auth_state.credential_linked}
/// Indicates that the auth credential was successfully linked with the
/// currently signed in user account.
///
/// See [AuthState] docs for usage examples.
/// {@endtemplate}
class CredentialLinked extends AuthState {
  /// A credential that was linked with the currently signed in user account.
  final AuthCredential credential;

  /// An instance of the [User] the credential was associated with.
  final User user;

  /// {@macro ui.auth.auth_state.credential_linked}
  CredentialLinked(this.credential, this.user);
}

/// {@template ui.auth.auth_state.auth_failed}
/// An [AuthState] that indicates that something went wrong during
/// authentication.
///
/// See [AuthState] docs for usage examples.
/// {@endtemplate}
class AuthFailed extends AuthState {
  /// The error that occurred during authentication.
  /// Often this is an instance of [FirebaseAuthException] that might contain
  /// more details about the error.
  ///
  /// There is an [ErrorText] widget that can be used to display error details
  /// in human readable form.
  final Exception exception;

  /// {@macro ui.auth.auth_state.auth_failed}
  AuthFailed(this.exception);
}

/// {@template ui.auth.auth_state.signed_in}
/// An [AuthState] that indicates that the user has successfully signed in.
///
/// See [AuthState] docs for usage examples.
/// {@endtemplate}
class SignedIn extends AuthState {
  /// An instance of the [User] that was signed in.
  final User? user;

  /// {@macro ui.auth.auth_state.signed_in}
  SignedIn(this.user);
}

/// A state that indicates that a new user account was created.
class UserCreated extends AuthState {
  /// A [UserCredential] that was obtained during authentication process.
  final UserCredential credential;

  UserCreated(this.credential);
}

/// {@template ui.auth.auth_state.different_sign_in_methods_found}
/// An [AuthState] that indicates that there are different auth providers
/// associated with an email that was used to authenticate.
///
/// See [AuthState] docs for usage examples.
/// {@endtemplate}
class DifferentSignInMethodsFound extends AuthState {
  /// An email that has different auth providers associated with.
  final String email;

  /// An instance of the auth credential that was obtained during sign in flow.
  /// Could be used to link with the user account after a sign in using on of
  /// the available [methods].
  final AuthCredential? credential;

  /// A list of provider ids that were found for the [email].
  final List<String> methods;

  /// {@macro ui.auth.auth_state.different_sign_in_methods_found}
  DifferentSignInMethodsFound(this.email, this.methods, this.credential);
}

/// {@template ui.auth.auth_state.fetching_providers_for_email}
/// An [AuthState] that indicates that there is a lookup of available providers
/// for an email in progress.
///
/// See [AuthState] docs for usage examples.
/// {@endtemplate}
class FetchingProvidersForEmail extends AuthState {
  /// {@macro ui.auth.auth_state.fetching_providers_for_email}
  const FetchingProvidersForEmail();
}

/// {@template ui.auth.auth_state.mfa_required}
/// An [AuthState] that indicates that multi-factor authentication is required.
/// {@endtemplate}
class MFARequired extends AuthState {
  /// A multi-factor resolver that should be used to complete MFA.
  final MultiFactorResolver resolver;

  const MFARequired(this.resolver);
}

class AuthStateProvider extends InheritedWidget {
  final AuthState state;

  const AuthStateProvider({
    Key? key,
    required this.state,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(AuthStateProvider oldWidget) {
    return state != oldWidget.state;
  }
}

/// {@template ui.auth.auth_state.auth_state_transition}
/// A sub-type of the [Notification] that is used to notify about auth state
/// transitions. You could use [NotificationListener], but it is recommended
/// to use [AuthStateListener] instead.
/// {@endtemplate}
class AuthStateTransition<T extends AuthController> extends Notification {
  /// Previous [AuthState].
  final AuthState from;

  /// Current [AuthState].
  final AuthState to;

  /// An instance of [AuthController] that could be used to perform further
  /// actions of the auth flow.
  final T controller;

  /// {@macro ui.auth.auth_state.auth_state_transition}}
  AuthStateTransition(this.from, this.to, this.controller);
}

typedef AuthStateListenerCallback<T extends AuthController> = bool? Function(
  AuthState oldState,
  AuthState state,
  T controller,
);

/// {@template ui.auth.auth_state.auth_state_listener}
/// A [Widget] that could be used to listen auth state transitions.
///
/// For example, you could show a snackbar when some error occurs:
///
/// ```dart
/// AuthStateListener<EmailAuthController>(
///   child: LoginView(
///     actions: AuthAction.signIn,
///     providers: [EmailAuthProvider()],
///   ),
///   listener: (oldState, state, controller) {
///     if (state is AuthFailed) {
///       ScaffoldMessenger.of(context).showSnackBar(
///         SnackBar(content: ErrorText(exception: state.exception),
///       );
///     }
///   }
/// )
/// ```
/// {@endtemplate}
class AuthStateListener<T extends AuthController> extends StatelessWidget {
  final Widget child;
  final AuthStateListenerCallback<T> listener;

  const AuthStateListener({
    Key? key,
    required this.child,
    required this.listener,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (notification) {
        if (notification is! AuthStateTransition<T>) {
          return false;
        }

        return listener(
              notification.from,
              notification.to,
              notification.controller,
            ) ??
            false;
      },
      child: child,
    );
  }
}
