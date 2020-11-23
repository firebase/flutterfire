import 'package:flutter_test/flutter_test.dart';
import 'package:e2e/e2e.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  group('$RemoteConfig', () {
    RemoteConfig remoteConfig;

    setUp(() async {
      await Firebase.initializeApp();
      remoteConfig = await RemoteConfig.instance;
      // Set our config to no minimum fetch interval so that settings change immediately
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
          minimumFetchIntervalMillis: 0, fetchTimeoutMillis: 30 * 1000));
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
      final activated = await remoteConfig.activateFetched();
      expect(activated, true);

      // TODO should verify that our config settings actually took
      expect(remoteConfig.getString('welcome'), 'Earth, welcome! Hello!');
      expect(remoteConfig.getValue('welcome').source, ValueSource.valueRemote);

      expect(remoteConfig.getString('hello'), 'default hello');
      expect(remoteConfig.getValue('hello').source, ValueSource.valueDefault);

      expect(remoteConfig.getInt('nonexisting'), 0);

      expect(
        remoteConfig.getValue('nonexisting').source,
        ValueSource.valueStatic,
      );
    });
  });
}
