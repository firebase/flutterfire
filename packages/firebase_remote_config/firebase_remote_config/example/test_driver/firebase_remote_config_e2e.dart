// @dart=2.9

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
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: Duration(seconds: 8),
        minimumFetchInterval: Duration.zero,
      ));
      await remoteConfig.setDefaults(<String, dynamic>{
        'welcome': 'default welcome',
        'hello': 'default hello',
      });
    });

    testWidgets('fetch', (WidgetTester tester) async {
      final mark = DateTime.now();
      expect(remoteConfig.lastFetchTime.isBefore(mark), true);
      await remoteConfig.fetchAndActivate();
      expect(remoteConfig.lastFetchStatus, RemoteConfigFetchStatus.success);
      expect(remoteConfig.lastFetchTime.isAfter(mark), true);

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

    testWidgets('settings', (WidgetTester tester) async {
      expect(remoteConfig.settings.fetchTimeout, Duration(seconds: 8));
      expect(remoteConfig.settings.minimumFetchInterval, Duration.zero);
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: Duration.zero,
        minimumFetchInterval: Duration(seconds: 88),
      ));
      expect(remoteConfig.settings.fetchTimeout, Duration(seconds: 60));
      expect(remoteConfig.settings.minimumFetchInterval, Duration(seconds: 88));
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
          fetchTimeout: Duration(seconds: 10, milliseconds: 500),
          minimumFetchInterval: Duration.zero));
      expect(remoteConfig.settings.fetchTimeout, Duration(seconds: 10));
      expect(remoteConfig.settings.minimumFetchInterval, Duration.zero);
    });
  });
}
