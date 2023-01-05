// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import 'lang/en.dart';

/// An abstract class containing all labels that concrete languages should
/// provide.
///
/// The easiest way to override some of these labels is to provide
/// an object that extends [DefaultLocalizations] and pass it to the
/// [MaterialApp.localizationsDelegates].
///
/// ```dart
/// import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
///
/// class LabelOverrides extends DefaultLocalizations {
///   const LabelOverrides();
///
///   @override
///   String get emailInputLabel => 'Enter your email';
/// }
///
/// MaterialApp(
///   // ...
///   localizationsDelegates: [
///     FirebaseUILocalizations.withDefaultOverrides(const LabelOverrides()),
///     GlobalMaterialLocalizations.delegate,
///     GlobalWidgetsLocalizations.delegate,
///     FirebaseUILocalizations.delegate,
///   ],
/// )
/// ```
abstract class FirebaseUILocalizationLabels {
  const FirebaseUILocalizationLabels();

  /// Used as a label of the `EmailInput`.
  String get emailInputLabel;

  /// Used as a label of the `PasswordInput`.
  String get passwordInputLabel;

  /// Used as a label of the `EmailForm` submit button
  /// when the `AuthAction` is `AuthAction.signIn`.
  String get signInActionText;

  /// Used as a label of the `EmailForm` submit button
  /// when the `AuthAction` is `AuthAction.signUp`.
  String get registerActionText;

  /// Used as a label of the `EmailForm` submit button
  /// when the `AuthAction` is `AuthAction.link`.
  String get linkEmailButtonText;

  /// Used as a label of the `PhoneVerificationButton`.
  String get signInWithPhoneButtonText;

  /// Used as a label of the `OAuthProviderButton` for Google provider.
  String get signInWithGoogleButtonText;

  /// Used as a label of the `OAuthProviderButton` for Apple provider.
  String get signInWithAppleButtonText;

  /// Used as a label of the `OAuthProviderButton` for Facebook provider.
  String get signInWithFacebookButtonText;

  /// Used as a label of the `OAuthProviderButton` for Twitter provider.
  String get signInWithTwitterButtonText;

  /// Used as a title of the `PhoneInputView`.
  String get phoneVerificationViewTitleText;

  /// Used as a label of the submit button of the `PhoneInputView`.
  String get verifyPhoneNumberButtonText;

  /// Used as a label of the submit button of the `SMSCodeInputView`.
  String get verifyCodeButtonText;

  /// Used as a generic error message when unable to resolve error details
  /// from `Exception` or `FirebaseAuthException`.
  String get unknownError;

  /// Used as an error text when `AutoresolutionFailedException` is being
  /// thrown.
  String get smsAutoresolutionFailedError;

  /// Used as a status text of the `SMSCodeInput` when code verification is
  /// in progress.
  String get verifyingSMSCodeText;

  /// Used as a label of the `SMSCodeInput`.
  String get enterSMSCodeText;

  /// Used as an error text of the `EmailInput` when the email is empty.
  String get emailIsRequiredErrorText;

  /// Used as an error text of the `EmailInput` if the provided
  /// email is not valid.
  String get isNotAValidEmailErrorText;

  /// Used as an error message when the account for provided email was not
  /// found.
  String get userNotFoundErrorText;

  /// Used as an error message when the user tries to sign up with an email
  /// that is already used.
  String get emailTakenErrorText;

  /// Used as an error message when account is blocked and user tries to
  /// perform some actions with the account (e.g. unlinking a credential).
  String get accessDisabledErrorText;

  /// Used as an error text of the `PasswordInput` when provided password
  /// is empty or is not correct.
  String get wrongOrNoPasswordErrorText;

  /// Used as a title of the `LoginView` when `AuthAction` is
  /// `AuthAction.signIn`.
  String get signInText;

  /// Used as a title of the `LoginView` when `AuthAction` is
  /// `AuthAction.signUp`.
  String get registerText;

  /// Used as a hint text of the `LoginView` suggesting to create a new account.
  String get registerHintText;

  /// Used as a hint text of the `LoginView` suggesting to sign in instead of
  /// registering a new account.
  String get signInHintText;

  /// Used as a label of the `SignOutButton`.
  String get signOutButtonText;

  /// Used as a label of the `PhoneInput`.
  String get phoneInputLabel;

  /// Used as an error text when `PhoneInput` is empty.
  String get phoneNumberIsRequiredErrorText;

  /// Used as an error text when `PhoneInput` contains an invalid phone number.
  String get phoneNumberInvalidErrorText;

  /// A title of the `ProfileScreen`.
  String get profile;

  /// Used as a placeholder of the `EditableUserDisplayName`.
  String get name;

  /// Used as a label of the `DeleteAccountButton`.
  String get deleteAccount;

  /// Used as an error text when `PasswordInput` is empty.
  String get passwordIsRequiredErrorText;

  /// Used as an error text when `PasswordInput` used to confirm the password
  /// is empty.
  String get confirmPasswordIsRequiredErrorText;

  /// Used as an error text when provided passwords do not match.
  String get confirmPasswordDoesNotMatchErrorText;

  /// Used as a label of the `PasswordInput` that confirms a provided password.
  String get confirmPasswordInputLabel;

  /// Used as a label of the `ForgotPasswordButton`.
  String get forgotPasswordButtonLabel;

  /// Used as a title of the `ForgotPasswordView`.
  String get forgotPasswordViewTitle;

  /// Used as a label of submit button of the `ForgotPasswordView`.
  String get resetPasswordButtonLabel;

  /// Used as a title of the dialog that requires re-authentication of the
  /// user when performing destructive actions.
  String get verifyItsYouText;

  /// Used as a title of the dialog that indicates that there are
  /// different available sign in methods for a provided email.
  String get differentMethodsSignInTitleText;

  /// Used as a title of the `FindProvidersForEmailView`.
  String get findProviderForEmailTitleText;

  /// Used as a label of the submit button that takes the user to the next step
  /// of the authenticatiion flow.
  String get continueText;

  /// Used as a placeholder of the country code input.
  String get countryCode;

  /// Used as an error text when provide country code is invalid.
  String get invalidCountryCode;

  /// Used as a label of the country code picker dropdown.
  String get chooseACountry;

  /// Used as a hint to connect more providers.
  String get enableMoreSignInMethods;

  /// Used as a label of the row showing connected providers.
  String get signInMethods;

  /// Used as a title of the `EmailSignUpDialog`.
  String get provideEmail;

  /// Used as a label of the back button.
  String get goBackButtonLabel;

  /// Indicates that the password reset email was sent.
  String get passwordResetEmailSentText;

  /// Used as a hint on a `ForgotPasswordView`.
  String get forgotPasswordHintText;

  /// Used as a label of the `EmailLinkSignInButton`.
  String get emailLinkSignInButtonLabel;

  /// Used as a title on the `EmailLinkSignInView`.
  String get signInWithEmailLinkViewTitleText;

  /// Indicates that email with a sign in link was sent.
  String get signInWithEmailLinkSentText;

  /// Used as a label of the submit button on the `EmailLinkSignInView`.
  String get sendLinkButtonLabel;

  /// Error text that is show when user tries to use an OAuth provider that
  /// doesn't belong to currently signed in user account.
  String get credentialAlreadyInUseErrorText;

  /// Button label that suggests to disable 2FA.
  String get disable;

  /// Button label that suggests to enable 2FA.
  String get enable;

  /// 2-step verification settings tile title.
  String get mfaTitle;

  /// Label that suggests that 2-step verification is not enabled.
  String get off;

  /// Label that suggests that 2-step verification is enabled.
  String get on;

  // DataTable components
  String get valueLabel;
  String get typeLabel;
  String get stringLabel;
  String get numberLabel;
  String get booleanLabel;
  String get mapLabel;
  String get arrayLabel;
  String get nullLabel;
  String get cancelLabel;
  String get updateLabel;
  String get northInitialLabel;
  String get southInitialLabel;
  String get westInitialLabel;
  String get eastInitialLabel;
  String get timestampLabel;
  String get longitudeLabel;
  String get latitudeLabel;
  String get geopointLabel;
  String get referenceLabel;
}

class DefaultLocalizations extends EnLocalizations {
  const DefaultLocalizations();
}
