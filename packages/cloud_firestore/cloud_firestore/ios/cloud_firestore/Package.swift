// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import PackageDescription

let libraryVersion = "6.7.1"
let firebaseSdkVersion: Version = "12.15.0"

let package = Package(
  name: "cloud_firestore",
  platforms: [
    .iOS("15.0")
  ],
  products: [
    .library(name: "cloud-firestore", targets: ["cloud_firestore"])
  ],
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", exact: firebaseSdkVersion),
    .package(name: "firebase_core", path: "../firebase_core"),
  ],
  targets: [
    .target(
      name: "cloud_firestore",
      dependencies: [
        .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
        .product(name: "firebase-core", package: "firebase_core"),
      ],
      resources: [
        .process("Resources")
      ],
      cSettings: [
        .headerSearchPath("include/cloud_firestore/Private"),
        .headerSearchPath("include/cloud_firestore/Public"),
        .define("LIBRARY_VERSION", to: "\"\(libraryVersion)\""),
        .define("LIBRARY_NAME", to: "\"flutter-fire-fst\""),
      ]
    )
  ]
)
