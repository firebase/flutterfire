#!/bin/bash

# Navigate to the correct directory if necessary
# cd path/to/your/flutter/project

# Run the flutter drive command
echo "HHHHHHHHHHH"
echo $(pwd)

TARGET_PATH="$1/integration_test/e2e_test.dart"
DRIVER_PATH="$1/test_driver/integration_test.dart"

echo "Running flutter drive with target: $TARGET_PATH and driver: $DRIVER_PATH"


if flutter drive --target="$TARGET_PATH" --driver="$DRIVER_PATH" -d chrome --dart-define=CI=true | grep -q '\[E\]'; then
    echo "Tests failed"
    exit 1
else
    echo "All tests have passed"
fi
