// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import Foundation
import PackageDescription

let firebase_sdk_version = "11.0.0"
let library_version = "3.4.1"

let package = Package(
  name: "firebase_core",
  platforms: [
    .iOS("13.0"),
  ],
  products: [
    .library(name: "firebase-core", targets: ["firebase_core"]),
  ],
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: Version(firebase_sdk_version)!),
  ],
  targets: [
    .target(
      name: "firebase_core",
      dependencies: [
        // No product for firebase-core so we pull in the smallest one
        .product(name: "FirebaseInstallations", package: "firebase-ios-sdk"),
      ],
      path: "packages/firebase_core/firebase_core/ios/firebase_core/Sources", // Specify the path to the source files
      resources: [
        .process("packages/firebase_core/firebase_core/ios/firebase_core/Sources/firebase_core/Resources"),
      ],
      cSettings: [
        .headerSearchPath("packages/firebase_core/firebase_core/ios/firebase_core/Sources/firebase_core/include/firebase_core"),
        .define("LIBRARY_VERSION", to: "\"\(library_version)\""),
        .define("LIBRARY_NAME", to: "\"flutter-fire-core\""),
      ]
    ),
  ]
)
