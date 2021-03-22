#!/bin/bash

DEFAULT_TARGET="./test_driver/MELOS_PARENT_PACKAGE_NAME_e2e.dart"

ACTION=$1
TARGET_FILE=${2:-$DEFAULT_TARGET}

melos bootstrap

if [ "$ACTION" == "android" ]
then
  melos exec -c 1 --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" -- \
    flutter build apk --debug --target="$TARGET_FILE" --dart-define=CI=true --no-android-gradle-daemon
  MELOS_EXIT_CODE=$?
  pkill dart || true
  pkill java || true
  exit $MELOS_EXIT_CODE
fi

if [ "$ACTION" == "ios" ]
then
  melos exec -c 1 --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" -- \
    flutter build ios --no-codesign --simulator --debug --target="$TARGET_FILE" --dart-define=CI=true
  exit
fi

if [ "$ACTION" == "macos" ]
then
  melos exec -c 1 --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" -- \
    flutter build macos --debug --target="$TARGET_FILE" --device-id=macos --dart-define=CI=true
  exit
fi
