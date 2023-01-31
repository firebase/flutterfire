// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_oauth/firebase_ui_oauth.dart';
import 'package:flutter/widgets.dart';

import 'src/actions.dart';
import 'src/oauth_providers.dart';
import 'src/providers/auth_provider.dart';

export 'src/actions.dart';
export 'src/auth_controller.dart' show AuthAction, AuthController;
export 'src/auth_flow.dart';
export 'src/auth_state.dart'
    show
        Uninitialized,
        FetchingProvidersForEmail,
        AuthStateListenerCallback,
        AuthState,
        AuthStateListener,
        CredentialLinked,
        CredentialReceived,
        SignedIn,
        SigningIn,
        UserCreated,
        AuthFailed,
        DifferentSignInMethodsFound,
        MFARequired;
export 'src/email_verification.dart';
export 'src/flows/email_flow.dart';
export 'src/flows/email_link_flow.dart';
export 'src/flows/oauth_flow.dart' show OAuthController, OAuthFlow;
export 'src/flows/phone_auth_flow.dart';
export 'src/flows/universal_email_sign_in_flow.dart';
// ignore_for_file: use_build_context_synchronously

export 'src/loading_indicator.dart';
export 'src/mfa.dart' show startMFAVerification;
export 'src/navigation/authentication.dart';
export 'src/navigation/forgot_password.dart';
export 'src/navigation/phone_verification.dart';
export 'src/oauth/provider_resolvers.dart' show providerIcon;
export 'src/oauth/social_icons.dart' show SocialIcons;
export 'src/oauth_providers.dart' show OAuthHelpers;
export 'src/providers/auth_provider.dart';
export 'src/providers/email_auth_provider.dart';
export 'src/providers/email_link_auth_provider.dart';
export 'src/providers/phone_auth_provider.dart';
export 'src/providers/universal_email_sign_in_provider.dart';
export 'src/screens/email_link_sign_in_screen.dart';
export 'src/screens/email_verification_screen.dart';
export 'src/screens/forgot_password_screen.dart';
export 'src/screens/internal/responsive_page.dart'
    show HeaderBuilder, SideBuilder;
export 'src/screens/phone_input_screen.dart';
export 'src/screens/profile_screen.dart' show ProfileScreen;
export 'src/screens/register_screen.dart';
export 'src/screens/sign_in_screen.dart';
export 'src/screens/sms_code_input_screen.dart';
export 'src/screens/universal_email_sign_in_screen.dart';
export 'src/styling/style.dart' show FirebaseUIStyle;
export 'src/styling/theme.dart' show FirebaseUITheme;
export 'src/views/different_method_sign_in_view.dart';
export 'src/views/email_link_sign_in_view.dart';
export 'src/views/find_providers_for_email_view.dart';
export 'src/views/forgot_password_view.dart';
export 'src/views/login_view.dart';
export 'src/views/phone_input_view.dart';
export 'src/views/reauthenticate_view.dart';
export 'src/views/sms_code_input_view.dart';
export 'src/widgets/auth_flow_builder.dart';
export 'src/widgets/delete_account_button.dart';
export 'src/widgets/different_method_sign_in_dialog.dart';
export 'src/widgets/editable_user_display_name.dart';
export 'src/widgets/email_form.dart'
    show EmailForm, ForgotPasswordAction, EmailFormStyle;
export 'src/widgets/email_input.dart';
export 'src/widgets/email_link_sign_in_button.dart';
export 'src/widgets/email_sign_up_dialog.dart';
export 'src/widgets/error_text.dart' show ErrorText;
export 'src/widgets/forgot_password_button.dart';
export 'src/widgets/internal/oauth_provider_button.dart'
    show OAuthProviderButton, OAuthButtonVariant;
export 'src/widgets/internal/universal_button.dart' show ButtonVariant;
export 'src/widgets/layout_flow_aware_padding.dart';
export 'src/widgets/password_input.dart';
export 'src/widgets/phone_input.dart' show PhoneInputState, PhoneInput;
export 'src/widgets/phone_verification_button.dart'
    show PhoneVerificationButton;
export 'src/widgets/reauthenticate_dialog.dart';
export 'src/widgets/sign_out_button.dart';
export 'src/widgets/sms_code_input.dart' show SMSCodeInputState, SMSCodeInput;
export 'src/widgets/user_avatar.dart';

class FirebaseUIAuth {
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

    final resolvedApp = app ?? Firebase.app();

    if (_configuredApps[resolvedApp] ?? false) {
      throw Exception(
        'You can only configure providers once '
        'for each Firebase App',
      );
    }

    _providers[resolvedApp] = configs;

    configs.whereType<OAuthProvider>().forEach((element) {
      final auth = FirebaseAuth.instanceFor(app: resolvedApp);
      OAuthProviders.register(auth, element);
    });
  }

  static Future<void> signOut({
    BuildContext? context,
    FirebaseAuth? auth,
  }) async {
    final resolvedAuth = auth ?? FirebaseAuth.instance;
    await OAuthProviders.signOut(resolvedAuth);
    await resolvedAuth.signOut();

    if (context != null) {
      final action = FirebaseUIAction.ofType<SignedOutAction>(context);
      action?.callback(context);
    }
  }
}
