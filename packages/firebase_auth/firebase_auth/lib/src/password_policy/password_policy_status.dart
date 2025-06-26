import 'password_policy.dart';

class PasswordPolicyStatus {
  bool status;
  final PasswordPolicy passwordPolicy;

  // Initialize all fields to true by default (meaning they pass validation)
  bool meetsMinPasswordLength = true;
  bool meetsMaxPasswordLength = true;
  bool meetsLowercaseRequirement = true;
  bool meetsUppercaseRequirement = true;
  bool meetsDigitsRequirement = true;
  bool meetsSymbolsRequirement = true;

  PasswordPolicyStatus(this.status, this.passwordPolicy);
}
