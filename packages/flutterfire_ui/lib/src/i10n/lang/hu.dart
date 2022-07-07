import '../default_localizations.dart';

class HuLocalizations extends FlutterFireUILocalizationLabels {
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

  const HuLocalizations({
    this.emailInputLabel = 'Email',
    this.passwordInputLabel = 'Jelszó',
    this.signInActionText = 'Bejelentkezés',
    this.registerActionText = 'Regisztráció',
    this.signInButtonText = 'Bejelentkezés',
    this.registerButtonText = 'Regisztráció',
    this.linkEmailButtonText = 'Következő',
    this.signInWithPhoneButtonText = 'Bejelentkezés telefonszámmal',
    this.signInWithGoogleButtonText = 'Google bejelentkezés',
    this.signInWithAppleButtonText = 'Apple bejelentkezés',
    this.signInWithTwitterButtonText = 'Twitter bejelentkezés',
    this.signInWithFacebookButtonText = 'Facebook bejelentkezés',
    this.phoneVerificationViewTitleText = 'Add meg a telefonszámod',
    this.verifyPhoneNumberButtonText = 'Következő',
    this.verifyCodeButtonText = 'Ellenőrzés',
    this.verifyingPhoneNumberViewTitle = 'Add meg az SMS kódot',
    this.unknownError = 'Ismeretlen hiba történt',
    this.smsAutoresolutionFailedError =
        'Nem sikerült az SMS kódot kinyerni. Kérlek add meg a kódot manuálisan',
    this.smsCodeSentText = 'SMS kód elküldve',
    this.sendingSMSCodeText = 'SMS kód küldése...',
    this.verifyingSMSCodeText = 'SMS kód ellenőrzése...',
    this.enterSMSCodeText = 'Add meg az SMS kódot',
    this.emailIsRequiredErrorText = 'Email cím megadása kötelező',
    this.isNotAValidEmailErrorText = 'Helyes email címet adj meg',
    this.userNotFoundErrorText = 'A fiók nem létezik',
    this.emailTakenErrorText = 'Ezzel az email címmel már regisztráltak',
    this.accessDisabledErrorText =
        'Ez a fiók átmenetileg le van tiltva',
    this.wrongOrNoPasswordErrorText =
        'Érvénytelen jelszó vagy a felhasználónak nincs jelszava',
    this.signInText = 'Bejelentkezés',
    this.registerText = 'Regisztráció',
    this.registerHintText = 'Nincs fiókod?',
    this.signInHintText = 'Már van fiókod?',
    this.signOutButtonText = 'Kijelentkezés',
    this.phoneInputLabel = 'Telefonszám',
    this.phoneNumberInvalidErrorText = 'Érvénytelen telefonszám',
    this.phoneNumberIsRequiredErrorText = 'Telefonszám megadása kötelező',
    this.profile = 'Profil',
    this.name = 'Név',
    this.deleteAccount = 'Fiók törlése',
    this.passwordIsRequiredErrorText = 'Jelszó megadása kötelező',
    this.confirmPasswordIsRequiredErrorText = 'Jelszó megerősítése',
    this.confirmPasswordDoesNotMatchErrorText = 'Jelszavak nem egyeznek',
    this.confirmPasswordInputLabel = 'Jelszó ismét',
    this.forgotPasswordButtonLabel = 'Efelejtett jelszó?',
    this.forgotPasswordViewTitle = 'Elfelejtett jelszó',
    this.resetPasswordButtonLabel = 'Jelszó visszaállítása',
    this.verifyItsYouText = 'Igazold magad',
    this.differentMethodsSignInTitleText =
        'Válassz az alábbi bejelentkezés lehetőségek közül',
    this.findProviderForEmailTitleText = 'Add meg az email címed a folytatáshoz',
    this.continueText = 'Folytatás',
    this.countryCode = 'Országkód',
    this.codeRequiredErrorText = 'Országkód megadása kötelező',
    this.invalidCountryCode = 'Érvénytelen országkód',
    this.chooseACountry = 'Válassz országot',
    this.enableMoreSignInMethods = 'Több bejelentkezési módszer engedélyezése',
    this.signInMethods = 'Bejelentkezési módszerek',
    this.provideEmail = 'Add meg az email címed és jelszavad',
    this.goBackButtonLabel = 'Vissza',
    this.passwordResetEmailSentText =
        'Elküldtük az emailt a linkkel a jelszó visszaállításához. Ellenőrizd az emailedet.',
    this.forgotPasswordHintText =
        'Add meg az email címed és elküldjük a jelszó visszaállító linket',
    this.emailLinkSignInButtonLabel = 'Bejelentkezés varázslinkkel',
    this.signInWithEmailLinkViewTitleText = 'Bejelentkezés varázslinkkel',
    this.signInWithEmailLinkSentText =
        'Elküldtük az emailt a varázslinkkel. Ellenőrizd az emailedet és használd a linket a bejelentkezéshez',
    this.sendLinkButtonLabel = 'Varázslink elküldése',
    this.arrayLabel = 'tömb',
    this.booleanLabel = 'logikai',
    this.mapLabel = 'map',
    this.nullLabel = 'null',
    this.numberLabel = 'szám',
    this.stringLabel = 'string',
    this.typeLabel = 'típus',
    this.valueLabel = 'érték',
    this.cancelLabel = 'mégse',
    this.updateLabel = 'frissítés',
    this.northInitialLabel = 'É',
    this.southInitialLabel = 'D',
    this.westInitialLabel = 'Ny',
    this.eastInitialLabel = 'K',
    this.timestampLabel = 'időbélyeg',
    this.longitudeLabel = 'hosszúság',
    this.latitudeLabel = 'szélesség',
    this.geopointLabel = 'geopont',
    this.referenceLabel = 'referencia',
  });
}
