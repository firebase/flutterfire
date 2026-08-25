// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import PackageDescription

let firebaseSdkVersion: Version = "12.18.0"

let package = Package(
  name: "firebase_crashlytics",
  platforms: [
    .iOS("15.0")
  ],
  products: [
    .library(name: "firebase-crashlytics", targets: ["firebase_crashlytics"])
  ],
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", exact: firebaseSdkVersion),
    .package(name: "firebase_core", path: "../firebase_core"),
    .package(name: "FlutterFramework", path: "../FlutterFramework"),
  ],
  targets: [
    // SPM does not allow mixing Swift and ObjC in a single target.
    .target(
      name: "firebase_crashlytics_objc",
      dependencies: [
        .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk")
      ],
      path: "Sources/firebase_crashlytics_objc",
      publicHeadersPath: "include",
      cSettings: [
        .headerSearchPath("include")
      ]
    ),
    .target(
      name: "firebase_crashlytics",
      dependencies: [
        "firebase_crashlytics_objc",
        .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
        .product(name: "firebase-core", package: "firebase_core"),
        .product(name: "FlutterFramework", package: "FlutterFramework"),
      ],
      path: "Sources/firebase_crashlytics",
      resources: [
        .process("Resources")
      ]
    ),
  ]
)
