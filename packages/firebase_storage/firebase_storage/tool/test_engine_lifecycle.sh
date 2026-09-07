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
project="$example_root/ios/Runner.xcodeproj"
scheme="$project/xcshareddata/xcschemes/StorageLifecycleTests.xcscheme"
if [[ -e "$scheme" ]]; then
  echo "A StorageLifecycleTests scheme already exists; refusing to replace it." >&2
  exit 1
fi
ruby -e 'require "xcodeproj"'
curl --silent --show-error --max-time 5 --output /dev/null http://127.0.0.1:9199/
backup="$(mktemp -d)"
cp "$project/project.pbxproj" "$backup/project.pbxproj"
cp "$example_root/ios/Podfile" "$backup/Podfile"
cp "$project/xcshareddata/xcschemes/Runner.xcscheme" "$backup/Runner.xcscheme"
restore_project() {
  cp "$backup/project.pbxproj" "$project/project.pbxproj"
  cp "$backup/Podfile" "$example_root/ios/Podfile"
  cp "$backup/Runner.xcscheme" "$project/xcshareddata/xcschemes/Runner.xcscheme"
  rm -f "$scheme"
  rm -rf "$backup"
}
trap restore_project EXIT
(
  cd "$example_root"
  flutter build ios --simulator --debug --no-codesign --no-pub \
    --target=integration_test/native_lifecycle_main.dart
)
ruby "$package_root/tool/configure_engine_lifecycle_test.rb" "$example_root/ios"
xcodebuild test \
  -workspace "$example_root/ios/Runner.xcworkspace" \
  -scheme StorageLifecycleTests -configuration Debug \
  -destination "platform=iOS Simulator,id=$1" \
  -derivedDataPath "$example_root/build/ios" \
  -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO \
  "FRAMEWORK_SEARCH_PATHS=\$(inherited) $example_root/build/ios/Debug-iphonesimulator"
