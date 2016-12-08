import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';

const _firebaseScopes = const [
  "https://www.googleapis.com/auth/firebase.database",
  "https://www.googleapis.com/auth/userinfo.email"
];

Future<AccessToken> getAccessToken(IOClient client) async {
  var serviceAccountJsonPath = (await Isolate.resolvePackageUri(
          Uri.parse('package:firebase/src/assets/service_account.json')))
      .toFilePath();

  var serviceAccountJsonString =
      new File(serviceAccountJsonPath).readAsStringSync();

  var creds = new ServiceAccountCredentials.fromJson(serviceAccountJsonString);

  var accessCreds = await obtainAccessCredentialsViaServiceAccount(
      creds, _firebaseScopes, client);

  return accessCreds.accessToken;
}

Future<String> getDatabaseUri() async {
  var serviceAccountJsonPath = (await Isolate.resolvePackageUri(
          Uri.parse('package:firebase/src/assets/config.json')))
      .toFilePath();

  var jsonString = new File(serviceAccountJsonPath).readAsStringSync();

  var json = JSON.decode(jsonString) as Map;

  return json['DATABASE_URL'];
}
