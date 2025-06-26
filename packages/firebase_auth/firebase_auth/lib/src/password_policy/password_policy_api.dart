// Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'password_policy.dart';
import 'dart:convert';
import 'dart:core';

class PasswordPolicyApi {
  final FirebaseAuth _auth;
  final String _apiUrl = 'https://identitytoolkit.googleapis.com/v2/passwordPolicy?key=';

  PasswordPolicyApi(this._auth);

  final int _schemaVersion = 1;

  Future<PasswordPolicy> fetchPasswordPolicy() async {
    try {
      final String _apiKey = _auth.app.options.apiKey;
      final response = await http.get(Uri.parse('$_apiUrl$_apiKey'));
      if (response.statusCode == 200) {
        final policy = json.decode(response.body);

        // Validate schema version
        final _schemaVersion = policy['schemaVersion'];
        if (!isCorrectSchemaVersion(_schemaVersion)) {
          throw Exception('Schema Version mismatch, expected version 1 but got $policy');
        }

        Map<String, dynamic> rawPolicy = json.decode(response.body);
        return PasswordPolicy(rawPolicy);
      } else {
        throw Exception('Failed to fetch password policy, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch password policy: $e');
    }
  }

  bool isCorrectSchemaVersion(int schemaVersion) {
    return _schemaVersion == schemaVersion;
  }
}
