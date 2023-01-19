#!/bin/bash

ACTION=$1

if [ "$ACTION" == "android" ]
then
  # Sleep to allow emulator to settle.
  sleep 15
  melos exec -c 1 --fail-fast --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" --dir-exists=integration_test -- \
    flutter test integration_test/MELOS_PARENT_PACKAGE_NAME_e2e_test.dart $FLUTTER_COMMAND_FLAGS --dart-define=CI=true
  exit
fi

if [ "$ACTION" == "ios" ]
then
  SIMULATOR="iPhone 11"
  # Boot simulator and wait for System app to be ready.
  xcrun simctl bootstatus "$SIMULATOR" -b
  xcrun simctl logverbose "$SIMULATOR" enable
  # Sleep to allow simulator to settle.
  sleep 15
  # Uncomment following line to have simulator logs printed out for debugging purposes.
  # xcrun simctl spawn booted log stream --predicate 'eventMessage contains "flutter"' &
  melos exec -c 1 --fail-fast --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" --dir-exists=integration_test -- \
    flutter test integration_test/MELOS_PARENT_PACKAGE_NAME_e2e_test.dart $FLUTTER_COMMAND_FLAGS -d \"$SIMULATOR\" --dart-define=CI=true
  MELOS_EXIT_CODE=$?
  xcrun simctl shutdown "$SIMULATOR"
  exit $MELOS_EXIT_CODE
fi

if [ "$ACTION" == "macos" ]
then
  melos exec -c 1 --fail-fast --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" --dir-exists=test_driver -- \
    flutter test integration_test/MELOS_PARENT_PACKAGE_NAME_e2e_test.dart $FLUTTER_COMMAND_FLAGS -d macos --dart-define=CI=true
  exit
fi

if [ "$ACTION" == "web" ]
then
  melos bootstrap --scope="*firebase_core*" --scope="$FLUTTERFIRE_PLUGIN_SCOPE"
  chromedriver --port=4444 &
  melos exec -c 1 --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" --dir-exists=web -- \
    flutter drive $FLUTTER_COMMAND_FLAGS --verbose-system-logs --device-id=web-server --target=./integration_test/MELOS_PARENT_PACKAGE_NAME_e2e_test.dart --driver=./test_driver/integration_test.dart --dart-define=CI=true
  exit
fi
