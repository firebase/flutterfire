// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import PackageDescription

let firebase_sdk_version: Version = "12.9.0"

let package = Package(
  name: "cloud_functions",
  platforms: [
    .macOS("10.15"),
  ],
  products: [
    .library(name: "cloud-functions", targets: ["cloud_functions"]),
  ],
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: firebase_sdk_version),
    .package(name: "firebase_core", path: "../firebase_core"),
  ],
  targets: [
    .target(
      name: "cloud_functions",
      dependencies: [
        .product(name: "FirebaseFunctions", package: "firebase-ios-sdk"),
        .product(name: "firebase-core", package: "firebase_core"),
      ],
      resources: [
        .process("Resources"),
      ]
    ),
  ]
)
