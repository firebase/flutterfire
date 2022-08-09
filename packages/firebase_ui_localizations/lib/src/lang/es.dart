import '../default_localizations.dart';

class EsLocalizations extends FirebaseUILocalizationLabels {
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

  const EsLocalizations({
    this.emailInputLabel = 'Correo electrónico',
    this.passwordInputLabel = 'Contraseña',
    this.signInActionText = 'Iniciar sesión',
    this.registerActionText = 'Registrarse',
    this.linkEmailButtonText = 'Siguiente',
    this.signInWithPhoneButtonText = 'Entra con teléfono',
    this.signInWithGoogleButtonText = 'Entra con Google',
    this.signInWithAppleButtonText = 'Entra con Apple',
    this.signInWithTwitterButtonText = 'Entra con Twitter',
    this.signInWithFacebookButtonText = 'Entra con Facebook',
    this.phoneVerificationViewTitleText = 'Ingresa tu número de teléfono',
    this.verifyPhoneNumberButtonText = 'Siguiente',
    this.verifyCodeButtonText = 'Verificar',
    this.unknownError = 'Ha ocurrido un error desconocido',
    this.smsAutoresolutionFailedError =
        'No se ha podido detectar el código SMS automáticamente. Por favor, ingrese su código manualmente',
    this.verifyingSMSCodeText = 'Verificando el código SMS ...',
    this.enterSMSCodeText = 'Introduce el código SMS',
    this.emailIsRequiredErrorText = 'El correo electrónico es obligatorio',
    this.isNotAValidEmailErrorText = 'Ingresa un correo electrónico válido',
    this.userNotFoundErrorText = 'No existe una cuenta con este usuario',
    this.emailTakenErrorText =
        'Ya existe una cuenta con este correo electrónico',
    this.accessDisabledErrorText =
        'El acceso a esta cuenta se ha inhabilitado temporalmente',
    this.wrongOrNoPasswordErrorText =
        'La contraseña no es válida o el usuario no tiene contraseña.',
    this.signInText = 'Iniciar sesión',
    this.registerText = 'Registrarse',
    this.registerHintText = '¿No tienes una cuenta?',
    this.signInHintText = '¿Ya tienes una cuenta?',
    this.signOutButtonText = 'Cerrar sesión',
    this.phoneInputLabel = 'Número de teléfono',
    this.phoneNumberInvalidErrorText = 'El número de teléfono no es válido',
    this.phoneNumberIsRequiredErrorText =
        'El número de teléfono es obligatorio',
    this.profile = 'Perfil',
    this.name = 'Nombre',
    this.deleteAccount = 'Eliminar cuenta',
    this.passwordIsRequiredErrorText = 'La contraseña es obligatoria',
    this.confirmPasswordIsRequiredErrorText = 'Confirma tu contraseña',
    this.confirmPasswordDoesNotMatchErrorText = 'Las contraseñas no coinciden',
    this.confirmPasswordInputLabel = 'Confirma la contraseña',
    this.forgotPasswordButtonLabel = '¿Has olvidado tu contraseña?',
    this.forgotPasswordViewTitle = 'Contraseña olvidada',
    this.resetPasswordButtonLabel = 'Restablecer contraseña',
    this.verifyItsYouText = 'Verifica que eres tú',
    this.differentMethodsSignInTitleText =
        'Utilice uno de los siguientes métodos para iniciar sesión',
    this.findProviderForEmailTitleText =
        'Introduce su correo electrónico para continuar',
    this.continueText = 'Continuar',
    this.countryCode = 'Código de país',
    this.invalidCountryCode = 'El código del país es inválido',
    this.chooseACountry = 'Seleccione un país',
    this.enableMoreSignInMethods = 'Habilitar más métodos de inicio de sesión',
    this.signInMethods = 'Métodos de inicio de sesión',
    this.provideEmail = 'Proporcione su correo electrónico y contraseña',
    this.goBackButtonLabel = 'Volver',
    this.passwordResetEmailSentText =
        'Le enviamos un correo electrónico con un enlace para restablecer su contraseña. Por favor revise su correo electrónico.',
    this.forgotPasswordHintText =
        'Introduce su correo electrónico y le enviaremos un enlace para restablecer su contraseña',
    this.emailLinkSignInButtonLabel = 'Iniciar sesión con enlace mágico',
    this.signInWithEmailLinkViewTitleText = 'Iniciar sesión con enlace mágico',
    this.signInWithEmailLinkSentText =
        'Le hemos enviado un correo electrónico con un enlace mágico. Revise su correo electrónico y siga el enlace para iniciar sesión',
    this.sendLinkButtonLabel = 'Enviar enlace mágico',
    this.arrayLabel = 'arreglo',
    this.booleanLabel = 'booleano',
    this.mapLabel = 'mapa',
    this.nullLabel = 'nulo',
    this.numberLabel = 'número',
    this.stringLabel = 'string',
    this.typeLabel = 'tipo',
    this.valueLabel = 'valor',
    this.cancelLabel = 'cancelar',
    this.updateLabel = 'actualizar',
    this.northInitialLabel = 'N',
    this.southInitialLabel = 'S',
    this.westInitialLabel = 'O',
    this.eastInitialLabel = 'E',
    this.timestampLabel = 'marca de tiempo',
    this.longitudeLabel = 'longitud',
    this.latitudeLabel = 'latitud',
    this.geopointLabel = 'geopunto',
    this.referenceLabel = 'referencia',
  });
}
