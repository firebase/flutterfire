@TestOn('browser')
import 'dart:convert';

import 'package:firebase/firebase.dart';
import 'package:firebase/src/assets/assets.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

/// Requires service account credentials for the project to be specified in `service_account.json`
/// in order to publish config parameters for testing.
void main() {
  App app;
  RemoteConfigAdmin admin;

  setUpAll(() async {
    await config();
    admin = RemoteConfigAdmin(await readServiceAccountJson());
    final existingConfig = await admin.readRemoteConfig();
    expect(existingConfig.isEmpty, true,
        reason: 'This unit test requires remote config to be empty.');
    app = initializeApp(
      apiKey: apiKey,
      authDomain: authDomain,
      databaseURL: databaseUrl,
      projectId: projectId,
      storageBucket: storageBucket,
      appId: appId,
    );
  });

  tearDownAll(() async {
    // Clear remote config on exit
    await admin.publishRemoteConfig({});
    admin.dispose();
    if (app != null) {
      await app.delete();
      app = null;
    }
  });

  group('RemoteConfig', () {
    final defaultParams = const {
      'unit_test_string': 'default',
      'unit_test_number': 1,
      'unit_test_boolean': false,
      'unit_test_local_string': 'abc',
      'unit_test_local_number': 3.5,
      'unit_test_local_bool': true,
    };
    final remoteParams = const {
      'unit_test_string': 'remote',
      'unit_test_number': 2.5,
      'unit_test_boolean': true,
      'unit_test_remote_string': 'def',
      'unit_test_remote_number': 7,
      'unit_test_remote_bool': true,
    };
    // Remote params overwrite default params
    final mergedParams = Map.from(defaultParams)..addAll(remoteParams);

    RemoteConfig rc;

    setUpAll(() async {
      await admin.publishRemoteConfig(remoteParams);
    });

    setUp(() async {
      rc = remoteConfig(app);
      await rc.ensureInitialized();
      rc.setLogLevel(RemoteConfigLogLevel.error);
      rc.defaultConfig = defaultParams;
      rc.settings.fetchTimeoutMillis = const Duration(seconds: 10);
      rc.settings.minimumFetchInterval = const Duration(seconds: 120);
    });

    test('defaultConfig', () async {
      expect(rc.defaultConfig, defaultParams);
    });

    test('settings', () async {
      expect(rc.settings.fetchTimeoutMillis, const Duration(seconds: 10));
      expect(rc.settings.minimumFetchInterval, const Duration(seconds: 120));
    });

    test('fetch', () async {
      expect(rc.lastFetchStatus, RemoteConfigFetchStatus.notFetchedYet);
      await rc.fetch();
      expect(rc.lastFetchStatus, RemoteConfigFetchStatus.success);
      final activated = await rc.activate();
      expect(activated, true);
      final fetchedAndActivated = await rc.fetchAndActivate();
      // since we fetch and activate right after the previous fetch, we expect [fetchAndActivated] to be `false`,
      // assuming that it took less time than `minimumFetchInterval`.
      expect(fetchedAndActivated, false);
    });

    test('values', () async {
      await rc.fetchAndActivate();
      for (var me in remoteParams.entries) {
        // extract the last part of attribute name to determine the data type
        final dataType = me.key.split('_').last;
        final expectedValue = me.value;
        switch (dataType) {
          case 'bool':
            expect(rc.getBoolean(me.key), expectedValue);
            break;
          case 'number':
            expect(rc.getNumber(me.key).toDouble(), expectedValue);
            break;
          default:
            expect(rc.getString(me.key), '$expectedValue');
            break;
        }
        final v = rc.getValue(me.key);
        expect(v.asString(), '$expectedValue');
        expect(v.getSource(), RemoteConfigValueSource.remote);
      }
      expect(rc.getAll().map((k, v) => MapEntry(k, '${v.asString()}')),
          mergedParams.map((k, v) => MapEntry(k, '$v')));
      for (var me in defaultParams.entries) {
        final dataType = me.key.split('_').last;
        if (remoteParams.containsKey(me.key)) {
          continue;
        }
        final expectedValue = me.value;
        switch (dataType) {
          case 'bool':
            expect(rc.getBoolean(me.key), expectedValue);
            break;
          case 'number':
            expect(rc.getNumber(me.key).toDouble(), expectedValue);
            break;
          default:
            expect(rc.getString(me.key), '$expectedValue');
            break;
        }
        final v = rc.getValue(me.key);
        expect(v.asString(), '$expectedValue');
        expect(v.getSource(), RemoteConfigValueSource.defaults);
      }
      final staticValue = rc.getValue('non_existent');
      expect(staticValue.getSource(), RemoteConfigValueSource.static);
      expect(staticValue.asString(), '');
      expect(staticValue.asBoolean(), false);
      expect(staticValue.asNumber().toInt(), 0);
    });
  });
}

/// This helper class uses Remote Config REST API to read and publish remote config parameters for testing.
class RemoteConfigAdmin {
  static final remoteConfigScopes = [
    'https://www.googleapis.com/auth/firebase.remoteconfig'
  ];

  ServiceAccountCredentials _serviceAccountCredentials;
  String _projectId;
  http.Client _httpClient;
  AccessCredentials _creds;
  String _etag;

  RemoteConfigAdmin(Map<String, dynamic> serviceAccountJson) {
    _httpClient = http.Client();
    _serviceAccountCredentials =
        ServiceAccountCredentials.fromJson(serviceAccountJson);
    _projectId = serviceAccountJson['project_id'];
  }

  Map<String, dynamic> _createConfigDef(Map<String, dynamic> params) {
    return {
      'conditions': [],
      'parameters': params.map((k, v) => MapEntry(k, {
            'defaultValue': {'value': '$v'},
            'description': 'Created by firebase-dart unit tests'
          })),
    };
  }

  String get _endpointUrl => 'https://firebaseremoteconfig.googleapis.com'
      '/v1/projects/$_projectId/remoteConfig';

  Future<String> _getAccessToken() async {
    if (_creds == null || _creds.accessToken.hasExpired) {
      _creds = await obtainAccessCredentialsViaServiceAccount(
          _serviceAccountCredentials, remoteConfigScopes, _httpClient);
    }
    return _creds.accessToken.data;
  }

  Future<Map<String, dynamic>> readRemoteConfig() async {
    final accessToken = await _getAccessToken();
    final resp = await _httpClient.get(
      _endpointUrl,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (resp.statusCode != 200) {
      throw Exception('Could not read confg. Response: ${resp.body}');
    }
    _etag = resp.headers['etag'];
    final config = jsonDecode(resp.body);
    final result =
        ((config['parameters'] as Map<String, dynamic>) ?? {}).map((k, v) {
      final dataType = k.split('_').last;
      final value = ((v as Map<String, dynamic>)['defaultValue']
          as Map<String, dynamic>)['value'];
      dynamic v2;
      switch (dataType) {
        case 'bool':
          v2 = ['1', 'true', 't', 'yes', 'y', 'on'].contains(value);
          break;
        case 'number':
          v2 = num.parse(value);
          break;
        default:
          v2 = v;
          break;
      }
      return MapEntry<String, dynamic>(k, v2);
    });
    return result;
  }

  Future<void> publishRemoteConfig(Map<String, dynamic> params) async {
    final configDef = _createConfigDef(params);
    final encoded = json.encode(configDef);
    final accessToken = await _getAccessToken();
    final resp = await _httpClient.put(
      _endpointUrl,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'If-Match': _etag ?? '*',
      },
      body: encoded,
    );
    if (resp.statusCode != 200) {
      throw Exception('Could not publish confg. Response: ${resp.body}');
    }
    _etag = resp.headers['etag'];
  }

  void dispose() {
    _httpClient.close();
  }
}
