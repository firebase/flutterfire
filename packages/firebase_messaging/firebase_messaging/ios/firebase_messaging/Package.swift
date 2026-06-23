// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import PackageDescription

let libraryVersion = "16.4.1"
let firebaseSdkVersion: Version = "12.15.0"

let package = Package(
  name: "firebase_messaging",
  platforms: [
    .iOS("15.0")
  ],
  products: [
    .library(name: "firebase-messaging", targets: ["firebase_messaging"])
  ],
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", exact: firebaseSdkVersion),
    .package(name: "firebase_core", path: "../firebase_core"),
  ],
  targets: [
    .target(
      name: "firebase_messaging",
      dependencies: [
        .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
        .product(name: "firebase-core", package: "firebase_core"),
      ],
      resources: [
        .process("Resources")
      ],
      cSettings: [
        .headerSearchPath("include"),
        .define("LIBRARY_VERSION", to: "\"\(libraryVersion)\""),
        .define("LIBRARY_NAME", to: "\"flutter-fire-fcm\""),
      ]
    )
  ]
)
