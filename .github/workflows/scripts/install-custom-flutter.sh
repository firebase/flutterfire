#!/bin/bash

BRANCH=$1
git clone https://github.com/flutter/flutter --depth 1 -b "stable" "$GITHUB_WORKSPACE/_flutter"
echo "$GITHUB_WORKSPACE/_flutter/bin" >> $GITHUB_PATH

