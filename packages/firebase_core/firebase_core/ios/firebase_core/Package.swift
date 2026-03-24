// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import PackageDescription

let library_version_string = "4.5.0"
let firebase_sdk_version: Version = "12.9.0"
let shared_spm_version: Version = "4.5.0-firebase-core-swift"

let package = Package(
  name: "firebase_core",
  platforms: [
    .iOS("15.0"),
  ],
  products: [
    .library(name: "firebase-core", targets: ["firebase_core"]),
  ],
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: firebase_sdk_version),
    .package(url: "https://github.com/firebase/flutterfire", exact: shared_spm_version),
  ],
  targets: [
    .target(
      name: "firebase_core",
      dependencies: [
        // No product for firebase-core so we pull in the smallest one
        .product(name: "FirebaseInstallations", package: "firebase-ios-sdk"),
        .product(name: "firebase-core-shared", package: "flutterfire"),
      ],
      exclude: [
        // These are now pulled in as a remote dependency from FlutterFire repo
        "FLTFirebaseCorePlugin.m",
        "FLTFirebasePlugin.m",
        "FLTFirebasePluginRegistry.m",
        "messages.g.m",
        "include/firebase_core/FLTFirebaseCorePlugin.h",
        "include/firebase_core/messages.g.h",
        "include/firebase_core/FLTFirebasePlugin.h",
        "include/firebase_core/FLTFirebasePluginRegistry.h",
      ],
      resources: [
        .process("Resources"),
      ],
      cSettings: [
        .headerSearchPath("include/firebase_core"),
        .define("LIBRARY_VERSION", to: "\"\(library_version_string)\""),
        .define("LIBRARY_NAME", to: "\"flutter-fire-core\""),
      ]
    ),
  ]
)
