#!/bin/bash

BRANCH=$1
git clone https://github.com/invertase/flutter --depth 1 -b "macos-provisioning" "$GITHUB_WORKSPACE/_flutter"
echo "$GITHUB_WORKSPACE/_flutter/bin" >> $GITHUB_PATH

