#!/bin/bash

xcrun simctl boot "iPhone 11"

melos exec -c 1 --fail-fast --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" --dir-exists=test_driver -- \
  flutter drive -d \"iPhone 11\" --no-pub --target=./test_driver/MELOS_PARENT_PACKAGE_NAME_e2e.dart