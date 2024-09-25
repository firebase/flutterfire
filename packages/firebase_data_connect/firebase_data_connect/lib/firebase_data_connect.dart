// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library firebase_data_connect;

export 'src/firebase_data_connect.dart';
export 'src/common/common_library.dart'
    show
        ConnectorConfig,
        DataConnectError,
        DataConnectErrorCode,
        Serializer,
        Deserializer,
        CallerSDKType;
export 'src/core/empty_serializer.dart' show emptySerializer;
export 'src/core/ref.dart'
    show MutationRef, OperationRef, OperationResult, QueryRef, QueryResult;

export 'src/optional.dart'
    show Optional, OptionalState, nativeFromJson, nativeToJson;
export 'src/timestamp.dart' show Timestamp;
