// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import PackageDescription

let library_version = "0.4.1-5"
let firebase_sdk_version: Version = "12.9.0"

let package = Package(
  name: "firebase_app_check",
  platforms: [
    .macOS("10.15"),
  ],
  products: [
    .library(name: "firebase-app-check", targets: ["firebase_app_check"]),
  ],
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: firebase_sdk_version),
    .package(name: "firebase_core", path: "../firebase_core"),
  ],
  targets: [
    .target(
      name: "firebase_app_check",
      dependencies: [
        .product(name: "FirebaseAppCheck", package: "firebase-ios-sdk"),
        .product(name: "firebase-core", package: "firebase_core"),
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
