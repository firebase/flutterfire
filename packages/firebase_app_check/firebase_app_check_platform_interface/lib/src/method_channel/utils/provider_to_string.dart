import 'package:firebase_app_check_platform_interface/src/android_provider.dart';

/// Converts [Provider] to [String]
String getProviderString(AndroidProvider? provider) {
  switch (provider) {
    case AndroidProvider.playIntegrity:
      return 'playIntegrity';
    case AndroidProvider.safetyNet:
      return 'safetyNet';
    case AndroidProvider.debug:
    default:
      return 'debug';
  }
}
