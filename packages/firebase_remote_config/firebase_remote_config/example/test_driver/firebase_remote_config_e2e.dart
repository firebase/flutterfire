// @dart = 2.9
import 'package:drive/drive.dart' as drive;
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

void testsMain() {
  group('RemoteConfig', () {
    RemoteConfig remoteConfig;

    setUp(() async {
      await Firebase.initializeApp();
      remoteConfig = RemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 8),
        minimumFetchInterval: Duration.zero,
      ));
      await remoteConfig.setDefaults(<String, dynamic>{
        'welcome': 'default welcome',
        'hello': 'default hello',
      });
      await remoteConfig.ensureInitialized();
    });

    test('fetch', () async {
      final mark = DateTime.now();
      expect(remoteConfig.lastFetchTime.isBefore(mark), true);
      await remoteConfig.fetchAndActivate();
      expect(remoteConfig.lastFetchStatus, RemoteConfigFetchStatus.success);
      expect(remoteConfig.lastFetchTime.isAfter(mark), true);
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

    test('settings', () async {
      expect(remoteConfig.settings.fetchTimeout, const Duration(seconds: 8));
      expect(remoteConfig.settings.minimumFetchInterval, Duration.zero);
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: Duration.zero,
        minimumFetchInterval: const Duration(seconds: 88),
      ));
      expect(remoteConfig.settings.fetchTimeout, const Duration(seconds: 60));
      expect(remoteConfig.settings.minimumFetchInterval,
          const Duration(seconds: 88));
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10, milliseconds: 500),
          minimumFetchInterval: Duration.zero));
      expect(remoteConfig.settings.fetchTimeout, const Duration(seconds: 10));
      expect(remoteConfig.settings.minimumFetchInterval, Duration.zero);
    });
  });
}

void main() => drive.main(testsMain);
