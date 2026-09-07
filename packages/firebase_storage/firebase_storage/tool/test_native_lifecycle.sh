#!/usr/bin/env bash
# Copyright 2026 The Chromium Authors.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
set -euo pipefail

# Test the Foundation-only dispatcher without a generated Flutter framework
# or a running Firebase emulator. Full plugin integration is tested separately.
package_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d)"
trap 'rm -rf "$test_root"' EXIT
mkdir -p "$test_root/Sources/firebase_storage" "$test_root/Tests/firebase_storageTests"
cp "$package_root/ios/firebase_storage/Sources/firebase_storage/TaskEventDispatcher.swift" \
  "$test_root/Sources/firebase_storage/"
cp "$package_root/ios/firebase_storage/Tests/firebase_storageTests/TaskEventDispatcherTests.swift" \
  "$test_root/Tests/firebase_storageTests/"
cat > "$test_root/Package.swift" <<'SWIFT'
// swift-tools-version: 5.9
import PackageDescription
let package = Package(name: "StorageLifecycleTests", targets: [
  .target(name: "firebase_storage"),
  .testTarget(name: "firebase_storageTests", dependencies: ["firebase_storage"]),
])
SWIFT
swift test --package-path "$test_root"
