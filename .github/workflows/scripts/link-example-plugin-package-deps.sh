#!/bin/bash
# Usage: link-example-plugin-package-deps.sh <example-app-dir> <ios|macos>
#
# Flutter adds a plugin's own Swift package to its example app's Xcode project
# as a local package override, at the plugin's real path. Flutter's generated
# package reaches the same plugin through the ephemeral symlink farm
# (`<platform>/Flutter/ephemeral/Packages/.packages`), where its
# `path: "../firebase_core"` and `path: "../FlutterFramework"` dependencies
# exist. When Xcode resolves the override instead, those paths point next to
# the real package and resolution fails ("... doesn't exist in file system").
# The CI Xcode picks the override often enough that a retry does not help, so
# link each sibling dependency into the plugin's platform directory, pointing
# at the farm Flutter generates before it runs xcodebuild.
set -euo pipefail

app_dir=$(cd "$1" && pwd)
platform=$2
plugin_root=$(dirname "$app_dir")

[ -f "$plugin_root/pubspec.yaml" ] || exit 0
plugin=$(sed -n 's/^name: *//p' "$plugin_root/pubspec.yaml" | head -n 1)
manifest="$plugin_root/$platform/$plugin/Package.swift"
[ -f "$manifest" ] || exit 0

packages="$app_dir/$platform/Flutter/ephemeral/Packages/.packages"
grep -oE 'path: "\.\./[A-Za-z0-9_]+"' "$manifest" |
  sed -E 's/.*\.\.\/([A-Za-z0-9_]+)"/\1/' |
  sort -u |
  while read -r dependency; do
    link="$plugin_root/$platform/$dependency"
    # Never replace a real package that lives there.
    if [ -e "$link" ] && [ ! -L "$link" ]; then
      continue
    fi
    ln -sfn "$packages/$dependency" "$link"
    echo "Linked $link -> $packages/$dependency"
  done
