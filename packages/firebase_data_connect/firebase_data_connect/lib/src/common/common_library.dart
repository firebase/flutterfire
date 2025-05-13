// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:convert';

import 'package:firebase_app_check/firebase_app_check.dart';

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

part 'dataconnect_error.dart';
part 'dataconnect_options.dart';

enum CallerSDKType { core, generated }

String getGoogApiVal(CallerSDKType sdkType, String packageVersion) {
  String apiClientValue = 'gl-dart/$packageVersion fire/$packageVersion';
  if (sdkType == CallerSDKType.generated) {
    apiClientValue += ' dart/gen';
  }
  return '$apiClientValue gl-${kIsWeb ? 'web' : Platform.operatingSystem}';
}

String getFirebaseClientVal(String packageVersion) {
  return 'flutter-fire-dc/$packageVersion';
}

/// Transport Options for connecting to a specific host.
class TransportOptions {
  /// Constructor
  TransportOptions(this.host, this.port, this.isSecure);

  /// Host to connect to
  String host;

  /// Port to connect to
  int? port;

  /// isSecure - use secure protocol
  bool? isSecure;
}

/// Interface for transports connecting to the DataConnect backend.
abstract class DataConnectTransport {
  /// Constructor.
  DataConnectTransport(
    this.transportOptions,
    this.options,
    this.appId,
    this.sdkType,
  );

  /// Transport options.
  TransportOptions transportOptions;

  /// DataConnect backend configuration.
  DataConnectOptions options;

  /// FirebaseAppCheck to use to get app check token.
  FirebaseAppCheck? appCheck;

  /// Core or generated SDK being used.
  CallerSDKType sdkType;

  /// Application ID
  String appId;

  /// Invokes corresponding query endpoint.
  Future<Data> invokeQuery<Data, Variables>(
    String queryName,
    Deserializer<Data> deserializer,
    Serializer<Variables> serializer,
    Variables? vars,
    String? token,
  );

  /// Invokes corresponding mutation endpoint.
  Future<Data> invokeMutation<Data, Variables>(
    String queryName,
    Deserializer<Data> deserializer,
    Serializer<Variables> serializer,
    Variables? vars,
    String? token,
  );
}
