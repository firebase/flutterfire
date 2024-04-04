// FirebaseStoragePlatform Mock
class MockFirebaseStorage extends Mock
    with
        // ignore: prefer_mixin, plugin_platform_interface needs to migrate to use `mixin`
        MockPlatformInterfaceMixin
    implements
        TestFirebaseStoragePlatform {
  MockFirebaseStorage() {
    TestFirebaseStoragePlatform();
  }

  @override
  final int maxOperationRetryTime = 0;
  @override
  final int maxDownloadRetryTime = 0;
  @override
  final int maxUploadRetryTime = 0;

  @override
  FirebaseStoragePlatform delegateFor({FirebaseApp? app, String? bucket}) {
    return super.noSuchMethod(
        Invocation.method(#delegateFor, [], {#app: app, #bucket: bucket}),
        returnValue: TestFirebaseStoragePlatform());
  }

  @override
  ReferencePlatform ref(String? path) {
    return super.noSuchMethod(Invocation.method(#ref, [path]),
        returnValue: TestReferencePlatform(),
        returnValueForMissingStub: TestReferencePlatform());
  }

  @override
  Future<void> useStorageEmulator(String host, int port) async {
    return super
        .noSuchMethod(Invocation.method(#useStorageEmulator, [host, port]));
  }
}
