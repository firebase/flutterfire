import '../default_localizations.dart';

class PlLocalizations extends FlutterFireUILocalizationLabels {
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
  final String signInButtonText;
  @override
  final String registerButtonText;
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
  final String verifyingPhoneNumberViewTitle;
  @override
  final String unknownError;
  @override
  final String smsAutoresolutionFailedError;
  @override
  final String smsCodeSentText;
  @override
  final String sendingSMSCodeText;
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
  final String codeRequiredErrorText;
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

  const PlLocalizations({
    this.emailInputLabel = 'Adres e-mail',
    this.passwordInputLabel = 'Hasło',
    this.signInActionText = 'Zaloguj się',
    this.registerActionText = 'Zarejestruj się',
    this.signInButtonText = 'Zaloguj się',
    this.registerButtonText = 'Zarejestruj się',
    this.linkEmailButtonText = 'Dalej',
    this.signInWithPhoneButtonText = 'Zaloguj się przy użyciu telefonu',
    this.signInWithGoogleButtonText = 'Zaloguj się przez Google',
    this.signInWithAppleButtonText = 'Zaloguj się przez Apple',
    this.signInWithTwitterButtonText = 'Zaloguj się przez Twitter',
    this.signInWithFacebookButtonText = 'Zaloguj się przez Facebook',
    this.phoneVerificationViewTitleText = 'Wprowadź swój numer telefonu',
    this.verifyPhoneNumberButtonText = 'Dalej',
    this.verifyCodeButtonText = 'Zweryfikuj',
    this.verifyingPhoneNumberViewTitle = 'Wpisz kod SMS',
    this.unknownError = 'Wystąpił nieznany błąd',
    this.smsAutoresolutionFailedError =
        'Nie udało się automatycznie określić kodu SMS. Wprowadź kod ręcznie',
    this.smsCodeSentText = 'Kod SMS wysłany',
    this.sendingSMSCodeText = 'Wysyłanie kodu SMS...',
    this.verifyingSMSCodeText = 'Weryfikowanie kodu SMS...',
    this.enterSMSCodeText = 'Wprowadź kod SMS',
    this.emailIsRequiredErrorText = 'Adres e-mail jest wymagany',
    this.isNotAValidEmailErrorText = 'Wpisz prawidłowy adres e-mail',
    this.userNotFoundErrorText = "Takie konto nie istnieje",
    this.emailTakenErrorText = 'Konto z tym adresem e-mail już istnieje',
    this.accessDisabledErrorText =
        'Access to this account has been temporarily disabled',
    this.wrongOrNoPasswordErrorText =
        'Hasło jest nieprawidłowe lub użytkownik nie ma hasła',
    this.signInText = 'Zaloguj się',
    this.registerText = 'Zarejestruj się',
    this.registerHintText = "Nie masz konta?",
    this.signInHintText = 'Masz już konto?',
    this.signOutButtonText = 'Wyloguj się',
    this.phoneInputLabel = 'Numer telefonur',
    this.phoneNumberInvalidErrorText = 'Numer telefonu jest nieprawidłowy',
    this.phoneNumberIsRequiredErrorText = 'Numer telefonu jest wymagany',
    this.profile = 'Profil',
    this.name = 'Nazwa',
    this.deleteAccount = 'Usuń konto',
    this.passwordIsRequiredErrorText = 'Hasło jest wymagane',
    this.confirmPasswordIsRequiredErrorText = 'Potwierdź hasło',
    this.confirmPasswordDoesNotMatchErrorText = 'Hasła nie pasują',
    this.confirmPasswordInputLabel = 'Potwierdź hasło',
    this.forgotPasswordButtonLabel = 'Zapomniałeś hasła?',
    this.forgotPasswordViewTitle = 'Zresetuj hasło',
    this.resetPasswordButtonLabel = 'Reset password',
    this.verifyItsYouText = "Potwierdź, że to ty",
    this.differentMethodsSignInTitleText =
        'Użyj jednej z poniższych metod, aby się zalogować',
    this.findProviderForEmailTitleText = 'Wprowadź swój adres e-mail, aby kontynuować',
    this.continueText = 'Kontynuuj',
    this.countryCode = 'Kod kraju',
    this.codeRequiredErrorText = 'Kod kraju jest wymagany',
    this.invalidCountryCode = 'Nieprawidłowy kod kraju',
    this.chooseACountry = 'Wybierz kraj',
    this.enableMoreSignInMethods = 'Włącz więcej metod logowania',
    this.signInMethods = 'Metody logowania',
    this.provideEmail = 'Wpisz swój adres e-mail i hasło',
    this.goBackButtonLabel = 'Wstecz',
    this.passwordResetEmailSentText =
        "Wysłaliśmy Ci wiadomość e-mail z linkiem do zresetowania hasła. Sprawdź pocztę email.",
    this.forgotPasswordHintText =
        'Wprowadź swój adres e-mail, a wyślemy Ci link do zresetowania hasła',
    this.emailLinkSignInButtonLabel = 'Zaloguj się przez link',
    this.signInWithEmailLinkViewTitleText = 'Zaloguj się za pomocą linku',
    this.signInWithEmailLinkSentText =
        "Wysłaliśmy Ci e-mail z linkiem. Sprawdź swoją pocztę e-mail i kliknij link, aby się zalogować.",
    this.sendLinkButtonLabel = 'Wyślij link',
    this.arrayLabel = 'array',
    this.booleanLabel = 'boolean',
    this.mapLabel = 'map',
    this.nullLabel = 'null',
    this.numberLabel = 'number',
    this.stringLabel = 'string',
    this.typeLabel = 'type',
    this.valueLabel = 'value',
    this.cancelLabel = 'anuluj',
    this.updateLabel = 'aktualizuj',
    this.northInitialLabel = 'N',
    this.southInitialLabel = 'S',
    this.westInitialLabel = 'W',
    this.eastInitialLabel = 'E',
    this.timestampLabel = 'timestamp',
    this.longitudeLabel = 'longitude',
    this.latitudeLabel = 'latitude',
    this.geopointLabel = 'geopoint',
    this.referenceLabel = 'reference',
  });
}
