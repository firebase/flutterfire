import '../default_localizations.dart';

class HiLocalizations extends FirebaseUILocalizationLabels {
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

  const HiLocalizations({
    this.emailInputLabel = 'ईमेल',
    this.passwordInputLabel = 'पासवर्ड',
    this.signInActionText = 'साइन इन करें',
    this.registerActionText = 'रजिस्टर करें',
    this.linkEmailButtonText = 'अगला',
    this.signInWithPhoneButtonText = 'फ़ोन से साइन इन करें',
    this.signInWithGoogleButtonText = 'Google के साथ साइन इन करें',
    this.signInWithAppleButtonText = 'Apple के साथ साइन इन करें',
    this.signInWithTwitterButtonText = 'Twitter के साथ साइन इन करें',
    this.signInWithFacebookButtonText = 'Facebook के साथ साइन इन करें',
    this.phoneVerificationViewTitleText = 'अपना दूरभाष क्रमांक दर्ज करें',
    this.verifyPhoneNumberButtonText = 'अगला',
    this.verifyCodeButtonText = 'सत्यापित करें',
    this.unknownError = 'एक अज्ञात त्रुटि हुई',
    this.smsAutoresolutionFailedError =
        'एसएमएस कोड को स्वचालित रूप से हल करने में विफल। कृपया अपना कोड मैन्युअल रूप से दर्ज करें',
    this.verifyingSMSCodeText = 'एसएमएस कोड सत्यापित किया जा रहा है...',
    this.enterSMSCodeText = 'एसएमएस कोड दर्ज करें',
    this.emailIsRequiredErrorText = 'ईमेल की जरूरत है',
    this.isNotAValidEmailErrorText = 'एक वैध ईमेल प्रदान करें',
    this.userNotFoundErrorText = 'ईमेल अकाउंट मौजूद नहीं है',
    this.emailTakenErrorText = 'ऐसे ईमेल वाला अकाउंट पहले से मौजूद है',
    this.accessDisabledErrorText =
        'इस ईमेल अकाउंट तक पहुंच अस्थायी रूप से अक्षम कर दी गई है',
    this.wrongOrNoPasswordErrorText =
        'पासवर्ड अमान्य है या उपयोगकर्ता के पास पासवर्ड नहीं है',
    this.signInText = 'साइन इन करें',
    this.registerText = 'रजिस्टर करें',
    this.registerHintText = 'अकाउंट नहीं है?',
    this.signInHintText = 'क्या आपके पास पहले से एक अकाउंट मौजूद है?',
    this.signOutButtonText = 'साइन आउट',
    this.phoneInputLabel = 'फ़ोन नंबर',
    this.phoneNumberInvalidErrorText = 'फ़ोन नंबर अमान्य है',
    this.phoneNumberIsRequiredErrorText = 'फ़ोन नंबर आवश्यक है',
    this.profile = 'प्रोफ़ाइल',
    this.name = 'नाम',
    this.deleteAccount = 'अकाउंट डिलीट करें',
    this.passwordIsRequiredErrorText = 'पासवर्ड की आवश्यकता है',
    this.confirmPasswordIsRequiredErrorText = 'अपने पासवर्ड की पुष्टि करें',
    this.confirmPasswordDoesNotMatchErrorText = 'पासवर्ड मेल नहीं खाते',
    this.confirmPasswordInputLabel = 'पुष्टि करें',
    this.forgotPasswordButtonLabel = 'पासवर्ड भूल गए?',
    this.forgotPasswordViewTitle = 'पासवर्ड भूल गए',
    this.resetPasswordButtonLabel = 'पासवर्ड रीसेट',
    this.verifyItsYouText = 'सत्यापित करें कि यह आप हैं',
    this.differentMethodsSignInTitleText =
        'साइन इन करने के लिए निम्न विधियों में से एक का उपयोग करें',
    this.findProviderForEmailTitleText = 'आगे बढ़ने के लिए अपना ईमेल दर्ज करें',
    this.continueText = 'आगे बढ़े',
    this.countryCode = 'कोड',
    this.invalidCountryCode = 'अमान्य कोड',
    this.chooseACountry = 'अपना देश चुनें',
    this.enableMoreSignInMethods = 'अधिक साइन इन विधियों को सक्षम करें',
    this.signInMethods = 'साइन इन करने के तरीके',
    this.provideEmail = 'अपना ईमेल और पासवर्ड प्रदान करें',
    this.goBackButtonLabel = 'वापस जाएं',
    this.passwordResetEmailSentText =
        'हमने आपको आपका पासवर्ड रीसेट करने के लिए एक लिंक के साथ एक ईमेल भेजा है। कृपया अपनी ईमेल देखें।',
    this.forgotPasswordHintText =
        'अपना ईमेल प्रदान करें और हम आपको आपका पासवर्ड रीसेट करने के लिए एक लिंक भेजेंगे',
    this.emailLinkSignInButtonLabel = 'मैजिक लिंक के साथ साइन इन करें',
    this.signInWithEmailLinkViewTitleText = 'मैजिक लिंक के साथ साइन इन करें',
    this.signInWithEmailLinkSentText =
        'हमने आपको एक जादुई लिंक के साथ एक ईमेल भेजा है। अपना ईमेल जांचें और साइन इन करने के लिए लिंक का अनुसरण करें',
    this.sendLinkButtonLabel = 'मैजिक लिंक भेजें',
    this.arrayLabel = 'सरणी',
    this.booleanLabel = 'बूलियन',
    this.mapLabel = 'मैप',
    this.nullLabel = 'खाली',
    this.numberLabel = 'नंबर',
    this.stringLabel = 'स्ट्रिंग',
    this.typeLabel = 'टाइप',
    this.valueLabel = 'वैल्यू',
    this.cancelLabel = 'रद्द करें',
    this.updateLabel = 'अपडेट',
    this.northInitialLabel = 'N',
    this.southInitialLabel = 'S',
    this.westInitialLabel = 'W',
    this.eastInitialLabel = 'E',
    this.timestampLabel = 'टाइमस्टैंप',
    this.longitudeLabel = 'लोंगिट्यूड',
    this.latitudeLabel = 'लैटीट्यूड',
    this.geopointLabel = 'भू बिंदु',
    this.referenceLabel = 'संदर्भ',
  });
}
