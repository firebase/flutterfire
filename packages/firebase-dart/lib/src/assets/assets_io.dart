// NOTE: this file SHOULD NOT be imported outside of this package. It exists to
// share logic between tests and examples.

// Adding these ignores since `googleapis_auth` is not a "regular" dependency
// See https://github.com/dart-lang/pana/issues/167
// ignore_for_file: uri_does_not_exist, non_type_as_type_argument, undefined_class, undefined_function

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';

const _firebaseScopes = [
  "https://www.googleapis.com/auth/firebase.database",
  "https://www.googleapis.com/auth/userinfo.email"
];

Future<AccessToken> getAccessToken(Client client) async {
  var serviceAccountJsonPath = (await Isolate.resolvePackageUri(
          Uri.parse('package:firebase/src/assets/service_account.json')))
      .toFilePath();

  var serviceAccountJsonString =
      File(serviceAccountJsonPath).readAsStringSync();

  var creds = ServiceAccountCredentials.fromJson(serviceAccountJsonString);

  var accessCreds = await obtainAccessCredentialsViaServiceAccount(
      creds, _firebaseScopes, client);

  return accessCreds.accessToken;
}

Future<String> getDatabaseUri() async {
  var serviceAccountJsonPath = (await Isolate.resolvePackageUri(
          Uri.parse('package:firebase/src/assets/config.json')))
      .toFilePath();

  var jsonString = File(serviceAccountJsonPath).readAsStringSync();

  var json = jsonDecode(jsonString) as Map;

  return json['DATABASE_URL'];
}
