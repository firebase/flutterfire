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

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_data_connect/src/common/common_library.dart';
import 'package:firebase_data_connect/src/core/ref.dart';
import 'package:flutter/foundation.dart';

import './network/transport_library.dart'
    if (dart.library.io) './network/grpc_library.dart'
    if (dart.library.html) './network/rest_library.dart';

import 'cache/cache_data_types.dart';
import 'cache/cache_manager.dart';

/// DataConnect class
class FirebaseDataConnect extends FirebasePluginPlatform {
  /// Constructor for initializing Data Connect
  @visibleForTesting
  FirebaseDataConnect({
    required this.app,
    required this.connectorConfig,
    this.auth,
    this.appCheck,
    CallerSDKType? sdkType,
    this.cacheSettings
  })  : options = DataConnectOptions(
          app.options.projectId,
          connectorConfig.location,
          connectorConfig.connector,
          connectorConfig.serviceId,
        ),
        super(app.name, 'plugins.flutter.io/firebase_data_connect') {
    _queryManager = QueryManager(this);
    if (sdkType != null) {
      _sdkType = sdkType;
    }
  }

  /// CacheManager
  Cache? cacheManager;

  /// QueryManager manages ongoing queries, and their subscriptions.
  late QueryManager _queryManager;

  /// Type of SDK the user is currently calling.
  CallerSDKType _sdkType = CallerSDKType.core;

  /// FirebaseApp
  FirebaseApp app;

  /// FirebaseAppCheck
  FirebaseAppCheck? appCheck;

  /// Due to compatibility issues with grpc-web, we swap out the transport based on what platform the user is using.
  /// For web, we use RestTransport. For mobile, we use GRPCTransport.
  late DataConnectTransport transport;

  /// FirebaseAuth
  FirebaseAuth? auth;

  /// ConnectorConfig + projectId
  @visibleForTesting
  DataConnectOptions options;

  /// Data Connect specific config information
  ConnectorConfig connectorConfig;

  /// Cache settings
  CacheSettings? cacheSettings;

  /// Custom transport options for connecting to the Data Connect service.
  @visibleForTesting
  TransportOptions? transportOptions;

  /// Checks whether the transport has been properly initialized.
  @visibleForTesting
  void checkTransport() {
    transportOptions ??=
        TransportOptions('firebasedataconnect.googleapis.com', null, true);
    transport = getTransport(
      transportOptions!,
      options,
      app.options.appId,
      _sdkType,
      appCheck,
    );
  }

  @visibleForTesting
  void checkAndInitializeCache() {
    if (cacheSettings != null) {
      cacheManager = Cache(cacheSettings!, this);
    }
  }

  /// Returns a [QueryRef] object.
  QueryRef<Data, Variables> query<Data, Variables>(
    String operationName,
    Deserializer<Data> dataDeserializer,
    Serializer<Variables> varsSerializer,
    Variables? vars,
  ) {
    checkTransport();
    checkAndInitializeCache();
    return QueryRef<Data, Variables>(
      this,
      operationName,
      transport,
      dataDeserializer,
      _queryManager,
      varsSerializer,
      vars,
    );
  }

  /// Returns a [MutationRef] object.
  MutationRef<Data, Variables> mutation<Data, Variables>(
    String operationName,
    Deserializer<Data> dataDeserializer,
    Serializer<Variables> varsSerializer,
    Variables? vars,
  ) {
    checkTransport();
    return MutationRef<Data, Variables>(
      this,
      operationName,
      transport,
      dataDeserializer,
      varsSerializer,
      vars,
    );
  }

  /// useDataConnectEmulator connects to the DataConnect emulator.
  void useDataConnectEmulator(
    String host,
    int port, {
    bool automaticHostMapping = true,
    bool isSecure = false,
  }) {
    String mappedHost = automaticHostMapping ? getMappedHost(host) : host;
    transportOptions = TransportOptions(mappedHost, port, isSecure);

    if (cacheManager != null) {
      // dispose and clean this up. it will get reinitialized for newer QueryRefs that target the emulator.
      cacheManager?.dispose();
      cacheManager = null;
    }
  }

  /// Currently cached DataConnect instances. Maps from app name to ConnectorConfigStr, DataConnect.
  @visibleForTesting
  static final Map<String, Map<String, FirebaseDataConnect>> cachedInstances =
      {};

  /// Returns an instance using a specified [FirebaseApp].
  ///
  /// If [app] is not provided, the default Firebase app will be used.
  /// If pass in [appCheck], request session will get protected from abusing.
  static FirebaseDataConnect instanceFor({
    FirebaseApp? app,
    FirebaseAuth? auth,
    FirebaseAppCheck? appCheck,
    CallerSDKType? sdkType,
    required ConnectorConfig connectorConfig,
    CacheSettings? cacheSettings = const CacheSettings()
  }) {
    app ??= Firebase.app();
    auth ??= FirebaseAuth.instanceFor(app: app);
    appCheck ??= FirebaseAppCheck.instanceFor(app: app);

    if (cachedInstances[app.name] != null &&
        cachedInstances[app.name]![connectorConfig.toJson()] != null) {
      return cachedInstances[app.name]![connectorConfig.toJson()]!;
    }

    FirebaseDataConnect newInstance = FirebaseDataConnect(
      app: app,
      auth: auth,
      appCheck: appCheck,
      connectorConfig: connectorConfig,
      sdkType: sdkType,
      cacheSettings: cacheSettings,
    );
    if (cachedInstances[app.name] == null) {
      cachedInstances[app.name] = <String, FirebaseDataConnect>{};
    }
    cachedInstances[app.name]![connectorConfig.toJson()] = newInstance;

    return newInstance;
  }
}
