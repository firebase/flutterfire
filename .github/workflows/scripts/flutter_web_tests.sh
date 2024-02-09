#!/bin/bash

echo "HHHHHHHHHHH"
echo $(pwd)

echo "Running flutter drive with target: $TARGET_PATH and driver: $DRIVER_PATH"

cd "/Users/runner/work/flutterfire/flutterfire/$1"
echo "switched directory"
echo $(pwd)

if flutter drive --target=./integration_test/e2e_test.dart --driver=./test_driver/integration_test.dart -d chrome --dart-define=CI=true | grep -q '\[E\]'; then
    echo "Tests failed"
    exit 1
else
    echo "All tests have passed"
fi
