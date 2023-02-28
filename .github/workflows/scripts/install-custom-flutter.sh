#!/bin/bash

git clone https://github.com/invertase/flutter --depth 1 -b "macos-provisioning-profile" "$GITHUB_WORKSPACE/flutter"
echo "$GITHUB_WORKSPACE/flutter/bin" >> $GITHUB_PATH

flutter config --no-analytics
flutter pub global activate melos 2.9.0
flutter pub global activate flutter_plugin_tools
echo "$HOME/.pub-cache/bin" >> $GITHUB_PATH
echo "$GITHUB_WORKSPACE/flutter/.pub-cache/bin" >> $GITHUB_PATH
echo "$GITHUB_WORKSPACE/flutter/bin/cache/dart-sdk/bin" >> $GITHUB_PATH
