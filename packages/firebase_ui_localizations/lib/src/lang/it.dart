import '../default_localizations.dart';

class ItLocalizations extends FirebaseUILocalizationLabels {
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

  const ItLocalizations({
    this.emailInputLabel = 'Email',
    this.passwordInputLabel = 'Password',
    this.signInActionText = 'Accedi',
    this.registerActionText = 'Registrati',
    this.linkEmailButtonText = 'Successivo',
    this.signInWithPhoneButtonText = 'Accedi con telefono',
    this.signInWithGoogleButtonText = 'Accedi con Google',
    this.signInWithAppleButtonText = 'Accedi con Apple',
    this.signInWithTwitterButtonText = 'Accedi con Twitter',
    this.signInWithFacebookButtonText = 'Accedi con Facebook',
    this.phoneVerificationViewTitleText = 'Inserisci il tuo numero di telefono',
    this.verifyPhoneNumberButtonText = 'Successivo',
    this.verifyCodeButtonText = 'Verifica',
    this.unknownError = 'Si è verificato un errore sconosciuto',
    this.smsAutoresolutionFailedError =
        'Impossibile risolvere automaticamente il codice SMS. Si prega di inserire il codice manualmente',
    this.verifyingSMSCodeText = 'Verifica del codice SMS...',
    this.enterSMSCodeText = 'Digita codice SMS',
    this.emailIsRequiredErrorText = "L'email è richiesta",
    this.isNotAValidEmailErrorText = 'Fornisci una email valida',
    this.userNotFoundErrorText = "L'account non esiste",
    this.emailTakenErrorText = "L'account con tale email esiste già",
    this.accessDisabledErrorText =
        "L'accesso a questo account è stato temporaneamente disabilitato",
    this.wrongOrNoPasswordErrorText =
        "La password non è valida o l'utente non dispone di una password",
    this.signInText = 'Accedi',
    this.registerText = 'Registrati',
    this.registerHintText = 'Non hai un account?',
    this.signInHintText = 'Hai già un account?',
    this.signOutButtonText = 'Disconnetti',
    this.phoneInputLabel = 'Numero di telefono',
    this.phoneNumberInvalidErrorText = 'Il numero di telefono non è valido',
    this.phoneNumberIsRequiredErrorText = 'Il numero di telefono è richiesto',
    this.profile = 'Profilo',
    this.name = 'Nome',
    this.deleteAccount = 'Rimuovi account',
    this.passwordIsRequiredErrorText = 'La password è richiesta',
    this.confirmPasswordIsRequiredErrorText = 'Conferma la tua password',
    this.confirmPasswordDoesNotMatchErrorText = 'Le password non coincidono',
    this.confirmPasswordInputLabel = 'Conferma password',
    this.forgotPasswordButtonLabel = 'Password dimenticata?',
    this.forgotPasswordViewTitle = 'Password dimenticata',
    this.resetPasswordButtonLabel = 'Resetta password',
    this.verifyItsYouText = 'Verifica che sei tu',
    this.differentMethodsSignInTitleText =
        'Utilizza uno dei seguenti metodi di accesso',
    this.findProviderForEmailTitleText = 'Digita la tua email per continuare',
    this.continueText = 'Continua',
    this.countryCode = 'Prefisso internazionale',
    this.invalidCountryCode = 'Prefisso internazionale non valido',
    this.chooseACountry = 'Scegli una nazione',
    this.enableMoreSignInMethods = 'Abilita più metodi di accesso',
    this.signInMethods = 'Metodi di accesso',
    this.provideEmail = 'Fornisci la tua email e password',
    this.goBackButtonLabel = 'Torna indietro',
    this.passwordResetEmailSentText =
        'Ti abbiamo inviato una email con un link per reimpostare la tua password. Si prega di controllare la tua email.',
    this.forgotPasswordHintText =
        'Fornisci la tua email e ti invieremo un link per reimpostare la tua password',
    this.emailLinkSignInButtonLabel = 'Accedi con link magico',
    this.signInWithEmailLinkViewTitleText = 'Accedi con link magico',
    this.signInWithEmailLinkSentText =
        'Ti abbiamo inviato una email con un link magico. Controlla la tua email e segui il link per accedere',
    this.sendLinkButtonLabel = 'Invia link magico',
    this.arrayLabel = 'lista',
    this.booleanLabel = 'booleano',
    this.mapLabel = 'mappa',
    this.nullLabel = 'nullo',
    this.numberLabel = 'numero',
    this.stringLabel = 'stringa',
    this.typeLabel = 'tipo',
    this.valueLabel = 'valore',
    this.cancelLabel = 'annulla',
    this.updateLabel = 'aggiorna',
    this.northInitialLabel = 'N',
    this.southInitialLabel = 'S',
    this.westInitialLabel = 'O',
    this.eastInitialLabel = 'E',
    this.timestampLabel = 'timestamp',
    this.longitudeLabel = 'longitudine',
    this.latitudeLabel = 'latitudine',
    this.geopointLabel = 'geopunto',
    this.referenceLabel = 'riferimento',
  });
}
