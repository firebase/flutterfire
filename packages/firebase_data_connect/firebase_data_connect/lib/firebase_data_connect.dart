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

export 'src/any_value.dart' show AnyValue, defaultSerializer;
export 'src/common/common_library.dart'
    show
        ConnectorConfig,
        DataConnectError,
        DataConnectFieldPathSegment,
        DataConnectOperationError,
        DataConnectListIndexPathSegment,
        DataConnectOperationFailureResponse,
        DataConnectOperationFailureResponseErrorInfo,
        DataConnectErrorCode,
        Serializer,
        Deserializer,
        CallerSDKType;
export 'src/core/empty_serializer.dart' show emptySerializer;
export 'src/core/ref.dart'
    show MutationRef, OperationRef, OperationResult, QueryRef, QueryResult;
export 'src/firebase_data_connect.dart';
export 'src/optional.dart'
    show
        Optional,
        OptionalState,
        nativeFromJson,
        nativeToJson,
        listDeserializer,
        listSerializer;
export 'src/timestamp.dart' show Timestamp;
export 'src/cache/cache_data_types.dart' show CacheSettings, QueryFetchPolicy, CacheStorage;
