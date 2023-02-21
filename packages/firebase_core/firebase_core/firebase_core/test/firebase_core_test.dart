import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core/firebase_core_platform_interface.dart';
import 'package:firebase_core/firebase_core_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFirebaseCorePlatform
    with MockPlatformInterfaceMixin
    implements FirebaseCorePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FirebaseCorePlatform initialPlatform = FirebaseCorePlatform.instance;

  test('$MethodChannelFirebaseCore is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFirebaseCore>());
  });

  test('getPlatformVersion', () async {
    FirebaseCore firebaseCorePlugin = FirebaseCore();
    MockFirebaseCorePlatform fakePlatform = MockFirebaseCorePlatform();
    FirebaseCorePlatform.instance = fakePlatform;

    expect(await firebaseCorePlugin.getPlatformVersion(), '42');
  });
}
