import '../default_localizations.dart';

class ZhLocalizations extends FirebaseUILocalizationLabels {
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

  const ZhLocalizations({
    this.emailInputLabel = '电子邮箱',
    this.passwordInputLabel = '密码',
    this.signInActionText = '登录',
    this.registerActionText = '注册',
    this.linkEmailButtonText = '下一步',
    this.signInWithPhoneButtonText = '使用手机号登录',
    this.signInWithGoogleButtonText = '使用Google登录',
    this.signInWithAppleButtonText = '使用Apple登录',
    this.signInWithTwitterButtonText = '使用Twitter登录',
    this.signInWithFacebookButtonText = '使用Facebook登录',
    this.phoneVerificationViewTitleText = '输入手机号码',
    this.verifyPhoneNumberButtonText = '下一步',
    this.verifyCodeButtonText = '验证',
    this.unknownError = '发生未知错误',
    this.smsAutoresolutionFailedError = '无法自动解析短信验证码。请手动输入验证码',
    this.verifyingSMSCodeText = '正在验证短信验证码...',
    this.enterSMSCodeText = '输入短信验证码',
    this.emailIsRequiredErrorText = '电子邮箱地址为必填项',
    this.isNotAValidEmailErrorText = '请输入有效的电子邮箱地址',
    this.userNotFoundErrorText = '账户不存在',
    this.emailTakenErrorText = '该邮箱已被注册',
    this.accessDisabledErrorText = '该账户已被暂时禁止访问',
    this.wrongOrNoPasswordErrorText = '密码无效或改账户没有密码',
    this.signInText = '登录',
    this.registerText = '注册',
    this.registerHintText = '没有账户',
    this.signInHintText = '已有账户？',
    this.signOutButtonText = '退出登录',
    this.phoneInputLabel = '手机号',
    this.phoneNumberInvalidErrorText = '手机号码无效',
    this.phoneNumberIsRequiredErrorText = '手机号码为必填项',
    this.profile = '资料',
    this.name = '姓名',
    this.deleteAccount = '删除账户',
    this.passwordIsRequiredErrorText = '密码为必填项',
    this.confirmPasswordIsRequiredErrorText = '确认密码',
    this.confirmPasswordDoesNotMatchErrorText = '两次输入的密码不一致',
    this.confirmPasswordInputLabel = '确认密码',
    this.forgotPasswordButtonLabel = '忘记密码？',
    this.forgotPasswordViewTitle = '忘记密码',
    this.resetPasswordButtonLabel = '重置密码',
    this.verifyItsYouText = '身份验证',
    this.differentMethodsSignInTitleText = '使用下面任意一种方式登录',
    this.findProviderForEmailTitleText = '输入电子邮箱以继续',
    this.continueText = '继续',
    this.countryCode = '地区代码',
    this.invalidCountryCode = '无效的地区代码',
    this.chooseACountry = '选择一个国家或地区',
    this.enableMoreSignInMethods = '启用更多登录方式',
    this.signInMethods = '登录方式',
    this.provideEmail = '输入电子邮箱和密码',
    this.goBackButtonLabel = '返回',
    this.passwordResetEmailSentText = '我们向您的邮箱发送了重置密码的链接。请查看您的邮箱',
    this.forgotPasswordHintText = '输入您的邮箱以便我们为您发送重置密码的链接',
    this.emailLinkSignInButtonLabel = '使用魔法链接登录',
    this.signInWithEmailLinkViewTitleText = '使用魔法链接登录',
    this.signInWithEmailLinkSentText = '我们向您的邮箱发送了魔法链接。请查看您的邮箱并点击链接登录',
    this.sendLinkButtonLabel = '发送魔法链接',
    this.arrayLabel = '数组',
    this.booleanLabel = '布尔',
    this.mapLabel = '图',
    this.nullLabel = '空',
    this.numberLabel = '数',
    this.stringLabel = '字符串',
    this.typeLabel = '类型',
    this.valueLabel = '值',
    this.cancelLabel = '取消',
    this.updateLabel = '更新',
    this.northInitialLabel = '北',
    this.southInitialLabel = '南',
    this.westInitialLabel = '西',
    this.eastInitialLabel = '东',
    this.timestampLabel = '时间戳',
    this.longitudeLabel = '经度',
    this.latitudeLabel = '维度',
    this.geopointLabel = '地理点',
    this.referenceLabel = '引用',
  });
}
