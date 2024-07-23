#!/bin/bash
rm -rf lib/src/generated
mkdir lib/src/generated
protoc --dart_out=grpc:lib/src/generated -I./protos/firebase -I./protos/google  connector_service.proto google/protobuf/struct.proto graphql_error.proto --proto_path=./protos
