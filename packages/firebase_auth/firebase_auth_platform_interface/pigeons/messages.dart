import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeon/messages.pigeon.dart',
    // We export in the lib folder to expose the class to other packages.
    dartTestOut: 'lib/src/pigeon/test_api.dart',
    javaOut:
        '../firebase_auth/android/src/main/java/io/flutter/plugins/firebase/auth/GeneratedAndroidFirebaseAuth.java',
    javaOptions: JavaOptions(
      package: 'io.flutter.plugins.firebase.auth',
      className: 'GeneratedAndroidFirebaseAuth',
    ),
    objcHeaderOut: '../firebase_auth/ios/Classes/messages.g.h',
    objcSourceOut: '../firebase_auth/ios/Classes/messages.g.m',
  ),
)
class PigeonMultiFactorAssertion {
  const PigeonMultiFactorAssertion({
    required this.id,
  });

  final String id;
}

class PigeonMultiFactorSession {
  const PigeonMultiFactorSession({
    required this.id,
  });

  final String id;
}

@HostApi(dartHostTestHandler: 'TestMultiFactorUserHostApi')
abstract class MultiFactorUserHostApi {
  void enroll(
    String appName,
    PigeonMultiFactorAssertion assertion,
    String? displayName,
  );

  @async
  PigeonMultiFactorSession getSession(String appName);
}
