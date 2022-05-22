export 'src/loading_indicator.dart';
export 'src/auth/widgets/auth_flow_builder.dart';
export 'src/auth/auth_controller.dart' show AuthAction, AuthController;
export 'src/auth/auth_state.dart'
    show
        AuthState,
        AuthStateListener,
        CredentialLinked,
        CredentialReceived,
        SignedIn,
        SigningIn,
        AuthFailed,
        DifferentSignInMethodsFound;

export 'src/auth/providers/auth_provider.dart';
export 'src/auth/providers/email_auth_provider.dart';
export 'src/auth/providers/email_link_auth_provider.dart';
export 'src/auth/providers/phone_auth_provider.dart';
export 'src/auth/providers/universal_email_sign_in_provider.dart';

export 'src/auth/flows/phone_auth_flow.dart';
export 'src/auth/flows/email_link_flow.dart';
export 'src/auth/flows/universal_email_sign_in_flow.dart';

export 'src/auth/widgets/phone_input.dart' show PhoneInputState, PhoneInput;

export 'src/auth/widgets/sms_code_input.dart'
    show SMSCodeInputState, SMSCodeInput;

export 'src/auth/flows/email_flow.dart';
export 'src/auth/flows/oauth_flow.dart' show OAuthController, OAuthFlow;

export 'src/auth/oauth/social_icons.dart' show SocialIcons;
export 'src/auth/oauth/provider_resolvers.dart' show providerIcon;
export 'src/auth/oauth_providers.dart' show OAuthHelpers;

export 'src/auth/widgets/auth_flow_builder.dart';
export 'src/auth/widgets/email_form.dart'
    show EmailForm, ForgotPasswordAction, EmailFormStyle;
export 'src/auth/widgets/error_text.dart' show ErrorText;
export 'src/auth/widgets/phone_verification_button.dart'
    show PhoneVerificationButton;

export 'src/auth/widgets/internal/oauth_provider_button.dart'
    show OAuthProviderButton, OAuthProviderIconButton, OAuthButtonVariant;

export 'src/auth/widgets/sign_out_button.dart';
export 'src/auth/widgets/user_avatar.dart';
export 'src/auth/widgets/editable_user_display_name.dart';
export 'src/auth/widgets/delete_account_button.dart';
export 'src/auth/widgets/email_input.dart';
export 'src/auth/widgets/password_input.dart';
export 'src/auth/widgets/forgot_password_button.dart';
export 'src/auth/widgets/reauthenticate_dialog.dart';
export 'src/auth/widgets/different_method_sign_in_dialog.dart';
export 'src/auth/widgets/email_sign_up_dialog.dart';
export 'src/auth/widgets/apple_sign_in_button.dart';
export 'src/auth/widgets/facebook_sign_in_button.dart';
export 'src/auth/widgets/google_sign_in_button.dart';
export 'src/auth/widgets/twitter_sign_in_button.dart';

export 'src/auth/views/login_view.dart';
export 'src/auth/views/phone_input_view.dart';
export 'src/auth/views/sms_code_input_view.dart';
export 'src/auth/views/reauthenticate_view.dart';
export 'src/auth/views/forgot_password_view.dart';
export 'src/auth/views/different_method_sign_in_view.dart';
export 'src/auth/views/find_providers_for_email_view.dart';
export 'src/auth/views/email_link_sign_in_view.dart';

export 'src/auth/screens/internal/responsive_page.dart'
    show HeaderBuilder, SideBuilder;
export 'src/auth/screens/phone_input_screen.dart';
export 'src/auth/screens/sms_code_input_screen.dart';
export 'src/auth/screens/sign_in_screen.dart';
export 'src/auth/screens/register_screen.dart';
export 'src/auth/screens/profile_screen.dart' show ProfileScreen;
export 'src/auth/screens/forgot_password_screen.dart';
export 'src/auth/screens/universal_email_sign_in_screen.dart';
export 'src/auth/screens/email_link_sign_in_screen.dart';
export 'src/auth/screens/email_verification_screen.dart';

export 'src/auth/navigation/phone_verification.dart';
export 'src/auth/navigation/forgot_password.dart';
export 'src/auth/navigation/authentication.dart';
export 'src/auth/actions.dart';
export 'src/auth/email_verification.dart';

export 'src/auth/styling/theme.dart' show FlutterFireUITheme;
export 'src/auth/styling/style.dart' show FlutterFireUIStyle;
export 'src/auth/widgets/internal/universal_button.dart' show ButtonVariant;

import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui_oauth/flutterfire_ui_oauth.dart';

import 'src/auth/actions.dart';
import 'src/auth/oauth_providers.dart';
import 'src/auth/providers/auth_provider.dart';

class FlutterFireUIAuth {
  static final _providers = <FirebaseApp, List<AuthProvider>>{};
  static final _configuredApps = <FirebaseApp, bool>{};

  static List<AuthProvider> providersFor(FirebaseApp app) {
    return _providers[app] ?? [];
  }

  static bool isAppConfigured(FirebaseApp app) {
    return _providers.containsKey(app);
  }

  static void configureProviders(
    List<AuthProvider> configs, {
    FirebaseApp? app,
  }) {
    if (Firebase.apps.isEmpty) {
      throw Exception(
        'You must call Firebase.initializeApp() '
        'before calling configureProviders()',
      );
    }

    final _app = app ?? Firebase.app();

    if (_configuredApps[_app] ?? false) {
      throw Exception(
        'You can only configure providers once '
        'for each Firebase App',
      );
    }

    _providers[_app] = configs;

    configs.whereType<OAuthProvider>().forEach((element) {
      final auth = FirebaseAuth.instanceFor(app: _app);
      OAuthProviders.register(auth, element);
    });
  }

  static Future<void> signOut({
    BuildContext? context,
    FirebaseAuth? auth,
  }) async {
    final _auth = auth ?? FirebaseAuth.instance;
    await OAuthProviders.signOut(_auth);
    await _auth.signOut();

    if (context != null) {
      final action = FlutterFireUIAction.ofType<SignedOutAction>(context);
      action?.callback(context);
    }
  }
}
