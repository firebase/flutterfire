// @dart = 2.9

import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth auth = FirebaseAuth.instance;

String TEST_PASSWORD = 'testpassword';

// Random time-based email to ensure unique test user account
// each time.
String TEST_PHONE_NUMBER = '+447111555666';
String TEST_SMS_CODE = '123456';

String /*!*/ generateRandomEmail({
  String prefix = '',
  String suffix = '@foo.bar',
}) {
  var uuid = createCryptoRandomString();
  var testEmail = prefix + uuid + suffix;

  return testEmail;
}

// Gets a custom token from the rnfirebase api for test purposes.
Future getCustomToken(
    String uid, Map<String, dynamic> claims, String idToken) async {
  try {
    var path = 'https://api.rnfirebase.io/auth/user/$uid/custom-token';
    var body = json.encode(claims);
    var headers = {'authorization': 'Bearer $idToken'};

    final response = await http.post(
      Uri.parse(path),
      headers: headers,
      body: body,
    );
    if (response.statusCode == 200) {
      // successful, parse json
      var jsonData = json.decode(response.body);
      return jsonData['token'];
    } else {
      // response wasn't successful, throw
      throw Exception(
        'Unexpected response from server: (${response.statusCode}) ${response.reasonPhrase}',
      );
    }
  } catch (err) {
    throw Exception(err.toString());
  }
}

Future<void> ensureSignedIn(String testEmail) async {
  if (auth.currentUser == null) {
    try {
      await auth.createUserWithEmailAndPassword(
        email: testEmail,
        password: TEST_PASSWORD,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        await auth.signInWithEmailAndPassword(
          email: testEmail,
          password: TEST_PASSWORD,
        );
      }
    } catch (e) {
      print('ensureSignedIn Error $e');
    }
  }
}

Future<void> ensureSignedOut() async {
  if (auth.currentUser != null) {
    await auth.signOut();
  }
}

Random _random = Random.secure();

String createCryptoRandomString([int length = 32]) {
  var values = List<int>.generate(length, (i) => _random.nextInt(256));

  return base64Url.encode(values).toLowerCase();
}
