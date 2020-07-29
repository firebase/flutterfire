#!/bin/bash

ACTION=$1

if [ "$ACTION" == "android" ]
then
  melos exec -c 1 --fail-fast --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" --dir-exists=test_driver -- \
    flutter drive --no-pub --no-build --target=./test_driver/MELOS_PARENT_PACKAGE_NAME_e2e.dart
  exit
fi

if [ "$ACTION" == "ios" ]
then
  xcrun simctl boot "iPhone 11"
  melos exec -c 1 --fail-fast --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" --dir-exists=test_driver -- \
    flutter drive -d \"iPhone 11\" --no-pub --no-build --target=./test_driver/MELOS_PARENT_PACKAGE_NAME_e2e.dart
  xcrun simctl shutdown "iPhone 11"
  exit
fi

if [ "$ACTION" == "macos" ]
then
  melos exec -c 1 --fail-fast --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" --dir-exists=test_driver -- \
    flutter drive -d macos --no-pub --no-build --target=./test_driver/MELOS_PARENT_PACKAGE_NAME_e2e.dart
  exit
fi

if [ "$ACTION" == "web" ]
then
  melos clean && melos bootstrap
  chromedriver --port=4444 --log-level=INFO &
  melos exec -c 1 --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" --dir-exists=web -- \
    flutter drive -d chrome --no-build --release --no-pub --verbose-system-logs --browser-name=chrome --target=./test_driver/MELOS_PARENT_PACKAGE_NAME_e2e.dart
  exit
fi
