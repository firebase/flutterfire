# Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

# Resolves two Swift package graphs against a local git repo tagged 13.0.0,
# 13.1.1, and 13.2.0.
#
# The published firebase-ios-sdk pin is 13.2.0, which is also the newest 13.x
# tag, so resolving the real packages cannot show that an exact pin held the
# resolver back. This fixture pins core at 13.1.1 while the other package
# allows any 13.x. The resolved version has to be 13.1.1. A second graph, where
# core also uses `from: "13.0.0"`, has to select 13.2.0.

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

write_graph() {
  name="$1"
  core_requirement="$2"
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
    .package(url: "$sdk", from: "13.0.0"),
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
  python3 - "$1/app/Package.resolved" <<'PY'
import json, sys
pins = json.load(open(sys.argv[1]))["pins"]
versions = [
    pin["state"]["version"]
    for pin in pins
    if pin["identity"] == "firebase-ios-sdk"
]
if len(versions) != 1:
    raise SystemExit(f"expected one firebase-ios-sdk pin, found {versions}")
print(versions[0])
PY
}

resolve() {
  GIT_CONFIG_COUNT=1 \
    GIT_CONFIG_KEY_0=protocol.file.allow \
    GIT_CONFIG_VALUE_0=always \
    swift package resolve --package-path "$1/app" >/dev/null
  resolved_version "$1"
}

write_graph pinned 'exact: "13.1.1"'
write_graph floated 'from: "13.0.0"'

pinned_version=$(resolve "$root/pinned")
floated_version=$(resolve "$root/floated")

echo "core exact 13.1.1, plugin from 13.0.0 -> $pinned_version"
echo "core from 13.0.0, plugin from 13.0.0 -> $floated_version"

if [ "$pinned_version" != "13.1.1" ]; then
  echo "expected the exact pin 13.1.1, got $pinned_version" >&2
  exit 1
fi

if [ "$floated_version" != "13.2.0" ]; then
  echo "expected the floated graph to select 13.2.0, got $floated_version" >&2
  exit 1
fi
