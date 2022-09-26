#!/bin/bash

flutter config --no-analytics
flutter pub global activate melos 2.4.0
flutter pub global activate flutter_plugin_tools
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
echo "$HOME/.pub-cache/bin" >> $GITHUB_PATH
echo "$GITHUB_WORKSPACE/_flutter/.pub-cache/bin" >> $GITHUB_PATH
echo "$GITHUB_WORKSPACE/_flutter/bin/cache/dart-sdk/bin" >> $GITHUB_PATH
