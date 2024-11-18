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

part of firebase_data_connect_common;

/// Types of DataConnect errors that can occur.
enum DataConnectErrorCode { unavailable, unauthorized, other }

/// Error thrown when DataConnect encounters an error.
class DataConnectError extends FirebaseException {
  DataConnectError(this.dataConnectErrorCode, message)
      : super(
            plugin: 'Data Connect',
            code: dataConnectErrorCode.toString(),
            message: message);
  final DataConnectErrorCode dataConnectErrorCode;
}

typedef Serializer<Variables> = String Function(Variables vars);
typedef DynamicSerializer<Variables> = dynamic Function(Variables vars);
typedef Deserializer<Data> = Data Function(String data);
typedef DynamicDeserializer<Data> = Data Function(dynamic data);
