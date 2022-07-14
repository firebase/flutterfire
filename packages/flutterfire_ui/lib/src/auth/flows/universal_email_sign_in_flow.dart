import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterfire_ui/auth.dart';

/// A controller interface of the [UniversalEmailSignInFlow].
abstract class UniversalEmailSignInController extends AuthController {
  /// {@template ffui.auth.auth_controller.find_providers_for_email}
  /// Finds providers that can be used to sign in with a provided email.
  /// Calls [AuthListener.onBeforeProvidersForEmailFetch], if request succeded –
  /// [AuthListener.onDifferentProvidersFound] is called and
  /// [AuthListener.onError] if failed.
  /// {@endtemplate}
  void findProvidersForEmail(String email);
}

/// {@template ffui.auth.flows.universal_email_sign_in_flow}
/// An auth flow that resolves providers that are accosicatied with the given
/// email.
/// {@endtemplate}
class UniversalEmailSignInFlow extends AuthFlow<UniversalEmailSignInProvider>
    implements UniversalEmailSignInController, UniversalEmailSignInListener {
  // {@macro ffui.auth.flows.universal_email_sign_in_flow}
  UniversalEmailSignInFlow({
    /// {@macro ffui.auth.auth_flow.ctor.provider}
    required UniversalEmailSignInProvider provider,

    /// {@macro ffui.auth.auth_controller.auth}
    FirebaseAuth? auth,

    /// {@macro @macro ffui.auth.auth_action}
    AuthAction? action,
  }) : super(
          initialState: const Uninitialized(),
          provider: provider,
          auth: auth,
          action: action,
        );

  @override
  void findProvidersForEmail(String email) {
    provider.findProvidersForEmail(email);
  }
}
