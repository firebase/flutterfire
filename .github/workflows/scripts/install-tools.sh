#!/bin/bash

flutter config --no-analytics
flutter pub global activate melos 2.4.0
flutter pub global activate flutter_plugin_tools
echo "$HOME/.pub-cache/bin" >> $GITHUB_PATH
echo "$GITHUB_WORKSPACE/_flutter/.pub-cache/bin" >> $GITHUB_PATH
echo "$GITHUB_WORKSPACE/_flutter/bin/cache/dart-sdk/bin" >> $GITHUB_PATH
