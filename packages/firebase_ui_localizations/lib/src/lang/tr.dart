import '../default_localizations.dart';

class TrLocalizations extends FirebaseUILocalizationLabels {
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

  const TrLocalizations({
    this.emailInputLabel = 'E-mail',
    this.passwordInputLabel = 'Şifre',
    this.signInActionText = 'Giriş yap',
    this.registerActionText = 'Kayıt ol',
    this.linkEmailButtonText = 'İleri',
    this.signInWithPhoneButtonText = 'Telefon ile giriş yap',
    this.signInWithGoogleButtonText = 'Google ile giriş yap',
    this.signInWithAppleButtonText = 'Apple ile giriş yap',
    this.signInWithTwitterButtonText = 'Twitter ile giriş yap',
    this.signInWithFacebookButtonText = 'Facebook ile giriş yap',
    this.phoneVerificationViewTitleText = 'Telefon numaranızı girin',
    this.verifyPhoneNumberButtonText = 'İleri',
    this.verifyCodeButtonText = 'Doğrula',
    this.unknownError = 'Bilinmeyen bir hata meydana geldi',
    this.smsAutoresolutionFailedError =
        'SMS kodu otomatik olarak eklenemedi. Lütfen kodu manuel olarak girin',
    this.verifyingSMSCodeText = 'SMS kodu doğrulanıyor...',
    this.enterSMSCodeText = 'SMS kodunu girin',
    this.emailIsRequiredErrorText = 'E-mail gerekli',
    this.isNotAValidEmailErrorText = 'Geçerli bir e-mail adresi girin',
    this.userNotFoundErrorText = 'Hesap bulunamadı',
    this.emailTakenErrorText = 'Bu email ile bir hesap mevcut',
    this.accessDisabledErrorText =
        'Bu hesaba erişim geçici olarak devre dışı bırakıldı.',
    this.wrongOrNoPasswordErrorText =
        'Şifre geçersiz veya kullanıcının bir şifresi yok',
    this.signInText = 'Giriş yap',
    this.registerText = 'Kayıt ol',
    this.registerHintText = 'Hesabın yok mu?',
    this.signInHintText = 'Zaten bir hesabın var mı?',
    this.signOutButtonText = 'Çıkış yap',
    this.phoneInputLabel = 'Telefon numarası',
    this.phoneNumberInvalidErrorText = 'Telefon numarası geçersiz',
    this.phoneNumberIsRequiredErrorText = 'Telefon numarası gerekli',
    this.profile = 'Profil',
    this.name = 'İsim',
    this.deleteAccount = 'Hesabı sil',
    this.passwordIsRequiredErrorText = 'Şifre gerekli',
    this.confirmPasswordIsRequiredErrorText = 'Şifrenizi onaylayın',
    this.confirmPasswordDoesNotMatchErrorText = 'Şifreler uyuşmadı',
    this.confirmPasswordInputLabel = 'Şifreni onayla',
    this.forgotPasswordButtonLabel = 'Şifrenizi mi unuttunuz?',
    this.forgotPasswordViewTitle = 'Şifremi unuttum',
    this.resetPasswordButtonLabel = 'Şifreyi sıfırla',
    this.verifyItsYouText = 'Siz olduğunuzu doğrulayın',
    this.differentMethodsSignInTitleText =
        'Giriş yapmak için aşağıdaki yöntemlerden birini kullanın',
    this.findProviderForEmailTitleText =
        'Devam etmek için email adresinizi girin',
    this.continueText = 'Devam et',
    this.countryCode = 'Kod',
    this.invalidCountryCode = 'Geçersiz kod',
    this.chooseACountry = 'Bir ülke seçin',
    this.enableMoreSignInMethods = 'Daha fazla oturum açma yöntemi etkinleştir',
    this.signInMethods = 'Oturum açma yöntemleri',
    this.provideEmail = 'Email ve şifrenizi girin',
    this.goBackButtonLabel = 'Geri git',
    this.passwordResetEmailSentText =
        'Şifrenizi sıfırlamak için size email ile bir link gönderdik. Lütfen emailinizi kontrol edin.',
    this.forgotPasswordHintText =
        'E-mail adresinizi verin ve size şifrenizi sıfırlamanız için bir bağlantı gönderelim',
    this.emailLinkSignInButtonLabel = 'Sihirli bağlantı ile giriş yap',
    this.signInWithEmailLinkViewTitleText = 'Sihirli bağlantı ile giriş yap',
    this.signInWithEmailLinkSentText =
        'Sana sihirli bir link ile bir email gönderdik. Emailinizi kontrol edin ve oturum açmak için bağlantıyı takip edin',
    this.sendLinkButtonLabel = 'Sihirli bağlantı gönder',
    this.arrayLabel = 'array',
    this.booleanLabel = 'boolean',
    this.mapLabel = 'map',
    this.nullLabel = 'null',
    this.numberLabel = 'number',
    this.stringLabel = 'string',
    this.typeLabel = 'type',
    this.valueLabel = 'value',
    this.cancelLabel = 'iptal',
    this.updateLabel = 'güncelle',
    this.northInitialLabel = 'K',
    this.southInitialLabel = 'G',
    this.westInitialLabel = 'D',
    this.eastInitialLabel = 'B',
    this.timestampLabel = 'timestamp',
    this.longitudeLabel = 'longitude',
    this.latitudeLabel = 'latitude',
    this.geopointLabel = 'geopoint',
    this.referenceLabel = 'reference',
  });
}
