import '../default_localizations.dart';

class DeLocalizations extends FirebaseUILocalizationLabels {
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

  const DeLocalizations({
    this.emailInputLabel = 'E-Mail',
    this.passwordInputLabel = 'Passwort',
    this.signInActionText = 'Anmelden',
    this.registerActionText = 'Registrieren',
    this.linkEmailButtonText = 'Weiter',
    this.signInWithPhoneButtonText = 'Mit Telefon anmelden',
    this.signInWithGoogleButtonText = 'Mit Google anmelden',
    this.signInWithAppleButtonText = 'Mit Apple anmelden',
    this.signInWithTwitterButtonText = 'Mit Twitter anmelden',
    this.signInWithFacebookButtonText = 'Mit Facebook anmelden',
    this.phoneVerificationViewTitleText = 'Geben Sie Ihre Telefonnummer ein',
    this.verifyPhoneNumberButtonText = 'Weiter',
    this.verifyCodeButtonText = 'Überprüfen',
    this.unknownError = 'Ein unbekannter Fehler ist aufgetreten',
    this.smsAutoresolutionFailedError =
        'Der SMS-Code konnte nicht automatisch aufgelöst werden. Bitte geben Sie Ihren Code manuell ein',
    this.verifyingSMSCodeText = 'SMS-Code überprüfen...',
    this.enterSMSCodeText = 'SMS-Code eingeben',
    this.emailIsRequiredErrorText = 'E-Mail ist erforderlich',
    this.isNotAValidEmailErrorText = 'Geben Sie eine gültige E-Mail an',
    this.userNotFoundErrorText = 'Das Konto existiert nicht',
    this.emailTakenErrorText = 'Konto mit dieser E-Mail existiert bereits',
    this.accessDisabledErrorText =
        'Der Zugriff auf dieses Konto wurde vorübergehend deaktiviert',
    this.wrongOrNoPasswordErrorText =
        'Das Passwort ist ungültig oder der Benutzer hat kein Passwort',
    this.signInText = 'Anmelden',
    this.registerText = 'Registrieren',
    this.registerHintText = 'Sie haben noch kein Konto?',
    this.signInHintText = 'Sie haben bereits ein Konto?',
    this.signOutButtonText = 'Abmelden',
    this.phoneInputLabel = 'Telefonnummer',
    this.phoneNumberInvalidErrorText = 'Telefonnummer ist ungültig',
    this.phoneNumberIsRequiredErrorText = 'Telefonnummer ist erforderlich',
    this.profile = 'Profil',
    this.name = 'Name',
    this.deleteAccount = 'Konto löschen',
    this.passwordIsRequiredErrorText = 'Passwort ist erforderlich',
    this.confirmPasswordIsRequiredErrorText = 'Bestätigen Sie Ihr Passwort',
    this.confirmPasswordDoesNotMatchErrorText =
        'Passwörter stimmen nicht überein',
    this.confirmPasswordInputLabel = 'Passwort bestätigen',
    this.forgotPasswordButtonLabel = 'Passwort vergessen?',
    this.forgotPasswordViewTitle = 'Passwort vergessen',
    this.resetPasswordButtonLabel = 'Passwort zurücksetzen',
    this.verifyItsYouText = 'Überprüfen Sie, ob Sie es sind',
    this.differentMethodsSignInTitleText =
        'Verwenden Sie eine der folgenden Methoden, um sich anzumelden',
    this.findProviderForEmailTitleText =
        'Geben Sie Ihre E-Mail-Adresse ein, um fortzufahren',
    this.continueText = 'Weiter',
    this.countryCode = 'Ländercode',
    this.invalidCountryCode = 'Ungültiger Code',
    this.chooseACountry = 'Wählen Sie ein Land',
    this.enableMoreSignInMethods = 'Weitere Anmeldemethoden aktivieren',
    this.signInMethods = 'Anmeldemethoden',
    this.provideEmail = 'Geben Sie E-Mail und Passwort an',
    this.goBackButtonLabel = 'Zurück',
    this.passwordResetEmailSentText =
        'Wir haben Ihnen eine E-Mail mit einem Link zum Zurücksetzen Ihres Passworts geschickt. Bitte prüfen Sie Ihre E-Mail.',
    this.forgotPasswordHintText =
        'Geben Sie Ihre E-Mail-Adresse an und wir senden Ihnen einen Link zum Zurücksetzen Ihres Passworts',
    this.emailLinkSignInButtonLabel = 'Anmelden mit Magic Link',
    this.signInWithEmailLinkViewTitleText = 'Mit Magic Link anmelden',
    this.signInWithEmailLinkSentText =
        'Wir haben Ihnen eine E-Mail mit einem Magic Link geschickt. Prüfen Sie Ihre E-Mail und folgen Sie dem Link, um sich anzumelden',
    this.sendLinkButtonLabel = 'Magic Link senden',
    this.arrayLabel = 'array',
    this.booleanLabel = 'boolean',
    this.mapLabel = 'map',
    this.nullLabel = 'null',
    this.numberLabel = 'number',
    this.stringLabel = 'string',
    this.typeLabel = 'type',
    this.valueLabel = 'value',
    this.cancelLabel = 'abbrechen',
    this.updateLabel = 'aktualisieren',
    this.northInitialLabel = 'N',
    this.southInitialLabel = 'S',
    this.westInitialLabel = 'W',
    this.eastInitialLabel = 'O',
    this.timestampLabel = 'timestamp',
    this.longitudeLabel = 'longitude',
    this.latitudeLabel = 'latitude',
    this.geopointLabel = 'geopoint',
    this.referenceLabel = 'reference',
  });
}
