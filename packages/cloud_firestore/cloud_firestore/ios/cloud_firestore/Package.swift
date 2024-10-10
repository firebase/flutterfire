// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import Foundation
import PackageDescription

let library_version = "5.4.1"

let package = Package(
  name: "cloud_firestore",
  platforms: [
    .iOS("13.0"),
  ],
  products: [
    .library(name: "cloud-firestore", targets: ["cloud_firestore"]),
  ],
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.0.0"),
    .package(name: "firebase_core", path: "../../../../firebase_core/firebase_core/ios/firebase_core")
  ],
  targets: [
    .target(
      name: "cloud_firestore",
      dependencies: [
        .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
        .product(name: "firebase-core", package: "firebase_core") // Add firebase_core to target dependencies
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
