@TestOn('browser')
import 'package:firebase/firebase.dart' as fb;
import 'package:firebase/src/assets/assets.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() async {
    await config();
  });

  test('firebase.js not loaded throws exception', () {
    expect(
        () => fb.initializeApp(
            apiKey: apiKey,
            authDomain: authDomain,
            databaseURL: databaseUrl,
            storageBucket: storageBucket),
        throwsA(isA<fb.FirebaseJsNotLoadedException>()));
  });
}
