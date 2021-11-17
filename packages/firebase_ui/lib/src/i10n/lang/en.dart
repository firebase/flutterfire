import '../default_localizations.dart';

class EnLocalizations extends FirebaseUILocalizationLabels {
  @override
  final String emailInputLabel;
  @override
  final String passwordInputLabel;
  @override
  final String signInActionText;
  @override
  final String signUpActionText;
  @override
  final String linkEmailButtonText;
  @override
  final String signInButtonText;
  @override
  final String signUpButtonText;
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

  const EnLocalizations({
    this.emailInputLabel = 'Email',
    this.passwordInputLabel = 'Password',
    this.signInActionText = 'Sign in',
    this.signUpActionText = 'Sign up',
    this.signInButtonText = 'Sign in',
    this.signUpButtonText = 'Sign up',
    this.linkEmailButtonText = 'Next',
    this.signInWithPhoneButtonText = 'Sign in with phone',
    this.signInWithGoogleButtonText = 'Sign in with Google',
    this.signInWithAppleButtonText = 'Sign in with Apple',
    this.signInWithTwitterButtonText = 'Sign in with Twitter',
    this.signInWithFacebookButtonText = 'Sign in with Facebook',
    this.phoneVerificationViewTitleText = 'Enter your phone number',
    this.verifyPhoneNumberButtonText = 'Next',
    this.verifyCodeButtonText = 'Verify',
    this.verifyingPhoneNumberViewTitle = 'Enter code from SMS',
    this.unknownError = 'An unknown error occured',
    this.smsAutoresolutionFailedError =
        'Failed to resolve SMS code automatically. Please enter your code manually',
    this.smsCodeSentText = 'SMS code sent',
    this.sendingSMSCodeText = 'Sending SMS code...',
    this.verifyingSMSCodeText = 'Verifying SMS code...',
    this.enterSMSCodeText = 'Enter SMS code',
    this.emailIsRequiredErrorText = 'Email is required',
    this.isNotAValidEmailErrorText = 'Provide a valid email',
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
  });
}
