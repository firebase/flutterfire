import '../default_localizations.dart';

class PtLocalizations extends FirebaseUILocalizationLabels {
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

  const PtLocalizations({
    this.emailInputLabel = 'E-mail',
    this.passwordInputLabel = 'Senha',
    this.signInActionText = 'Fazer login',
    this.registerActionText = 'Registrar',
    this.linkEmailButtonText = 'Próximo',
    this.signInWithPhoneButtonText = 'Fazer login com o telefone',
    this.signInWithGoogleButtonText = 'Fazer login com o Google',
    this.signInWithAppleButtonText = 'Fazer login com a Apple',
    this.signInWithTwitterButtonText = 'Fazer login com o Twitter',
    this.signInWithFacebookButtonText = 'Fazer login com o Facebook',
    this.phoneVerificationViewTitleText = 'Digite seu número de telefone',
    this.verifyPhoneNumberButtonText = 'Próximo',
    this.verifyCodeButtonText = 'Verificar',
    this.unknownError = 'Ocorreu um erro desconhecido',
    this.smsAutoresolutionFailedError =
        'Falha ao detectar o código SMS automaticamente. Por favor, digite o seu código manualmente',
    this.verifyingSMSCodeText = 'Verificando o código SMS...',
    this.enterSMSCodeText = 'Digite o código SMS',
    this.emailIsRequiredErrorText = 'O e-mail é obrigatório',
    this.isNotAValidEmailErrorText = 'Digite um e-mail válido',
    this.userNotFoundErrorText = 'Conta não existe',
    this.emailTakenErrorText = 'Já existe uma conta com esse e-mail',
    this.accessDisabledErrorText =
        'O acesso a esta conta foi temporariamente desativado',
    this.wrongOrNoPasswordErrorText =
        'A senha é inválida ou o usuário não tem uma senha',
    this.signInText = 'Fazer login',
    this.registerText = 'Registrar',
    this.registerHintText = 'Não tem uma conta?',
    this.signInHintText = 'Já tem uma conta?',
    this.signOutButtonText = 'Sair',
    this.phoneInputLabel = 'Número de telefone',
    this.phoneNumberInvalidErrorText = 'Número de telefone inválido',
    this.phoneNumberIsRequiredErrorText = 'O número de telefone é obrigatório',
    this.profile = 'Perfil',
    this.name = 'Nome',
    this.deleteAccount = 'Deletar conta',
    this.passwordIsRequiredErrorText = 'A senha é obrigatória',
    this.confirmPasswordIsRequiredErrorText = 'Confirme sua senha',
    this.confirmPasswordDoesNotMatchErrorText = 'As senhas não coincidem',
    this.confirmPasswordInputLabel = 'Confirmar senha',
    this.forgotPasswordButtonLabel = 'Esqueceu a senha?',
    this.forgotPasswordViewTitle = 'Esqueci minha senha',
    this.resetPasswordButtonLabel = 'Redefinir senha',
    this.verifyItsYouText = 'Verifique se é você',
    this.differentMethodsSignInTitleText =
        'Use um dos seguintes métodos para fazer login',
    this.findProviderForEmailTitleText = 'Digite seu e-mail para continuar',
    this.continueText = 'Continuar',
    this.countryCode = 'Código',
    this.invalidCountryCode = 'Código inválido',
    this.chooseACountry = 'Escolha um país',
    this.enableMoreSignInMethods = 'Ative mais métodos de login',
    this.signInMethods = 'Métodos de login',
    this.provideEmail = 'Digite seu e-mail e senha',
    this.goBackButtonLabel = 'Voltar',
    this.passwordResetEmailSentText =
        'Enviamos um e-mail para você com um link para redefinir sua senha. Por favor, verifique seu e-mail.',
    this.forgotPasswordHintText =
        'Digite seu e-mail e nós lhe enviaremos um link para redefinir sua senha',
    this.emailLinkSignInButtonLabel = 'Faça login com o link mágico',
    this.signInWithEmailLinkViewTitleText = 'Faça login com o link mágico',
    this.signInWithEmailLinkSentText =
        'Enviamos um e-mail com um link mágico para você. Verifique seu e-mail e siga o link para fazer o login',
    this.sendLinkButtonLabel = 'Enviar link mágico',
    this.arrayLabel = 'lista',
    this.booleanLabel = 'boleano',
    this.mapLabel = 'mapa',
    this.nullLabel = 'nulo',
    this.numberLabel = 'número',
    this.stringLabel = 'cadeia de caracteres',
    this.typeLabel = 'tipo',
    this.valueLabel = 'valor',
    this.cancelLabel = 'cancelar',
    this.updateLabel = 'atualizar',
    this.northInitialLabel = 'N',
    this.southInitialLabel = 'S',
    this.westInitialLabel = 'O',
    this.eastInitialLabel = 'L',
    this.timestampLabel = 'carimbo do tempo',
    this.longitudeLabel = 'longitude',
    this.latitudeLabel = 'latitude',
    this.geopointLabel = 'geoponto',
    this.referenceLabel = 'referência',
  });
}
