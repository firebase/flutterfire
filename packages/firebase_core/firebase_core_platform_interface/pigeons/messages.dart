// ignore_for_file: avoid_positional_boolean_parameters, one_member_abstracts

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.pigeon.dart',
    javaOut:
        '../firebase_core/android/src/main/java/io/flutter/plugins/firebase/core/GeneratedAndroidFirebaseCore.java',
    javaOptions: JavaOptions(
      package: 'io.flutter.plugins.firebase.core',
      className: 'GeneratedAndroidFirebaseCore',
    ),
  ),
)
class PigeonInitializeAppRequest {
  PigeonInitializeAppRequest({
    required this.apiKey,
    required this.appName,
    required this.appId,
    required this.messagingSenderId,
    required this.projectId,
    required this.databaseURL,
    required this.storageBucket,
    required this.trackingId,
  });

  String apiKey;
  String? appName;
  String appId;
  String messagingSenderId;
  String projectId;
  String? databaseURL;
  String? storageBucket;
  String? trackingId;
}

@HostApi()
abstract class FirebaseCoreHostApi {
  @async
  Map<String, Object> intializeApp(
    PigeonInitializeAppRequest? initializeAppRequest,
  );
}
