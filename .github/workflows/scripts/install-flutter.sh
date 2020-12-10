#!/bin/bash

BRANCH=$1

if [ "$BRANCH" == "dev" ]
then
  # TODO Flutter dev branch is currently broken so we're unable to test MacOS.
  echo "TODO: Skipping macOS testing due to Flutter dev branch issue. Switching branch to stable."
  BRANCH=stable
fi

git clone https://github.com/flutter/flutter.git --depth 1 -b $BRANCH _flutter
echo "$GITHUB_WORKSPACE/_flutter/bin" >> $GITHUB_PATH
