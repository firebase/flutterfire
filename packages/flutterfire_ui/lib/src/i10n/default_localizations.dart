import 'package:flutterfire_ui/src/i10n/lang/es.dart';

import 'lang/en.dart';
import '../i10n/lang/ar.dart';
import 'lang/fr.dart';

abstract class FlutterFireUILocalizationLabels {
  const FlutterFireUILocalizationLabels();

  String get emailInputLabel;
  String get passwordInputLabel;
  String get signInActionText;
  String get registerActionText;

  String get signInButtonText;
  String get registerButtonText;
  String get linkEmailButtonText;

  String get signInWithPhoneButtonText;
  String get signInWithGoogleButtonText;
  String get signInWithAppleButtonText;
  String get signInWithFacebookButtonText;
  String get signInWithTwitterButtonText;
  String get phoneVerificationViewTitleText;
  String get verifyPhoneNumberButtonText;
  String get verifyCodeButtonText;
  String get verifyingPhoneNumberViewTitle;
  String get unknownError;
  String get smsAutoresolutionFailedError;
  String get smsCodeSentText;
  String get sendingSMSCodeText;
  String get verifyingSMSCodeText;
  String get enterSMSCodeText;
  String get emailIsRequiredErrorText;
  String get isNotAValidEmailErrorText;
  String get userNotFoundErrorText;
  String get emailTakenErrorText;
  String get accessDisabledErrorText;
  String get wrongOrNoPasswordErrorText;
  String get signInText;
  String get registerText;
  String get registerHintText;
  String get signInHintText;
  String get signOutButtonText;
  String get phoneInputLabel;
  String get phoneNumberIsRequiredErrorText;
  String get phoneNumberInvalidErrorText;
  String get profile;
  String get name;
  String get deleteAccount;
  String get passwordIsRequiredErrorText;
  String get confirmPasswordIsRequiredErrorText;
  String get confirmPasswordDoesNotMatchErrorText;
  String get confirmPasswordInputLabel;
  String get forgotPasswordButtonLabel;
  String get forgotPasswordViewTitle;
  String get resetPasswordButtonLabel;
  String get verifyItsYouText;
  String get differentMethodsSignInTitleText;
  String get findProviderForEmailTitleText;
  String get continueText;
  String get countryCode;
  String get codeRequiredErrorText;
  String get invalidCountryCode;
  String get chooseACountry;
  String get enableMoreSignInMethods;
  String get signInMethods;
  String get provideEmail;
  String get goBackButtonLabel;
  String get passwordResetEmailSentText;
  String get forgotPasswordHintText;
  String get emailLinkSignInButtonLabel;
  String get signInWithEmailLinkViewTitleText;
  String get signInWithEmailLinkSentText;
  String get sendLinkButtonLabel;

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

const localizations = <String, FlutterFireUILocalizationLabels>{
  'en': EnLocalizations(),
  'es': EsLocalizations(),
  'ar': ArLocalizations(),
  'fr': FrLocalizations(),
};

class DefaultLocalizations extends EnLocalizations {
  const DefaultLocalizations();
}
