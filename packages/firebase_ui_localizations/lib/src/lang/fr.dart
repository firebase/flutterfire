import '../default_localizations.dart';

class FrLocalizations extends FirebaseUILocalizationLabels {
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

  const FrLocalizations({
    this.emailInputLabel = 'Email',
    this.passwordInputLabel = 'Mot de passe',
    this.signInActionText = 'Connexion',
    this.registerActionText = 'Inscription',
    this.linkEmailButtonText = 'Suivant',
    this.signInWithPhoneButtonText = 'Se connecter avec un téléphone',
    this.signInWithGoogleButtonText = 'Se connecter avec Google',
    this.signInWithAppleButtonText = 'Se connecter avec Apple',
    this.signInWithTwitterButtonText = 'Se connecter avec Twitter',
    this.signInWithFacebookButtonText = 'Se connecter avec Facebook',
    this.phoneVerificationViewTitleText = 'Entrez votre numéro de téléphone',
    this.verifyPhoneNumberButtonText = 'Suivant',
    this.verifyCodeButtonText = 'Vérifier',
    this.unknownError = "Une erreur inconnue s'est produite",
    this.smsAutoresolutionFailedError =
        'Impossible de retrouver le code automatiquement. Veuillez entrer votre code manuellement',
    this.verifyingSMSCodeText = 'Vérification du code SMS',
    this.enterSMSCodeText = 'Entrez le code reçu par SMS',
    this.emailIsRequiredErrorText = 'Un email est requis',
    this.isNotAValidEmailErrorText = 'Veuillez entrer un email valide',
    this.userNotFoundErrorText = "Le compte n'existe pas",
    this.emailTakenErrorText = 'Un compte existe déjà avec cette adresse email',
    this.accessDisabledErrorText =
        "L'accés à ce compte a été temporairement verrouillé",
    this.wrongOrNoPasswordErrorText =
        "Le mot de passe est invalide ou l'utilisateur n'a pas de mot de passe",
    this.signInText = 'Connexion',
    this.registerText = 'Inscription',
    this.registerHintText = "Vous n'avez pas de compte ?",
    this.signInHintText = 'Vous avez déjà un compte ?',
    this.signOutButtonText = 'Déconnexion',
    this.phoneInputLabel = 'Numéro de téléphone',
    this.phoneNumberInvalidErrorText =
        "Le numéro de téléphone n'est pas valide",
    this.phoneNumberIsRequiredErrorText = 'Un numéro de téléphone est requis',
    this.profile = 'Profil',
    this.name = 'Nom',
    this.deleteAccount = 'Supprimer le compte',
    this.passwordIsRequiredErrorText = 'Un mot de passe est requis',
    this.confirmPasswordIsRequiredErrorText =
        'Veuillez confirmer votre mot de passe',
    this.confirmPasswordDoesNotMatchErrorText =
        'Les mots de passe ne se correspondent pas',
    this.confirmPasswordInputLabel = 'Confirmez votre mot de passe',
    this.forgotPasswordButtonLabel = 'Mot de passe oublié ?',
    this.forgotPasswordViewTitle = 'Mot de passe oublié',
    this.resetPasswordButtonLabel = 'Réinitialiser votre mot de passe',
    this.verifyItsYouText = 'Vérifiez votre identité',
    this.differentMethodsSignInTitleText =
        'Utilisez une des méthodes suivantes pour vous connecter',
    this.findProviderForEmailTitleText =
        'Entrez votre adresse email pour continuer',
    this.continueText = 'Continuer',
    this.countryCode = 'Code',
    this.invalidCountryCode = 'Code pays invalide',
    this.chooseACountry = 'Choisissez un pays',
    this.enableMoreSignInMethods = 'Activer plus de moyens de connexion',
    this.signInMethods = 'Moyens de connexion',
    this.provideEmail = 'Fournissez votre adresse email et votre mot de passe',
    this.goBackButtonLabel = 'Retour',
    this.passwordResetEmailSentText =
        'Nous vous avons envoyé un email avec un lien pour réinitialiser votre mot de passe. Veuillez vérifier vos emails.',
    this.forgotPasswordHintText =
        'Fournissez votre adresse email et nous vous enverrons un lien pour réinitialiser votre mot de passe',
    this.emailLinkSignInButtonLabel = 'Connectez-vous avec le lien magique',
    this.signInWithEmailLinkViewTitleText =
        'Connectez-vous avec le lien magique',
    this.signInWithEmailLinkSentText =
        'Nous vous avons envoyé un email avec un lien magique. Vérifiez vos emails et clickez sur le lien pour vous connecter',
    this.sendLinkButtonLabel = 'Envoyer un lien magique',
    this.arrayLabel = 'liste',
    this.booleanLabel = 'booléen',
    this.mapLabel = 'map',
    this.nullLabel = 'nul',
    this.numberLabel = 'numéro',
    this.stringLabel = 'chaîne de caractères',
    this.typeLabel = 'type',
    this.valueLabel = 'valeur',
    this.cancelLabel = 'annuler',
    this.updateLabel = 'rafraichir',
    this.northInitialLabel = 'N',
    this.southInitialLabel = 'S',
    this.westInitialLabel = 'O',
    this.eastInitialLabel = 'E',
    this.timestampLabel = 'horodatage',
    this.longitudeLabel = 'longitude',
    this.latitudeLabel = 'latitude',
    this.geopointLabel = 'géopoint',
    this.referenceLabel = 'référence',
  });
}
