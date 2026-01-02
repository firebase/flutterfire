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

part of 'transport_library.dart';

/// Default TransportStub to satisfy compilation of the library.
class TransportStub implements DataConnectTransport {
  /// Constructor.
  TransportStub(
    this.transportOptions,
    this.options,
    this.appId,
    this.sdkType,
    this.appCheck,
  );

  /// FirebaseAuth
  @override

  /// FirebaseAppCheck
  @override
  FirebaseAppCheck? appCheck;

  /// DataConnect backend options.
  @override
  DataConnectOptions options;

  /// Network configuration options.
  @override
  TransportOptions transportOptions;

  /// Core or Generated SDK being used.
  @override
  CallerSDKType sdkType;

  @override
  String appId;

  /// Stub for invoking a mutation.
  @override
  Future<ServerResponse> invokeMutation<Data, Variables>(
    String queryName,
    Deserializer<Data> deserializer,
    Serializer<Variables>? serializer,
    Variables? vars,
    String? token,
  ) async {
    // TODO: implement invokeMutation
    throw UnimplementedError();
  }

  /// Stub for invoking a query.
  @override
  Future<ServerResponse> invokeQuery<Data, Variables>(
    String queryName,
    Deserializer<Data> deserializer,
    Serializer<Variables>? serialize,
    Variables? vars,
    String? token,
  ) async {
    // TODO: implement invokeQuery
    throw UnimplementedError();
  }
}

DataConnectTransport getTransport(
  TransportOptions transportOptions,
  DataConnectOptions options,
  String appId,
  CallerSDKType sdkType,
  FirebaseAppCheck? appCheck,
) =>
    TransportStub(transportOptions, options, appId, sdkType, appCheck);
