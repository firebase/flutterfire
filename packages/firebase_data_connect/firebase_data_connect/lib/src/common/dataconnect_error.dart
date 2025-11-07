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

part of 'common_library.dart';

/// Types of DataConnect errors that can occur.
enum DataConnectErrorCode { unavailable, unauthorized, cacheMiss, codecFailed, other }

/// Error thrown when DataConnect encounters an error.
class DataConnectError extends FirebaseException {
  DataConnectError(this.dataConnectErrorCode, String? message)
      : super(
          plugin: 'Data Connect',
          code: dataConnectErrorCode.toString(),
          message: message,
        );
  final DataConnectErrorCode dataConnectErrorCode;
}

/// Error thrown when an operation is partially successful.
class DataConnectOperationError<T> extends DataConnectError {
  DataConnectOperationError(
      DataConnectErrorCode code, String message, this.response)
      : super(code, message);
  final DataConnectOperationFailureResponse<T> response;
}

/// Nested class containing errors and decoded data.
class DataConnectOperationFailureResponse<T> {
  DataConnectOperationFailureResponse(this.errors, this.rawData, this.data);
  final Map<String, dynamic>? rawData;
  final List<DataConnectOperationFailureResponseErrorInfo> errors;
  final T? data;
}

/// Error information per error.
class DataConnectOperationFailureResponseErrorInfo {
  DataConnectOperationFailureResponseErrorInfo(this.path, this.message);
  String message;
  List<DataConnectPathSegment> path;
}

/// Path where error occurred.
sealed class DataConnectPathSegment {}

class DataConnectFieldPathSegment extends DataConnectPathSegment {
  final String field;
  DataConnectFieldPathSegment(this.field);
}

class DataConnectListIndexPathSegment extends DataConnectPathSegment {
  final int index;
  DataConnectListIndexPathSegment(this.index);
}

typedef Serializer<Variables> = String Function(Variables vars);
typedef DynamicSerializer<Variables> = dynamic Function(Variables vars);
typedef Deserializer<Data> = Data Function(String data);
typedef DynamicDeserializer<Data> = Data Function(dynamic data);
