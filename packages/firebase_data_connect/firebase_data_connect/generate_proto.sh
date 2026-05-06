#!/bin/bash

# Uses dart protoc_plugin version 21.1.2. There are compilation issues with newer plugin versions.
# https://github.com/google/protobuf.dart/releases/tag/protoc_plugin-v21.1.2
# Run `pub global activate protoc_plugin 21.1.2`

rm -rf lib/src/generated
mkdir lib/src/generated
protoc --dart_out=grpc:lib/src/generated -I./protos/firebase -I./protos/google  connector_service.proto google/protobuf/struct.proto google/protobuf/duration.proto graphql_error.proto graphql_response_extensions.proto --proto_path=./protos
