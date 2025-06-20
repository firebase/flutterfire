import 'password_policy.dart';

class PasswordPolicyStatus {
  bool status;
  final PasswordPolicy passwordPolicy;

  late bool meetsMinPasswordLength;
  late bool meetsMaxPasswordLength;
  late bool meetsLowercaseRequirement;
  late bool meetsUppercaseRequirement;
  late bool meetsDigitsRequirement;
  late bool meetsSymbolsRequirement;

  PasswordPolicyStatus(this.status, this.passwordPolicy);
}
