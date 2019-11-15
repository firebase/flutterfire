import 'package:flutter_test/flutter_test.dart';
import 'package:e2e/e2e.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  group('$RemoteConfig', () {
    RemoteConfig remoteConfig;

    setUp(() async {
      remoteConfig = await RemoteConfig.instance;
      await remoteConfig
          .setConfigSettings(RemoteConfigSettings(debugMode: true));
      await remoteConfig.setDefaults(<String, dynamic>{
        'welcome': 'default welcome',
        'hello': 'default hello',
      });
    });

    testWidgets('fetch', (WidgetTester tester) async {
      final DateTime lastFetchTime = remoteConfig.lastFetchTime;
      expect(lastFetchTime.isBefore(DateTime.now()), true);
      await remoteConfig.fetch(expiration: const Duration(seconds: 0));
      expect(remoteConfig.lastFetchStatus, LastFetchStatus.success);
      await remoteConfig.activateFetched();

      expect(remoteConfig.getString('welcome'), 'Earth, welcome! Hello!');
      expect(remoteConfig.getString('hello'), 'default hello');
      expect(remoteConfig.getInt('nonexisting'), 0);

      expect(remoteConfig.getValue('welcome').source, ValueSource.valueRemote);
      expect(remoteConfig.getValue('hello').source, ValueSource.valueDefault);
      expect(
        remoteConfig.getValue('nonexisting').source,
        ValueSource.valueStatic,
      );
    });
  });
}
