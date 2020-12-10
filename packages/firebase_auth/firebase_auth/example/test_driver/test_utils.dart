// @dart = 2.9

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth auth = FirebaseAuth.instance;

String TEST_PASSWORD = 'testpassword';

// Random time-based email to ensure unique test user account
// each time.
String TEST_PHONE_NUMBER = '+447111555666';
String TEST_SMS_CODE = '123456';
String /*!*/ generateRandomEmail({prefix = '', suffix = '@foo.bar'}) {
  var uuid = Uuid().v1();
  var testEmail = prefix + uuid + suffix;

  return testEmail;
}

// Gets a custom token from the rnfirebase api for test purposes.
Future getCustomToken(
    String uid, Map<String, dynamic> claims, String idToken) async {
  try {
    var path = "https://api.rnfirebase.io/auth/user/" + uid + "/custom-token";
    var body = json.encode(claims);
    var headers = {"authorization": "Bearer " + idToken};

    final response = await http.post(path, headers: headers, body: body);
    if (response.statusCode == 200) {
      // successful, parse json
      var jsonData = json.decode(response.body);
      return jsonData["token"];
    } else {
      // response wasn't successful, throw
      throw Exception("Unexpected response from server: (" +
          response.statusCode.toString() +
          ") " +
          response.reasonPhrase);
    }
  } catch (err) {
    throw Exception(err.toString());
  }
}

void ensureSignedIn(testEmail) async {
  if (auth.currentUser == null) {
    try {
      await auth.createUserWithEmailAndPassword(
          email: testEmail, password: TEST_PASSWORD);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        await auth.signInWithEmailAndPassword(
            email: testEmail, password: TEST_PASSWORD);
      }
    } catch (e) {
      print("ensureSignedIn Error ${e}");
    }
  }
}

void ensureSignedOut() async {
  if (auth.currentUser != null) {
    await auth.signOut();
  }
}
