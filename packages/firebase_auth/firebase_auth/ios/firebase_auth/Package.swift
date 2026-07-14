// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import PackageDescription

let libraryVersion = "6.5.6"
let firebaseSdkVersion: Version = "12.15.0"

let package = Package(
  name: "firebase_auth",
  platforms: [
    .iOS("15.0")
  ],
  products: [
    .library(name: "firebase-auth", targets: ["firebase_auth"])
  ],
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", exact: firebaseSdkVersion),
    .package(name: "firebase_core", path: "../firebase_core"),
  ],
  targets: [
    .target(
      name: "firebase_auth",
      dependencies: [
        .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
        .product(name: "firebase-core", package: "firebase_core"),
      ],
      resources: [
        .process("Resources")
      ],
      cSettings: [
        .headerSearchPath("include/Private"),
        .headerSearchPath("include/Public"),
        .define("LIBRARY_VERSION", to: "\"\(libraryVersion)\""),
        .define("LIBRARY_NAME", to: "\"flutter-fire-auth\""),
      ]
    )
  ]
)
