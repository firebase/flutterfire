import '../default_localizations.dart';

class EnLocalizations extends FlutterFireUILocalizationLabels {
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

  const EnLocalizations({
    this.emailInputLabel = 'Email',
    this.passwordInputLabel = 'Password',
    this.signInActionText = 'Sign in',
    this.registerActionText = 'Register',
    this.signInButtonText = 'Sign in',
    this.registerButtonText = 'Register',
    this.linkEmailButtonText = 'Agla',
    this.signInWithPhoneButtonText = 'Sign in with phone',
    this.signInWithGoogleButtonText = 'Sign in with Google',
    this.signInWithAppleButtonText = 'Sign in with Apple',
    this.signInWithTwitterButtonText = 'Sign in with Twitter',
    this.signInWithFacebookButtonText = 'Sign in with Facebook',
    this.phoneVerificationViewTitleText = 'Apna phone number daalein',
    this.verifyPhoneNumberButtonText = 'Next',
    this.verifyCodeButtonText = 'Verify',
    this.verifyingPhoneNumberViewTitle = 'Enter code from SMS',
    this.unknownError = 'An unknown error occurred',
    this.smsAutoresolutionFailedError =
        'Failed to resolve SMS code automatically. Manually code enter karein',
    this.smsCodeSentText = 'SMS code sent',
    this.sendingSMSCodeText = 'Sending SMS code...',
    this.verifyingSMSCodeText = 'Verifying SMS code...',
    this.enterSMSCodeText = 'Enter SMS code',
    this.emailIsRequiredErrorText = 'Email is required',
    this.isNotAValidEmailErrorText = 'Email provide karein',
    this.userNotFoundErrorText = "Account doesn't exist",
    this.emailTakenErrorText = 'Account with such email already exists',
    this.accessDisabledErrorText =
        'Access to this account has been temporarily disabled',
    this.wrongOrNoPasswordErrorText =
        'The password is invalid or the user does not have a password',
    this.signInText = 'Sign in',
    this.registerText = 'Register',
    this.registerHintText = "Don't have an account?",
    this.signInHintText = 'Already have an account?',
    this.signOutButtonText = 'Sign out',
    this.phoneInputLabel = 'Phone number',
    this.phoneNumberInvalidErrorText = 'Phone number is invalid',
    this.phoneNumberIsRequiredErrorText = 'Phone number zaroori hai',
    this.profile = 'Profile',
    this.name = 'Name',
    this.deleteAccount = 'Delete account',
    this.passwordIsRequiredErrorText = 'Password zaroori hai',
    this.confirmPasswordIsRequiredErrorText = 'Confirm your password',
    this.confirmPasswordDoesNotMatchErrorText = 'Passwords nahi milte',
    this.confirmPasswordInputLabel = 'Confirm password',
    this.forgotPasswordButtonLabel = 'Forgot password?',
    this.forgotPasswordViewTitle = 'Forgot password',
    this.resetPasswordButtonLabel = 'Reset password',
    this.verifyItsYouText = "Verify it's you",
    this.differentMethodsSignInTitleText =
        'Inmei sey koi ek Sign in method chunnei',
    this.findProviderForEmailTitleText = 'Enter your email to continue',
    this.continueText = 'Continue',
    this.countryCode = 'Code',
    this.codeRequiredErrorText = 'Country code zaroori hai',
    this.invalidCountryCode = 'Invalid code',
    this.chooseACountry = 'Country choose karein',
    this.enableMoreSignInMethods = 'Enable more sign in methods',
    this.signInMethods = 'Sign in methods',
    this.provideEmail = 'Email and password provide karein',
    this.goBackButtonLabel = 'Go back',
    this.passwordResetEmailSentText =
        "Humne apko Password reset karne ka link bheja hai. Email check karien",
    this.forgotPasswordHintText =
        'Password reset link panei ke liye Email provide karein',
    this.emailLinkSignInButtonLabel = 'Sign in with magic link',
    this.signInWithEmailLinkViewTitleText = 'Sign in with magic link',
    this.signInWithEmailLinkSentText =
        "Humne apko email bheji hai with a magic link. Usse check karke follow karein",
    this.sendLinkButtonLabel = 'Send magic link',
    this.arrayLabel = 'array',
    this.booleanLabel = 'boolean',
    this.mapLabel = 'map',
    this.nullLabel = 'null',
    this.numberLabel = 'number',
    this.stringLabel = 'string',
    this.typeLabel = 'type',
    this.valueLabel = 'value',
    this.cancelLabel = 'cancel',
    this.updateLabel = 'update',
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