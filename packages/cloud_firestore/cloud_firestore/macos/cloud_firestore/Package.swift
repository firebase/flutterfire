// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import PackageDescription

let library_version = "6.1.3"
let firebase_sdk_version = Version("12.9.0")!
let shared_spm_version = Version("4.5.0-firebase-core-swift")!

let package = Package(
  name: "cloud_firestore",
  platforms: [
    .macOS("10.15"),
  ],
  products: [
    .library(name: "cloud-firestore", targets: ["cloud_firestore"]),
  ],
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: firebase_sdk_version),
    .package(url: "https://github.com/firebase/flutterfire", exact: shared_spm_version),
  ],
  targets: [
    .target(
      name: "cloud_firestore",
      dependencies: [
        .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
        // Wrapper dependency
        .product(name: "firebase-core-shared", package: "flutterfire"),
      ],
      resources: [
        .process("Resources"),
      ],
      cSettings: [
        .headerSearchPath("include/cloud_firestore/Private"),
        .headerSearchPath("include/cloud_firestore/Public"),
        .define("LIBRARY_VERSION", to: "\"\(library_version)\""),
        .define("LIBRARY_NAME", to: "\"flutter-fire-fst\""),
      ]
    ),
  ]
)
