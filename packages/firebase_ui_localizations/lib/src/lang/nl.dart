import '../default_localizations.dart';

class NlLocalizations extends FirebaseUILocalizationLabels {
  @override
  final String emailInputLabel;
  @override
  final String passwordInputLabel;
  @override
  final String signInActionText;
  @override
  final String registerActionText;
  @override
  final String linkEmailButtonText;

  @override
  final String signInWithPhoneButtonText;
  @override
  final String signInWithGoogleButtonText;
  @override
  final String signInWithAppleButtonText;
  @override
  final String signInWithFacebookButtonText;
  @override
  final String signInWithTwitterButtonText;
  @override
  final String phoneVerificationViewTitleText;
  @override
  final String verifyPhoneNumberButtonText;
  @override
  final String verifyCodeButtonText;

  @override
  final String unknownError;
  @override
  final String smsAutoresolutionFailedError;

  @override
  final String verifyingSMSCodeText;
  @override
  final String enterSMSCodeText;
  @override
  final String emailIsRequiredErrorText;
  @override
  final String isNotAValidEmailErrorText;
  @override
  final String userNotFoundErrorText;
  @override
  final String emailTakenErrorText;
  @override
  final String accessDisabledErrorText;
  @override
  final String wrongOrNoPasswordErrorText;
  @override
  final String signInText;
  @override
  final String registerText;
  @override
  final String registerHintText;
  @override
  final String signInHintText;
  @override
  final String signOutButtonText;
  @override
  final String phoneInputLabel;
  @override
  final String phoneNumberIsRequiredErrorText;
  @override
  final String phoneNumberInvalidErrorText;
  @override
  final String profile;
  @override
  final String name;
  @override
  final String deleteAccount;
  @override
  final String passwordIsRequiredErrorText;
  @override
  final String confirmPasswordIsRequiredErrorText;
  @override
  final String confirmPasswordDoesNotMatchErrorText;
  @override
  final String confirmPasswordInputLabel;
  @override
  final String forgotPasswordButtonLabel;
  @override
  final String forgotPasswordViewTitle;
  @override
  final String resetPasswordButtonLabel;
  @override
  final String verifyItsYouText;
  @override
  final String differentMethodsSignInTitleText;
  @override
  final String findProviderForEmailTitleText;
  @override
  final String continueText;
  @override
  final String countryCode;

  @override
  final String invalidCountryCode;
  @override
  final String chooseACountry;
  @override
  final String enableMoreSignInMethods;
  @override
  final String signInMethods;
  @override
  final String provideEmail;
  @override
  final String goBackButtonLabel;
  @override
  final String passwordResetEmailSentText;
  @override
  final String forgotPasswordHintText;
  @override
  final String emailLinkSignInButtonLabel;
  @override
  final String signInWithEmailLinkViewTitleText;
  @override
  final String signInWithEmailLinkSentText;
  @override
  final String sendLinkButtonLabel;
  @override
  final String arrayLabel;
  @override
  final String booleanLabel;
  @override
  final String mapLabel;
  @override
  final String nullLabel;
  @override
  final String numberLabel;
  @override
  final String stringLabel;
  @override
  final String typeLabel;
  @override
  final String valueLabel;
  @override
  final String cancelLabel;
  @override
  final String updateLabel;
  @override
  final String northInitialLabel;
  @override
  final String southInitialLabel;
  @override
  final String westInitialLabel;
  @override
  final String eastInitialLabel;
  @override
  final String timestampLabel;
  @override
  final String latitudeLabel;
  @override
  final String longitudeLabel;
  @override
  final String geopointLabel;
  @override
  final String referenceLabel;

  const NlLocalizations({
    this.emailInputLabel = 'E-mailadres',
    this.passwordInputLabel = 'Wachtwoord',
    this.signInActionText = 'Inloggen',
    this.registerActionText = 'Registreren',
    this.linkEmailButtonText = 'Verder',
    this.signInWithPhoneButtonText = 'Inloggen met telefoon',
    this.signInWithGoogleButtonText = 'Inloggen met Google',
    this.signInWithAppleButtonText = 'Inloggen met Apple',
    this.signInWithTwitterButtonText = 'Inloggen met Twitter',
    this.signInWithFacebookButtonText = 'Inloggen met Facebook',
    this.phoneVerificationViewTitleText = 'Voer uw telefoonnummer in',
    this.verifyPhoneNumberButtonText = 'Verder',
    this.verifyCodeButtonText = 'Verifieer',
    this.unknownError = 'Er is een onbekende fout opgetreden',
    this.smsAutoresolutionFailedError =
        'Automatisch verifiëren van de SMS code is niet gelukt. Voer de code handmatig in.',
    this.verifyingSMSCodeText = 'SMS code verifiëren...',
    this.enterSMSCodeText = 'Voer SMS code in',
    this.emailIsRequiredErrorText = 'E-mailadres is verplicht',
    this.isNotAValidEmailErrorText = 'Voer een geldig e-mailadres in',
    this.userNotFoundErrorText = 'Account bestaat niet',
    this.emailTakenErrorText = 'Een account met dit e-mailadres bestaat al',
    this.accessDisabledErrorText =
        'Toegang tot dit account is tijdelijk geblokkeerd',
    this.wrongOrNoPasswordErrorText =
        'Het wachtwoord is fout of de gebruiker heeft geen wachtwoord',
    this.signInText = 'Inloggen',
    this.registerText = 'Registreren',
    this.registerHintText = 'Heb je nog geen account?',
    this.signInHintText = 'Heb je al een account?',
    this.signOutButtonText = 'Uitloggen',
    this.phoneInputLabel = 'Telefoonnummer',
    this.phoneNumberInvalidErrorText = 'Telefoonnummer is fout',
    this.phoneNumberIsRequiredErrorText = 'Telefoonnummer is verplicht',
    this.profile = 'Profiel',
    this.name = 'Naam',
    this.deleteAccount = 'Account verwijderen',
    this.passwordIsRequiredErrorText = 'Wachtwoord is verplicht',
    this.confirmPasswordIsRequiredErrorText = 'Bevestig wachtwoord',
    this.confirmPasswordDoesNotMatchErrorText =
        'Wachtwoorden komen niet overeen',
    this.confirmPasswordInputLabel = 'Bevestig wachtwoord',
    this.forgotPasswordButtonLabel = 'Wachtwoord vergeten?',
    this.forgotPasswordViewTitle = 'Wachtwoord vergeten',
    this.resetPasswordButtonLabel = 'Wachtwoord herstellen',
    this.verifyItsYouText = 'Verifieër dat jij het bent',
    this.differentMethodsSignInTitleText =
        'Gebruik één van de volgende methodes om in te loggen',
    this.findProviderForEmailTitleText =
        'Voer uw e-mailadres in om verder te gaan',
    this.continueText = 'Verder',
    this.countryCode = 'Landcode',
    this.invalidCountryCode = 'Ongeldige landcode',
    this.chooseACountry = 'Kies een land',
    this.enableMoreSignInMethods = 'Meer inlogmethodes aanzetten',
    this.signInMethods = 'Inlogmethodes',
    this.provideEmail = 'Vul e-mailadres en wachtwoord in',
    this.goBackButtonLabel = 'Terug',
    this.passwordResetEmailSentText =
        'We hebben je een e-mail met een link gestuurd om je wachtwoord te herstellen. Controleer je e-mail.',
    this.forgotPasswordHintText =
        'Vul je e-mailadres in en we sturen je een e-mail om je wachtwoord te herstellen',
    this.emailLinkSignInButtonLabel = 'Inloggen met een magic link',
    this.signInWithEmailLinkViewTitleText = 'Inloggen met een magic link',
    this.signInWithEmailLinkSentText =
        'We hebben een e-mail met een magic link gestuurd. Controleer je e-mail en klik op de link om in te loggen',
    this.sendLinkButtonLabel = 'Stuur magic link',
    this.arrayLabel = 'array',
    this.booleanLabel = 'boolean',
    this.mapLabel = 'map',
    this.nullLabel = 'null',
    this.numberLabel = 'number',
    this.stringLabel = 'string',
    this.typeLabel = 'type',
    this.valueLabel = 'value',
    this.cancelLabel = 'annuleren',
    this.updateLabel = 'updaten',
    this.northInitialLabel = 'N',
    this.southInitialLabel = 'Z',
    this.westInitialLabel = 'W',
    this.eastInitialLabel = 'O',
    this.timestampLabel = 'timestamp',
    this.longitudeLabel = 'longitude',
    this.latitudeLabel = 'latitude',
    this.geopointLabel = 'geopoint',
    this.referenceLabel = 'reference',
  });
}
