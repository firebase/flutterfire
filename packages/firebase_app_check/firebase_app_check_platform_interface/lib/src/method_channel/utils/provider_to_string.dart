import 'package:firebase_app_check_platform_interface/src/android_provider.dart';

/// Converts [Provider] to [String]
String getProviderString(AndroidProvider? provider) {
  switch (provider) {
    // ignore: deprecated_member_use_from_same_package
    case AndroidProvider.safetyNet:
      return 'safetyNet';
    case AndroidProvider.debug:
      return 'debug';
    case AndroidProvider.playIntegrity:
    default:
      return 'playIntegrity';
  }
}
