import '../default_localizations.dart';

class FrLocalizations extends FlutterFireUILocalizationLabels {
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

  const FrLocalizations({
    this.emailInputLabel = 'E-mail',
    this.passwordInputLabel = 'Mot de passe',
    this.signInActionText = "S'identifier",
    this.registerActionText = "S'inscrire",
    this.signInButtonText = "S'identifier",
    this.registerButtonText = "S'inscrire",
    this.linkEmailButtonText = 'Suivant',
    this.signInWithPhoneButtonText = 'Connectez-vous avec téléphone',
    this.signInWithGoogleButtonText = 'Connectez-vous avec Google',
    this.signInWithAppleButtonText = 'Connectez-vous avec Apple',
    this.signInWithTwitterButtonText = 'Connectez-vous avec Twitter',
    this.signInWithFacebookButtonText = 'Connectez-vous avec Facebook',
    this.phoneVerificationViewTitleText = 'Entrez votre numéro de téléphone',
    this.verifyPhoneNumberButtonText = 'Suivant',
    this.verifyCodeButtonText = 'Vérifier',
    this.verifyingPhoneNumberViewTitle = 'Entrez le code de SMS',
    this.unknownError = 'Une erreur inconnue est survenue',
    this.smsAutoresolutionFailedError =
        'Échec de la résolution du code SMS automatiquement. Veuillez entrer votre code manuellement',
    this.smsCodeSentText = 'Code SMS envoyé',
    this.sendingSMSCodeText = 'Envoi du code SMS ...',
    this.verifyingSMSCodeText = 'Vérification du code SMS ...',
    this.enterSMSCodeText = 'Entrez le code SMS',
    this.emailIsRequiredErrorText = 'Email est requis',
    this.isNotAValidEmailErrorText = 'Fournir un email valide',
    this.userNotFoundErrorText = "Le compte n'existe pas",
    this.emailTakenErrorText = 'Le compte avec un cet email existe déjà',
    this.accessDisabledErrorText = "L'accès à ce compte a été temporairement désactivé",
    this.wrongOrNoPasswordErrorText = "Le mot de passe est invalide ou l'utilisateur n'a pas de mot de passe",
    this.signInText = "S'identifier",
    this.registerText = "S'inscrire",
    this.registerHintText = "Vous n'avez pas de compte?",
    this.signInHintText = 'Vous avez déjà un compte?',
    this.signOutButtonText = 'Déconnexion',
    this.phoneInputLabel = 'Numéro de téléphone',
    this.phoneNumberInvalidErrorText = 'Le numéro de téléphone est invalide',
    this.phoneNumberIsRequiredErrorText = 'Le numéro de téléphone est requis',
    this.profile = 'Profil',
    this.name = 'Nom',
    this.deleteAccount = 'Supprimer le compte',
    this.passwordIsRequiredErrorText = 'Mot de passe requis',
    this.confirmPasswordIsRequiredErrorText = 'Confirmer votre mot de passe',
    this.confirmPasswordDoesNotMatchErrorText = 'Les mots de passe ne correspondent pas',
    this.confirmPasswordInputLabel = 'Confirmez le mot de passe',
    this.forgotPasswordButtonLabel = 'Mot de passe oublié?',
    this.forgotPasswordViewTitle = 'Mot de passe oublié',
    this.resetPasswordButtonLabel = 'Réinitialiser le mot de passe',
    this.verifyItsYouText = "Vérifiez que c'est vous",
    this.differentMethodsSignInTitleText = "Utilisez l'une des méthodes suivantes pour vous connecter",
    this.findProviderForEmailTitleText = 'Entrez votre email pour continuer',
    this.continueText = 'Continuez',
    this.countryCode = 'Code',
    this.codeRequiredErrorText = 'Le code de pays est requis',
    this.invalidCountryCode = 'Code invalide',
    this.chooseACountry = 'Choisissez un pays',
    this.enableMoreSignInMethods = 'Activer plus de méthodes de connexion',
    this.signInMethods = "Méthodes d'identification",
    this.provideEmail = 'Fournissez votre email et votre mot de passe',
    this.goBackButtonLabel = 'Retourner',
    this.passwordResetEmailSentText =
        'Nous vous avons envoyé un email avec un lien pour réinitialiser votre mot de passe. Veuillez vérifier votre email.',
    this.forgotPasswordHintText =
        'Fournissez votre email et nous vous enverrons un lien pour réinitialiser votre mot de passe',
    this.emailLinkSignInButtonLabel = 'Connectez-vous avec Magic Link',
    this.signInWithEmailLinkViewTitleText = 'Connectez-vous avec Magic Link',
    this.signInWithEmailLinkSentText =
        'Nous vous avons envoyé un email avec une lien magique. Vérifiez votre email et suivez le lien pour vous connecter',
    this.sendLinkButtonLabel = 'Envoyer Magic Link',
    this.arrayLabel = 'tableau',
    this.booleanLabel = 'booléen',
    this.mapLabel = 'map',
    this.nullLabel = 'null',
    this.numberLabel = 'numéro',
    this.stringLabel = 'chaîne de caractères',
    this.typeLabel = 'type',
    this.valueLabel = 'valeur',
    this.cancelLabel = 'annuler',
    this.updateLabel = 'mettre à jour',
    this.northInitialLabel = 'N',
    this.southInitialLabel = 'S',
    this.westInitialLabel = 'O',
    this.eastInitialLabel = 'E',
    this.timestampLabel = 'horodatage',
    this.longitudeLabel = 'longitude',
    this.latitudeLabel = 'latitude',
    this.geopointLabel = 'geopoint',
    this.referenceLabel = 'référence',
  });
}
