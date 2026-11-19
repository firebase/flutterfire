#!/bin/bash
# Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

# Resolves Swift package graphs against a local git repo tagged 13.0.0,
# 13.1.1, 13.2.0, and 13.3.0.
#
# The published firebase-ios-sdk pin is 13.2.0, which is also the newest 13.x
# tag, so resolving the real packages cannot show that an exact pin held the
# resolver back. This fixture tags a newer 13.3.0. Core's exact 13.2.0 pin has
# to win over a plugin `from: "13.2.0"`, and over an older plugin
# `from: "13.1.1"`. An older core pin has to fail against a plugin built on
# 13.2.0. A core that also uses `from` has to float to 13.3.0.

set -eu

root=$(mktemp -d)
trap 'rm -rf "$root"' EXIT

sdk="$root/firebase-ios-sdk"
mkdir -p "$sdk/Sources/FirebaseCore"

cat >"$sdk/Package.swift" <<'EOF'
// swift-tools-version: 5.9
import PackageDescription
let package = Package(
  name: "firebase-ios-sdk",
  products: [
    .library(name: "FirebaseCore", targets: ["FirebaseCore"])
  ],
  targets: [
    .target(name: "FirebaseCore")
  ]
)
EOF

cat >"$sdk/Sources/FirebaseCore/FirebaseCore.swift" <<'EOF'
public enum FirebaseCoreMarker {}
EOF

git -C "$sdk" init -q
git -C "$sdk" add .
git -C "$sdk" -c user.email="spm-pin@example.com" -c user.name="spm-pin" commit -qm "13.0.0"
git -C "$sdk" tag 13.0.0
printf '\n// 13.1.1\n' >>"$sdk/Sources/FirebaseCore/FirebaseCore.swift"
git -C "$sdk" add .
git -C "$sdk" -c user.email="spm-pin@example.com" -c user.name="spm-pin" commit -qm "13.1.1"
git -C "$sdk" tag 13.1.1
printf '\n// 13.2.0\n' >>"$sdk/Sources/FirebaseCore/FirebaseCore.swift"
git -C "$sdk" add .
git -C "$sdk" -c user.email="spm-pin@example.com" -c user.name="spm-pin" commit -qm "13.2.0"
git -C "$sdk" tag 13.2.0
printf '\n// 13.3.0\n' >>"$sdk/Sources/FirebaseCore/FirebaseCore.swift"
git -C "$sdk" add .
git -C "$sdk" -c user.email="spm-pin@example.com" -c user.name="spm-pin" commit -qm "13.3.0"
git -C "$sdk" tag 13.3.0

write_graph() {
  name="$1"
  core_requirement="$2"
  plugin_requirement="$3"
  dir="$root/$name"
  mkdir -p "$dir/core/Sources/core" "$dir/plugin/Sources/plugin" "$dir/app/Sources/app"

  cat >"$dir/core/Package.swift" <<EOF
// swift-tools-version: 5.9
import PackageDescription
let package = Package(
  name: "firebase_core",
  products: [
    .library(name: "firebase-core", targets: ["core"])
  ],
  dependencies: [
    .package(url: "$sdk", $core_requirement),
  ],
  targets: [
    .target(
      name: "core",
      dependencies: [
        .product(name: "FirebaseCore", package: "firebase-ios-sdk")
      ]
    )
  ]
)
EOF

  cat >"$dir/core/Sources/core/Core.swift" <<'EOF'
public enum CoreMarker {}
EOF

  cat >"$dir/plugin/Package.swift" <<EOF
// swift-tools-version: 5.9
import PackageDescription
let package = Package(
  name: "firebase_auth",
  products: [
    .library(name: "firebase-auth", targets: ["plugin"])
  ],
  dependencies: [
    .package(url: "$sdk", $plugin_requirement),
    .package(name: "firebase_core", path: "../core"),
  ],
  targets: [
    .target(
      name: "plugin",
      dependencies: [
        .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
        .product(name: "firebase-core", package: "firebase_core")
      ]
    )
  ]
)
EOF

  cat >"$dir/plugin/Sources/plugin/Plugin.swift" <<'EOF'
public enum PluginMarker {}
EOF

  cat >"$dir/app/Package.swift" <<'EOF'
// swift-tools-version: 5.9
import PackageDescription
let package = Package(
  name: "app",
  dependencies: [
    .package(name: "firebase_auth", path: "../plugin"),
  ],
  targets: [
    .executableTarget(
      name: "app",
      dependencies: [
        .product(name: "firebase-auth", package: "firebase_auth")
      ]
    )
  ]
)
EOF

  cat >"$dir/app/Sources/app/main.swift" <<'EOF'
print("ok")
EOF
}

resolved_version() {
  file="$1/app/Package.resolved"
  # Do not parse this with python3. A python3 earlier on PATH can be a stub
  # that exits 0 and prints nothing, which hides a resolved version.
  raw=$(
    grep -E -A 20 '"identity" *: *"firebase-ios-sdk"' "$file" |
      grep '"version"' |
      head -1 || true
  )
  version=$(printf '%s\n' "$raw" | sed -E 's/.*"version" *: *"([^"]+)".*/\1/')
  if [ -z "$raw" ] || [ "$version" = "$raw" ]; then
    echo "could not read the firebase-ios-sdk version from $file" >&2
    cat "$file" >&2
    exit 1
  fi
  printf '%s\n' "$version"
}

resolve() {
  GIT_CONFIG_COUNT=1 \
    GIT_CONFIG_KEY_0=protocol.file.allow \
    GIT_CONFIG_VALUE_0=always \
    swift package resolve --package-path "$1/app" >/dev/null
  resolved_version "$1"
}

expect_conflict() {
  dir="$1"
  err="$dir/resolve.err"
  if GIT_CONFIG_COUNT=1 \
    GIT_CONFIG_KEY_0=protocol.file.allow \
    GIT_CONFIG_VALUE_0=always \
    swift package resolve --package-path "$dir/app" >"$dir/resolve.out" 2>"$err"
  then
    echo "expected a version conflict for $dir" >&2
    exit 1
  fi
  if ! grep -q '13.2.0' "$err" || ! grep -q '13.1.1' "$err"; then
    echo "expected the conflict to mention 13.1.1 and 13.2.0" >&2
    cat "$err" >&2
    exit 1
  fi
}

write_graph current 'exact: "13.2.0"' 'from: "13.2.0"'
write_graph older_plugin 'exact: "13.2.0"' 'from: "13.1.1"'
write_graph stale_core 'exact: "13.1.1"' 'from: "13.2.0"'
write_graph floated 'from: "13.0.0"' 'from: "13.2.0"'

current_version=$(resolve "$root/current")
older_plugin_version=$(resolve "$root/older_plugin")
floated_version=$(resolve "$root/floated")
expect_conflict "$root/stale_core"

echo "core exact 13.2.0, plugin from 13.2.0 -> $current_version"
echo "core exact 13.2.0, plugin from 13.1.1 -> $older_plugin_version"
echo "core from 13.0.0, plugin from 13.2.0 -> $floated_version"
echo "core exact 13.1.1, plugin from 13.2.0 -> conflict"

if [ "$current_version" != "13.2.0" ]; then
  echo "expected the exact pin 13.2.0, got $current_version" >&2
  exit 1
fi

if [ "$older_plugin_version" != "13.2.0" ]; then
  echo "expected an older plugin floor to select 13.2.0, got $older_plugin_version" >&2
  exit 1
fi

if [ "$floated_version" != "13.3.0" ]; then
  echo "expected the floated graph to select 13.3.0, got $floated_version" >&2
  exit 1
fi
