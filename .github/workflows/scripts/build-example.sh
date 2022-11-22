#!/bin/bash

DEFAULT_TARGET="./integration_test/MELOS_PARENT_PACKAGE_NAME_e2e_test.dart"

ACTION=$1
TARGET_FILE=${2:-$DEFAULT_TARGET}

melos bootstrap --scope="*firebase_core*" --scope="$FLUTTERFIRE_PLUGIN_SCOPE"

if [ "$ACTION" == "android" ]
then
  melos exec -c 1 --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" -- \
    flutter build apk $FLUTTER_COMMAND_FLAGS --debug --target="$TARGET_FILE" --dart-define=CI=true --no-android-gradle-daemon
  MELOS_EXIT_CODE=$?
  pkill dart || true
  pkill java || true
  exit $MELOS_EXIT_CODE
fi

if [ "$ACTION" == "ios" ]
then
  melos exec -c 1 --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" -- \
    flutter build ios $FLUTTER_COMMAND_FLAGS --no-codesign --simulator --debug --target="$TARGET_FILE" --dart-define=CI=true
  exit
fi

if [ "$ACTION" == "macos" ]
then
  melos exec -c 1 --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" -- \
    flutter build macos $FLUTTER_COMMAND_FLAGS --debug --target="$TARGET_FILE" --device-id=macos --dart-define=CI=true
  exit
fi
