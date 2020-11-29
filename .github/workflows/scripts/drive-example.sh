#!/bin/bash

ACTION=$1

if [ "$ACTION" == "android" ]
then
  # Sleep to allow emulator to settle.
  sleep 15

  # Create an emulator log for troubleshooting, will be uploaded as an artifact
  nohup sh -c "$ANDROID_HOME/platform-tools/adb logcat '*:D' > adb-log.txt" &

  melos exec -c 1 --fail-fast --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" --dir-exists=test_driver -- \
    flutter drive --no-pub --target=./test_driver/MELOS_PARENT_PACKAGE_NAME_e2e.dart --dart-define=CI=true
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

  # Create a simulator log for troubleshooting, will be uploaded as an artifact
  nohup sh -c "sleep 30 && xcrun simctl spawn booted log stream --level debug --style compact > simulator.log 2>&1 &"

  melos exec -c 1 --fail-fast --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" --dir-exists=test_driver -- \
    flutter drive -d \"$SIMULATOR\" --no-pub --target=./test_driver/MELOS_PARENT_PACKAGE_NAME_e2e.dart --dart-define=CI=true
  MELOS_EXIT_CODE=$?
  xcrun simctl shutdown "$SIMULATOR"
  exit $MELOS_EXIT_CODE
fi

if [ "$ACTION" == "macos" ]
then
  melos exec -c 1 --fail-fast --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" --dir-exists=test_driver -- \
    flutter drive -d macos --no-pub --target=./test_driver/MELOS_PARENT_PACKAGE_NAME_e2e.dart --dart-define=CI=true
  exit
fi

if [ "$ACTION" == "web" ]
then
  melos bootstrap
  chromedriver --port=4444 &
  melos exec -c 1 --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" --dir-exists=web -- \
    flutter drive --no-pub --verbose-system-logs --device-id=web-server --target=./test_driver/MELOS_PARENT_PACKAGE_NAME_e2e.dart --dart-define=CI=true
  exit
fi
