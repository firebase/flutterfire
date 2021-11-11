import 'lang/en.dart';

abstract class FirebaseUILocalizationLabels {
  const FirebaseUILocalizationLabels();

  String get emailInputLabel;
  String get passwordInputLabel;
  String get signInActionText;
  String get signUpActionText;

  String get signInButtonText;
  String get signUpButtonText;
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
}

const localizations = <String, FirebaseUILocalizationLabels>{
  'en': EnLocalizations(),
};

class DefaultLocalizations extends EnLocalizations {
  const DefaultLocalizations();
}
