import '../default_localizations.dart';

class ArLocalizations extends FirebaseUILocalizationLabels {
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

  const ArLocalizations({
    this.emailInputLabel = 'البريد الإلكتروني',
    this.passwordInputLabel = 'كلمة المرور',
    this.signInActionText = 'تسجيل الدخول',
    this.registerActionText = 'تسجيل جديد',
    this.linkEmailButtonText = 'التالي',
    this.signInWithPhoneButtonText = 'تسجيل الدخول برقم الهاتف',
    this.signInWithGoogleButtonText = 'تسجيل الدخول باستخدام Google',
    this.signInWithAppleButtonText = 'تسجيل الدخول باستخدام Apple',
    this.signInWithTwitterButtonText = 'تسجيل الدخول باستخدام Twitter',
    this.signInWithFacebookButtonText = 'تسجيل الدخول باستخدام Facebook',
    this.phoneVerificationViewTitleText = 'أدخل رقم هاتفك',
    this.verifyPhoneNumberButtonText = 'التالي',
    this.verifyCodeButtonText = 'تحقق',
    this.unknownError = 'حدث خطأ غير متوقع',
    this.smsAutoresolutionFailedError =
        'حدث خطأ أثناء محاولة قراءة الرمز تلقائياً. رجاءً قم بإدخاله يدوياً',
    this.verifyingSMSCodeText = 'جاري التحقق من الرمز المرسل...',
    this.enterSMSCodeText = 'أدخل الرمز المرسل',
    this.emailIsRequiredErrorText = 'البريد الإلكتروني مطلوب',
    this.isNotAValidEmailErrorText = 'رجاء قم بإدخال بريد إلكتروني صالح',
    this.userNotFoundErrorText = 'هذا الحساب غير موجود',
    this.emailTakenErrorText = 'هذا البريد الإلكتروني مستخدم مسبقاً',
    this.accessDisabledErrorText = 'تم تعطيل الوصول إلى هذا الحساب مؤقتًا',
    this.wrongOrNoPasswordErrorText =
        'كلمة المرور غير صالحة أو أن هذا المستخدم ليس لديه كلمة مرور',
    this.signInText = 'تسجيل الدخول',
    this.registerText = 'إنشاء حساب',
    this.registerHintText = 'ليس لديك حساب مسبقا؟',
    this.signInHintText = 'لديك حساب مسبقا؟',
    this.signOutButtonText = 'تسجيل الخروج',
    this.phoneInputLabel = 'رقم الهاتف',
    this.phoneNumberInvalidErrorText = 'رقم الهاتف المدخل غير صالح',
    this.phoneNumberIsRequiredErrorText = 'رقم الهاتف مطلوب',
    this.profile = 'الملف الشخصي',
    this.name = 'الاسم',
    this.deleteAccount = 'حذف الحساب',
    this.passwordIsRequiredErrorText = 'كلمة المرور مطلوبة',
    this.confirmPasswordIsRequiredErrorText = 'قم بتأكيد كلمة مرورك',
    this.confirmPasswordDoesNotMatchErrorText =
        'كلمات المرور المدخلة غير متطابقة',
    this.confirmPasswordInputLabel = 'تأكيد كلمة المرور',
    this.forgotPasswordButtonLabel = 'نسيت كلمة المرور؟',
    this.forgotPasswordViewTitle = 'استرجاع كلمة المرور المنسية',
    this.resetPasswordButtonLabel = 'إعادة تعيين كلمة المرور',
    this.verifyItsYouText = 'تحقق من هويتك',
    this.differentMethodsSignInTitleText =
        'استخدم إحدى الطرق التالية لتسجيل الدخول',
    this.findProviderForEmailTitleText = 'أدخل بريدك الإلكتروني للمتابعة',
    this.continueText = 'استمرار',
    this.countryCode = 'رمز الدولة',
    this.invalidCountryCode = 'رمز الدولة هذا غير صالح',
    this.chooseACountry = 'اختر الدولة',
    this.enableMoreSignInMethods = 'تفعيل المزيد من طرق تسجيل الدخول',
    this.signInMethods = 'طرق تسجيل الدخول',
    this.provideEmail = 'أدخل بريدك الإلكتروني وكلمة المرور',
    this.goBackButtonLabel = 'رجوع',
    this.passwordResetEmailSentText =
        'لقد أرسلنا إليك بريدًا إلكترونيًا يحتوي على رابط لإعادة تعيين كلمة المرور الخاصة بك. من فضلك تفقد بريدك الالكتروني',
    this.forgotPasswordHintText =
        'أدخل بريدك الإلكتروني وسنرسل لك رابطًا لإعادة تعيين كلمة مرورك',
    this.emailLinkSignInButtonLabel = 'تسجيل الدخول عن طريق الرابط',
    this.signInWithEmailLinkViewTitleText = 'تسجيل الدخول عن طريق الرابط',
    this.signInWithEmailLinkSentText =
        'لقد أرسلنا رابط تسجيل الدخول إلى بريدك الإلكتروني. تفقد صندوق رسائلك واضغط على الرابط لتسجيل الدخول',
    this.sendLinkButtonLabel = 'أرسل رابط تسجيل الدخول',
    this.arrayLabel = 'مصفوفة',
    this.booleanLabel = 'قيمة منطقية',
    this.mapLabel = 'كائن',
    this.nullLabel = 'بدون قيمة',
    this.numberLabel = 'رقم',
    this.stringLabel = 'نص',
    this.typeLabel = 'نوع',
    this.valueLabel = 'قيمة',
    this.cancelLabel = 'إلغاء',
    this.updateLabel = 'تحديث',
    this.northInitialLabel = 'شمال',
    this.southInitialLabel = 'جنوب',
    this.westInitialLabel = 'غرب',
    this.eastInitialLabel = 'شرق',
    this.timestampLabel = 'طابع زمني',
    this.longitudeLabel = 'خط الطول',
    this.latitudeLabel = 'خط العرض',
    this.geopointLabel = 'نقطة جغرافية',
    this.referenceLabel = 'مرجع',
  });
}
