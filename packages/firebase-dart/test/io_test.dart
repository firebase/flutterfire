@TestOn('vm')
import 'package:firebase/firebase_io.dart';
import 'package:firebase/src/assets/assets_io.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';

import 'test_util.dart';

void main() {
  String databaseUri;
  FirebaseClient fbClient;
  String testUri;

  setUpAll(() async {
    var token = await getAccessToken(Client());
    fbClient = FirebaseClient(token.data);
    databaseUri = await getDatabaseUri();
  });

  setUp(() {
    var path = validDatePath();
    testUri = '$databaseUri/$path.json';
  });

  tearDown(() async {
    await fbClient.delete(testUri);
    testUri = null;
  });

  tearDownAll(() {
    if (fbClient != null) {
      fbClient.close();
    }
  });

  test('never-accessed path is null', () async {
    var response = await fbClient.get(testUri);
    expect(response, isNull);
  });

  test('Uri is fine, too', () async {
    var response = await fbClient.get(Uri.parse(testUri));
    expect(response, isNull);
  });

  test('put', () async {
    var response = await fbClient.put(testUri, 'bob');
    expect(response, 'bob');

    response = await fbClient.get(testUri);
    expect(response, 'bob');
  });

  test('post', () async {
    var response = await fbClient.post(testUri, 'bob') as Map;
    expect(response, contains('name'));

    var key = response['name'];

    response = await fbClient.get(testUri);
    expect(response, {key: 'bob'});
  });

  test('patch', () async {
    var response = await fbClient.patch(testUri, {'someNewKey': 'bob'}) as Map;
    expect(response, contains('someNewKey'));

    var key = 'someNewKey';

    response = await fbClient.get(testUri);
    expect(response, {key: 'bob'});
  });
}
