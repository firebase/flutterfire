#!/bin/bash

git clone https://github.com/invertase/flutter --depth 1 -b "macos-provisioning-profile" "$GITHUB_WORKSPACE/flutter"
echo "$GITHUB_WORKSPACE/flutter/bin" >> $GITHUB_PATH
