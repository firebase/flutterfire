// Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:core';

class PasswordPolicyApi {
  final FirebaseAuth auth;
  final String _apiUrl = 'https://identitytoolkit.googleapis.com/v2/passwordPolicy?key=';

  PasswordPolicyApi(this.auth);

  final int schemaVersion = 1;

  Future<Map<String, dynamic>> fetchPasswordPolicy() async {
    try {
      final String _apiKey = auth.app.options.apiKey;
      final response = await http.get(Uri.parse('$_apiUrl$_apiKey'));
      if (response.statusCode == 200) {
        final policy = json.decode(response.body);

        // Validate schema version
        final _schemaVersion = policy['schemaVersion'];
        if (!isCorrectSchemaVersion(_schemaVersion)) {
          throw Exception('Schema Version mismatch, expected version 1 but got $policy');
        }

        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch password policy, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch password policy: $e');
    }
  }

  bool isCorrectSchemaVersion(int _schemaVersion) {
    return schemaVersion == _schemaVersion;
  }
}
