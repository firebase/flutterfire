// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import PackageDescription

let library_version = "0.4.1-5"
let firebase_sdk_version = Version("12.9.0")!
let shared_spm_version = Version("4.5.0-firebase-core-swift")!

let package = Package(
  name: "firebase_app_check",
  platforms: [
    .iOS("15.0"),
  ],
  products: [
    .library(name: "firebase-app-check", targets: ["firebase_app_check"]),
  ],
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: firebase_sdk_version),
    .package(url: "https://github.com/firebase/flutterfire", exact: shared_spm_version),
  ],
  targets: [
    .target(
      name: "firebase_app_check",
      dependencies: [
        .product(name: "FirebaseAppCheck", package: "firebase-ios-sdk"),
        // Wrapper dependency
        .product(name: "firebase-core-shared", package: "flutterfire"),
      ],
      resources: [
        .process("Resources"),
      ],
      cSettings: [
        .headerSearchPath("include"),
        .define("LIBRARY_VERSION", to: "\"\(library_version)\""),
        .define("LIBRARY_NAME", to: "\"flutter-fire-appcheck\""),
      ]
    ),
  ]
)
