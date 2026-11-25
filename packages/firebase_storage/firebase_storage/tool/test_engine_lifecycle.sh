#!/usr/bin/env bash
# Copyright 2026 The Chromium Authors.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <iOS simulator UDID>" >&2
  exit 64
fi
package_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
example_root="$package_root/example"
curl --silent --show-error --max-time 5 --output /dev/null http://127.0.0.1:9199/
(
  cd "$example_root"
  flutter build ios --simulator --debug --no-codesign --no-pub \
    --target=integration_test/native_lifecycle_main.dart
)
xcodebuild test \
  -workspace "$example_root/ios/Runner.xcworkspace" \
  -scheme Runner -configuration Debug \
  -destination "platform=iOS Simulator,id=$1" \
  -derivedDataPath "$example_root/build/native-tests" \
  -clonedSourcePackagesDirPath "$example_root/build/ios/SourcePackages" \
  -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO \
  "BUILD_DIR=$example_root/build/ios"
