#!/bin/bash

# Navigate to the correct directory if necessary
# cd path/to/your/flutter/project

# Run the flutter drive command
echo "HHHHHHHHHHH"
echo pwd
if flutter drive --target=./integration_test/e2e_test.dart --driver=./test_driver/integration_test.dart -d chrome --dart-define=CI=true | grep -q '\[E\]'; then
    echo "Tests failed"
    exit 1
else
    echo "All tests have passed"
fi
