#!/bin/bash

ACTION=$1

if [ "$ACTION" == "android" ]
then
  # Sleep to allow emulator to settle.
  sleep 15
  melos exec -c 1 --fail-fast --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" --dir-exists=test_driver -- \
    flutter drive --no-pub --target=./test_driver/MELOS_PARENT_PACKAGE_NAME_e2e.dart
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
  melos exec -c 1 --fail-fast --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" --dir-exists=test_driver -- \
    flutter drive -d \"$SIMULATOR\" --no-pub --target=./test_driver/MELOS_PARENT_PACKAGE_NAME_e2e.dart
  MELOS_EXIT_CODE=$?
  xcrun simctl shutdown "$SIMULATOR"
  exit $MELOS_EXIT_CODE
fi

if [ "$ACTION" == "macos" ]
then
  # TODO Flutter dev branch is currently broken so we're unable to test MacOS.
  echo "TODO: Skipping macOS testing due to Flutter dev branch issue."
  exit
  melos exec -c 1 --fail-fast --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" --dir-exists=test_driver -- \
    flutter drive -d macos --no-pub --target=./test_driver/MELOS_PARENT_PACKAGE_NAME_e2e.dart
  exit
fi

if [ "$ACTION" == "web" ]
then
  melos bootstrap
  chromedriver --port=4444 &
  melos exec -c 1 --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" --dir-exists=web -- \
    flutter drive --release --no-pub --verbose-system-logs --browser-name=chrome --target=./test_driver/MELOS_PARENT_PACKAGE_NAME_e2e.dart
  exit
fi
