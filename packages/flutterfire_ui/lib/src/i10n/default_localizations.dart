// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'lang/ar.dart';
import 'lang/en.dart';
import 'lang/fr.dart';
import 'lang/it.dart';
import 'lang/ja.dart';
import 'lang/pt.dart';
import 'lang/nl.dart';
import 'lang/tr.dart';
import 'lang/id.dart';
import 'lang/hi.dart';
import 'lang/de.dart';
import 'lang/es.dart';
import 'lang/zh.dart';

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
  'hi': HiLocalizations(),
  'es': EsLocalizations(),
  'ar': ArLocalizations(),
  'tr': TrLocalizations(),
  'fr': FrLocalizations(),
  'it': ItLocalizations(),
  'ja': JaLocalizations(),
  'pt': PtLocalizations(),
  'nl': NlLocalizations(),
  'id': IdLocalizations(),
  'de': DeLocalizations(),
  'zh': ZhLocalizations(),
};

class DefaultLocalizations extends EnLocalizations {
  const DefaultLocalizations();
}
