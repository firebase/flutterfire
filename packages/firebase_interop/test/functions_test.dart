@TestOn('browser')
import 'package:firebase/firebase.dart';
import 'package:firebase/src/assets/assets.dart';
import 'package:test/test.dart';

void main() {
  App app;

  setUpAll(() async {
    await config();
  });

  setUp(() async {
    app = initializeApp(
        apiKey: apiKey,
        authDomain: authDomain,
        databaseURL: databaseUrl,
        storageBucket: storageBucket,
        projectId: projectId);
  });

  group('Functions', () {
    Functions functions;

    setUp(() async {
      functions = app.functions();
      expect(functions, isNotNull);
    });

    test('httpsCallable', () async {
      var data = {'text': 'firebase'};
      var functionName = 'helloWorld';

      var result = await functions.httpsCallable(functionName).call(data);

      expect(result.data['text'], 'hello world, firebase');
    });
  });
}
