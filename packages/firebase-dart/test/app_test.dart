@TestOn('browser')
import 'package:firebase/firebase.dart' as fb;
import 'package:firebase/src/assets/assets.dart';
import 'package:test/test.dart';

void main() {
  fb.App app;

  setUpAll(() async {
    await config();
  });

  setUp(() async {
    app = fb.initializeApp(
        apiKey: apiKey,
        authDomain: authDomain,
        databaseURL: databaseUrl,
        projectId: projectId,
        storageBucket: storageBucket);
  });

  tearDown(() async {
    if (app != null) {
      await app.delete();
      app = null;
    }
  });

  group('App instance', () {
    test('Exists', () {
      expect(app, isNotNull);
      expect(fb.app(), isNotNull);
      expect(fb.apps.first.name, app.name);
    });

    test('Is [DEFAULT]', () {
      expect(app.name, '[DEFAULT]');
    });

    test('Has options', () {
      expect(app.options, isNotNull);
      expect(app.options.apiKey, apiKey);
      expect(app.options.storageBucket, storageBucket);
      expect(app.options.authDomain, authDomain);
      expect(app.options.databaseURL, databaseUrl);
    });

    test('Get database', () {
      expect(app.database(), isNotNull);
    });

    test('Get Auth', () {
      expect(app.auth(), isNotNull);
    });

    test('Get storage', () {
      expect(app.storage(), isNotNull);
    });

    test('Get storage with a bucket', () {
      expect(app.storage('gs://$storageBucket'), isNotNull);
    });

    test('Get firestore', () {
      expect(app.firestore(), isNotNull);
    }, skip: 'Causes teardown to hang on delete');

    test('Can be created with name', () async {
      var app2 = fb.initializeApp(
          apiKey: apiKey,
          authDomain: authDomain,
          databaseURL: databaseUrl,
          projectId: projectId,
          storageBucket: storageBucket,
          name: 'MySuperApp');

      expect(app2, isNotNull);
      expect(fb.app('MySuperApp'), isNotNull);
      expect(app2.name, 'MySuperApp');
      expect(fb.apps.length, 2); //[DEFAULT] and MySuperApp

      await app2.delete();
    });

    test('Can be deleted', () async {
      fb.initializeApp(
          apiKey: apiKey,
          authDomain: authDomain,
          databaseURL: databaseUrl,
          projectId: projectId,
          storageBucket: storageBucket,
          name: 'MyDeletedApp');

      expect(fb.app('MyDeletedApp'), isNotNull);
      expect(fb.apps.where((app) => app.name == 'MyDeletedApp').toList(),
          isNotEmpty);

      await fb.app('MyDeletedApp').delete();
      expect(
          fb.apps.where((app) => app.name == 'MyDeletedApp').toList(), isEmpty);
    });
  });

  group('Top level', () {
    test('Get Auth', () {
      expect(fb.auth(), isNotNull);
      expect(fb.auth(app), isNotNull);
    });

    test('Get Database', () {
      expect(fb.database(), isNotNull);
      expect(fb.database(app), isNotNull);
    });

    test('Get Storage', () {
      expect(fb.storage(), isNotNull);
      expect(fb.storage(app), isNotNull);
    });

    test('Get Firestore', () {
      expect(fb.firestore(), isNotNull);
      expect(fb.firestore(app), isNotNull);
    }, skip: 'Causes teardown to hang on delete');
  });

  test('SDK version', () {
    expect(fb.SDK_VERSION, startsWith('7.'));
  });

  group('ServerValue', () {
    test('TIMESTAMP', () {
      expect(fb.ServerValue.TIMESTAMP, isNotNull);
    });
  });
}
