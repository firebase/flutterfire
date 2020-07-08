// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_remote_config_platform_interface;

Map<String, RemoteConfigValue> _parseRemoteConfigParameters(
    {Map<dynamic, dynamic> parameters}) {
  final Map<String, RemoteConfigValue> parsedParameters =
      <String, RemoteConfigValue>{};
  parameters.forEach((dynamic key, dynamic value) {
    final ValueSource valueSource = _parseValueSource(value['source']);
    final RemoteConfigValue remoteConfigValue =
        RemoteConfigValue._(value['value']?.cast<int>(), valueSource);
    parsedParameters[key] = remoteConfigValue;
  });
  return parsedParameters;
}

ValueSource _parseValueSource(String sourceStr) {
  switch (sourceStr) {
    case 'static':
      return ValueSource.valueStatic;
    case 'default':
      return ValueSource.valueDefault;
    case 'remote':
      return ValueSource.valueRemote;
    default:
      return null;
  }
}
