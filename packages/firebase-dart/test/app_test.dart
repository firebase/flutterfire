@TestOn('browser')
import 'package:firebase/firebase.dart' as fb;
import 'package:firebase/src/assets/assets.dart';
import 'package:test/test.dart';

void main() {
  group("App", () {
    setUpAll(() async {
      await config();
    });

    group('instance', () {
      fb.App app;

      setUpAll(() {
        app = fb.initializeApp(
            apiKey: apiKey,
            authDomain: authDomain,
            databaseURL: databaseUrl,
            storageBucket: storageBucket);
      });

      test("Exists", () {
        expect(app, isNotNull);
        expect(fb.app(), isNotNull);
        expect(fb.apps.first.name, app.name);
      });

      test("Is [DEFAULT]", () {
        expect(app.name, "[DEFAULT]");
      });

      test("Has options", () {
        expect(app.options, isNotNull);
        expect(app.options.apiKey, apiKey);
        expect(app.options.storageBucket, storageBucket);
        expect(app.options.authDomain, authDomain);
        expect(app.options.databaseURL, databaseUrl);
      });

      test("Get database", () {
        expect(app.database(), isNotNull);
      });

      test("Get Auth", () {
        expect(app.auth(), isNotNull);
      });

      test("Get storage", () {
        expect(app.storage(), isNotNull);
      });
    });

    test("Can be created with name", () {
      var app2 = fb.initializeApp(
          apiKey: apiKey,
          authDomain: authDomain,
          databaseURL: databaseUrl,
          storageBucket: storageBucket,
          name: "MySuperApp");

      expect(app2, isNotNull);
      expect(fb.app("MySuperApp"), isNotNull);
      expect(app2.name, "MySuperApp");
      expect(fb.apps.length, 2); //[DEFAULT] and MySuperApp
    });

    test("Can be deleted", () async {
      fb.initializeApp(
          apiKey: apiKey,
          authDomain: authDomain,
          databaseURL: databaseUrl,
          storageBucket: storageBucket,
          name: "MyDeletedApp");

      expect(fb.app("MyDeletedApp"), isNotNull);
      expect(fb.apps.where((app) => app.name == "MyDeletedApp").toList(),
          isNotEmpty);

      await fb.app("MyDeletedApp").delete();
      expect(
          fb.apps.where((app) => app.name == "MyDeletedApp").toList(), isEmpty);
    });
  });

  group("Firebase", () {
    test("SDK version", () {
      expect(fb.SDK_VERSION, startsWith("3."));
    });

    group('ServerValue', () {
      test('TIMESTAMP', () {
        expect(fb.ServerValue.TIMESTAMP, isNotNull);
      });
    });
  });
}
