import '../default_localizations.dart';

class JaLocalizations extends FirebaseUILocalizationLabels {
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

  const JaLocalizations({
    this.emailInputLabel = 'Eメール',
    this.passwordInputLabel = 'パスワード',
    this.signInActionText = 'サインイン',
    this.registerActionText = '新規登録',
    this.linkEmailButtonText = '次へ',
    this.signInWithPhoneButtonText = '電話番号でサインイン',
    this.signInWithGoogleButtonText = 'Googleでサインイン',
    this.signInWithAppleButtonText = 'Appleでサインイン',
    this.signInWithTwitterButtonText = 'Twitterでサインイン',
    this.signInWithFacebookButtonText = 'Facebookでサインイン',
    this.phoneVerificationViewTitleText = '電話番号を入力してください',
    this.verifyPhoneNumberButtonText = '次へ',
    this.verifyCodeButtonText = '認証',
    this.unknownError = '不明なエラーが発生しました',
    this.smsAutoresolutionFailedError = 'SMSコードの自動認証に失敗しました。コードを手動で入力してください。',
    this.verifyingSMSCodeText = 'SMSコードを認証中...',
    this.enterSMSCodeText = 'SMSコードを入力',
    this.emailIsRequiredErrorText = 'メールアドレスは必須項目です',
    this.isNotAValidEmailErrorText = 'メールアドレスの形式が正しくありません',
    this.userNotFoundErrorText = 'アカウントが存在しません',
    this.emailTakenErrorText = 'このメールアドレスはすでに使用されています',
    this.accessDisabledErrorText = 'このアカウントへのアクセスは一時的に停止されています',
    this.wrongOrNoPasswordErrorText = 'パスワードが無効である、またはユーザーがパスワードを持っていません',
    this.signInText = 'サインイン',
    this.registerText = '新規登録',
    this.registerHintText = 'アカウントをお持ちでない方',
    this.signInHintText = 'すでにアカウントをお持ちの方',
    this.signOutButtonText = 'サインアウト',
    this.phoneInputLabel = '電話番号',
    this.phoneNumberInvalidErrorText = '電話番号が無効です',
    this.phoneNumberIsRequiredErrorText = '電話番号は必須項目です',
    this.profile = 'プロフィール',
    this.name = '名前',
    this.deleteAccount = 'アカウントを削除',
    this.passwordIsRequiredErrorText = 'パスワードは必須項目です',
    this.confirmPasswordIsRequiredErrorText = 'パスワードの確認は必須項目です',
    this.confirmPasswordDoesNotMatchErrorText = 'パスワードが一致しません',
    this.confirmPasswordInputLabel = 'パスワードの確認',
    this.forgotPasswordButtonLabel = 'パスワードを忘れた方はこちら',
    this.forgotPasswordViewTitle = 'パスワードを忘れた場合',
    this.resetPasswordButtonLabel = 'パスワードをリセット',
    this.verifyItsYouText = '本人確認をします',
    this.differentMethodsSignInTitleText = '以下のいずれかの方法でサインインしてください',
    this.findProviderForEmailTitleText = 'Eメールを入力して次へ',
    this.continueText = '続ける',
    this.countryCode = '国番号',
    this.invalidCountryCode = '国番号が無効です',
    this.chooseACountry = '国を選択してください',
    this.enableMoreSignInMethods = 'より多くのサインイン方法を有効にする',
    this.signInMethods = 'サインイン方法',
    this.provideEmail = 'メールアドレスとパスワードを入力してください',
    this.goBackButtonLabel = '戻る',
    this.passwordResetEmailSentText =
        'パスワードをリセットするためのリンクを記載したメールを送信しました。メールをご確認ください。',
    this.forgotPasswordHintText = 'パスワードをリセットするためのリンクを送信します',
    this.emailLinkSignInButtonLabel = 'マジックリンクでサインイン',
    this.signInWithEmailLinkViewTitleText = 'マジックリンクでサインイン',
    this.signInWithEmailLinkSentText =
        'マジックリンクが記載されたメールを送信しました。メールをご確認の上、リンクからサインインしてください。',
    this.sendLinkButtonLabel = 'マジックリンクを送信',
    this.arrayLabel = 'array',
    this.booleanLabel = 'boolean',
    this.mapLabel = 'map',
    this.nullLabel = 'null',
    this.numberLabel = 'number',
    this.stringLabel = 'string',
    this.typeLabel = 'type',
    this.valueLabel = 'value',
    this.cancelLabel = 'キャンセル',
    this.updateLabel = '更新',
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
