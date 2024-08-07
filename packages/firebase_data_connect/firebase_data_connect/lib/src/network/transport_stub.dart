// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_data_connect_transport;

class TransportStub implements DataConnectTransport {
  TransportStub(this.transportOptions, this.options);
  @override
  DataConnectOptions options;

  @override
  TransportOptions transportOptions;

  @override
  Future<Data> invokeMutation<Data, Variables>(
      String queryName,
      Deserializer<Data> deserializer,
      Serializer<Variables>? serializer,
      Variables? vars,
      String? token,
      String? appCheckToken) async {
    // TODO: implement invokeMutation
    throw UnimplementedError();
  }

  @override
  Future<Data> invokeQuery<Data, Variables>(
      String queryName,
      Deserializer<Data> deserializer,
      Serializer<Variables>? serialize,
      Variables? vars,
      String? token,
      String? appCheckToken) async {
    // TODO: implement invokeQuery
    throw UnimplementedError();
  }
}

DataConnectTransport getTransport(
        TransportOptions transportOptions, DataConnectOptions options) =>
    TransportStub(transportOptions, options);
