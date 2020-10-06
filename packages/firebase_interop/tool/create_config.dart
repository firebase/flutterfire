import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

final _assetPath = 'lib/src/assets/';

void main() {
  // make sure the working dir is the root of the project
  if (!File('pubspec.yaml').existsSync()) {
    throw StateError('Not in the root! - ${Directory.current}');
  }

  var samplePath = p.join(_assetPath, 'config.json.sample');
  if (!File(samplePath).existsSync()) {
    throw StateError("'$samplePath should exist");
  }

  var configPath = p.join(_assetPath, 'config.json');
  var configFile = File(configPath);

  if (configFile.existsSync()) {
    throw StateError("Config exists. It should not. '$configPath'");
  }

  var vars = [
    'API_KEY',
    'AUTH_DOMAIN',
    'DATABASE_URL',
    'STORAGE_BUCKET',
    'PROJECT_ID',
    'APP_ID',
  ];

  var config = <String, String>{};
  for (var envVar in vars) {
    if (Platform.environment.containsKey(envVar)) {
      config[envVar] = Platform.environment[envVar];
    } else {
      throw StateError('Missing needed environment variable $envVar');
    }
  }

  configFile
      .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(config));

  // now for the service_account silly
  if (!Platform.environment.containsKey('SERVICE_ACCOUNT_JSON')) {
    throw StateError('Expected a ENV variable of SERVICE_ACCOUNT_JSON');
  }

  var serviceAccountJson =
      utf8.decode(base64.decode(Platform.environment['SERVICE_ACCOUNT_JSON']));

  var serviceAccountPath = p.join(_assetPath, 'service_account.json');
  File(serviceAccountPath).writeAsStringSync(serviceAccountJson);
}
