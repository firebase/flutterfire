#!/bin/bash

# Fast fail the script on failures.
set -e

dartanalyzer --fatal-warnings \
  lib/firebase.dart \
  lib/firebase_io.dart \
  test/firebase_test.dart

pub run test -p vm,firefox
