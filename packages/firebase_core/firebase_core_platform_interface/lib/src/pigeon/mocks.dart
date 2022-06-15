import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

class MockFirebaseApp implements TestFirebaseCoreHostApi {
  @override
  Future<PigeonInitializeReponse> initializeApp(
    String appName,
    PigeonFirebaseOptions initializeAppRequest,
  ) async {
    return PigeonInitializeReponse(
      name: appName,
      options: PigeonFirebaseOptions(
        apiKey: '123',
        projectId: '123',
        appId: '123',
        messagingSenderId: '123',
      ),
      pluginConstants: {},
    );
  }

  @override
  Future<List<PigeonInitializeReponse?>> initializeCore() async {
    return [
      PigeonInitializeReponse(
        name: defaultFirebaseAppName,
        options: PigeonFirebaseOptions(
          apiKey: '123',
          projectId: '123',
          appId: '123',
          messagingSenderId: '123',
        ),
        pluginConstants: {},
      )
    ];
  }

  @override
  Future<PigeonFirebaseOptions> optionsFromResource() async {
    return PigeonFirebaseOptions(
      apiKey: '123',
      projectId: '123',
      appId: '123',
      messagingSenderId: '123',
    );
  }
}

void setupFirebaseCoreMocks() {
  TestFirebaseCoreHostApi.setup(MockFirebaseApp());
}
