// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_data_connect_common;

/// Types of DataConnect errors that can occur.
enum DataConnectErrorCode { unavailable, unauthorized, other }

/// Error thrown when DataConnect encounters an error.
class DataConnectError extends FirebaseException {
  DataConnectError(this._dataConnectErrorCode, this.message)
      : super(
            plugin: 'Data Connect',
            code: _dataConnectErrorCode.toString(),
            message: message);
  final String message;
  final DataConnectErrorCode _dataConnectErrorCode;
}

typedef Serializer<Variables> = String Function(Variables vars);
typedef Deserializer<Data> = Data Function(String data);

enum OperationType { query, mutation }
