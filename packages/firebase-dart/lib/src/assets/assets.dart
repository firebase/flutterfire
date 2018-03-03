import 'dart:async';
import 'dart:convert';

import 'package:http/browser_client.dart' as http;
import 'package:http/http.dart' as http;

Map<String, dynamic> _configVal;

String get apiKey => _getConfig('API_KEY');
String get authDomain => _getConfig('AUTH_DOMAIN');
String get databaseUrl => _getConfig('DATABASE_URL');
String get storageBucket => _getConfig('STORAGE_BUCKET');
String get projectId => _getConfig('PROJECT_ID');
String get messagingSenderId => _getConfig('MESSAGING_SENDER_ID');
String get serverKey => _getConfig('SERVER_KEY');
String get vapidKey => _getConfig('VAPID_KEY');

String _getConfig(String key) {
  if (_configVal == null) {
    throw new StateError('You must call config() first');
  }

  var value = _configVal[key];

  if (value == null) {
    throw new ArgumentError('`$key` is not configured in `config.json`.');
  }

  return value;
}

Future config() async {
  if (_configVal != null) {
    return;
  }

  var client = new http.BrowserClient();

  try {
    var response =
        await client.get('/packages/firebase/src/assets/config.json');
    if (response.statusCode > 399) {
      throw new StateError(
          "Problem with server: ${response.statusCode} ${response.body}");
    }

    var jsonString = response.body;
    _configVal = JSON.decode(jsonString) as Map<String, dynamic>;
  } catch (e) {
    print("Error getting `config.json`. Make sure it exists.");
    rethrow;
  } finally {
    client.close();
  }
}
