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

import './network/rest_library.dart';
import './network/transport_library.dart';

import 'cache/cache_data_types.dart';
import 'cache/cache.dart';

/// DataConnect class
class FirebaseDataConnect extends FirebasePluginPlatform {
  /// Constructor for initializing Data Connect
  @visibleForTesting
  FirebaseDataConnect(
      {required this.app,
      required this.connectorConfig,
      this.auth,
      this.appCheck,
      CallerSDKType? sdkType,
      this.cacheSettings})
      : options = DataConnectOptions(
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

  /// Transport for connecting to the Data Connect service.
  /// Routes between RestTransport and WebSocketTransport based on subscription status
  DataConnectTransport? transport;

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
    if (transport != null) {
      return;
    }
    transportOptions ??=
        TransportOptions('firebasedataconnect.googleapis.com', null, true);
    final rest = RestTransport(
      transportOptions!,
      options,
      app.options.appId,
      _sdkType,
      appCheck,
    );
    final ws = WebSocketTransport(
      transportOptions!,
      options,
      app.options.appId,
      _sdkType,
      appCheck,
      auth,
    );
    transport = _RoutingTransport(rest, ws);
  }

  @visibleForTesting
  void checkAndInitializeCache() {
    if (cacheSettings != null && cacheManager == null) {
      cacheManager = Cache(cacheSettings!, this);
      _queryManager.initializeImpactedQueriesSub();
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
    String queryId =
        OperationRef.createOperationId(operationName, vars, varsSerializer);

    QueryRef<Data, Variables>? ref =
        _queryManager.trackedQueries[queryId] as QueryRef<Data, Variables>?;
    if (ref != null) {
      return ref;
    } else {
      return QueryRef<Data, Variables>(
        this,
        operationName,
        transport!,
        dataDeserializer,
        _queryManager,
        varsSerializer,
        vars,
      );
    }
  }

  /// Returns a [MutationRef] object.
  MutationRef<Data, Variables> mutation<Data, Variables>(
    String operationName,
    Deserializer<Data> dataDeserializer,
    Serializer<Variables> varsSerializer,
    Variables? vars,
  ) {
    checkTransport();
    //initialize cache since mutations on a stream could result in subscribed query updates
    checkAndInitializeCache();
    return MutationRef<Data, Variables>(
      this,
      operationName,
      transport!,
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

    // dispose and clean this up. it will get reinitialized for newer QueryRefs that target the emulator.
    cacheManager?.dispose();
    cacheManager = null;

    // transport will get reinitialized for newer QueryRefs that target the emulator.
    transport = null;
  }

  /// Currently cached DataConnect instances. Maps from app name to ConnectorConfigStr, DataConnect.
  @visibleForTesting
  static final Map<String, Map<String, FirebaseDataConnect>> cachedInstances =
      {};

  /// Returns an instance using a specified [FirebaseApp].
  ///
  /// If [app] is not provided, the default Firebase app will be used.
  /// If pass in [appCheck], request session will get protected from abusing.
  static FirebaseDataConnect instanceFor(
      {FirebaseApp? app,
      FirebaseAuth? auth,
      FirebaseAppCheck? appCheck,
      CallerSDKType? sdkType,
      required ConnectorConfig connectorConfig,
      CacheSettings? cacheSettings}) {
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

class _RoutingTransport implements DataConnectTransport {
  _RoutingTransport(this.rest, this.websocket);
  final RestTransport rest;
  final WebSocketTransport websocket;

  @override
  FirebaseAppCheck? get appCheck => rest.appCheck;
  @override
  set appCheck(FirebaseAppCheck? val) {
    rest.appCheck = val;
    websocket.appCheck = val;
  }

  @override
  CallerSDKType get sdkType => rest.sdkType;
  @override
  set sdkType(CallerSDKType val) {
    rest.sdkType = val;
    websocket.sdkType = val;
  }

  @override
  TransportOptions get transportOptions => rest.transportOptions;
  @override
  set transportOptions(TransportOptions val) {
    rest.transportOptions = val;
    websocket.transportOptions = val;
  }

  @override
  DataConnectOptions get options => rest.options;
  @override
  set options(DataConnectOptions val) {
    rest.options = val;
    websocket.options = val;
  }

  @override
  String get appId => rest.appId;
  @override
  set appId(String val) {
    rest.appId = val;
    websocket.appId = val;
  }

  @override
  Future<ServerResponse> invokeMutation<Data, Variables>(
    String operationId,
    String queryName,
    Deserializer<Data> deserializer,
    Serializer<Variables>? serializer,
    Variables? vars,
    String? token,
  ) {
    if (websocket.isConnected) {
      return websocket.invokeMutation(
          operationId, queryName, deserializer, serializer, vars, token);
    }
    return rest.invokeMutation(
        operationId, queryName, deserializer, serializer, vars, token);
  }

  @override
  Future<ServerResponse> invokeQuery<Data, Variables>(
    String operationId,
    String queryName,
    Deserializer<Data> deserializer,
    Serializer<Variables>? serialize,
    Variables? vars,
    String? token,
  ) {
    if (websocket.isConnected) {
      return websocket.invokeQuery(
          operationId, queryName, deserializer, serialize, vars, token);
    }
    return rest.invokeQuery(
        operationId, queryName, deserializer, serialize, vars, token);
  }

  @override
  Stream<ServerResponse> invokeStreamQuery<Data, Variables>(
    String operationId,
    String queryName,
    Deserializer<Data> deserializer,
    Serializer<Variables>? serializer,
    Variables? vars,
    String? token,
  ) {
    return websocket.invokeStreamQuery(
        operationId, queryName, deserializer, serializer, vars, token);
  }
}
