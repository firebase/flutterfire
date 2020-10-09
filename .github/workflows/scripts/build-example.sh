#!/bin/bash

DEFAULT_TARGET="./test_driver/MELOS_PARENT_PACKAGE_NAME_e2e.dart"

ACTION=$1
TARGET_FILE=${2:-$DEFAULT_TARGET}

melos bootstrap

if [ "$ACTION" == "android" ]
then
  melos exec -c 1 --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" -- \
    flutter build apk --debug --target="$TARGET_FILE"
  MELOS_EXIT_CODE=$?
  pkill dart || true
  pkill java || true
  pkill -f '.*GradleDaemon.*' || true
  exit $MELOS_EXIT_CODE
fi

if [ "$ACTION" == "ios" ]
then
  melos exec -c 1 --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" -- \
    flutter build ios --no-codesign --simulator --debug --target="$TARGET_FILE"
  exit
fi

if [ "$ACTION" == "macos" ]
then
  # TODO Flutter dev branch is currently broken so we're unable to test MacOS.
  echo "TODO: Skipping macOS testing due to Flutter dev branch issue."
  exit
  melos exec -c 1 --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" -- \
    flutter build macos --debug --target="$TARGET_FILE"
  exit
fi
